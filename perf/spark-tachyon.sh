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


sparkshellcount_with_tachyon()
{
	echo "restaring tachyon"
	cd ~/work/tachyon
	bin/start-local.sh
	echo

	sparkshellcount $1

	# tachyon daemons need to be stopped for tee outside stop waiting
	cd ~/work/tachyon
	bin/stop.sh
	sudo rm -rf /mnt/ramdisk/*
	bin/format.sh
	echo
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
			filename=tachyon://localhost:19998/hit_data.tsv.$s$e
			( sparkshellcount_with_tachyon $filename 2>&1 ) | tee -a $OUTFILE
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
