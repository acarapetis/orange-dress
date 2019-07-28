#set xdata time
#set timefmt '%Y-%m-%d'
#set xrange ['2018-04-01':'2018-08-1']
#set format x '%d/%m'
set datafile separator ','
plot 'activity.csv' using 1:2
