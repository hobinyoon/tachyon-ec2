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
set style fill solid

_label_offset_y(x) = x

plot \
INFILE u 0:(0):xticlabel(1) w points pointsize 0.01 lc rgb "#E0E0E0" notitle, \
INFILE u ($0 - 0.1):2 w boxes lc rgb "#8080FF" t "first", \
INFILE u ($0 + 0.1):3 w boxes lc rgb "#FF8080" t "second and later", \
INFILE u ($0 - 0.1):(_label_offset_y($2)):(sprintf("%.4f", $2)) w labels center tc rgb "blue" notitle, \
INFILE u ($0 + 0.1):(_label_offset_y($3)):(sprintf("%.4f", $3)) w labels center tc rgb "red" notitle

# setting the label offset using the auto-calculated yrange
set output OUTFILE
_label_offset_y(x) = x + x / abs(x) * (GPVAL_Y_MAX - GPVAL_Y_MIN) * 0.020
replot