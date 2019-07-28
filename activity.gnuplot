set xdata time
set timefmt '%Y%m'
set xrange ['201804':'201908']
#set format x '%Y-%m'
set terminal 'png' size 1200,480
set output 'activity.png'
set datafile separator '\t'
set boxwidth 2500000
set style fill solid
plot 'activity.csv' using 1:2:xtic(1) with boxes
