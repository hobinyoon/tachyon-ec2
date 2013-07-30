# Tested with gnuplot 4.6 patchlevel 3

set terminal pdf enhanced dashed size 5.50in, 4.125in

set key under nobox

set border back lc rgb "#808080"
set ylabel "Normalized time to Spark s3n"
set xlabel "File name\nsize" offset 0,-1

set grid y back lt 0 lc rgb "#E0E0E0"

INFILE = system("echo $INFILE")
OUTFILE = system("echo $OUTFILE")
TITLE = system("echo $TITLE")
#set title TITLE

set output OUTFILE

X_BEGIN=-0.25
X_END=0.25
X_LEN=X_END-X_BEGIN

I_MIN=0
I_MAX=3
I_LEN=I_MAX - I_MIN + 1
X_STEP=X_LEN/I_LEN

_offset(i) = X_BEGIN + X_STEP * (i - I_MIN)

set logscale y
set style fill solid 0.2 noborder
BOXWIDTH=0.1

plot \
INFILE u 0:(0):xticlabel(1) w points pointsize 0.01 lc rgb "#E0E0E0" not, \
INFILE u ($0 + _offset(0)):2:(BOXWIDTH) w boxes lt 1 lc rgb "red" t "spark - tachyon - s3n files. left - first, right - second and later", \
INFILE u ($0 + _offset(1)):3:(BOXWIDTH) w boxes lt 1 lc rgb "red" not, \
INFILE u ($0 + _offset(3)):4:(BOXWIDTH) w boxes lt 1 lc rgb "#006400" t "spark - tachyon - peer tachyon - s3n files. left - first, right - second and later", \
INFILE u ($0 + _offset(4)):5:(BOXWIDTH) w boxes lt 1 lc rgb "#006400" not, \
INFILE u ($0 + _offset(0)):2:(sprintf("%.2f", $2)) w labels offset 0,0.4 tc rgb "red" not, \
INFILE u ($0 + _offset(1)):3:(sprintf("%.2f", $3)) w labels offset 0,0.4 tc rgb "red" not, \
INFILE u ($0 + _offset(3)):4:(sprintf("%.2f", $4)) w labels offset 0,0.4 tc rgb "#006400" not, \
INFILE u ($0 + _offset(4)):5:(sprintf("%.2f", $5)) w labels offset 0,0.4 tc rgb "#006400" not
