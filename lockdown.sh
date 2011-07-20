#!/bin/bash

# Script to lock down a Fedora based Linux system

### FUNCTIONS ###


# errorExit does exactly that
errorExit(){
	echo It appears you are trying to use this on a system that is not Fedora.
	echo Get out your favorite editor and start contributing to this project!
	exit 999
}

lockdown(){
	
}

echo This script has been created to help lock down Fedora based Linux systems.
if [ -f /etc/redhat-release ]
	then
		grep Fedora /etc/redhat-relase
		if [ $? -eq 0 ]
			then
				errorExit
		else 
			lockdown
		fi
	else
	errorExit
fi