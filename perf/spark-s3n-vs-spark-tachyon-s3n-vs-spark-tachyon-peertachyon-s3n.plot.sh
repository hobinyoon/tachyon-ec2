#!/bin/bash

export INFILE=../result/spark-s3n-vs-spark-tachyon-s3n-vs-spark-tachyon-peertachyon-s3n-07272013-235015
export OUTFILE=$INFILE.pdf
export TITLE="Normalized time of Spark - Tachyon - s3n and Spark - Tachyon - Peer Tachyon - s3n"
gnuplot spark-s3n-vs-spark-tachyon-s3n-vs-spark-tachyon-peertachyon-s3n.gnuplot
