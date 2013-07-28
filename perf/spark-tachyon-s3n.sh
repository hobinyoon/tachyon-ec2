#!/bin/bash


sparkshellcount()
{
	local_fn=/mnt/tachyon/$1
	tachyon_fn=tachyon://tachyon-ec2-0:19998/$1

	echo "restaring tachyon"
	cd ~/work/tachyon
	bin/start-local.sh
	echo

	echo "spark-shell count"

	jps -l | grep -v Jps | sort -k 2
	echo

	cd ~/work/spark
	./spark-shell <<END_SCRIPT
val s = sc.textFile("$tachyon_fn")
s.count()
END_SCRIPT

	# tachyon daemons need to be stopped for tee outside stop waiting
	cd ~/work/tachyon
	bin/stop.sh
	sudo rm -rf /mnt/ramdisk/*
	bin/format.sh
	echo
}


sparkshellcount_11()
{
	local_fn=/mnt/tachyon/$1
	tachyon_fn=tachyon://tachyon-ec2-0:19998/$1

	echo "restaring tachyon"
	cd ~/work/tachyon
	bin/start-local.sh
	echo

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

	# tachyon daemons need to be stopped for tee outside stop waiting
	cd ~/work/tachyon
	bin/stop.sh
	sudo rm -rf /mnt/ramdisk/*
	bin/format.sh
	echo
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


OUTFILE=~/work/tachyon/logs/spark-tachyon-s3n-`date +"%m%d%Y-%H%M%S"`
touch $OUTFILE

cd ~/work/tachyon
bin/stop.sh
sudo rm -rf /mnt/ramdisk/*
bin/format.sh
echo

for ((i = 0; i < 10; i ++))
do
	echo "run1 #: "$i | tee -a $OUTFILE
	echo "" | tee -a $OUTFILE
	run_by_sizes sparkshellcount
done

echo "run11:" | tee -a $OUTFILE
echo "" | tee -a $OUTFILE
run_by_sizes sparkshellcount_11
