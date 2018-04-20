#!/bin/bash
# Author : Teddy Skarin
var MN_QUEUE_POSITION=450
let QUEUE_LENGTH=4000
echo "$MN_QUEUE_POSITION"
# 1. Create ProgressBar function
		function ProgressBar {
# Process data
			
			#echo 3.6 | awk '{print int($1+0.5)}'|
			let _progress=(MN_QUEUE_POSITION*100/QUEUE_LENGTH*100)/100
			let _done=(${_progress}*4)/10
			let _left=40-$_done
# Build progressbar string lengths
			_done=$(printf "%${_done}s")
			_left=$(printf "%${_left}s")
# 1.2 Build progressbar strings and print the ProgressBar line
# 1.2.1 Output example:
# 1.2.1.1 Progress : [########################################] 100%
#printf "\rProgress : [${_done// /|}${_left// /-}] ${_progress}%%"
printf "\r[${_done// /#}${_left// /-}] ${_progress}%%"

		}
# Variables
		_start=1
# This accounts as the "totalState" variable for the ProgressBar function
		_end=100
# Proof of concept
for number in $(seq ${_start} ${_end})
do
	sleep 0.1
	ProgressBar ${number} ${_end}
done
printf '\nFinished!\n'
