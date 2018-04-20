#!/bin/bash
<<<<<<< HEAD
#work in cron well!
#./dash-cli masternodelist full > ./tmp/cached_mnlistfull
=======

./dash-cli masternodelist full > ./tmp/cached_mnlistfull
>>>>>>> e93f79cb418008e3a2ba936f3d71bf2b898ba14c

MN_LIST=$(cat ./tmp/cached_mnlistfull)
MNADDR=$1

<<<<<<< HEAD
IFS=. ; set  -- $* ; 
=======
IFS=. ; set  -- $* ;
>>>>>>> e93f79cb418008e3a2ba936f3d71bf2b898ba14c
DEC_ADDR=$(echo $(( ($1*256**3) + ($2*256**2) + ($3*256) + ($4) )) )
IFS=""

if [ -z $MNADDR ]; then
    echo "usage: $0 <masternode address>"
    exit -1
fi
NOW=`date +%s`
SORTED_MN_LIST=$(echo "$MN_LIST" | grep -w ENABLED | sed -e 's/[}|{]//' -e 's/"//g' -e 's/,//g' | grep -v ^$ | \
awk ' \
{
    if ($7 == 0) {
        TIME = $6
        print $_ " " TIME

    }
    else {
        xxx = ("'$NOW'" - $7)
        if ( xxx >= $6) {
            TIME = $6
        }
        else {
            TIME = xxx
        }
        print $_ " " TIME
    }
}' |  sort -k10 -n)

echo "$SORTED_MN_LIST" | grep $MNADDR | awk '{print $9 " " $4}' > tmpfile
<<<<<<< HEAD
if [ `ls -l tmpfile | awk '{print $5}'` -eq 0 ] ; then
echo "IP is not listed."
exit
fi ;

while read LINE;
do 
	grep  "$LINE" | awk -F':' '{print $1}' 
	IFS=. ; set -- $*	
=======
while read LINE;
do
	grep  "$LINE" | awk -F':' '{print $1}'
	IFS=. ; set -- $*
>>>>>>> e93f79cb418008e3a2ba936f3d71bf2b898ba14c
	IP_DEC=$(echo $(( ($1*256**3) + ($2*256**2) + ($3*256) + ($4) )) )
	if [ $DEC_ADDR -eq $IP_DEC ]
	then
		PubKey=$(echo -e "$LINE"  | awk '{print $2}' | cut -c26-34 )
	fi
done < tmpfile
#echo "PubKey=$PubKey"

<<<<<<< HEAD
=======

>>>>>>> e93f79cb418008e3a2ba936f3d71bf2b898ba14c
echo "$SORTED_MN_LIST" > ./tmp/mnlist_sorted

TOTAL_MN_IN_QUEUE=$(echo "$SORTED_MN_LIST" | wc -l)
MN_QUEUE_POSITION=$(echo "$SORTED_MN_LIST" | grep -B9999999 $PubKey | wc -l)
MN_VISIBLE=$((MN_QUEUE_POSITION > 0))
<<<<<<< HEAD
if [ $MN_VISIBLE -gt 0 ]; then
=======
>>>>>>> e93f79cb418008e3a2ba936f3d71bf2b898ba14c
SELECTION_LENGTH=$(( $TOTAL_MN_IN_QUEUE / 10 ))
LENGTH_QUEUE_TO_POOL=$(( $TOTAL_MN_IN_QUEUE - $SELECTION_LENGTH ))
MN_QUEUE_IN_SELECTION=$(( $MN_QUEUE_POSITION >= $LENGTH_QUEUE_TO_POOL ))
percent=$(echo "scale=2;100*$MN_QUEUE_POSITION/$LENGTH_QUEUE_TO_POOL" | bc -l )
MN_QUEUE_DATA=$(echo "$SORTED_MN_LIST" | grep $PubKey)
# echo = "$MN_QUEUE_DATA"
MN_PAY_BLOCK=$(echo "$MN_QUEUE_DATA" | awk '{print $8}')
LAST_MN_IN_QUEUE_TO_POOL=$(echo "$SORTED_MN_LIST" |sed -n "$(( $LENGTH_QUEUE_TO_POOL-1 ))"p | awk '{print $8, $9}')
FIRST_BLOCK_IN_POOL=$(sed -n "$LENGTH_QUEUE_TO_POOL"p  ./tmp/mnlist_sorted | awk '{print $8}')
LAST_PAID_MN_FIRST_IN_POOL=$(sed -n "$LENGTH_QUEUE_TO_POOL"p  ./tmp/mnlist_sorted | awk '{print $10}')
<<<<<<< HEAD
AVG_TIME_FIND_BLOCK=$(echo "$LAST_PAID_MN_FIRST_IN_POOL / $LENGTH_QUEUE_TO_POOL * 100" | bc -l | awk '{print int($1+0.5)}') 
=======
AVG_TIME_FIND_BLOCK=$(echo "$LAST_PAID_MN_FIRST_IN_POOL / $LENGTH_QUEUE_TO_POOL * 100" | bc -l | awk '{print int($1+0.5)}')
>>>>>>> e93f79cb418008e3a2ba936f3d71bf2b898ba14c
MN_TIME_about_POOL=$(echo "($FIRST_BLOCK_IN_POOL  - $MN_PAY_BLOCK) * $AVG_TIME_FIND_BLOCK / 100" | bc -l | awk '{print int($1+0.5)}')




MN_LAST_PAID_EPOCH=$(echo "$MN_QUEUE_DATA" | awk '{print $7}')
MN_Pubkey=$(echo "$MN_QUEUE_DATA" | awk '{print $4}')
MN_LAST_PAID_AGO=$((NOW - MN_LAST_PAID_EPOCH))
#MN_LAST_PAID_AGO_10=$(echo "$MN_QUEUE_DATA" | awk '{print $10}')
MN_LAST_SEEN_EPOCH=$(echo "$MN_QUEUE_DATA" | awk '{print $5}')
#echo "MN_LAST_PAID_AGO = $MN_LAST_PAID_AGO sec"
#echo "MN_LAST_PAID_AGO(10) = $MN_LAST_PAID_AGO_10 sec"
i=$MN_LAST_PAID_AGO
((sec=i%60, i/=60, min=i%60, i/=60, hrs=i%24, i/=24, day=i%24))
timestampMNLPA=$(printf "%dd%02dh%02dm" $day $hrs $min)
<<<<<<< HEAD
#echo "MN_LAST_PAID_AGO = $timestampMNLPA"	
	
	
	
	
	
	if [ $MN_TIME_about_POOL -le 0 ]; then 
		{ 
		MN_TIME_about_POOL=$(( -$MN_TIME_about_POOL )) 
=======
#echo "MN_LAST_PAID_AGO = $timestampMNLPA"





	if [ $MN_TIME_about_POOL -le 0 ]; then
		{
		MN_TIME_about_POOL=$(( -$MN_TIME_about_POOL ))
>>>>>>> e93f79cb418008e3a2ba936f3d71bf2b898ba14c
		}
	fi
i=$MN_TIME_about_POOL
((sec=i%60, i/=60, min=i%60, i/=60, hrs=i%24, i/=24, day=i%24))
timestamp2=$(printf "%ddays %02dh%02dm" $day $hrs $min)
#echo "MN_TIME_about_POOL = $timestamp2"
#
percent=$(echo "scale=2;100*$MN_QUEUE_POSITION/$LENGTH_QUEUE_TO_POOL" | bc -l )
percent_int=$(echo "$percent" | awk '{print int($1+0.5)}')
<<<<<<< HEAD
#Create ProgressBar		
=======
#Create ProgressBar
>>>>>>> e93f79cb418008e3a2ba936f3d71bf2b898ba14c
		let _done=($percent_int*4)/10
		let _left=40-$_done
		_done=$(printf "%${_done}s")
		_left=$(printf "%${_left}s")
<<<<<<< HEAD
#if [ $MN_VISIBLE -gt 0 ]; then
	if	[ $MN_QUEUE_IN_SELECTION -eq 0 ]; then 
		#Masternode in queue to SELECTION POOL
		{
		echo ""
		echo -e "masternode $MNADDR -...$PubKey\n      in queue position $(( $TOTAL_MN_IN_QUEUE - $MN_QUEUE_POSITION ))  /  $TOTAL_MN_IN_QUEUE " 
		printf "      $timestamp2 left till SELECTION!\n[${_done// /#}${_left// /-}|SELECTION POOL]\n${_done// / }^ $percent%% "
		}
    else 
    	#Masternode in  SELECTION POOL
    	echo ""
 		printf "masternode $MNADDR -...$PubKey\n      in selection pool for $timestamp2\n       Last payment was $timestampMNLPA ago.\n[########################################|SELECTION POOL]\n ${_done// / }"   	
=======
if [ $MN_VISIBLE -gt 0 ]; then
	if	[ $MN_QUEUE_IN_SELECTION -eq 0 ]; then
		#Masternode in queue to SELECTION POOL
		{
		echo ""
		echo -e "masternode $MNADDR - $PubKey\n      in queue position $(( $TOTAL_MN_IN_QUEUE - $MN_QUEUE_POSITION ))  /  $TOTAL_MN_IN_QUEUE "
		printf "      $timestamp2 left till SELECTION!\n[${_done// /#}${_left// /-}|SELECTION POOL]\n${_done// / }^ $percent%% "
		}
    else
    	#Masternode in  SELECTION POOL
    	echo ""
 		printf "masternode $MNADDR - $PubKey\n      in selection pool for $timestamp2\n       Last payment was $timestampMNLPA ago.\n[########################################|SELECTION POOL]\n ${_done// / }"
>>>>>>> e93f79cb418008e3a2ba936f3d71bf2b898ba14c
	fi
else
    echo "is not in masternode list"
fi
echo
<<<<<<< HEAD

=======
#####
>>>>>>> e93f79cb418008e3a2ba936f3d71bf2b898ba14c
