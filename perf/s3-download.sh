#!/bin/bash

download_s3_data()
{
	\rm /mnt/data/*
	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.100 /mnt/data
	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.100.gz /mnt/data
	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.1000 /mnt/data
	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.1000.gz /mnt/data
	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.10000 /mnt/data
	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.10000.gz /mnt/data
	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.100000 /mnt/data
	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.100000.gz /mnt/data
	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.1000000 /mnt/data
	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.1000000.gz /mnt/data
	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.2000000 /mnt/data
	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.2000000.gz /mnt/data
	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.3000000 /mnt/data
	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.3000000.gz /mnt/data
#	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.4000000 /mnt/data
#	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.4000000.gz /mnt/data
}


OUTFILE=~/work/tachyon/logs/s3-download-time-`date +"%m%d%Y-%H%M%S"`

for ((i=0; i<3; i++))
do
	( download_s3_data 2>&1 ) | tee -a $OUTFILE
	( download_s3_data 2>&1 ) | tee -a $OUTFILE
	( download_s3_data 2>&1 ) | tee -a $OUTFILE
done
