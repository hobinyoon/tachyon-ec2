#!/bin/bash

export INFILE_SO=../result/spark-only-07162013-064954.gz_
export OUTFILE=../result/spark-only-07162013-064954.gz_.pdf
export I_MIN=5
export I_MAX=14
export TITLE="Spark reading local files. gzipped files"
gnuplot _spark-w-or-wo-tachyon.gnuplot

export INFILE_SO=../result/spark-only-07162013-064954.plain
export OUTFILE=../result/spark-only-07162013-064954.plain.pdf
export TITLE="Spark reading local files. plain files"
gnuplot _spark-w-or-wo-tachyon.gnuplot

export INFILE_SO=../result/spark-tachyon-07162013-064425.gz_
export OUTFILE=../result/spark-tachyon-07162013-064425.gz_.pdf
export TITLE="Spark with Tachyon. gzipped files"
gnuplot _spark-w-or-wo-tachyon.gnuplot

export INFILE_SO=../result/spark-tachyon-07162013-064425.plain
export OUTFILE=../result/spark-tachyon-07162013-064425.plain.pdf
export TITLE="Spark with Tachyon. plain files"
gnuplot _spark-w-or-wo-tachyon.gnuplot
