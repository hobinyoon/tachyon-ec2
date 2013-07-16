#!/bin/bash


sparkshellcount()
{
	echo "spark-shell count"

	jps -l | grep -v Jps | sort -k 2
	echo

	cd ~/work/spark-0.7.0
	./spark-shell <<END_SCRIPT
val s = sc.textFile("$1")
s.count()
s.count()
s.count()
s.count()
s.count()
s.count()
s.count()
s.count()
s.count()
s.count()
END_SCRIPT
}


declare -a SIZES=(
100
1000
10000
100000
500000
)


OUTFILE=~/work/tachyon/logs/sparkshell-`date +"%m%d%Y-%H%M%S"`


run_sparkshell_example()
{
	declare -a extensions=(
	".gz"
	""
	)

	for e in "${extensions[@]}"
	do
		for s in "${SIZES[@]}"
		do
			# spark-shell with tachyon
			filename=/mnt/data/hit_data.tsv.$s$e
			( sparkshellcount $filename 2>&1 ) | tee -a $OUTFILE
		done
	done
}


cd ~/work/tachyon
bin/stop.sh
sudo rm -rf /mnt/ramdisk/*

# ideally, run multiple times... but
for ((i = 0; i < 1; i ++))
do
	echo "run #: "$i | tee -a $OUTFILE
	echo "" | tee -a $OUTFILE
	run_sparkshell_example
done
