# Tested with gnuplot 4.6 patchlevel 3

set terminal pdf enhanced size 5.50in, 4.125in

set key under nobox

set border back lc rgb "#808080"
set ylabel "Time (sec)"
set xlabel "File name\nsize" offset 0,-1

set grid y back lt 0 lc rgb "#E0E0E0"

INFILE_SS3 = system("echo $INFILE_SS3")
INFILE_STS3 = system("echo $INFILE_STS3")
OUTFILE = system("echo $OUTFILE")
TITLE = system("echo $TITLE")
set title TITLE

set output OUTFILE

set logscale y
set pointsize 0.5

X_BEGIN=-0.25
X_END=0.25
X_LEN=X_END-X_BEGIN

I_MIN=0
I_MAX=5
I_LEN=I_MAX - I_MIN
X_STEP=X_LEN/I_LEN

_offset(i) = X_BEGIN + X_STEP * (i - I_MIN)

# lc rgb "#006400"
#INFILE_STS3 u ($0 + _offset(4)):2:(sprintf("%.2f", $2)) w labels right offset -0.75,0 tc rgb "#FFFFFF" notitle, \
#INFILE_STS3 u ($0 + _offset(4)):2:3:4 w errorbars pointtype 2 lc rgb "#000000" t "TODO: spark - tachyon - remote tachyon, first", \
#INFILE_STS3 u ($0 + _offset(5)):5:6:7 w errorbars pointtype 2 lc rgb "#000000" t "TODO: spark - tachyon - remote tachyon, second and later", \

plot \
INFILE_SS3 u 0:(0):xticlabel(1) w points pointsize 0.01 lc rgb "#E0E0E0" notitle, \
INFILE_SS3 u ($0 + _offset(0)):2:3:4 w errorbars pointtype 1 lc rgb "blue" t "spark - s3, first", \
INFILE_SS3 u ($0 + _offset(0)):2:(sprintf("%.2f", $2)) w labels right offset -0.75,0 tc rgb "blue" notitle, \
INFILE_SS3 u ($0 + _offset(1)):5:6:7 w errorbars pointtype 2 lc rgb "blue" t "spark - s3, second and later", \
INFILE_SS3 u ($0 + _offset(1)):5:(sprintf("%.2f", $5)) w labels right offset -0.75,0 tc rgb "blue" notitle, \
INFILE_STS3 u ($0 + _offset(2)):2:3:4 w errorbars pointtype 1 lc rgb "red" t "spark - tachyon - s3, first", \
INFILE_STS3 u ($0 + _offset(2)):2:(sprintf("%.2f", $2)) w labels left offset 0.75,0 tc rgb "red" notitle, \
INFILE_STS3 u ($0 + _offset(3)):5:6:7 w errorbars pointtype 2 lc rgb "red" t "spark - tachyon - s3, second and later", \
INFILE_STS3 u ($0 + _offset(3)):5:(sprintf("%.2f", $5)) w labels left offset 0.75,0 tc rgb "red" notitle, \
INFILE_STS3 u ($0 + _offset(4)):2:3:4 w points pointsize 0.01 lc rgb "#E0E0E0" t "TODO: spark - tachyon - remote tachyon, first", \
INFILE_STS3 u ($0 + _offset(5)):5:6:7 w points pointsize 0.01 lc rgb "#E0E0E0" t "TODO: spark - tachyon - remote tachyon, second and later"
