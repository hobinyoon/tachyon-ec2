#! /usr/bin/python

import sys
import re


# input format: 2m8.586s
def to_sec(ms):
	t = re.split('m|s', ms)
	return int(t[0]) * 60 + float(t[1])


FILESIZES = {
1: "1\\n525B",
100: "100\\n53KB",
1000: "1000\\n740KB",
10000: "10000\\n11.8MB",
100000: "100000\\n119MB",
500000: "500000\\n590MB",
}


class Time:
	def __init__(self, filename):
		self.filename = filename
		self.time = []

	def __repr__(self):
		return ("%s %f %f %f %s" %
			(FILESIZES[int(self.filename)],
			sum(self.time) / float(len(self.time)), min(self.time), max(self.time),
			" ".join(["%f" % i for i in self.time])))

	def add(self, time):
		self.time.append(time)


def get_downtime(filename):
	dt = None
	if filename in filename_downtime:
		dt = filename_downtime[filename]
	else:
		dt = Time(filename)
		filename_downtime[filename] = dt
	return dt


def print_filename_downtime():
	print "# filename avg min max time..."
	for fd in sorted(filename_downtime):
		print filename_downtime[fd]


filename_downtime = {}


def filter0(filename):
	in_ = open(filename, "r")

	filename = ""
	time = ""

	while True:
		line = in_.readline()
		if not line:
			break
		if re.match("^File s3://2012-05-19-sample/hit_data\.tsv\.", line):
			m = re.match("\d+", line[41:])
			filename = m.group(0)
			continue

		if re.match("^real\t", line):
			time = to_sec(line[5:])
			#print "%s %s" % (filename, time)
			get_downtime(filename).add(time)
			continue
	
	#print_filename_downtime()
	return filename_downtime


def main(argv):
	if len(argv) != 2:
		sys.exit("Usage: %s filename\n"
				"  Ex: %s ../result/s3-download-07192013-062102"
				% (argv[0], argv[0]))
	filename = argv[1]

	filter0(filename)
	print_filename_downtime()


if __name__ == "__main__":
    sys.exit(main(sys.argv))
