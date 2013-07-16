# Tested with gnuplot 4.6 patchlevel 3

set terminal pdf enhanced size 5.50in, 4.125in

set key under nobox

set border back lc rgb "#808080"
set ylabel "Time (sec)"
set xlabel "File name\nsize" offset 0,-1

set grid y back lt 0 lc rgb "#E0E0E0"

INFILE_SO = system("echo $INFILE_SO")
OUTFILE = system("echo $OUTFILE")
# adding 0 is how you convert string to int
I_MIN = system("echo $I_MIN") + 0
I_MAX = system("echo $I_MAX") + 0
TITLE = system("echo $TITLE")
set title TITLE
set rmargin 6

set output OUTFILE

set pointsize 0.5

# plot INFILE_SO u ($0-0.15):2:3:4 w errorbars pointtype 7 title "Spark processing local files", \
#      INFILE_SO u ($0-0.05):5:6:7 w errorbars pointtype 7 title "S3 get + Spark", \
#      INFILE_SO u 0:(0):xticlabel(1) w points pointsize 0.01 lc rgb "#E0E0E0" notitle

# started from parameterized this one...
# 8 to 17
#plot INFILE_SO u ($0-0.15):8 w points pointtype 7 lc rgb "red" notitle, \
#     INFILE_SO u ($0-0.10):9 w points pointtype 7 lc rgb "blue" notitle, \
#     INFILE_SO u ($0-0.05):17 w points pointtype 7 lc rgb "blue" notitle, \
#     INFILE_SO u 0:(0):xticlabel(1) w points pointsize 0.01 lc rgb "#E0E0E0" notitle

X_BEGIN=-0.25
X_END=0.25
X_LEN=X_END-X_BEGIN

I_LEN=I_MAX - I_MIN + 1
X_STEP=X_LEN/I_LEN

_offset(i) = X_BEGIN + X_STEP * (i - I_MIN)

plot \
INFILE_SO u 0:(0):xticlabel(1) w points pointsize 0.01 lc rgb "#E0E0E0" notitle, \
INFILE_SO u ($0 + _offset(I_MIN)):I_MIN:(sprintf("%.2f", $5)) w labels right offset -1,0 tc rgb "red" notitle, \
INFILE_SO u ($0 + _offset(I_MIN)):I_MIN w points pointtype 7 lc rgb "red" title "first count()", \
INFILE_SO u ($0 + _offset(I_MIN+1)):I_MIN+1 w points pointtype 7 lc rgb "blue" title "second count() and later", \
for [i=I_MIN+2:I_MAX] INFILE_SO u ($0 + _offset(i)):i w points pointtype 7 lc rgb "blue" notitle, \
INFILE_SO u ($0 + _offset(I_MAX+1)):2:3:4 w errorbars pointtype 1 lc rgb "blue" notitle, \
INFILE_SO u ($0 + _offset(I_MAX+1)):2:(sprintf("%.2f", $2)) w labels left offset 0.7,0 tc rgb "blue" notitle

#INFILE_SO u ($0 + _offset(I_MAX+1)):2:3:4 w errorbars pointtype 1 lc rgb "#008080" notitle

									
#INFILE_SO u ($0 + _offset(I_MAX+1)):2:3:4 w errorbars pointtype 7 lc rgb "#008080" notitle

# wanted to use $I_MIN for the sprintf argument, but it won't let me. I assume
# the first count() index is always 5.
# INFILE_SO u ($0 + _offset(I_MIN)):I_MIN:(sprintf("%.2f", $I_MIN)) w labels right offset -1,0 tc rgb "red" notitle, \
