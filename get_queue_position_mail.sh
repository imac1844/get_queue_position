
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

#echo "$SORTED_MN_LIST" > ./tmp/mnlist_sorted

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
	if [ $MN_TIME_about_POOL -le 0 ]; then 
		{ 
		MN_TIME_about_POOL=$(( -$MN_TIME_about_POOL )) 
		}
	fi

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

# Additional information about masternodes, queue, seletion pool, ect. 
# No used in script and can be comment by "#"
# echo  -n "Now  "   
# date
# echo "TOTAL_MN_IN_QUEUE = $TOTAL_MN_IN_QUEUE"
# echo "MN_QUEUE_POSITION = $MN_QUEUE_POSITION"
# echo "MN_QUEUE_POSITION_from_BOOTON = $(( $TOTAL_MN_IN_QUEUE - $MN_QUEUE_POSITION )) "
# echo "SELECTION_LENGTH = $SELECTION_LENGTH"
# echo "LENGTH_QUEUE_TO_POOL = $LENGTH_QUEUE_TO_POOL"
# MN_Pubkey=$(echo "$MN_QUEUE_DATA" | awk '{print $4}')
# echo "MN_Pubkey(4) = $MN_Pubkey"
# XXXXXX=$(echo "$MN_QUEUE_DATA" | awk '{print $6}')
# echo "XXXXXX(6) = $XXXXXX"
# i=$XXXXXX
# ((sec=i%60, i/=60, min=i%60, i/=60, hrs=i%24, i/=24, day=i%24))
# timestamp=$(printf "%d days %02d:%02d:%02d" $day $hrs $min $sec)
# echo "XXXXXX = $timestamp"
# MN_LAST_PAID_EPOCH=$(echo "$MN_QUEUE_DATA" | awk '{print $7}')
# echo "MN_LAST_PAID_EPOCH(7) = $MN_LAST_PAID_EPOCH sec"
# MN_LAST_PAID_TS=$(date -ud @$MN_LAST_PAID_EPOCH)
# echo "MN_LAST_PAID_TS = $MN_LAST_PAID_TS"
# MN_LAST_PAID_AGO=$((NOW - MN_LAST_PAID_EPOCH))
# MN_LAST_PAID_AGO_10=$(echo "$MN_QUEUE_DATA" | awk '{print $10}')
# MN_LAST_SEEN_EPOCH=$(echo "$MN_QUEUE_DATA" | awk '{print $5}')
# echo "MN_LAST_PAID_AGO = $MN_LAST_PAID_AGO sec"
# echo "MN_LAST_PAID_AGO(10) = $MN_LAST_PAID_AGO_10 sec"
# i=$MN_LAST_PAID_AGO
# ((sec=i%60, i/=60, min=i%60, i/=60, hrs=i%24, i/=24, day=i%24))
# timestamp1=$(printf "%d days %02d:%02d:%02d" $day $hrs $min $sec)
# echo "MN_LAST_PAID_AGO = $timestamp1"
# echo "MN_LAST_SEEN_EPOCH(5) = $MN_LAST_SEEN_EPOCH sec"
# MN_LAST_SEEN_TS=$(date -ud @$MN_LAST_SEEN_EPOCH)
# echo "MN_LAST_SEEN_TS = $MN_LAST_SEEN_TS"
# FIRST_MN_IN_QUEUE=$(echo "$SORTED_MN_LIST" | sed '1!D' | awk '{print $8, $9}')
# echo "FIRST_MN_IN_QUEUE = $FIRST_MN_IN_QUEUE"
# echo "MN_PAY_BLOCK = $MN_PAY_BLOCK"
# echo "LAST_MN_IN_QUEUE_TO_POOL = $LAST_MN_IN_QUEUE_TO_POOL"
# echo "FIRST_BLOCK_IN_POOL = $FIRST_BLOCK_IN_POOL"
# FIRST_MN_IN_POOL=$(echo "$SORTED_MN_LIST" |sed -n "$LENGTH_QUEUE_TO_POOL"p | awk '{print $8, $9}')
# echo "FIRST_MN_IN_POOL = $FIRST_MN_IN_POOL"
# echo "LAST_PAID_MN_FIRST_IN_POOL = $LAST_PAID_MN_FIRST_IN_POOL sec"
# LAST_PAID_FIRST_MN_IN_QUEUE=$(sed -n 1p  ./tmp/mnlist_sorted | awk '{print $10}')
# echo "LAST_PAID_FIRST_MN_IN_QUEUE = $LAST_PAID_FIRST_MN_IN_QUEUE sec"
# echo "AVG_TIME_FIND_BLOCK = $AVG_TIME_FIND_BLOCK/100 sec"
# i=$AVG_TIME_FIND_BLOCK
# ((mcsec=i%100, i/=100, sec=i%60, i/=60, min=i%60, i/=60, hrs=i%24, i/=24, day=i%24))
# timestamp=$(printf "%02d min %02d sec"  $min $sec)
# echo "AVG_TIME_FIND_BLOCK (min:sec) = $timestamp"
# BLOCKS_TO_FIRST_MN_IN_QUEUE=$(( $FIRST_BLOCK_IN_POOL - $MN_PAY_BLOCK  ))
# echo "BLOCKS_TO_FIRST_MN_IN_QUEUE = $BLOCKS_TO_FIRST_MN_IN_QUEUE"
# echo "MN_TIME_about_POOL = $timestamp2"


