#!/bin/bash

export INFILE=../result/s3-download-07192013-200247.p1
export OUTFILE=../result/s3-download-07192013-200247.pdf
gnuplot s3-download.gnuplot
