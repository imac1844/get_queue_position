#!/bin/bash
#NO work in cron !
MNLISTCMD="dash-cli masternodelist full 2>/dev/null"

MNADDR=$1

if [ -z $MNADDR ]; then
    echo "usage: $0 <masternode address>"
    exit -1
fi

function _cache_command(){

    # cache life in minutes
    AGE=2

    FILE=$1
    AGE=$2
    CMD=$3

    OLD=0
    CONTENTS=""
    if [ -e $FILE ]; then
        OLD=$(find $FILE -mmin +$AGE -ls | wc -l)
        CONTENTS=$(cat $FILE);
    fi
    if [ -z "$CONTENTS" ] || [ "$OLD" -gt 0 ]; then
        echo "REBUILD"
        CONTENTS=$(eval $CMD)
        echo "$CONTENTS" > $FILE
    fi
    echo "$CONTENTS"
}

NOW=`date +%s`
MN_LIST=$(_cache_command /tmp/cached_mnlistfull 2 "$MNLISTCMD")
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
MN_QUEUE_LENGTH=$(echo "$SORTED_MN_LIST" | wc -l)
MN_QUEUE_POSITION=$(echo "$SORTED_MN_LIST" | grep -B9999999 $MNADDR | wc -l)
#MN_TIME_IN_QUEUE=$(echo "$SORTED_MN_LIST" | grep $MNADDR | awk '{ print $10}')
MN_VISIBLE=$((MN_QUEUE_POSITION > 0))
SELECTION_LENGTH=$(( $MN_QUEUE_LENGTH / 10 ))
QUEUE_LENGTH=$(( $MN_QUEUE_LENGTH - $SELECTION_LENGTH ))
MN_QUEUE_IN_SELECTION=$(( $MN_QUEUE_POSITION >= $QUEUE_LENGTH ))
#echo "MN_QUEUE_IN_SELECTION = $MN_QUEUE_IN_SELECTION"
percent=$(echo "scale=2;100*$MN_QUEUE_POSITION/$QUEUE_LENGTH" | bc -l )
percent_int=$(echo "$percent" | awk '{print int($1+0.5)}')
let _done=($percent_int*4)/10
		let _left=40-$_done
		_done=$(printf "%${_done}s")
		_left=$(printf "%${_left}s")
if [ $MN_VISIBLE -gt 0 ]; then
	if	[ $MN_QUEUE_IN_SELECTION -eq 0 ]; then 
		{
		#MN 199.247.7.83 position 4289 in 4682
		echo -e "masternode $MNADDR position $(( $MN_QUEUE_LENGTH - $MN_QUEUE_POSITION )) in $MN_QUEUE_LENGTH " 
		
# Build progressbar strings and print the ProgressBar line
# [########################################|SELECTION POOL] 100%
		printf "${_done// / } $percent%%\n[${_done// /#}${_left// /-}|SELECTION POOL]"
		}
    	#echo -e "position $(( $MN_QUEUE_LENGTH - $MN_QUEUE_POSITION )) in $MN_QUEUE_LENGTH\n $percent % way to SELECTION POOL" 
    else 
 		#echo -e "position $(( $MN_QUEUE_LENGTH - $MN_QUEUE_POSITION )) in $MN_QUEUE_LENGTH\n $i Hours --> in SELECTION PENDING" 
 		printf "masternode $MNADDR position in SELECTION PENDING\n[########################################|SELECTION POOL]\n ${_done// / }"   	
	fi
else
    echo "is not in masternode list"
fi
echo
