#!/bin/bash

export INFILE_SS3=../result/spark-s3n-07182013-072656.p1
export INFILE_STS3=../result/spark-tachyon-s3n-07182013-211428.p1
export OUTFILE=../result/s3n-07182013-072656.pdf
export TITLE="Spark count()ing S3 files"
gnuplot spark-s3n.gnuplot

