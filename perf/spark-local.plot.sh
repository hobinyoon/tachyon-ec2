#!/bin/bash

export INFILE_SL=../result/spark-local-07272013-230819.p1
export INFILE_STL=../result/spark-tachyon-local-07272013-211120.p1
export OUTFILE=../result/local-07272013-230819.pdf
export TITLE="Spark count()ing local files"
gnuplot spark-local.gnuplot
