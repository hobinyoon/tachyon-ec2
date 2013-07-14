#!/bin/bash

export INFILE=../result/s3-download-time-07142013-174154.regular-files
export OUTFILE=../result/s3-download-time-07142013-174154.regular-files.pdf
gnuplot _s3-get-time.gnuplot

export INFILE=../result/s3-download-time-07142013-174154.gzipped-files
export OUTFILE=../result/s3-download-time-07142013-174154.gzipped-files.pdf
gnuplot _s3-get-time.gnuplot
