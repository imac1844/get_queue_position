#!/bin/bash
#works in cron well!
./dash-cli masternodelist full > ./tmp/cached_mnlistfull

MN_LIST=$(cat ./tmp/cached_mnlistfull)
MNADDR=$1

IFS=. ; set  -- $* ; 
DEC_ADDR=$(echo $(( ($1*256**3) + ($2*256**2) + ($3*256) + ($4) )) )
#echo "$DEC_ADDR"
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

echo "$SORTED_MN_LIST" > ./tmp/mnlist_sorted
echo "$SORTED_MN_LIST" | grep $MNADDR | awk '{print $9 " " $4}' > tmpfile
while read LINE;
do 
	grep  "$LINE" | awk -F':' '{print $1}' 
	IFS=. ; set -- $*	
	IP_DEC=$(echo $(( ($1*256**3) + ($2*256**2) + ($3*256) + ($4) )) )
	if [ $DEC_ADDR -eq $IP_DEC ]
	then
		PubKey=$(echo -e "$LINE"  | awk '{print $2}' | cut -c26-34 )
	fi
done < tmpfile
#echo "PubKey=$PubKey"

echo "$SORTED_MN_LIST" > ./tmp/mnlist_sorted

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


# TOTAL_MN_IN_QUEUE=$(echo "$SORTED_MN_LIST" | wc -l)
# MN_QUEUE_POSITION=$(echo "$SORTED_MN_LIST" | grep -B9999999 $MNADDR | wc -l)
# MN_VISIBLE=$((MN_QUEUE_POSITION > 0))
# SELECTION_LENGTH=$(( $TOTAL_MN_IN_QUEUE / 10 ))
# LENGTH_QUEUE_TO_POOL=$(( $TOTAL_MN_IN_QUEUE - $SELECTION_LENGTH ))
# MN_QUEUE_IN_SELECTION=$(( $MN_QUEUE_POSITION >= $LENGTH_QUEUE_TO_POOL ))
# percent=$(echo "scale=2;100*$MN_QUEUE_POSITION/$LENGTH_QUEUE_TO_POOL" | bc -l )
# #MN_QUEUE_DATA=$(echo "$SORTED_MN_LIST" | grep $MNADDR)
# echo = "MN_QUEUE_DATA = $MN_QUEUE_DATA"
# MN_PAY_BLOCK=$(echo "$MN_QUEUE_DATA" | awk '{print $8}')
# LAST_MN_IN_QUEUE_TO_POOL=$(echo "$SORTED_MN_LIST" | sed -n "$(( $LENGTH_QUEUE_TO_POOL-1 ))"p | awk '{print $8, $9}')
# FIRST_BLOCK_IN_POOL=$(sed -n "$LENGTH_QUEUE_TO_POOL"p  ./tmp/mnlist_sorted | awk '{print $8}')
# LAST_PAID_MN_FIRST_IN_POOL=$(sed -n "$LENGTH_QUEUE_TO_POOL"p  ./tmp/mnlist_sorted | awk '{print $10}')
# AVG_TIME_FIND_BLOCK=$(echo "$LAST_PAID_MN_FIRST_IN_POOL / $LENGTH_QUEUE_TO_POOL * 100" | bc -l | awk '{print int($1+0.5)}') 
# MN_TIME_about_POOL=$(echo "($FIRST_BLOCK_IN_POOL  - $MN_PAY_BLOCK) * $AVG_TIME_FIND_BLOCK / 100" | bc -l | awk '{print int($1+0.5)}')
# # 
# echo  -n "Now  "   
# date
# echo "TOTAL_MN_IN_QUEUE = $TOTAL_MN_IN_QUEUE"
# echo "MN_QUEUE_POSITION = $MN_QUEUE_POSITION"
# echo "MN_QUEUE_POSITION_from_BOOTON = $(( $TOTAL_MN_IN_QUEUE - $MN_QUEUE_POSITION )) "
# echo "SELECTION_LENGTH = $SELECTION_LENGTH"
# echo "LENGTH_QUEUE_TO_POOL = $LENGTH_QUEUE_TO_POOL"
# #MN_Pubkey=$(echo "$MN_QUEUE_DATA" | awk '{print $4}')
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
# 



#########################


#MN_ADDR_12DIG=`echo "$MNADDR" | grep -o -E '([0-9]*\.|[0-9]*)' | awk '{printf( "%03d\n", $1)}' | tr '\n' '.' | sed 's/.$//'`
#echo "MN_ADDR_12DIG = $MN_ADDR_12DIG"


# cat tmpfile | while read line
# do 
# 	IP_DEC=$(echo "$line" | awk '{print $1}' | tr . '\n' | awk '{s = s*256 + $1} END{print s}') 
# 	echo "IP_DEC=$IP_DEC"
# 	if [ "$IP_DEC" = "$DEC_ADDR" ]
# 	then 
# 		echo "IP_DEC=$IP_DEC"
# 		PubKey=$(echo "$line"  | awk '{print $2}')
#  		echo "PubKey=$PubKey"
# 	else
# 		echo "IP_DEC NO"
# 	fi
# done






	

#	IP_DEC=$(echo "$line" | awk '{print $1}' | grep -oE '\b[0-9]{1,3}(\.[0-9]{1,3}){3}\b'

#echo "$SORTED_MN_LIST" | grep $MNADDR | awk '{print $9" "$4}' > tmpfile	
	
# 	IFS=.
# 	set -- $*
# 	echo $(( ($1*256**3) + ($2*256**2) + ($3*256) + ($4) )) )
# 	echo "IP_DEC=$IP_DEC"
# 	if [ "$IP_DEC" = "$DEC_ADDR" ]
# 	then 
# 		echo "IP_DEC=$IP_DEC"
# 		PubKey=$(echo "$line"  | awk '{print $2}')
#  		echo "PubKey=$PubKey"
# 	else
# 		echo "WRONG_IP"
# 	fi
# done
# 
# echo 199.247.7.83 | tr . '\n' | awk '{s = s*256 + $1} END{print s}'
# 
# exit

# 
# if ($IP_DEC == 0)  {
#  	PubKey=$(echo "$line"  | awk '{print $2}')
#  	echo "PubKey=$PubKey"
#  	}
#  	
#MN_QUEUE_DATA=$(echo "$SORTED_MN_LIST" | grep $MNADDR | awk '{print $9}') 
# MN_QUEUE_DATA=$(echo "$SORTED_MN_LIST" | grep $MNADDR | awk '{print $9}')
#echo "$MN_QUEUE_DATA"


#echo 104.238.189.228 | tr . '\n' | awk '{s = s*256 + $1} END{print s}'

# Number -> IP address: (export ip=1113984275; for i in {1..4}; do s='.'$((ip%256))$s && ((ip>>=8)); done; echo ${s:1})

# exit
# echo "$MN_QUEUE_DATA" | grep  -o -E '([0-9]*\.|[0-9]*)' | awk  '{printf( "%03d\n", $1)}' | tr '\n' '.' | sed 's/.$//' > tmpfile2
# echo "$PADIP"
# exit
# PADIP=`echo "$MN_QUEUE_DATA" | grep  -o -E '([0-9]*\.|[0-9]*)' | awk '{printf( "%03d\n", $1)}' | tr '\n' '0' | sed 's/.$//'`


# echo "$SORTED_MN_LIST" > ./tmp/mnlist_sorted
# MN_Pubkey=$(echo "$SORTED_MN_LIST" | awk  -F '/${MNADDR.\/}/ { print $4 }')
# MN_Pubkey=$(echo "$SORTED_MN_LIST" | awk '{sub(/.$/,"",$9); print $9","$4}')
# awk 'f{sub(/.$/,"",$1); print $1}
# awk '{sub(/\.$/,"",$1); print $1","$5}'
# echo "MN_Pubkey = $MN_Pubkey"

# When you use a string to hold an RE (e.g. "\.") the string is parsed twice - once when the script is read by awk and then again when executed by awk. The result is you need to escape RE metacharacters twice (e.g. "\\.").
# 
# The better solution in every way is not to specify the RE as a string but specify it as an RE constant instead using appropriate delimiters, e.g. /\./:
# 
# awk 'BEGIN {OFS=FS="\t"} {gsub(/\./,"",$4);gsub(/\./,"",$5)}1' input
# exit

# -e 's/,//g'