#!/bin/bash


restart_tachyon()
{
	# restart tachyon
	cd ~/work/tachyon
	bin/start-local.sh
	echo
}


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
	echo
}


declare -a SIZES=(
100
1000
10000
100000
1000000
2000000
3000000
4000000
)


OUTFILE=~/work/tachyon/logs/sparkshell-`date +"%m%d%Y-%H%M%S"`


run_sparkshell_example()
{
	for s in "${SIZES[@]}"
	do
		# spark-shell only
		filename=/mnt/data/hit_data.tsv.$s
		( sparkshellcount $filename 2>&1 ) | tee -a $OUTFILE

		# spark-shell with tachyon
		filename=tachyon://localhost:19998/hit_data.tsv.$s
		( sparkshellcount_with_tachyon $filename 2>&1 ) | tee -a $OUTFILE
	done
}


cd ~/work/tachyon
bin/stop.sh


for ((i = 0; i < 10; i ++))
do
	echo "run #: "$i | tee -a $OUTFILE
	echo "" | tee -a $OUTFILE
	run_sparkshell_example
done

#reset
