#! /usr/bin/python

# 3-way merge

import sys
import os


# expect ts of format "0615-142715.737"
def get_ts(line):
	fw = line.split(' ')[0]
	if len(fw) != 15:
		return ""
	if not fw[0].isdigit():
		return ""
	if not fw[1].isdigit():
		return ""
	if not fw[2].isdigit():
		return ""
	if not fw[3].isdigit():
		return ""
	if fw[4] != "-":
		return ""
	if not fw[5].isdigit():
		return ""
	if not fw[6].isdigit():
		return ""
	if not fw[7].isdigit():
		return ""
	if not fw[8].isdigit():
		return ""
	if not fw[9].isdigit():
		return ""
	if not fw[10].isdigit():
		return ""
	if fw[11] != ".":
		return ""
	if not fw[12].isdigit():
		return ""
	if not fw[13].isdigit():
		return ""
	if not fw[14].isdigit():
		return ""

	return fw


def read_until_new_ts(fo):
	buf = ""
	ts = ""

	while True:
		line = fo.readline()

		if not line:
			fo.close()
			break

		buf += line

		ts_ = get_ts(line)
		if len(ts_) > 0:
			ts = ts_
			# print "len(buf)=%d" % len(buf)
			break

	return (buf, ts)


def buf_idx_with_oldest_ts(ts, buf, oldest_last):
	num_ts = len(ts)
	if num_ts == 0:
		raise Exception("len(ts) should be greater than 0")

	oldest_idx = 0
	for i in range(num_ts):
		if i == 0:
			continue

		if len(buf[oldest_idx]) == 0:
			if len(buf[i]) > 0:
				oldest_idx = i
				continue

		if len(ts[i]) > 0:
			if len(ts[oldest_idx]) == 0:
				oldest_idx = i;
			else:
				# if tie, continue with the previous one.
				if ts[i] == ts[oldest_idx]:
					if i == oldest_last:
						oldest_idx = i
				elif ts[i] < ts[oldest_idx]:
					oldest_idx = i;
	
	return oldest_idx


# can be generalized to n-way merge
def merge(file0, file1, file2):
	# buffers
	buf = ["", "", ""]

	# timestamps
	ts = ["", "", ""]

	# file objects
	fo = []
	fo.append(open(file0))
	fo.append(open(file1))
	fo.append(open(file2))

	num_files = 3

	oldest_last = -1

	while True:
		# read files and fill buffers and timestamps
		for i in range(num_files):
			#print i
			if len(buf[i]) == 0 and fo[i].closed == False:
				(buf[i], ts[i]) = read_until_new_ts(fo[i])
				#print "len(buf[%d])=%d %s" % (i, len(buf[i]), buf[i])

		# break if no buf is left
		buffer_left = False
		for i in range(num_files):
			if len(buf[i]) != 0:
				buffer_left = True
				break
		if buffer_left == False:
			break

		# output the buf with the oldest ts. buf without ts goes at the end.
		oldest = buf_idx_with_oldest_ts(ts, buf, oldest_last)
		if oldest_last == -1:
			oldest_last = oldest
		if oldest_last != oldest:
			sys.stdout.write("\n")
		oldest_last = oldest

		#print "[%d]\n%s------------" % (oldest, buf[oldest])
		sys.stdout.write("%s" % (buf[oldest]))
		buf[oldest] = ""
		ts[oldest] = ""


def main(argv):
	if len(argv) != 4:
		sys.exit("Usage: %s file1 file2 file3\n"
				"  Ex: %s ~/work/tachyon/logs/spark-shell.log ~/work/tachyon/logs/worker.log@127.0.1.1_06-15-2013 ~/work/tachyon/logs/master.log@127.0.1.1_06-15-2013"
				% (argv[0], argv[0]))
	
	file1 = argv[1]
	file2 = argv[2]
	file3 = argv[3]

	merge(file1, file2, file3)


if __name__ == "__main__":
    sys.exit(main(sys.argv))
