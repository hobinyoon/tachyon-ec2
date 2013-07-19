# Tested with gnuplot 4.6 patchlevel 3

set key under nobox

set border back lc rgb "#808080"
set ylabel "Time (sec)"
set xlabel "File name\nsize" offset 0,-1

set grid y back lt 0 lc rgb "#E0E0E0"

INFILE = system("echo $INFILE")
OUTFILE = system("echo $OUTFILE")
set title "S3 download time"
set pointsize 0.5

set output OUTFILE
set terminal pdf enhanced size 5.50in, 4.125in

set logscale y

X_BEGIN=-0.25
X_END=0.20
X_LEN=X_END-X_BEGIN

I_MIN=5
I_MAX=14
I_LEN=I_MAX - I_MIN + 1
X_STEP=X_LEN/I_LEN

_offset(i) = X_BEGIN + X_STEP * (i - I_MIN)

set rmargin 7

plot \
INFILE u ($0):(0):xticlabel(1) w points pointsize 0.01 lc rgb "#E0E0E0" notitle, \
for [i=I_MIN:I_MAX] INFILE u ($0 + _offset(i)):i w points pointtype 7 lc rgb "blue" notitle, \
INFILE u ($0 + _offset(I_MAX+1)):2:3:4 w errorbars pointtype 1 lc rgb "red" title "(min, avg, max) time", \
INFILE u ($0 + _offset(I_MAX+1)):2:(sprintf("%.2f",$2)) w labels left offset 0.75,0 tc rgb "red" notitle
