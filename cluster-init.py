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


def req_spot_inst(conn):
	# TODO: parameterize image-id, count, and max-price
	res = conn.request_spot_instances(price = 0.014, image_id = 'ami-a87a05c1', count=2, type='one-time', launch_group='tachyon', key_name='hobinyoon@gmail.com', security_groups=['tachyon'], instance_type='m1.medium')
	# TODO: wait for them and assign tags
	print res


# remote access to root is assumed.
def update_etc_hosts(ec2_inst_info):
	etc_hosts_filename = "/etc/hosts"
	print "Updating %s ..." % etc_hosts_filename

	for eii in ec2_inst_info:
		new_entry = "%s %s" % (eii.ipaddr, eii.hostname)

		# do they have the hostname in /etc/hosts?
		cmd = "grep \" %s$\" %s | wc -l" % (eii.hostname, etc_hosts_filename)
		output = subprocess.check_output(cmd, stderr=subprocess.STDOUT, shell=True)
		#print "[%s]" % output
		output = int(output.strip())

		if output >= 1:
			# modify the ip address
			cmd = "sed -i='' 's/.* %s$/%s %s/' %s" % (eii.hostname, eii.ipaddr, eii.hostname, etc_hosts_filename)
			remote_exe("localhost", "root", cmd)
			print "  Modified \"%s\"" % new_entry
		else:
			# append the ip hostname pair
			cmd = "echo \"%s\" >> %s" % (new_entry, etc_hosts_filename)
			remote_exe("localhost", "root", cmd)
			print "  Added \"%s\" to %s" % (new_entry, etc_hosts_filename)
	print ""


def remote_exe(remote_addr, user, cmd):
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
	cmd = "ssh %s@%s < %s" % (user, remote_addr, remote_cmd_filename)
	subprocess.check_call(cmd, shell=True)

	os.remove(remote_cmd_filename)


def delete_ssh_known_hosts(ec2_inst_info):
	known_hosts_file = os.path.expanduser("~")+ "/.ssh/known_hosts"

	print "Deleting hostnames in %s" % known_hosts_file
	for eii in ec2_inst_info:
		cmd = "ssh-keygen -f \"%s\" -R %s > /dev/null 2>&1" % (known_hosts_file, eii.hostname)
		subprocess.check_call(cmd, shell=True)
		print "  Deleted %s from %s" % (eii.hostname, known_hosts_file)

		# dots in ipaddr need to be escaped. although the chance of incorrect
		# deletion is very low.
		cmd = "ssh-keygen -f \"%s\" -R %s > /dev/null 2>&1" % (known_hosts_file, eii.ipaddr)
		subprocess.check_call(cmd, shell=True)
		print "  Deleted %s from %s" % (eii.ipaddr, known_hosts_file)
	print ""


def remote_init(ec2_inst_info, scriptfile):
	print "Initializing ec2 instances"

	cnt = 0
	for e in ec2_inst_info:
		cmd = "%s %d" % (scriptfile, cnt)
		for e2 in ec2_inst_info:
			cmd += (" %s %s" % (e2.hostname, e2.private_ipaddr))
		# can be parallelized when needed.
		# can not use e.hostname. this python process does not seem to notice
		# the change in /etc/hosts. although it would have been better so that
		# ssh does not ask the identity of the machine next time you ssh to the
		# machines using their hostnames.
		remote_exe(e.ipaddr, "ubuntu", cmd)
		cnt += 1


# wait for new or tachyon instances.  assume that a running instance with empty
# tag is a newly launched instance.
def wait_for_instances_and_tag(conn, cluster_name, num_inst):
	sir = None
	sys.stdout.write("Waiting for %d new or %s instances ." % (num_inst, cluster_name))
	sys.stdout.flush()

	insts = []
	while True:
		reservations = conn.get_all_instances()
		insts = []
		for r in reservations:
			#print_attrs(r)
			for i in r.instances:
				if i._state.name == "running":
					if len(i.tags) == 0:
						insts.append(i)
					elif ("cluster_name" in i.tags) and (i.tags["cluster_name"] == cluster_name):
						insts.append(i)

		if len(insts) >= num_inst:
			break

		time.sleep(2)
		sys.stdout.write(".")
		sys.stdout.flush()
	print ""
	print "  %s\n" % insts

	sys.stdout.write("Tagging instances ...")
	for i in insts:
		i.add_tag("cluster_name", cluster_name)
	print " done\n"

	return insts


def assign_hostname_and_get_info(insts, prefix):
	inst_info = []
	for i in insts:
		inst_info.append(Ec2InstInfo(
				i.id, i.image_id,
				i.ip_address, i.private_ip_address,
				i.instance_type, i._placement,
				i.launch_time))

	instinfo_sorted = sorted(inst_info)
	i = 0
	for ii in instinfo_sorted:
		ii.hostname = "%s%d" % (prefix, i)
		i += 1

	#print instinfo_sorted
	return instinfo_sorted


def main(argv):
	if len(argv) != 1:
		sys.exit("Usage: %s\n"
				"  Ex: %s" % (argv[0]))
	
	region_name = "us-east-1"
	conn = get_conn(region_name)
	#req_spot_inst(conn)

	insts = wait_for_instances_and_tag(conn, "tachyon", 2)
	ec2_inst_info = assign_hostname_and_get_info(insts, "tachyon-ec2-")

	delete_ssh_known_hosts(ec2_inst_info)
	update_etc_hosts(ec2_inst_info)

	remote_init(ec2_inst_info, "~/work/tachyon-ec2/_cluster-init.py")


if __name__ == "__main__":
    sys.exit(main(sys.argv))
