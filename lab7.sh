#!/bin/bash

path=""		#variable storing the path to the file with the listed folder
option=0	#variable storing user selection
touch /tmp/results.txt	#creation of a file in the temporary files folder in which the results of individual operations are stored
echo "The result file of the programme operation:" > /tmp/results.txt #file is overwritten just in case the previous program run was not terminated by command number 8, so that the result file is not deleted from the /tmp folder
if [ $# -gt 1 ]; then	#a condition that checks whether the user has sent more than one parameter
	echo "Incorrect number of parameters"
	exit 1
else
	if [[ "$1" =~ ^s[0-9]{6}$ ]]; then		#a condition that checks whether the first parameter is a valid index
		index="$1"
	elif [ "$1" == "-v" ]; then			#condition checking whether the user has invoked the program with the -v parameter
		echo "Program version: 1.0"
		echo "Last updated: 20.01.2022."
		exit 0
	elif [ "$1" == "" ]; then	#if no parameter is passed, the index of the user starting the program is taken
		index=$(whoami)
		echo "The index number of the initiator was taken"
	else				#in any other case, the program has been invoked incorrectly and will terminate
		echo "Incorrectly sent parameter"
		exit 1
	fi
fi
echo ""
echo "Enter the command number, without a dot, to select what you want to do:"
while [ $option -ne 8 ]; do	#the program will repeat itself until the user exits it with command number 8
	echo ""
	echo ""
	echo "1. Index number: $index"
	echo "2. Path to the data file: $path"
	echo "3. Verify the information in the data file"
	echo "4. Display the total number of students"
	echo "5. Display the total time logged on since the beginning of the semester"
	echo "6. Numerically display the home folder permissions of the currently logged in users"
	echo "7. Save your results in a text file"
	echo "8. Exit"
	echo "Enter the number of the command you want to execute:"
	read option	#retrieving the user's choice as to which command to invoke
	echo ""
	while ! [[ $option =~ ^[1-8]$ ]]; do
		echo "Incorrectly stated command, try again:"
		read option
	done
	echo ""
	echo ""
	case $option in		#case, which selects the appropriate commands based on the command number specified by the user	
	1)
		echo "Enter the new index number:"
		read i
		if [[ "$i" =~ ^s[0-9]{6}$ ]]; then	#the index will not be set if entered incorrectly
			index="$i"
		else
			echo "Incorrectly stated index"
		fi
	;;
	2)
		echo "Specify the path to the data file:"
		read p
		if [ -f "$p" ]; then	#the path will not be set if the specified file does not exist or if it is not a regular file
			path="$p"
		else
			echo "Such a file does not exist"
		fi
	;;
	3)
		if [ "$path" != "" ]; then	#the file will only be displayed if a valid path to this file has been previously specified
			echo "File content:" | tee -a /tmp/results.txt	#tee -a for some commands saves the result immediately to the file /tmp/results.txt created at the beginning of the program
			cat "$path" | tee -a /tmp/results.txt
			echo ""
			if [ "$(cat $path | egrep '^[dlcbsp-][rwx-]{9}')" != "" ]; then	#the conditional statement determines whether the file contains a list of files with attributes based on whether the permissions are given in the file 
				echo "The file contains a list of files with attributes" | tee -a /tmp/results.txt
			else
				echo "There is no information on file attributes in the file" | tee -a /tmp/results.txt
			fi
			if [ "$(cat $path | egrep '(^\..*$)|( \..*$)')" != "" ]; then #the conditional statement determines whether the file contains an index of files including hidden files, based on whether there are names starting with a dot in the file
				echo "Hidden files are included in the file:" | tee -a /tmp/results.txt
				cat "$path" | egrep '(^\..*$)|( \..*$)' | tee -a /tmp/results.txt
			else
				echo "There is no information in the file about hidden files" | tee -a /tmp/results.txt
			fi
		else
			echo "No file path specified" 
		fi
	;;
	4)
		number_of_students=$(ls -l /home | egrep -c 's[0-9]{6}')	#the number of students is determined by the number of student index folders in the /home folder
		echo "Number of students is $number_of_students" | tee -a /tmp/results.txt
	;;
	5)
		h=0	#variables storing the total number of hours and minutes
		m=0
		for t in $(last -s'2021-10-01' "$index" | egrep '\([0-9]{2}:[0-9]{2}\)' | cut -d'(' -f2 | cut -d')' -f1); do	#loop with time as variable, taken out of brackets at the end of the line, after the last command has been called
			hours=${t:0:2}			#this time is split into a variable holding the number of hours and a variable holding the number of minutes
			minutes=${t:3:2}
			if [[ "$hours" =~ ^0[0-9]$ ]]; then	#If the number of hours or minutes is, for example, in the form 05, these conditional intructions convert this value to 5 itself
				hours=${hours:1:1}
			fi
			if [[ "$minutes" =~ ^0[0-9]$ ]]; then
				minutes=${minutes:1:1}
			fi
			h=$(($h+$hours))	#the time from each iteration of the loop is added to the variables storing the total number of hours and minutes
			m=$(($m+$minutes))
			if [ $m -ge 60 ]; then	#if the number of minutes equals or exceeds 60, one hour shall be added and 60 subtracted from the number of minutes so that the time is written in human terms
				h=$(($h+1))
				m=$(($m-60))
			fi
		done
		echo "The total login time of a user with index $index is $h hours and $m minutes" | tee -a /tmp/results.txt
	;;
	6)
		for user in $(who | cut -d' ' -f1); do					#a loop with the name of the user as a variable, among the logged in users listed in the who command
			permissions=$(ls -l /home | grep "$user" | cut -d' ' -f1)	#for a user in a given iteration of the loop, the permissions of his home folder are extracted
			n_per=""							#variable that will hold a numeric record of the user's home folder permissions
			for (( i=1; i<=7; i=i+3 )); do	#a loop in which all three permission groups (for the owner, for the group and for the rest of the users) will be taken into account separately
				per=${permissions:$i:3}
				np=0
				if [ "${per:0:1}" == "r" ]; then	#on the basis of the individual entitlements, a number is calculated which determines the entitlement for the owner, the group or the rest 
					np=$(($np+4))
				fi
				if [ "${per:1:1}" == "w" ]; then
					np=$(($np+2))
				fi
				if [ "${per:2:1}" == "x" ]; then
					np=$(($np+1))
				fi
				n_per="${n_per}${np}"		#at the end of each iteration of this nested loop, the calculated number is appended to the variable that holds the numerical record of the folder permissions
			done
			echo "/home/$user --> $n_per" | tee -a /tmp/results.txt	#finally, the path of the home folder and its permissions are displayed for each logged-in user
		done
	;;
	7)
		cp /tmp/results.txt $(pwd)	#if the user chooses number 7, the resulting file from the /tmp folder will be copied to the current folder where the user is located
		echo "The result file was saved in the folder: $(pwd)/results.txt"
	;;
	8)
		rm /tmp/results.txt	#during program shutdown, the results.txt file is deleted from the /tmp folder
	;;
	esac
done
