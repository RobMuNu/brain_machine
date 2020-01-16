#!/usr/local/bin/bash
# Last updated by Aidan 25/09/19
# This grabs the initial probability vector (in a column file) and the transition matrix (for each emitted symbol in a new file) from the CSSR output files 
# This is done for each epsilon machine. 3900 epsilon machines * (1+|A|) files. That's a lot of files.

#hardcoded
num_symbols=2 #aka |A| alphabet size # Could undo hardcoding with num_symbols= read info file but meh
f2=" %1s"

# Begin loop over each of $fly $ch $a $lam here to access each fly"$fly"ch"$ch"a"$a"lam"$lam"_**** file
for fly in {1..13} #loop over 13 flies. Replace 13 with $numflies
do
	for a in {1..2} #loop over awake1 asleep2
	do
		for lam in {2..11} #loop over 10 history lengths	
		do
			for ch in {1..15} #loop over 15 channels
			do
				filename=fly"$fly"ch"$ch"a"$a"lam"$lam" # the name of the file I am getting transition info for

				echo 'Running for '"$filename"' ok here we go'
				###

				#Check that the _results file exists. If it does not exist we skip to the next fly/ch/a/lam file.
				# if exist do loop and get the initial probability and transition matrix
				# else skip
				if [ -f "$filename"_results ] #if the file exists
				then
					# Initial probabilities, taken from _results file
					grep 'P(state):' "$filename"_results | cut -d " " -f 2 >> inipi_"$filename" #make a new file with state distribution

					# Number of causal states N
					numstates=$(tail -n 1 "$filename"_info | grep -Eo '[0-9]+$') #This grabs the last line of _info, which reads 'Number of Inferred States: xxx' and grabs the number with grep -- IS CUT FASTER?

					#Create an array (N by N by |A|) of 0s, where N is number of states and |A| is number of symbols in alphabet
					declare -A trans # Or include it into trans[$i,$j,$k] like this
					for ((i=0;i<numstates;i++)) do #iterate from 0 to <numstates so it is N by N, but indexing starts at [0,0] because I have state 0 to state N-1
					    for ((j=0;j<numstates;j++)) do
					    	for ((k=0;k<num_symbols;k++)) do
					        	trans[$i,$j,$k]=0
					        done
					    done
					done

					#here I want to read 4 variables from either _inf.dot or _results file
					#but do this for every possible transition (N * 2)

					# Create a temp file with only useful information from _inf.dot
					tail -n +7 "$filename"_inf.dot > "$filename"_temp #create a temp file that only contains lines 7+ of _inf.dot file

					# Read the important parts (transition probabilities) from that temp file
					while IFS= read -r line; do
						from=$(echo $line |cut -d " " -f 1) #read from, the state that is transitioning from
						to=$(echo $line |cut -d " " -f 3) #read to, the state that is being transitioning to
						symbol=$(echo $line | cut -d " " -f 6 | cut -c 2) #read symbol, the emitted symbol on transition
						prob=$(echo $line |cut -d " " -f 7) #read value for the actual transition probabilty
						trans[$from,$to,$symbol]="$prob"
					#everything else can remain 0
					done < "$filename"_temp

					rm "$filename"_temp #remove _temp file

					# Now print each transition matrix to a file for each symbol
					for ((k=0;k<num_symbols;k++)) do
						for ((i=0;i<numstates;i++)) do
						#    printf "$f1" $j
						    for ((j=0;j<numstates;j++)) do
						       	printf "$f2" ${trans[$i,$j,$k]} >> trans"$k"_"$filename" #two separate files should have NxN matrices - one for each symbol type \\

							done
						    echo >> trans"$k"_"$filename" #goes to a new line after printing each column value in a row

						done
					done

					unset trans # unset the matrix. This is maybe overkill but should be safe
					echo "$filename"' was a success.'
					echo 
				else #when the file does not exist
					echo "$filename"_results" did not exist. Skipping to the next file"
					echo "$filename" >> skipped.txt
					echo
				fi 	#end if statement over file existing
	
			done
		done
	done
done

#end loop over fly ch a lam

echo 'ALL DONE'