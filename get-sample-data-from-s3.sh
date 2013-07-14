#!/bin/bash

sudo mkdir -p /mnt/data
sudo chown ubuntu /mnt/data

s3cmd get s3://2012-05-19-sample/hit_data.tsv.100 /mnt/data
s3cmd get s3://2012-05-19-sample/hit_data.tsv.100.gz /mnt/data
s3cmd get s3://2012-05-19-sample/hit_data.tsv.1000 /mnt/data
s3cmd get s3://2012-05-19-sample/hit_data.tsv.1000.gz /mnt/data
s3cmd get s3://2012-05-19-sample/hit_data.tsv.10000 /mnt/data
s3cmd get s3://2012-05-19-sample/hit_data.tsv.10000.gz /mnt/data
s3cmd get s3://2012-05-19-sample/hit_data.tsv.100000 /mnt/data
s3cmd get s3://2012-05-19-sample/hit_data.tsv.100000.gz /mnt/data
s3cmd get s3://2012-05-19-sample/hit_data.tsv.1000000 /mnt/data
s3cmd get s3://2012-05-19-sample/hit_data.tsv.1000000.gz /mnt/data
s3cmd get s3://2012-05-19-sample/hit_data.tsv.2000000 /mnt/data
s3cmd get s3://2012-05-19-sample/hit_data.tsv.2000000.gz /mnt/data
s3cmd get s3://2012-05-19-sample/hit_data.tsv.3000000 /mnt/data
s3cmd get s3://2012-05-19-sample/hit_data.tsv.3000000.gz /mnt/data
s3cmd get s3://2012-05-19-sample/hit_data.tsv.4000000 /mnt/data
s3cmd get s3://2012-05-19-sample/hit_data.tsv.4000000.gz /mnt/data
