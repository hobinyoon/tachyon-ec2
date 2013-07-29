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
		$1 $filename 2>&1
	done
}

run_by_sizes sparkshellcount
