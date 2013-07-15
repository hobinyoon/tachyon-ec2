# Tested with gnuplot 4.6 patchlevel 3

set terminal pdf enhanced size 5.50in, 4.125in

set key under nobox

set border back lc rgb "#808080"
set ylabel "Time (sec)"
set xlabel "File name"

set grid y back lt 0 lc rgb "#E0E0E0"

INFILE_SO = system("echo $INFILE_SO")
INFILE_ST = system("echo $INFILE_ST")
OUTFILE = system("echo $OUTFILE")
TITLE = system("echo $TITLE")
set title TITLE

set output OUTFILE

set pointsize 0.5

plot INFILE_SO using 0:(0):xticlabel(1) with points pointsize 0.01 notitle, \
     INFILE_SO using ($0-0.05):2:3:4 with errorbars pointtype 7 title "Spark processing local files", \
     INFILE_ST using ($0+0.05):2:3:4 with errorbars pointtype 7 title "Spark processing S3 files with Tachyon cache"
