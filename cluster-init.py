#! /usr/bin/python

import sys
import boto.ec2
import pprint
import pytz
import datetime
import subprocess
import os
import time


def print_inst(conn):
	reservations = conn.get_all_instances()
	for r in reservations:
		for inst in r.instances:
			if inst.state == "terminated":
				continue
			#pprint.pprint(inst.__dict__)
			print inst.region.name, inst.id, inst.state, inst.instance_type, inst.dns_name
			#pprint.pprint(inst.region.__dict__)


def get_conn(region_name):
	#print boto.ec2.regions()
	# us-west-1: N. California

	conn = boto.ec2.connect_to_region(region_name)
	if not conn:
		raise Exception("Invalid region: " + region_name)
	return conn


def print_attrs(r):
	print type(r)
	attrs = vars(r)
	print '\n'.join("%s: %s" % item for item in attrs.items())


def to_localtime(time_):
	# input in the format of 2013-07-11T20:43:05.000Z
	time_ = time_[0:time_.find('.')]

	utc = pytz.timezone('UTC')
	lt_utc = utc.localize(datetime.datetime.strptime(time_, '%Y-%m-%dT%H:%M:%S'))
	#print lt_utc
	pcf = pytz.timezone('US/Pacific')
	lt_pcf = lt_utc.astimezone(pcf)
	#print lt_pcf
	return lt_pcf


class Ec2InstInfo:
	def __init__(self, inst_id, image_id, ipaddr, private_ipaddr, inst_type, placement, launchtime):
		self.inst_id = inst_id
		self.image_id = image_id
		self.ipaddr = ipaddr
		self.private_ipaddr = private_ipaddr
		self.inst_type = inst_type
		self.placement = placement
		self.launchtime = launchtime
		self.hostname = ""

	def __repr__(self):
		attrs = vars(self)
		return ', '.join("%s: %s" % item for item in attrs.items())

	def __lt__(self, other):
		if self.launchtime < other.launchtime:
			return True
		elif self.launchtime > other.launchtime:
			return False

		return self.private_ipaddr < other.private_ipaddr


def assign_hostname(ec2_inst_info):
	i = 0
	for eii in ec2_inst_info:
		hn = "tachyon-ec2-%d" % i
		eii.hostname = hn
		i += 1


def wait_and_get_tachyon_ec2_instance_info(conn, num_inst):
	# Assume that tachyon ec2 instances have the tag name "tachyon". Does not
	# check the value of the tag.

	sir = None
	sys.stdout.write("Waiting for %d tachyon instances ." % num_inst)
	sys.stdout.flush()

	reservations = None

	while True:
		reservations = conn.get_all_instances(filters={'tag-key': 'tachyon'})
		if len(reservations) == num_inst:
			break
		time.sleep(2)
		sys.stdout.write(".")
		sys.stdout.flush()
	sys.stdout.write(" done\n")

	tachyon_ec2_instances = []
	for r in reservations:
		for i in r.instances:
			#print_attrs(i)
			ii = Ec2InstInfo(
				i.id, i.image_id,
				i.ip_address, i.private_ip_address,
				i.instance_type, i._placement,
				i.launch_time)
			tachyon_ec2_instances.append(ii)
	for ti in tachyon_ec2_instances:
		print "  %s" % ti
	print ""

	tei_sorted = sorted(tachyon_ec2_instances)
	assign_hostname(tei_sorted)
	return tei_sorted


def req_spot_inst(conn):
	# TODO: parameterize image-id, count, and max-price
	res = conn.request_spot_instances(price = 0.014, image_id = 'ami-a87a05c1', count=2, type='one-time', launch_group='tachyon', key_name='hobinyoon@gmail.com', security_groups=['tachyon'], instance_type='m1.medium')
	# TODO: wait for them and assign tags
	print res


def update_etc_hosts(ec2_inst_info):
	filename = "/etc/hosts"
	print "Updating local %s ..." % filename

	for eii in ec2_inst_info:
		new_entry = "%s %s" % (eii.ipaddr, eii.hostname)

		# do they have the hostname in /etc/hosts?
		cmd = "grep \" %s$\" %s | wc -l" % (eii.hostname, filename)
		output = subprocess.check_output(cmd, stderr=subprocess.STDOUT, shell=True)
		#print "[%s]" % output
		output = int(output.strip())

		if output >= 1:
			# modify the ip address
			cmd = "sed -i='' 's/.* %s$/%s %s/' %s" % (eii.hostname, eii.ipaddr, eii.hostname, filename)
			subprocess.check_call(cmd, shell=True)
			print "  Modified \"%s\"" % new_entry
		else:
			# append the ip hostname pair
			cmd = "echo \"%s\" >> %s" % (new_entry, filename)
			subprocess.check_call(cmd, shell=True)
			print "  Added \"%s\" to %s" % (new_entry, filename)
	print ""


def remote_exe(remote_addr, cmd):
	# nesting quotation marks does not work. make a temp file and redirect it.
	#cmd = "ssh ubuntu@%s 'sudo bash -c 'echo \"%s\" >> %s''" % (remote_addr, new_entry, filename)

	remote_cmd_filename = ".remote_cmd"
	fo = open(remote_cmd_filename, "w")
	fo.write(cmd)
	fo.close()

	# The message "Pseudo-terminal will not be allocated because stdin is not a
	# terminal." is not disappearing even after following
	# http://stackoverflow.com/questions/7114990/pseudo-terminal-will-not-be-allocated-because-stdin-is-not-a-terminal
	# Worse, it makes the script hangs.
	cmd = "ssh ubuntu@%s < %s" % (remote_addr, remote_cmd_filename)
	subprocess.check_call(cmd, shell=True)

	os.remove(remote_cmd_filename)


def delete_ssh_known_hosts(ec2_inst_info):
	known_hosts_file = "~/.ssh/known_hosts"

	print "Deleting hostnames in %s" % known_hosts_file
	for eii in ec2_inst_info:
		cmd = "sed -i='' '/^%s.*/d' %s" % (eii.hostname, known_hosts_file)
		subprocess.check_call(cmd, shell=True)
		print "  Deleted %s from %s" % (eii.hostname, known_hosts_file)

		# dots in ipaddr need to be escaped. although the chance of incorrect
		# deletion is very low.
		cmd = "sed -i='' '/^%s.*/d' %s" % (eii.ipaddr, known_hosts_file)
		subprocess.check_call(cmd, shell=True)
		print "  Deleted %s from %s" % (eii.ipaddr, known_hosts_file)
	print ""


def remote_init(ec2_inst_info):
	print "Initializing tachyon ec2 instances"

	cnt = 0
	for e in ec2_inst_info:
		cmd = "~/work/tachyon-ec2/_cluster-init.py %d" % cnt
		for e2 in ec2_inst_info:
			cmd += (" %s %s" % (e2.hostname, e2.private_ipaddr))
		# can be parallelized when it becomes a matter.
		remote_exe(e.ipaddr, cmd)
		cnt += 1


def main(argv):
	if len(argv) != 1:
		sys.exit("Usage: %s\n"
				"  Ex: %s" % (argv[0]))
	
	region_name = "us-east-1"
	conn = get_conn(region_name)

	#req_spot_inst(conn)
	ec2_inst_info = wait_and_get_tachyon_ec2_instance_info(conn, 2)

	delete_ssh_known_hosts(ec2_inst_info)
	update_etc_hosts(ec2_inst_info)

	remote_init(ec2_inst_info)


if __name__ == "__main__":
    sys.exit(main(sys.argv))
