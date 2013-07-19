#!/bin/bash

export INFILE=../result/spark-s3n-vs-spark-tachyon-s3n-07182013-072656
export OUTFILE=../result/spark-s3n-vs-spark-tachyon-s3n-07182013-072656.pdf
export TITLE="Spark - S3 vs. Spark - Tachyon - S3"
gnuplot spark-local-vs-spark-tachyon-local.gnuplot
