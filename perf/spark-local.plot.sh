#!/bin/bash

export INFILE_SL=../result/spark-local-07182013-064832.p1
export INFILE_STL=../result/spark-tachyon-local-07182013-182813.p1
export OUTFILE=../result/local-07182013-064832.pdf
export TITLE="Spark count()ing local files"
gnuplot spark-local.gnuplot
