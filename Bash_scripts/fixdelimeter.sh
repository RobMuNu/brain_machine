#!/usr/local/bin/bash
# 13/10/19
# for forward time
# This file converts all ';' delimiters in the *_state_series to ',' instead just so Matlab can fukin read it.
# # # Input
# 3900ish _state_series files
#
# # # Output
# *_comma files (forward time here_

for fly in 1 #loop over 13 flies.
do
	for a in {1..2} #loop over awake1 asleep2
	do
		for lam in {2..11} #loop over 10 history lengths	
		do
			for ch in {1..15} #loop over 15 channels
			do
				filename=fly"$fly"ch"$ch"a"$a"lam"$lam" # "$filename"
				echo 'attempting delimiter for '"$filename"' ok here we go'
				###

				#Check that the *_state_series file exists so can fix delimiter. If it does not exist we skip to the next fly/ch/a/lam file.
				# else skip
				if [ -f "$filename"_state_series ] #if the _state_series file exists
				then
					sed -i -e 's/;/,/g' "$filename"_state_series

					echo "$filename"' forward time comma delimit was a success.'
					echo 
				else
					echo "$filename"_state_series" did not exist. Skipping to the next file"
					echo "$filename" >> skippedcomma.txt # files in here didn't exist

					echo
				fi 	#end if statement over file existing
	
			done
		done
	done
done

#end loop over fly ch a lam

echo 'ALL DONE'