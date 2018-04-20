!/bin/bash
#works in cron well!
./dash-cli masternodelist full > ./tmp/cached_mnlistfull

MN_LIST=$(cat ./tmp/cached_mnlistfull)
# INPUT=$2

MNADDR=$1
echo "MNADDR=$MNADDR"
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


echo "$SORTED_MN_LIST" > ./tmp/mnlist_sorted

echo "$SORTED_MN_LIST" | grep $MNADDR | awk '{print $9 " " $4}' > tmpfile

echo "$MNADDR" ; IFS=. ; set -- $* ;
DEC_ADDR=$(echo $(( ($1*256**3) + ($2*256**2) + ($3*256) + ($4) )) )
echo "DEC_ADDR=$DEC_ADDR"

while read LINE;
do
	grep  "$LINE" | awk -F':' '{print $1}'
	IFS=. ; set -- $*
	IP_DEC=$(echo $(( ($1*256**3) + ($2*256**2) + ($3*256) + ($4) )) )
	if [ $IP_DEC -eq $DEC_ADDR ]
	echo "IP_DEC=$IP_DEC"
	then
		PubKey=$(echo -e "$LINE"  | awk '{print $2}' | cut -c26-34 )
	fi

done < tmpfile

echo "PubKey=$PubKey"

TOTAL_MN_IN_QUEUE=$(echo "$SORTED_MN_LIST" | wc -l)
MN_QUEUE_POSITION=$(echo "$SORTED_MN_LIST" | grep  -B9999999 $PubKey | wc -l)
MN_VISIBLE=$((MN_QUEUE_POSITION > 0))
SELECTION_LENGTH=$(( $TOTAL_MN_IN_QUEUE / 10 ))
LENGTH_QUEUE_TO_POOL=$(( $TOTAL_MN_IN_QUEUE - $SELECTION_LENGTH ))
MN_QUEUE_IN_SELECTION=$(( $MN_QUEUE_POSITION >= $LENGTH_QUEUE_TO_POOL ))
percent=$(echo "scale=2;100*$MN_QUEUE_POSITION/$LENGTH_QUEUE_TO_POOL" | bc -l )
MN_QUEUE_DATA=$(echo "$SORTED_MN_LIST" | grep  $PubKey)
#echo = "$MN_QUEUE_DATA"
MN_PAY_BLOCK=$(echo "$MN_QUEUE_DATA" | awk '{print $8}')
LAST_MN_IN_QUEUE_TO_POOL=$(echo "$SORTED_MN_LIST" |sed -n "$(( $LENGTH_QUEUE_TO_POOL-1 ))"p | awk '{print $8, $9}')
FIRST_BLOCK_IN_POOL=$(sed -n "$LENGTH_QUEUE_TO_POOL"p  ./tmp/mnlist_sorted | awk '{print $8}')
LAST_PAID_MN_FIRST_IN_POOL=$(sed -n "$LENGTH_QUEUE_TO_POOL"p  ./tmp/mnlist_sorted | awk '{print $10}')
AVG_TIME_FIND_BLOCK=$(echo "$LAST_PAID_MN_FIRST_IN_POOL / $LENGTH_QUEUE_TO_POOL * 100" | bc -l | awk '{print int($1+0.5)}')
MN_TIME_about_POOL=$(echo "($FIRST_BLOCK_IN_POOL  - $MN_PAY_BLOCK) * $AVG_TIME_FIND_BLOCK / 100" | bc -l | awk '{print int($1+0.5)}')
#	if [ $MN_TIME_about_POOL -le 0 ]; then
#		{
#		MN_TIME_about_POOL=$(( -$MN_TIME_about_POOL ))
#		}
#	fi
exit
i=$MN_TIME_about_POOL
((sec=i%60, i/=60, min=i%60, i/=60, hrs=i%24, i/=24, day=i%24))
timestamp2=$(printf "%ddays %02dh%02dm" $day $hrs $min)
#echo "MN_TIME_about_POOL = $timestamp2"
#
percent=$(echo "scale=2;100*$MN_QUEUE_POSITION/$LENGTH_QUEUE_TO_POOL" | bc -l )
percent_int=$(echo "$percent" | awk '{print int($1+0.5)}')
#Create ProgressBar
		let _done=($percent_int*4)/10
		let _left=40-$_done
		_done=$(printf "%${_done}s")
		_left=$(printf "%${_left}s")
if [ $MN_VISIBLE -gt 0 ]; then
	if	[ $MN_QUEUE_IN_SELECTION -eq 0 ]; then
		#Masternode in queue to SELECTION POOL
		{
		echo ""
		echo -e "masternode $MNADDR position $(( $TOTAL_MN_IN_QUEUE - $MN_QUEUE_POSITION )) in $TOTAL_MN_IN_QUEUE "
		printf "      $timestamp2 to SELECTION POOL\n[${_done// /#}${_left// /-}|SELECTION POOL]\n${_done// / }^ $percent%% "
		}
    else
    	#Masternode in  SELECTION POOL
    	echo ""
 		printf "masternode $MNADDR position in SELECTION PENDING\n     $timestamp2 in selecion pool and wait for payment! \n[########################################|SELECTION POOL]\n ${_done// / }"
	fi
else
    echo "is not in masternode list"
fi
echo
