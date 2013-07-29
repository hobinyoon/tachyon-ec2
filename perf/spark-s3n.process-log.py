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


class SparkResult:
	def __init__(self, filename):
		self.in_filename = filename
		self.filename_counttime = {}

		(data_c1, data_c11) = self.Filter0()
		self.Parse_C1(data_c1)
		self.Parse_C11(data_c11)

	def Filter0(self):
		in_fo = open(self.in_filename, "r")
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

			# 13/07/27 23:08:33 INFO spark.SparkContext: Job finished: count at <console>:15, took 0.357849291 s
			if re.match(".......................................... Job finished: count at", line):
				out.write(re.sub(" s$", "", line[85:]))
				continue
	
		#sys.stdout.write(out_c1.getvalue())
		#sys.stdout.write(out_c11.getvalue())
		return (out_c1, out_c11)

	def _GetCountTime(self, filename):
		ct = None
		if filename in self.filename_counttime:
			ct = self.filename_counttime[filename]
		else:
			ct = self.CountTime(filename)
			self.filename_counttime[filename] = ct
		return ct

	def Parse_C1(self, in_):
		in_.seek(0, 0)

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
				ct = self._GetCountTime(filename)
				ct.Add1(time)
				if filename == "500000":
					ns = "run #"
				else:
					ns = "filename"

	def Parse_C11(self, in_):
		in_.seek(0, 0)

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
				if not re.match("run11:", line):
					raise Exception("Unexpected line [%s]" % line)
				ns = "filename"
			elif ns == "filename":
				filename = line.strip()
				ns = "time"
			elif ns == "time":
				time = line.strip()
				#print "%s %s" % (filename, time)
				if time_cnt > 0:
					ct = self._GetCountTime(filename)
					ct.Add11(time)
				time_cnt += 1
				if time_cnt == 11:
					time_cnt = 0
					ns = "filename"

	def GenStatTable(self, out_file):
		of = open(out_file, "w")
		of.write("# filename\\nfilesize f_avg f_min f_max s_avg s_min s_max\n")
		for fc in sorted(self.filename_counttime):
			of.write("%s\n" % self.filename_counttime[fc])
		print "generated %s." % out_file


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
		
		def Add1(self, time):
			self.f_time.append(float(time))

		def Add11(self, time):
			self.s_time.append(float(time))

		def __repr__(self):
			return "%s %f %f %f %f %f %f" % \
					(FILESIZES[int(self.filename)],
					sum(self.f_time) / float(len(self.f_time)), min(self.f_time), max(self.f_time),
					sum(self.s_time) / float(len(self.s_time)), min(self.s_time), max(self.s_time))
			#return "%s\n  %s\n  %s" % (self.filename, self.f_time, self.s_time)

# expected output
#
# # filename\nfilesize f_avg f_min f_max s_avg s_min s_max
# ...
# 100\n53KB 0.261638 0.251010 0.275681 0.034885 0.023786 0.045215
# ...


def main(argv):
	if len(argv) != 2:
		sys.exit("Usage: %s filename\n"
				"  Ex: %s ../result/spark-s3n-07272013-235015"
				% (argv[0], argv[0]))
	
	in_file = argv[1]
	out_file = in_file + ".p1"

	sr = SparkResult(in_file)
	sr.GenStatTable(out_file)


if __name__ == "__main__":
    sys.exit(main(sys.argv))
