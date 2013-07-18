#! /usr/bin/python

import sys
import re


def filter_raw_log(filename):
	fo = open(filename, "r")

	while True:
		line = fo.readline()
		if not line:
			break
		line = line.strip()
		if re.match(".*run[1|11] #: \d", line):
			if line[0:7] == "scala> ":
				line = line[7:]
			print line
			continue

		if re.match(".*run11:$", line):
			print line
			continue

		# scala> val s = sc.textFile("/mnt/data/hit_data.tsv.1")
		if re.match("scala> val s = sc\.textFile\(\"", line):
			line = line[28:]
			print re.sub("(/mnt/data/hit_data\.tsv\.)|(\"\)$)", "", line)
			continue

		# 0718-072606.171 SS Job finished: count at <console>:15, took 9.26886005 s
		if re.match("............... SS Job finished: count at", line):
			print re.sub(" s$", "", line[61:])
			continue


def main(argv):
	if len(argv) != 2:
		sys.exit("Usage: %s filename\n"
				"  Ex: %s ../result/spark-local-07182013-064832"
				% (argv[0], argv[0]))
	
	filename = argv[1]

	filter_raw_log(filename)


if __name__ == "__main__":
    sys.exit(main(sys.argv))
