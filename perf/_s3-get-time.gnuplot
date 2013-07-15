# Tested with gnuplot 4.6 patchlevel 3

set terminal pdf enhanced size 5.50in, 4.125in

set key under nobox

set border back lc rgb "#808080"
set ylabel "Time (sec)"
set xlabel "File name"

set grid back lt 0 lc rgb "#E0E0E0"

INFILE = system("echo $INFILE")
OUTFILE = system("echo $OUTFILE")
set output OUTFILE

set pointsize 0.5

plot INFILE using 0:3:4:5:xticlabel(1) with errorbars pointtype 7 title "(min, avg, max) time"
