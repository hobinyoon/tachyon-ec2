#!/bin/bash

export INFILE_SL=../result/spark-local-07202013-000116.p1
export INFILE_STL=../result/spark-tachyon-local-07182013-182813.p1
export OUTFILE=../result/local-07202013-000116.pdf
export TITLE="Spark count()ing local files"
gnuplot spark-local.gnuplot
