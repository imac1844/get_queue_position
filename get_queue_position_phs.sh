#!/bin/bash
#work in cron well!
./dash-cli masternodelist full > ./tmp/cached_mnlistfull

MN_LIST=$(cat ./tmp/cached_mnlistfull)

MNADDR=$1

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
TOTAL_MN_IN_QUEUE=$(echo "$SORTED_MN_LIST" | wc -l)
MN_QUEUE_POSITION=$(echo "$SORTED_MN_LIST" | grep -B9999999 $MNADDR | wc -l)
MN_VISIBLE=$((MN_QUEUE_POSITION > 0))
SELECTION_LENGTH=$(( $TOTAL_MN_IN_QUEUE / 10 ))
LENGTH_QUEUE_TO_POOL=$(( $TOTAL_MN_IN_QUEUE - $SELECTION_LENGTH ))
MN_QUEUE_IN_SELECTION=$(( $MN_QUEUE_POSITION >= $LENGTH_QUEUE_TO_POOL ))
percent=$(echo "scale=2;100*$MN_QUEUE_POSITION/$LENGTH_QUEUE_TO_POOL" | bc -l )
MN_QUEUE_DATA=$(echo "$SORTED_MN_LIST" | grep $MNADDR)
MN_PAY_BLOCK=$(echo "$MN_QUEUE_DATA" | awk '{print $8}')
LAST_MN_IN_QUEUE_TO_POOL=$(echo "$SORTED_MN_LIST" |sed -n "$(( $LENGTH_QUEUE_TO_POOL-1 ))"p | awk '{print $8, $9}')
FIRST_BLOCK_IN_POOL=$(sed -n "$LENGTH_QUEUE_TO_POOL"p  ./tmp/mnlist_sorted | awk '{print $8}')
LAST_PAID_MN_FIRST_IN_POOL=$(sed -n "$LENGTH_QUEUE_TO_POOL"p  ./tmp/mnlist_sorted | awk '{print $10}')
AVG_TIME_FIND_BLOCK=$(echo "$LAST_PAID_MN_FIRST_IN_POOL / $LENGTH_QUEUE_TO_POOL * 100" | bc -l | awk '{print int($1+0.5)}') 
MN_TIME_about_POOL=$(echo "($FIRST_BLOCK_IN_POOL  - $MN_PAY_BLOCK) * $AVG_TIME_FIND_BLOCK / 100" | bc -l | awk '{print int($1+0.5)}')
MN_LAST_PAID_EPOCH=$(echo "$MN_QUEUE_DATA" | awk '{print $7}')
MN_Pubkey=$(echo "$MN_QUEUE_DATA" | awk '{print $4}')
MN_LAST_PAID_AGO=$((NOW - MN_LAST_PAID_EPOCH))
#MN_LAST_PAID_AGO_10=$(echo "$MN_QUEUE_DATA" | awk '{print $10}')
MN_LAST_SEEN_EPOCH=$(echo "$MN_QUEUE_DATA" | awk '{print $5}')
echo "MN_LAST_PAID_AGO = $MN_LAST_PAID_AGO sec"
#echo "MN_LAST_PAID_AGO(10) = $MN_LAST_PAID_AGO_10 sec"
i=$MN_LAST_PAID_AGO
((sec=i%60, i/=60, min=i%60, i/=60, hrs=i%24, i/=24, day=i%24))
timestampMNLPA=$(printf "%dd%02dh%02dm" $day $hrs $min)
echo "MN_LAST_PAID_AGO = $timestampMNLPA"


	if [ $MN_TIME_about_POOL -le 0 ]; then 
		{ 
		MN_TIME_about_POOL=$(( -$MN_TIME_about_POOL )) 
		}
	fi
i=$MN_TIME_about_POOL
((sec=i%60, i/=60, min=i%60, i/=60, hrs=i%24, i/=24, day=i%24))
timestamp2=$(printf "%ddays%02dh%02dm" $day $hrs $min)
percent=$(echo "scale=0;100*$MN_QUEUE_POSITION/$LENGTH_QUEUE_TO_POOL" | bc -l )
percent_int=$(echo "$percent" | awk '{print int($1+0.5)}')
#Create ProgressBar		
		let _done=($percent_int*5)/10
		let _done_caret=($percent_int*6)/10
		let _left=50-$_done
		_done=$(printf "%${_done}s")
		_done_caret=$(printf "%${_done_caret}s")
		_left=$(printf "%${_left}s")
if [ $MN_VISIBLE -gt 0 ]; then
	if	[ $MN_QUEUE_IN_SELECTION -eq 0 ]; then 
		#Masternode in queue to SELECTION POOL
		{
		echo ""
		myvar=$(echo -e "Masternode $MN_Pubkey") 
 		printf "in queue position $(( $TOTAL_MN_IN_QUEUE - $MN_QUEUE_POSITION ))/$TOTAL_MN_IN_QUEUE\n$timestamp2 left till SELECTION!\n[${_done// /|}${_left// /:}|S.P.]\n${_done_caret// / } $percent"%% > ./tmp/nvar		
		nvar=$(echo "$(cat ./tmp/nvar)")
		}
    else
    	#Masternode in  SELECTION POOL
    	let _done=50
    	_done=$(printf "%${_done}s")
    	echo ""
		myvar=$(echo -e "Masternode $MN_Pubkey")
 		printf "in selection pool for $timestamp2.\nLast payment was $timestampMNLPA ago.\n[${_done// /|}|S.P.]\n ${_done// / } " > ./tmp/nvar		   	
 		nvar=$(echo "$(cat ./tmp/nvar)")
	fi
else
    echo "is not in masternode list"
fi
echo

curl -s \
  --form-string "token=aj6kmtua94n5c4ss6vp6iwkyj6qhfp" \
  --form-string "user=u69uin39geyd7w4244sfbws6abd1wn" \
  --form-string "sound=bike" \
  --form-string "title=$myvar" \
  --form-string "message=$nvar" \
  https://api.pushover.net/1/messages.json

# Masternode now eligible for selection!
# In selection pool for 1d02h03m04s.
# Last payment was 9d08h07m06s ago.

# Masternode XoD4...StQP in
# queue position 1234/7654.
# Last paid 5d04h03m02s ago.
# 
# Masternode XoD4...StQP now
# eligible for selection!
# In pool for 1d02h03m04s.
# Last paid 9d08h07m06s ago. 
