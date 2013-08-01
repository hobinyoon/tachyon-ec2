#!/bin/bash

export INFILE_SL=../result/spark-local-07272013-230819.p1
export INFILE_STPL=../result/spark-tachyon-peertachyon-local-07282013-213249.p1
export INFILE_STPL_GOAL1G=../result/spark-tachyon-peertachyon-local-goal_1g-07272013-230819
export INFILE_STPL_GOAL10G=../result/spark-tachyon-peertachyon-local-goal_10g-07272013-230819
export OUTFILE=../result/local-goal-07272013-230819.pdf
export TITLE="Spark count()ing local files with goals"
gnuplot spark-local-w-goal.gnuplot
