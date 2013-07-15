#!/bin/bash

export INFILE=../result/s3-download-time-07142013-174154.regular-files
export OUTFILE=../result/s3-download-time-07142013-174154.regular-files.pdf
export TITLE="plain files"
gnuplot _s3-download.gnuplot

export INFILE=../result/s3-download-time-07142013-174154.gzipped-files
export OUTFILE=../result/s3-download-time-07142013-174154.gzipped-files.pdf
export TITLE="gzipped files"
gnuplot _s3-download.gnuplot
