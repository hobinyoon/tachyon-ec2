#!/bin/bash

export INFILE=../result/spark-local-vs-spark-tachyon-local-07202013-000116
export OUTFILE=../result/spark-local-vs-spark-tachyon-local-07202013-000116.pdf
export TITLE="Spark - local vs. Spark - Tachyon - local"
gnuplot spark-local-vs-spark-tachyon-local.gnuplot
