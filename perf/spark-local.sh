#!/bin/bash


sparkshellcount()
{
	echo "spark-shell count"

	jps -l | grep -v Jps | sort -k 2
	echo

	# drop file system cache of the file
	linux-fadvise $1 POSIX_FADV_DONTNEED

	cd ~/work/spark-0.7.0
	./spark-shell <<END_SCRIPT
val s = sc.textFile("$1").cache()
s.count()
END_SCRIPT
}


sparkshellcount_11()
{
	echo "spark-shell count"

	jps -l | grep -v Jps | sort -k 2
	echo

	# drop file system cache of the file
	linux-fadvise $1 POSIX_FADV_DONTNEED

	cd ~/work/spark-0.7.0
	./spark-shell <<END_SCRIPT
val s = sc.textFile("$1").cache()
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
s.count()
END_SCRIPT
}


declare -a SIZES=(
1
100
1000
10000
100000
500000
)


OUTFILE=~/work/tachyon/logs/spark-local-`date +"%m%d%Y-%H%M%S"`


run_by_sizes()
{
	for s in "${SIZES[@]}"
	do
		filename=/mnt/data/hit_data.tsv.$s
		( $1 $filename 2>&1 ) | tee -a $OUTFILE
	done
}


for ((i = 0; i < 10; i ++))
do
	echo "run1 #: "$i | tee -a $OUTFILE
	echo "" | tee -a $OUTFILE
	run_by_sizes sparkshellcount
done

echo "run11:" | tee -a $OUTFILE
echo "" | tee -a $OUTFILE
run_by_sizes sparkshellcount_11
