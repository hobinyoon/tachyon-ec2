#!/bin/bash

export INFILE=../result/spark-local-vs-spark-tachyon-local-07182013-064832.p1
export OUTFILE=../result/spark-local-vs-spark-tachyon-local-07182013-064832.pdf
export TITLE="Spark - local vs. Spark - Tachyon - local"
gnuplot spark-local-vs-spark-tachyon-local.gnuplot
