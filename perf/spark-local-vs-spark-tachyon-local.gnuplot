# Tested with gnuplot 4.6 patchlevel 3

set terminal pdf enhanced size 5.50in, 4.125in

set key under nobox

set border back lc rgb "#808080"
set ylabel "Overhead"
set xlabel "File name\nsize" offset 0,-1

set grid y back lt 0 lc rgb "#E0E0E0"

INFILE = system("echo $INFILE")
OUTFILE = system("echo $OUTFILE")
TITLE = system("echo $TITLE")
set title TITLE

set output OUTFILE

set pointsize 0.5
set boxwidth 0.075

plot \
INFILE u 0:(0):xticlabel(1) w points pointsize 0.01 lc rgb "#E0E0E0" notitle, \
INFILE u ($0 - 0.1):2 w boxes lc rgb "blue" t "first", \
INFILE u ($0 - 0.1):2:(sprintf("%.4f", $2)) w labels center offset 0,0.75 tc rgb "blue" notitle, \
INFILE u ($0 + 0.1):3 w boxes lc rgb "red" t "second and later", \
INFILE u ($0 + 0.1):3:(sprintf("%.4f", $3)) w labels center offset 0,0.75 tc rgb "red" notitle
