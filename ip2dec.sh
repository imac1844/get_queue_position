#!/bin/bash
ADDR=$1
#DEC_ADDR=$("$ADDR";IFS=. ; set -- $* ; echo $(( ($1*256**3) + ($2*256**2) + ($3*256) + ($4) )) )
echo "$ADDR"
IFS=.
set -- $*
echo $(( ($1*256**3) + ($2*256**2) + ($3*256) + ($4) )) 

#DEC_ADDR=$("$ADDR";IFS=. ; set -- $* ; echo $(( ($1*256**3) + ($2*256**2) + ($3*256) + ($4) )) )

echo "$ADDR" |
    tr . '\n' |
    while read octet; do
        printf "%.08d" $(echo "obase=2;$octet" | bc)
    done |
    echo $((2#$(cat)))