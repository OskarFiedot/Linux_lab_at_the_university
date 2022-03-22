#!/bin/bash

if [ "$1" == "-h" -o "$1" == "--help" ]; then		#conditional instruction checks if user has requested to display help for this script
	echo "Syntax: ./lab6.sh FOLDER_NAME FILE_NAME FOLDER_PERMISSIONS FILE_PERMISSIONS"
	echo "Description:"
	echo "The script lab6.sh creates a folder, named FOLDER_NAME, with the permissions of FOLDER_PERMISSIONS, then creates a file, named FILE_NAME, in that folder, with the permissions specified in FILE_PERMISSIONS."
	echo "Permissions should be given in numerical form, e.g. 770"
	exit 0
elif [ $# -ne 4 ]; then		#If not, the conditional function checks whether the correct number of arguments were sent. If not, the program terminates. 
	echo "Incorrect number of arguments sent to the program (should be 4)"
	exit 1
elif ! [[ "$3" =~ ^[0-7]{3}$ ]]; then	#conditional instructions that check whether the permissions have been correctly specified
	echo "Incorrectly specified permissions for a folder"
	exit 1
elif ! [[ "$4" =~ ^[0-7]{3}$ ]]; then
	echo "Incorrectly specified file permissions"
	exit 1
fi
#If the user did not ask for help, and if the number of arguments sent and the way the permissions were sent were correct, the program does its job
if ! [ -d "$1" ]; then 
	mkdir "$1"	
	echo "Folder $1 has been created"
else
	echo "Folder $1 already exists"
fi
chmod "$3" "$1"	#Granting permissions to a folder
echo "Permissions $3 has been granted to folder $1"
if ! [[ "$3" =~ ^[37][0-7]{2}$ ]]; then		#Checking whether the permissions granted to a folder allow you to create a file in it
	echo "Folder permissions do not allow to complete the operation"
	exit 0
fi
cd "$1"		#Entry into the created folder
if ! [ -f "$2" ]; then
	touch "$2"	#Create a file with the name that was sent to the program as the second parameter
	echo "A file $2 has been created in the folder $1"
else
	echo "File $2 already exists in folder $1"
fi
chmod "$4" "$2"	#Setting the previously created file, permissions, which were sent to the program as the fourth parameter
echo "File $2 in folder $1 has been assigned permissions of $4"
