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
		#return self.inst_id < other.inst_id
		return self.ipaddr < other.ipaddr


def assign_hostname(ec2_inst_info):
	i = 0
	for eii in ec2_inst_info:
		hn = "tachyon-ec2-%d" % i
		eii.hostname = hn
		i += 1


def get_active_spot_inst_info(conn):
	sir = None
	sys.stdout.write("Waiting for 2 active requests .")
	while True:
		# sir = conn.get_all_spot_instance_requests(filters={'state':'cancelled'})
		sir = conn.get_all_spot_instance_requests(filters={'state':'active'})
		if len(sir) >= 2:
			break
		time.sleep(2)
		sys.stdout.write(".")
	sys.stdout.write(" done\n")

	inst_ids = []
	for r in sir:
		#print r.instance_id
		inst_ids.append(r.instance_id)
		#print_attrs(r)
	#print 'instance IDs: %s' % ', '.join(map(str, inst_ids))
	#print ""

	reservations = conn.get_all_instances(instance_ids=inst_ids)

	ec2_inst_info = []

	# You may want to sort the result by their private ip addrs to group
	# network-distance-wise close machines together.

	for r in reservations:
		#print r
		#print_attrs(r)
		#print_attrs(r.instances[0])
		#print "DNS: %s, %s" % (r.instances[0].public_dns_name, r.instances[0].private_dns_name)
		#print_attrs(r.instances[0].region)
		#print_attrs(r.connection)
		ec2_ii = Ec2InstInfo(
			r.instances[0].id, r.instances[0].image_id,
			r.instances[0].ip_address, r.instances[0].private_ip_address,
			r.instances[0].instance_type, r.instances[0]._placement,
			r.instances[0].launch_time)
		ec2_inst_info.append(ec2_ii)
		print "  %s" % ec2_ii
	print ""

	ec2_inst_info_sorted = sorted(ec2_inst_info)
	assign_hostname(ec2_inst_info_sorted)
	return ec2_inst_info_sorted


def req_spot_inst(conn):
	res = conn.request_spot_instances(price = 0.014, image_id = 'ami-a87a05c1', count=2, type='one-time', launch_group='tachyon', key_name='hobinyoon@gmail.com', security_groups=['tachyon'], instance_type='m1.medium')
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

	# I am assuming that all active spot requests are for tachyon cluster. A VM
	# tagging will be needed when you have multiple spot requests.
	ec2_inst_info = get_active_spot_inst_info(conn)

	delete_ssh_known_hosts(ec2_inst_info)
	update_etc_hosts(ec2_inst_info)

	remote_init(ec2_inst_info)


if __name__ == "__main__":
    sys.exit(main(sys.argv))
