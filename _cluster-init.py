#! /usr/bin/python

import sys
import os
import subprocess


def print_attrs(r):
	print type(r)
	attrs = vars(r)
	print '\n'.join("%s: %s" % item for item in attrs.items())


def update_etc_hosts(machine_info):
	filename = "/etc/hosts"
	print "Updating %s ..." % filename

	for mi in machine_info:
		new_entry = "%s %s" % (mi.priv_ip, mi.hostname)

		# does /etc/hosts have the hostname?
		cmd = "grep \" %s$\" %s | wc -l" % (mi.hostname, filename)
		output = subprocess.check_output(cmd, stderr=subprocess.STDOUT, shell=True)
		#print "[%s]" % output
		output = int(output.strip())

		if output >= 1:
			# modify the ip address
			cmd = "sudo sed -i='' 's/.* %s$/%s %s/' %s" % (mi.hostname, mi.priv_ip, mi.hostname, filename)
			subprocess.check_call(cmd, shell=True)
			print "  Modified \"%s\"" % new_entry
		else:
			# append the ip hostname pair
			cmd = "sudo bash -c 'echo \"%s\" >> %s'" % (new_entry, filename)
			subprocess.check_call(cmd, shell=True)
			print "  Added \"%s\" to %s" % (new_entry, filename)
	print ""


def delete_ssh_known_hosts(machine_info):
	known_hosts_file = os.path.expanduser("~")+ "/.ssh/known_hosts"

	print "Deleting hostnames in %s" % known_hosts_file
	cmd = "ssh-keygen -f \"%s\" -R %s > /dev/null 2>&1" % (known_hosts_file, "localhost")
	subprocess.check_call(cmd, shell=True)
	print "  Deleted %s from %s" % ("localhost", known_hosts_file)

	for mi in machine_info:
		cmd = "ssh-keygen -f \"%s\" -R %s > /dev/null 2>&1" % (known_hosts_file, mi.hostname)
		subprocess.check_call(cmd, shell=True)
		print "  Deleted %s from %s" % (mi.hostname, known_hosts_file)

		# dots in ipaddr need to be escaped. although the chance of incorrect
		# deletion is very low.
		cmd = "ssh-keygen -f \"%s\" -R %s > /dev/null 2>&1" % (known_hosts_file, mi.priv_ip)
		subprocess.check_call(cmd, shell=True)
		print "  Deleted %s from %s" % (mi.priv_ip, known_hosts_file)
	print ""


def set_hostname(hostname):
	print "Setting hostname"
	cmd = "sudo hostname %s" % hostname
	subprocess.check_output(cmd, stderr=subprocess.STDOUT, shell=True)
	print ""


class MachineInfo:
	def __init__(self, hostname, priv_ip):
		self.hostname = hostname
		self.priv_ip = priv_ip

	def __repr__(self):
		attrs = vars(self)
		return ', '.join("%s: %s" % item for item in attrs.items())


def make_tachyon_data_folder():
	print "Making tachyon data folder"
	subprocess.check_output("sudo mkdir -p /mnt/tachyon/tachyon", stderr=subprocess.STDOUT, shell=True)
	subprocess.check_output("sudo chown -R ubuntu /mnt/tachyon", stderr=subprocess.STDOUT, shell=True)
	print ""


# args: index of this machine, hostname0, priv_ip0, hostname1, priv_ip1, ...
def main(argv):
	arg_len = len(argv)
	if (arg_len < 4) or (arg_len % 2 != 0):
		sys.exit("Usage: %s this_machine_idx hostname0 private_ip_0 hostname1 private_ip_1 ...\n"
				"  Ex: %s 0 tachyon-ec2-0 10.10.10.10 tachyon-ec2-1 10.10.10.22" % (argv[0], argv[0]))
	this_machine_idx = int(argv[1])

	machine_info = []
	i = 2
	while i < arg_len:
		machine_info.append(MachineInfo(argv[i], argv[i+1]))
		i += 2
	#for m in machine_info:
	#	print m
	
	delete_ssh_known_hosts(machine_info)
	update_etc_hosts(machine_info)
	set_hostname(machine_info[this_machine_idx].hostname)
	make_tachyon_data_folder()


if __name__ == "__main__":
    sys.exit(main(sys.argv))
