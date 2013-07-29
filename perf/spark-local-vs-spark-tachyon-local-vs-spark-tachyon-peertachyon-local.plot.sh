#!/bin/bash

export INFILE=../result/spark-local-vs-spark-tachyon-local-vs-spark-tachyon-peertachyon-local-07272013-230819
export OUTFILE=../result/spark-local-vs-spark-tachyon-local-vs-spark-tachyon-peertachyon-local-07272013-230819.pdf
export TITLE="Normalized time of Spark - Tachyon - local and Spark - Tachyon - Peer Tachyon - local"
gnuplot spark-local-vs-spark-tachyon-local-vs-spark-tachyon-peertachyon-local.gnuplot
