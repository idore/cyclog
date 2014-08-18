#!/bin/bash

#################################
# cyclog - by tony baldwin      #
# http://tonyb.us/cyclog        #
# keeping a personal cyclog     #
# released according to GPL v.3 #
#################################

filedate=$(date +%Y%m%d%H%M%S)
thismonth=$(date +%Y%m)
tday=$(date +%Y%m%d)


source  ~/.cyclog.conf
cd $clpath

# read entries
if [[ $1 = r ]]; then
	if [[ $2 ]]; then
		cat $2* | less
	else
		for i in $(ls -Rt *.ride); do cat $i; done | less
	fi
else
# help
if [[ $1 = h ]]; then
	echo "cyclog management system by tony baldwin, http://tonyb.us/cyclog
----------- cyclog usage ------------
cyclog - opens a new cyclog file to edit in your editor.
cyclog e filename - opens log entry with filename for editing. Must use full filename.
cyclog v filename - opens log entry with filename for viewing. Must use full filename.
cyclog d filename - delete cyclog file with filename.
cyclog r - reads all entries (cats all files in the dir, pipes to less)
cyclog r yyyymmdd - reads entries from date yyyymmdd. One can specify just yyyymm, or just yyyy, even.
cyclog l - lists all cyclog entries. Like r, it can be narrowed down with date parameters.
cyclog s searchterm - searches for searchterm in ride entries.
cyclog mo yyyymm - gives a monthly report for month yyyymm 
cyclog yr yyyy - gives a yearly report for year yyyy (such as cyclog yr 2013)
cyclog h - displays this help message.
--------------------------------------
DATES: YYYYMMDD means 4 digit year, 2 digit month, 2 digit day.
This month is $thismonth, Today is $tday.
TIMES: Enter time, including hours HH:MM:SS, even if you are doing short rides, under an hour.
i.e. for a 23minute 15second ride: 00:23:15
Otherwise the math will be all wrong.
REPORTS: yearly and monthly reports will give you data for
Total no. of workouts, total distance, total time, average distance, average speed
for the time period in question, to date.
-------------------------------------
cyclog is released according to GPL v. 3"
else
# list entries
if [[ $1 = l ]]; then
	if [[ $2 ]]; then
		ls -1t | grep $2
	else
		ls -1t
	fi
else
# delete an entry
if [[ $1 = d ]]; then
	read -p "Are you certain you wish to delete $2? " dr
	if [[ $dr = y ]]; then
		rm $2
	else
		exit
	fi
else
# view a single entry
if [[ $1 = v ]]; then
	less $2
else
# edit an entry
if [[ $1 = e ]]; then
	$editor $2
else
# search entries
if [[ $1 = s ]]; then
	grep -iw $2 *
else
#create monthly report
if [[ $1 = mo ]]; then
	if [ -e $2.month ]; then
		read -p "Report exists. View or Recreate? (v/r)" po0p
		if [ $po0p = v ] ; then 
			cat $2.month
			exit
		fi
	fi
		ttime=0
		tdist=0
		norides=0
		for i in $(ls $2*.ride); do norides=$((norides+1)); done
		for di in $(ls $2*.ride); do
		grep Distance $di | awk '{ print $2 }' >> $2.distance
		done
		for dis in $(cat $2.distance); do
		tdist=`echo "$tdist+$dis" | bc -l`
		done
		for ti in $(ls $2*.ride); do
		rtime=`grep Time $ti | awk '{ print $2 }'`
		timesex=`echo "$rtime" | awk -F: '{ print ($1*3600) +($2*60) + $3 }'`
		timehr=`echo $timesex / 3600 | bc -l`
		echo $timehr >> $2.time
		done
		for tim in $(cat $2.time); do
		ttime=`echo "$ttime+$tim" | bc -l`
		done
		mtime=`printf "%0.2f\n" $ttime`
		avedist=`echo "$tdist/$norides" | bc -l`
		avdist=`printf "%0.2f\n" $avedist`
		avpace=`echo "$tdist / $ttime" | bc -l`
		mph=`printf "%0.2f\n" $avpace`
		echo "---- $uname's Monthly Cycle Report $2 ----" > $2.month
		echo  "Total no. of rides = $norides
Total Distance = $tdist
Total Time = $mtime hrs
Average Distance = $avdist $dunit
Average Pace = $mph $dunit/hr
-------------------------------------" >> $2.month
		rm $2.distance
		rm $2.time
		cat $2.month
		exit
else
#create yearly report
if [[ $1 = yr ]]; then
	if [ -e $2.year ]; then
		read -p "Report exists. View or Recreate? (v/r)" po0p
		if [ $po0p = v ] ; then 
			cat $2.year
			exit
		fi
	fi
		ttime=0
		tdist=0
		norides=0
		for i in $(ls $2*.ride); do norides=$((norides+1)); done
		for di in $(ls $2*.ride); do
		grep Distance $di | awk '{ print $2 }' >> $2.distance
		done
		for dis in $(cat $2.distance); do
		tdist=`echo "$tdist+$dis" | bc -l`
		done
		for ti in $(ls $2*.ride); do
		rtime=`grep Time $ti | awk '{ print $2 }'`
		timesex=`echo "$rtime" | awk -F: '{ print ($1*3600) +($2*60) + $3 }'`
		timehr=`echo $timesex / 3600 | bc -l`
		echo $timehr >> $2.time
		done
		for tim in $(cat $2.time); do
		ttime=`echo "$ttime+$tim" | bc -l`
		done
		mtime=`printf "%0.2f\n" $ttime`
		avedist=`echo "$tdist/$norides" | bc -l`
		avdist=`printf "%0.2f\n" $avedist`
		avpace=`echo "$tdist / $ttime" | bc -l`
		mph=`printf "%0.2f\n" $avpace`
		echo "---- $uname's Yearly Cycle Report $2 ----" > $2.year
		echo  "Total no. of rides = $norides
Total Distance = $tdist
Total Time = $mtime hrs
Average Distance = $avdist $dunit
Average Pace = $mph $dunit/hr
-------------------------------------" >> $2.year
		rm $2.distance
		rm $2.time
		cat $2.year
		exit
		exit
#create new cyclog entry
else
	date=`date`
	read -p "Distance ($dunit):  " dist
	read -p "Time (HH:MM:SS, include hours, even if 00): " rtime
	read -p "Notes: " notes
	timesex=`echo "$rtime" | awk -F: '{ print ($1*3600) + ($2*60) + $3 }'`
	hrs=`echo "$timesex / 3600" | bc -l`
	pace=`echo "$dist / $hrs" | bc -l`
	mph=`printf "%0.2f\n" $pace`
	echo -e "\n$date\n\nDistance: $dist $dunit \nTime $rtime \nPace: $mph $dunit/hr\n-------------------\n$notes\n------------------\n" > $filedate.ride
	$editor $filedate.ride
#	scp -i /home/tony/.ssh/ttkey_dsa $filedate.ride tatooine:/home/tony/.cyclog
# REDMATRIX PLUGIN START
# This bit allows one to post to red (see https://redmatrixproject.info). 
# Only implemented if the $fplug value in ~/.cyclog.conf = y
# and, of course, the proper redmatrix parameters (user:pass, site.url) are present in same .conf file
if [[ $rplug = y ]]; then
	# initializing some variables for xposting.
	let snet=twit=fb=dw=lj=ij=tum=wp=lt=pp=0
	read -p "Post to Red? (y/n) " post
	if [[ $post = y ]]; then
		echo -e "#fitness #cycling\nposted with cyclog - http://tonyb.us/cyclog\n----------------\n" >> $clpath/$filedate.ride
		ud="$(cat $clpath/$filedate.ride)"
		title="$uname's cyclog"
		read -p "Will you be crossposting to other networks? (y/n) " xpo
		if [[ $xpo == y ]]; then
			echo "For each of the following, if you wish to xpost to the network, enter 1:"
			read -p "statusnet? " snet
			read -p "friendica? " fd
			read -p "dreamwidth? " dw
			read -p "livejournal? " lj
			read -p "insanejournal?" ij
			read -p "wordpress? " wp
			read -p "libertree? " lt
			read -p "pumpio? " pp
			read -p "diaspora?? " dia
		fi
		cats="cycling,fitness"
		if [[ $(curl -k -u $ruser:$rpass -d "status=$ud&title=$title&channel=$chan&rtof_enable=$fd&ljpost_enable=$lj&ijpost_enable=$ij&dwpost_enable=$dw&wppost_enable=$wp&libertree_enable=$lt&statusnet_enable=$snet&pumpio_enable=$pp&diaspora_enable=$dia&source=cyclog.sh&category=$cats" $rsite/api/statuses/update.xml | grep error) ]]; then
			echo "Error!"
			exit
		else
			echo "Success!"
			read -p "Shall we have a look in your a browser now? (y/n): " op
			if [ $op = "y" ]; then
				$browser $rsite/channel/$chan
			fi
		fi
	fi
fi
# REDMATRIX# PLUGIN END
fi
fi
fi
fi
fi
fi
fi
fi
fi
exit
