#!/bin/bash


sparkshellcount()
{
	tachyon_fn=tachyon://tachyon-ec2-0:19998/$1

	echo "spark-shell count"

	jps -l | grep -v Jps | sort -k 2
	echo

	cd ~/work/spark
	./spark-shell <<END_SCRIPT
val s = sc.textFile("$tachyon_fn")
s.count()
END_SCRIPT
}


sparkshellcount_11()
{
	tachyon_fn=tachyon://tachyon-ec2-0:19998/$1

	echo "spark-shell count"

	jps -l | grep -v Jps | sort -k 2
	echo

	cd ~/work/spark
	./spark-shell <<END_SCRIPT
val s = sc.textFile("$tachyon_fn")
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


run_by_sizes()
{
	for s in "${SIZES[@]}"
	do
		filename=hit_data.tsv.$s
		( $1 $filename 2>&1 ) | tee -a $OUTFILE
	done
}


OUTFILE=~/work/tachyon/logs/spark-tachyon-peertachyon-local-`date +"%m%d%Y-%H%M%S"`
touch $OUTFILE

for ((i = 0; i < 10; i ++))
do
	echo "run1 #: "$i | tee -a $OUTFILE
	echo "" | tee -a $OUTFILE
	run_by_sizes sparkshellcount
done

echo "run11:" | tee -a $OUTFILE
echo "" | tee -a $OUTFILE
run_by_sizes sparkshellcount_11
