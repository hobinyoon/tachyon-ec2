#!/bin/bash

download_s3_data()
{
	\rm /mnt/data/*
	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.1 /mnt/data
	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.100 /mnt/data
	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.1000 /mnt/data
	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.10000 /mnt/data
	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.100000 /mnt/data
	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.500000 /mnt/data
#	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.100.gz /mnt/data
#	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.1000.gz /mnt/data
#	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.10000.gz /mnt/data
#	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.100000.gz /mnt/data
#	time s3cmd get s3://2012-05-19-sample/hit_data.tsv.500000.gz /mnt/data
}


OUTFILE=~/work/tachyon/logs/s3-download-`date +"%m%d%Y-%H%M%S"`

for ((i=0; i<10; i++))
do
	( download_s3_data 2>&1 ) | tee -a $OUTFILE
done
