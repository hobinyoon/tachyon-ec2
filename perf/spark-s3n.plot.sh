#!/bin/bash

export INFILE_SS3=../result/spark-s3n-07272013-235015.p1
export INFILE_STS3=../result/spark-tachyon-s3n-07282013-050019.p1
export INFILE_STPS3=../result/spark-tachyon-peertachyon-s3n-07292013-211502.p1
export OUTFILE=../result/s3n-07272013-235015.pdf
export TITLE="Spark count()ing S3 files"
gnuplot spark-s3n.gnuplot
