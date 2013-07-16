# Tested with gnuplot 4.6 patchlevel 3

set key under nobox

set border back lc rgb "#808080"
set ylabel "Speed (MB/sec)"
set xlabel "File name\nsize" offset 0,-1

set grid y back lt 0 lc rgb "#E0E0E0"

INFILE = system("echo $INFILE")
TITLE = system("echo $TITLE")
set title TITLE
set pointsize 0.5

OUTFILE = INFILE.".pdf"
set output OUTFILE
set terminal pdf enhanced size 5.50in, 4.125in

plot INFILE u ($0-0.05):($2/1024/1024/$3):($2/1024/1024/$5):($2/1024/1024/$4) with errorbars pointtype 7 lc rgb "red" title "(min, avg, max) time" ,\
     INFILE u ($0+0.05):($2/1024/1024/$6) with points pointtype 7 lc rgb "blue" title "trials", \
     INFILE u ($0+0.05):($2/1024/1024/$7) with points pointtype 7 lc rgb "blue" notitle, \
     INFILE u ($0+0.05):($2/1024/1024/$8) with points pointtype 7 lc rgb "blue" notitle, \
     INFILE u ($0+0.05):($2/1024/1024/$9) with points pointtype 7 lc rgb "blue" notitle, \
     INFILE u ($0+0.05):($2/1024/1024/$10) with points pointtype 7 lc rgb "blue" notitle, \
     INFILE u ($0+0.05):($2/1024/1024/$11) with points pointtype 7 lc rgb "blue" notitle, \
     INFILE u ($0+0.05):($2/1024/1024/$12) with points pointtype 7 lc rgb "blue" notitle, \
     INFILE u ($0+0.05):($2/1024/1024/$13) with points pointtype 7 lc rgb "blue" notitle, \
     INFILE u ($0+0.05):($2/1024/1024/$14) with points pointtype 7 lc rgb "blue" notitle, \
     INFILE u ($0-0.05):($2/1024/1024/$3):(sprintf("%.1f",$2/1024/1024/$3)) w labels right offset -0.5,0 tc rgb "red" notitle, \
     INFILE u ($0):(0):xticlabel(1) with points pointsize 0.01 notitle

# This is not needed. Files can be exported with Mac Preview and they have better quality.
# OUTFILE = INFILE.".png"
# set output OUTFILE
# # tested with MacOS 10.8.4
# # tried these and none of these was satisfactory.
# #   /System/Library/Fonts/Helvetica.dfont
# #   ~/work/linux-home/Helvetica.ttf
# #   /Library/Fonts/Georgia.ttf
# #   /Library/Fonts/Microsoft/Times New Roman.ttf
# set terminal png enhanced font '/Library/Fonts/Microsoft/Arial.ttf' 8 size 640,480
# replot
