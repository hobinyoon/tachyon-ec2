# Tested with gnuplot 4.6 patchlevel 3

set terminal pdf enhanced size 5.50in, 4.125in

set key under nobox

set border back lc rgb "#808080"
set ylabel "Speed (MB/sec)"
set xlabel "File name\nsize in bytes" offset 0,-1

set grid y back lt 0 lc rgb "#E0E0E0"

INFILE = system("echo $INFILE")
OUTFILE = system("echo $OUTFILE")
TITLE = system("echo $TITLE")
set output OUTFILE
set title TITLE

set pointsize 0.5

plot INFILE using ($0-0.05):($2/1024/1024/$3):($2/1024/1024/$5):($2/1024/1024/$4) with errorbars pointtype 7 title "(min, avg, max) time" ,\
     INFILE using ($0+0.05):($2/1024/1024/$6) with points pointtype 7 lc rgb "#0000FF" title "trials", \
     INFILE using ($0+0.05):($2/1024/1024/$7) with points pointtype 7 lc rgb "#0000FF" notitle, \
     INFILE using ($0+0.05):($2/1024/1024/$8) with points pointtype 7 lc rgb "#0000FF" notitle, \
     INFILE using ($0+0.05):($2/1024/1024/$9) with points pointtype 7 lc rgb "#0000FF" notitle, \
     INFILE using ($0+0.05):($2/1024/1024/$10) with points pointtype 7 lc rgb "#0000FF" notitle, \
     INFILE using ($0+0.05):($2/1024/1024/$11) with points pointtype 7 lc rgb "#0000FF" notitle, \
     INFILE using ($0+0.05):($2/1024/1024/$12) with points pointtype 7 lc rgb "#0000FF" notitle, \
     INFILE using ($0+0.05):($2/1024/1024/$13) with points pointtype 7 lc rgb "#0000FF" notitle, \
     INFILE using ($0+0.05):($2/1024/1024/$14) with points pointtype 7 lc rgb "#0000FF" notitle, \
     INFILE using ($0):(0):xticlabel(1) with points pointsize 0.01 notitle
