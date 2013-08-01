# Tested with gnuplot 4.6 patchlevel 3

set terminal pdf enhanced dashed size 5.50in, 4.125in

set key under nobox

set border back lc rgb "#808080"
set ylabel "Time (sec)"
set xlabel "File name\nsize" offset 0,-1

set grid y back lt 0 lc rgb "#E0E0E0"

INFILE_SL = system("echo $INFILE_SL")
INFILE_STPL = system("echo $INFILE_STPL")
INFILE_STPL_GOAL1G = system("echo $INFILE_STPL_GOAL1G")
INFILE_STPL_GOAL10G = system("echo $INFILE_STPL_GOAL10G")
OUTFILE = system("echo $OUTFILE")
TITLE = system("echo $TITLE")
set title TITLE

set output OUTFILE

set logscale y

X_BEGIN=-0.25
X_END=0.25
X_LEN=X_END-X_BEGIN

I_MIN=0
I_MAX=9
I_LEN=I_MAX - I_MIN
X_STEP=X_LEN/I_LEN

_offset(i) = X_BEGIN + X_STEP * (i - I_MIN)

set xrange [- 0.5 : 5 + 0.5]
set style fill solid 0.2 noborder
BOXWIDTH=0.040

plot \
INFILE_SL           u 0:(0):xticlabel(1) w points pointsize 0.01 lc rgb "#E0E0E0" not, \
INFILE_SL           u ($0 + _offset(0)):2:3:4:(BOXWIDTH) w boxerrorbars lt 1 lc rgb "blue" t "spark - local files. left - first, right - second and later", \
INFILE_SL           u ($0 + _offset(1)):5:6:7:(BOXWIDTH) w boxerrorbars lt 1 lc rgb "blue" not, \
INFILE_STPL         u ($0 + _offset(2)):2:3:4:(BOXWIDTH) w boxerrorbars lt 1 lc rgb "#006400" t "spark - tachyon - peer tachyon - local files. left - first, right - second and later", \
INFILE_STPL         u ($0 + _offset(3)):5:6:7:(BOXWIDTH) w boxerrorbars lt 1 lc rgb "#006400" not, \
INFILE_STPL_GOAL1G  u ($0 + _offset(5)):2:3:4:(BOXWIDTH) w boxerrorbars lt 1 lc rgb "red" t "spark - tachyon - peer tachyon - local files. Ideal 1G. left - first, right - second and later", \
INFILE_STPL_GOAL1G  u ($0 + _offset(6)):5:6:7:(BOXWIDTH) w boxerrorbars lt 1 lc rgb "red" not, \
INFILE_STPL_GOAL10G u ($0 + _offset(7)):2:3:4:(BOXWIDTH) w boxerrorbars lt 1 lc rgb "red" t "spark - tachyon - peer tachyon - local files. Ideal 10G. left - first, right - second and later", \
INFILE_STPL_GOAL10G u ($0 + _offset(8)):5:6:7:(BOXWIDTH) w boxerrorbars lt 1 lc rgb "red" not, \
INFILE_SL           u ($0 + _offset(0)):2:(sprintf("%.2f", $2)) w labels right offset -0.75,0 tc rgb "blue" not, \
INFILE_SL           u ($0 + _offset(1)):5:(sprintf("%.2f", $5)) w labels right offset -0.75,0 tc rgb "blue" not, \
INFILE_STPL         u ($0 + _offset(2)):2:(sprintf("%.2f", $2)) w labels left offset 0.75,0 tc rgb "#006400" not, \
INFILE_STPL         u ($0 + _offset(3)):5:(sprintf("%.2f", $5)) w labels left offset 0.75,0 tc rgb "#006400" not, \
INFILE_STPL_GOAL1G  u ($0 + _offset(5)):2:(sprintf("%.2f", $2)) w labels left offset 0.75,0 tc rgb "red" not, \
INFILE_STPL_GOAL10G u ($0 + _offset(7)):2:(sprintf("%.2f", $2)) w labels left offset 0.75,0 tc rgb "red" not, \
INFILE_STPL_GOAL10G u ($0 + _offset(8)):5:(sprintf("%.2f", $5)) w labels left offset 0.75,0 tc rgb "red" not

#INFILE_STPL_GOAL1G  u ($0 + _offset(6)):5:(sprintf("%.2f", $5)) w labels left offset 0.75,0 tc rgb "red" not, \
