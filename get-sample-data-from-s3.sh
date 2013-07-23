#!/bin/bash

sudo mkdir -p /mnt/tachyon
sudo chown ubuntu /mnt/tachyon

s3cmd get s3://2012-05-19-sample/hit_data.tsv.1 /mnt/tachyon
s3cmd get s3://2012-05-19-sample/hit_data.tsv.100 /mnt/tachyon
s3cmd get s3://2012-05-19-sample/hit_data.tsv.100.gz /mnt/tachyon
s3cmd get s3://2012-05-19-sample/hit_data.tsv.1000 /mnt/tachyon
s3cmd get s3://2012-05-19-sample/hit_data.tsv.1000.gz /mnt/tachyon
s3cmd get s3://2012-05-19-sample/hit_data.tsv.10000 /mnt/tachyon
s3cmd get s3://2012-05-19-sample/hit_data.tsv.10000.gz /mnt/tachyon
s3cmd get s3://2012-05-19-sample/hit_data.tsv.100000 /mnt/tachyon
s3cmd get s3://2012-05-19-sample/hit_data.tsv.100000.gz /mnt/tachyon
s3cmd get s3://2012-05-19-sample/hit_data.tsv.500000 /mnt/tachyon
s3cmd get s3://2012-05-19-sample/hit_data.tsv.500000.gz /mnt/tachyon
