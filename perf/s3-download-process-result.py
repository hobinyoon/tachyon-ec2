#! /usr/bin/python

import sys
import re


# input format: 2m8.586s
def to_sec(ms):
	t = re.split('m|s', ms)
	return int(t[0]) * 60 + float(t[1])


# filename size avg min max list_of_times
# hit_data.tsv.100 55735 avg min max [0.171, ...]
# hit_data.tsv.100.gz 3502 avg min max [0.171, ...]


class Item:
	def __init__(self, filename, size, time):
		self.filename = filename
		self.size = size
		self.avg = 0.0
		self.min = 0.0
		self.max = 0.0
		self.time = [time]

	def __repr__(self):
		return ("%s %s %.3f %.3f %.3f %s" %
			(self.filename,
			self.size,
			self.avg,
			self.min,
			self.max,
			" ".join(["%0.3f" % i for i in self.time])))

	def add(self, time):
		self.time.append(time)

	def calc(self):
		self.avg = sum(self.time) / float(len(self.time))
		self.min = min(self.time)
		self.max = max(self.time)


def read_file(filename_):
	items = {}

	fo = open(filename_, "r")

	while True:
		line = fo.readline()
		if not line:
			break
		#print line

		tokens = line.strip().split(' ')
		filename = tokens[0]
		size = tokens[1]
		time = to_sec(tokens[2])

		#print filename, size, time
		if items.has_key(filename):
			items[filename].add(time)
		else:
			items[filename] = Item(filename, size, time)
	
	for i in items.keys():
		items[i].calc()

	return items


def print_items(items):
	for k in sorted(items.keys()):
		print items[k]

	# transpose in MS excel. not worth the time implementing it here.
	#sitems = sorted(items.keys())
	#for k in sitems:
	#	sys.stdout.write(k + " ")


def main(argv):
	if len(argv) != 2:
		sys.exit("Usage: %s filename\n"
				"  Ex: %s ../result/s3-download-time-07142013-174154.processed"
				% (argv[0], argv[0]))
	
	filename = argv[1]

	items = read_file(filename)
	print_items(items)


if __name__ == "__main__":
    sys.exit(main(sys.argv))
