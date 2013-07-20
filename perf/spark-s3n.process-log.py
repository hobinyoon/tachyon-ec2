#! /usr/bin/python

import sys
import re
import cStringIO


FILESIZES = {
1: "1\\n525B",
100: "100\\n53KB",
1000: "1000\\n740KB",
10000: "10000\\n11.8MB",
100000: "100000\\n119MB",
500000: "500000\\n590MB",
}


def filter0(filename):
	in_fo = open(filename, "r")
	out_c1 = cStringIO.StringIO()
	out_c11 = cStringIO.StringIO()
	out = out_c1

	while True:
		line = in_fo.readline()
		if not line:
			break
		if re.match(".*run[1|11] #: \d", line):
			if line[0:7] == "scala> ":
				line = line[7:]
			out.write(line)
			continue

		if re.match(".*run11:$", line):
			out = out_c11
			out.write(line)
			continue

		# scala> val s = sc.textFile("s3n://2012-05-19-sample/hit_data.tsv.100000")
		if re.match("scala> val s = sc\.textFile\(\"", line):
			line = line[28:]
			out.write(re.sub("(s3n://2012-05-19-sample/hit_data\.tsv\.)|(\"\).cache\(\)$)", "", line))
			continue

		# 0718-072606.171 SS Job finished: count at <console>:15, took 9.26886005 s
		if re.match("............... SS Job finished: count at", line):
			out.write(re.sub(" s$", "", line[61:]))
			continue
	
	#sys.stdout.write(out_c1.getvalue())
	#sys.stdout.write(out_c11.getvalue())
	return (out_c1, out_c11)


class CountTime:
	def __init__(self, filename): 
		self.filename = filename
		# first run
		self.f_avg = 0.0
		self.f_min = 0.0
		self.f_max = 0.0
		# second and after
		self.s_avg = 0.0
		self.s_min = 0.0
		self.s_max = 0.0

		self.f_time = []
		self.s_time = []
	
	def add1(self, time):
		self.f_time.append(float(time))

	def add11(self, time):
		self.s_time.append(float(time))

	def __repr__(self):
		return "%s %f %f %f %f %f %f" % \
				(FILESIZES[int(self.filename)],
				sum(self.f_time) / float(len(self.f_time)), min(self.f_time), max(self.f_time),
				sum(self.s_time) / float(len(self.s_time)), min(self.s_time), max(self.s_time))
		#return "%s\n  %s\n  %s" % (self.filename, self.f_time, self.s_time)
		

filename_counttime = {}


def filter_c1(strio):
	in_ = cStringIO.StringIO(strio.getvalue())

	# next state
	ns = "run #"
	run_no = ""
	filename = ""
	time = ""

	while True:
		line = in_.readline()
		if not line:
			break
		#sys.stdout.write(line)

		if ns == "run #":
			# run1 #: 0
			if not re.match("run1 #: \d", line):
				raise Exception("Unexpected line [%s]" % line)
			run_no = line[8:].strip()
			ns = "filename"
		elif ns == "filename":
			filename = line.strip()
			ns = "time"
		elif ns == "time":
			time = line.strip()
			#print "%s %s %s" % (run_no, filename, time)
			ct = get_counttime(filename)
			ct.add1(time)
			if filename == "500000":
				ns = "run #"
			else:
				ns = "filename"


def get_counttime(filename):
	ct = None
	if filename in filename_counttime:
		ct = filename_counttime[filename]
	else:
		ct = CountTime(filename)
		filename_counttime[filename] = ct
	return ct


def filter_c11(strio):
	in_ = cStringIO.StringIO(strio.getvalue())

	# next state
	ns = "run11"
	filename = ""
	time = ""
	time_cnt = 0

	while True:
		line = in_.readline()
		if not line:
			break
		#sys.stdout.write(line)

		if ns == "run11":
			# run1 #: 0
			if not re.match("scala> run11:", line):
				raise Exception("Unexpected line [%s]" % line)
			ns = "filename"
		elif ns == "filename":
			filename = line.strip()
			ns = "time"
		elif ns == "time":
			time = line.strip()
			#print "%s %s" % (filename, time)
			if time_cnt > 0:
				ct = get_counttime(filename)
				ct.add11(time)
			time_cnt += 1
			if time_cnt == 11:
				time_cnt = 0
				ns = "filename"


# expected output
#
# # filename f_avg f_min f_max s_avg s_min s_max
# ...
# 1000       1.2   1.1   1.3   0.2   0.1   0.3
# ...


def main(argv):
	if len(argv) != 2:
		sys.exit("Usage: %s filename\n"
				"  Ex: %s ../result/spark-s3n-07202013-003733"
				% (argv[0], argv[0]))
	
	in_file = argv[1]

	(s_c1, s_c11) = filter0(in_file)
	filter_c1(s_c1)
	filter_c11(s_c11)

	out_file = in_file + ".p1"
	of = open(out_file, "w")
	of.write("# filename f_avg f_min f_max s_avg s_min s_max\n")
	for fc in sorted(filename_counttime):
		of.write("%s\n" % filename_counttime[fc])
	print "generated %s." % out_file


if __name__ == "__main__":
    sys.exit(main(sys.argv))
