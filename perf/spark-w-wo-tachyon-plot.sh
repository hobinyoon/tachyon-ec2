#!/bin/bash

export INFILE_SO=../result/sparkshell-gz-07142013-163442.compact.3.spark-only
export INFILE_ST=../result/sparkshell-gz-07142013-163442.compact.3.spark-tachyon
export OUTFILE=../result/sparkshell-gz-07142013-163442.pdf
export TITLE="gzipped files"
gnuplot _spark-w-wo-tachyon.gnuplot

export INFILE_SO=../result/sparkshell-reg-07142013-070846.compact.2.spark-only
export INFILE_ST=../result/sparkshell-reg-07142013-070846.compact.2.spark-tachyon
export OUTFILE=../result/sparkshell-reg-07142013-070846.pdf
export TITLE="plain files"
gnuplot _spark-w-wo-tachyon.gnuplot
