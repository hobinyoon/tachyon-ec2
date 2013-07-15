#!/bin/bash

export INFILE=../result/s3-download-time-07142013-174154.regular-files
export TITLE="plain files"
gnuplot _s3-download.gnuplot

export INFILE=../result/s3-download-time-07142013-174154.gzipped-files
export TITLE="gzipped files"
gnuplot _s3-download.gnuplot
