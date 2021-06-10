#!/bin/bash
#Subin Gyawali

# -------------------------------------USER GUIDE-------------------------------------

# o	Navigate to the directory of file using cd command
# o	Run the program with command: bash manange.sh or ./run.sh
# o	Press ‘x’ as input anywhere in the program to exit the program

# o	Press 1 to enter Archive Management Console

# 		Press 1 to Set up archive cron settings
# 		•	A window will open allowing you to enter timings for the cron job. 
# 			Enter minute, hour, day of month, month and day of week based on your requirement
# 		•	A window will open allowing you to choose source folder or the folder you want to archive
# 		•	A window will open allowing you to choose destination folder to keep the archived file
# 		•	A window will open allowing you to enter the  name of the archived file without any extension
# 		•	The program will set up a cron job and will archive the chosen files on specified 
# 			time and will show a notification each time after archiving

# 		Press 2 to clear all existing crontab jobs for the user
# 		•	The program clears all the existing cron jobs for the user
# ------------------------------------------------------------------------------------

# Clearing all previous tput config
tput sgr0 
# clearing the screen at the starting of the program
tput clear

# Defining variable to store position for success messages
successX=8
# Defining regex strings to compare to input values for verification
nameRegex='^[a-z|A-Z|" "]+$'
usernameRegex='^[a-z|A-Z|0-9]+$'
passRegex='^[a-zA-Z0-9~@#$^*()_+={}|\\,.?:-]+$'

# Creating a function check to check if the given input was x
# exiting the application if yes
check (){
	if [ $1 = x ] 
	then 
      # clearing the screen and clearing all set tput properties
		tput clear 
		tput sgr0 
		exit
	fi
}

# Creating function checkFunction to check if the input value was x
# and running the respective function 
checkFunction(){
	if [ $1 = x ] 
	then 
      # clearing the screen and clearing all set tput properties
		tput clear 
		tput sgr0 
		$2
	fi
}
# CHECK FUNCTION AND CHECK HAVE BEEN CALLED IN MANY PLACES IN THE PROGRAM TO CHECK IF THE PROVIDED INPUT IS 'X' 
# THE FIRST PARAMETER DEFINES THE INPUT VALUE WHEREAS THE SECOND PARAMETER DEFINES THE FUNCTION TO BE EXECUTED
# IF 'X' WAS PRESSED 

# Creating a function to greet when each option is selected
greetFunction(){
	# Clears the screen
	clear	
	# Greetings
	tput cup 2 20
	tput rev
	echo " $1 "
	tput sgr0
}
# GREET FUNCTION HAS BEEN CALLED IN MANY PLACES IN THE PROGRAM 
# TO GREET AT THE START OF THE SPECIFIC SECTION OF THE PROGRAM
# IT TAKES THE STRING TO BE DISPLAYED AS ARGUMENT

# Defining function showError to show erros on the zenity window
showError(){
	tput sgr0
	zenity --error --no-wrap --title="Input Error" --text="$1"
}

# Defining function showMessage to show Info Messages on the zenity window
showMessage(){
	tput sgr0
	zenity --info --no-wrap --title="Message" --text="$1"
}

# SHOW ERROR AND SHOW MESSAGE FUNCTIONS HAVE BEEN CALLED IN MANY PLACES IN THE PROGRAM
# TO SHOW THE ERROR AND MESSAGE RESPECTIVELY
# BOTH THE FUNCTIONS TAKE THE STRING TO BE DISPLAYED AS ARGUMENT
# THE ZENITY PACKAGE HAS BEEN USED TO SHOW THE ERRORS AND MESSAGES IN THE WINDOW

# Creating a Function archiveManager to handle archive management
archiveManager(){
	clear
	# Greetings
	tput cup 2 20
	tput setab 1
	tput bold
	echo " WELCOME TO ARCHIVE MANAGER "
	tput sgr0

	# Displaying initial options to choose from at the start of the program for archive management
	tput cup 5 20 
	echo 1. Set Up Archive Settings
	tput cup 6 20 
	echo 2. Clear All Cron Jobs
	tput cup 7 20
	echo x To Exit From Anywhere

	tput bold 
	tput setaf 4
	tput cup 9 20 
	# Reading the choosen option value in the variable option
	read -p "Enter Your Choice: " option 
	tput sgr0

	# Validating the value of option variable
	# taking actions based on chosen value
	if [[ $option =~ [1-2]|[x] && $option -lt 3 ]]
	then
		# calling check function to check if the option value is equal to 'x'
		check $option
		
		if [ $option -eq 1 ]
		then
			# calling setUpArchive finction to set up crontab archive parameters
			setUpArchive
		elif [ $option -eq 2 ]
		then
			# Calling clearArchive function to clear all previous archive for the current user
			clearArchive
		fi
	else 	
		# Rerunning the archiveManager similar to restarting the program
		archiveManager
	fi
}

# Creating a function setUpArchive to set the archive and crontab settings
setUpArchive(){
	greetFunction "Set Up Archive Settings"

	# Showing zenity form window to allow user to select minute, hour, day of month, month and day of week to place a crontab job
	timeString=$(zenity --forms --title="Set Up Archive Settings" --width 400 --height 350 --text="Enter The Allowed Values In The Fields\nPlease Enter * To Skip The Input Field\n * Indicates any Value\n" \
   --add-entry="Minute [0-59]     " \
   --add-entry="Hour [0-23]     " \
   --add-entry="Day Of Month [1-31]     " \
   --add-entry="Month [1-12]     " \
   --add-entry="Day Of Week [0-6]     " \ )

	# Setting global delimiter variable 'IFS' to '|' to split the string using '|'
   	IFS="|"
	# Appending the pieces of splitted string to an array formValues
	read -a formValues <<< "$timeString"
	# Resetting the value of IFS
	IFS=" "

	# Checking if any one of the field in the form was left blank
	if [ ${#formValues[@]} -eq 5 ]
	then
		# Using while loop to check if any of the input field was supplied with values other than numbers and a '*'
		# Setting counter variable to execute while loop
		counter=0;
		crontabTime=""
		while [ $counter -lt ${#formValues[@]} ]
		do
			crontabTime="$crontabTime ${formValues[$counter]}"
			# checking for valid values
			if [[ ! ${formValues[$counter]} = "*" && ! ${formValues[$counter]} =~ ^[0-9]*$ ]]
			then
				# Showing error if incorrect values were supplied
				showError "Values Can't Be Other Than Numbers and '*'."
				# Breaking the loop when incorrect value is identified
				break
			fi
			# Incrementing counter variable
			counter=$((counter+1))
		done

		if [ $counter -lt 5 ]
		then
			# Rerunning the function to allow user to reenter the values
			setUpArchive
		fi

		if [[ ! ${formValues[0]} = "*" ]]
		then
			# Checking values' validity for minute field
			if [[ ${formValues[0]} -gt 59 || ${formValues[0]} -lt 0 ]]
			then
				# Showing error and rerunning the function
				showError "Minute Value Cannot be Less Than 0 or Greater Than 59."
				setUpArchive
			fi	
		fi
			
		if [[ ! ${formValues[1]} = "*" ]]
		then
			# Checking values' validity for hour field
			if [[ ${formValues[1]} -gt 23 || ${formValues[1]} -lt 0 ]]
			then
				# Showing error and rerunning the function
				showError "Hour Value Cannot be Less Than 0 or Greater Than 23."
				setUpArchive
			fi
		fi

		if [[ ! ${formValues[2]} = "*" ]]
		then
			# Checking values' validity for day of month field
			if [[ ${formValues[2]} -gt 31 || ${formValues[2]} -lt 1 ]]
			then
				# Showing error and rerunning the function
				showError "Day Of Month Value Cannot be Less Than 1 or Greater Than 31."
				setUpArchive
			fi
		fi

		if [[ ! ${formValues[3]} = "*" ]]
		then
			# Checking values' validity for month field
			if [[ ${formValues[3]} -gt 12 || ${formValues[3]} -lt 1 ]]
			then
				# Showing error and rerunning the function
				showError "Month Value Cannot be Less Than 1 or Greater Than 12."
				setUpArchive
			fi 
		fi
		
		if [[ ! ${formValues[4]} = "*" ]]
		then
			# Checking values' validity for day of week field
			if [[ ${formValues[4]} -gt 6 || ${formValues[4]} -lt 0 ]]
			then
				# Showing error and rerunning the function
				showError "Day Of Week Value Cannot be Less Than 0 or Greater Than 6."
				setUpArchive
			fi
		fi
		
		# Getting source folder path using setSourcePath function
		source=$(setSourcePath)
		# Getting destination folder path using setDestPath function
		dest=$(setDestPath)
		# Getting name of the zipped file name using setFileName function
		fileName=$(setFileName)

		# Setting new crontab to take inputs from a text file
		crontab -l > cron.txt

		# Appending cron jobs to the specified text file
		# Cron job to archive files and folders from the selected folder to the selected folder
		echo "$crontabTime tar -czf $dest/$fileName.tar.gz $source" >> cron.txt
		# Cron job to show notification each time when the archiving is performed
		echo "$crontabTime export DISPLAY=:0 && notify-send -t 8000 'Files Archived Successfully' 'Files and Folders in $source Have Been Backed Up and Stored in $dest'" >> cron.txt
		# Creating log file for the each archive
		echo "$crontabTime printf 'Crontab Archive Log\n\nSource Folder: $source\n\nDestination Folder: $dest\n\nList Of Archived Files\n\n' > $dest/cron-log.txt" >> cron.txt
		# Listing all the backed up files in the log file
		echo "$crontabTime ls -l '$source' >> $dest/cron-log.txt" >> cron.txt
		# Displaying archive time and date in the log file
		echo "$crontabTime printf '\n\nArchived On: ' >> $dest/cron-log.txt" >> cron.txt
		echo "$crontabTime date >> $dest/cron-log.txt" >> cron.txt
		# Setting crontab with the contents in the test file
		crontab cron.txt
		# Clearing screen and showing tab message again
		greetFunction "Set Up Archive Settings"
		# Showing confirmation message
		showMessage "Crontab Job Added Successfully."
		# Removing text file after adding the content to the crontab
		rm cron.txt
		# Prompting user to allow choose if he/she wants to continue with the program 
		reRunArchive
		
	else
		showError "Field Names Can't Be Empty and\nCan't Include Characters Other Than Numbers and '*'."
		# Rerunning the function
		setUpArchive
	fi
}

# Creating function clearArchive to clear all crontab jobs for the current user
clearArchive(){
	# Placing system error message at proper place using tput
	tput cup 11 20
	tput setaf 1
	# Clearing all cron jobs for the current user
	crontab -r
	# Showing confirm window
	showMessage "All Crontab Jobs Were Cleared Successfully."
	# Prompting user to allow choose if he/she wants to continue with the program 
	reRunArchive
}

# Creating setSourcePath fucntion to allow user to select source path for archiving
setSourcePath(){
	# Showing zenity window to allow select source folder for archiving
	source=$(zenity --file-selection --title="Choose Folder to Archive (Source)" --directory)

	# Checking if the folder is selected
	if [ -z "$source" ]
	then
		# Showing error and rerunning the function if folder was not selected
		showError "Source Path Can't Be Empty"
		setSourcePath
	else
		# returning selected path
		echo "$source"
	fi
}

# Creating function setDestPath to allow user to select destination path to place the archived zip
setDestPath(){
	# Showing zenity window to allow select destination folder for place archived zip
	dest=$(zenity --file-selection --title="Choose Folder to Place Archived File (Destination)" --directory)

	# Checking if the folder is selected
	if [ -z "$dest" ]
	then
		# Showing error and rerunning the function if folder was not selected
		showError "Destination Path Can't Be Empty"
		setSourcePath
	else
		# returning selected path
		echo "$dest"
	fi
}

# Creating fucntion setFileName to allow user to enter the file name for the zip
setFileName(){
	# Showing zenity window to allow user to enter file name for zipped file
	fileName=$(zenity --entry --title="Enter File Name" --text="Enter Zip File Name Without Extension\n")
	
	# Checking if the entered file name is valid
	if [[ $fileName =~ $usernameRegex ]]
	then
		# returning entered fileName
		echo $fileName
	else
		# Showing error and rerunning fucntion
		showError "File Name Can't Be Empty And\nCan't Include Spaces and Special Characters."
		setFileName
	fi
}

# Creating reRun function to ask the user if he/she wants to rerun the program
# and taking actions based on chosen option
reRunArchive(){
	# Modifying position to adjust text position
	tput cup 13 20
	tput bold
	tput setaf 4

	# reading the choosen option in read variable
	read -p "Do You want to continue with the program[y/n] ? " action
	tput sgr0	

	# restarting the program if user chooses 'y'
	if [ $action = y ]
	then		
		# callinfg archiveManager function if user selects to be in the program
		archiveManager
	else
		# Getting the file name of current file and re-executing
		./$(basename $0)
	fi
}

# Adjusting text position to greet and show menu at the start of the program
tput cup 2 20
tput rev
tput bold
echo " WELCOME TO ARCRON "
tput sgr0

# Displaying initial options to choose from at the start of the program
tput cup 5 20 
echo 1. Enter Archive Management Console
tput cup 6 20 
echo x To Exit From Anywhere

tput bold 
tput setaf 4
tput cup 9 20 
# Reading the choosen option value in the variable option
read -p "Enter Your Choice: " option 
tput sgr0

# Validating the value of option variable
# taking actions based on chosen value
if [[ $option =~ [1]|[x] && $option -lt 2 ]]
then
	# calling check function to check if the option value is equal to 'x'
	check $option
	
	if [ $option -eq 1 ]
	then
		# calling archiveManager function
		archiveManager
	fi
else 	
	clear    
	# Getting the file name of current file and re-executing if error occurs
	./$(basename $0)
fi

#Subin Gyawali

