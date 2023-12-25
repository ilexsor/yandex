#!/bin/bash

#Check root priveleges, if not - exit
if [[ $EUID -ne 0  ]]; then
	echo "error: Permition denided SUDO needed"
	exit 1
fi

#Show help information
show_help() {
	clear
	echo "DEVOPS SCRIPT(1)"
	echo
	echo "NAME"
	echo "	script.sh - list pretty system information"
	echo 
	echo "SYNOPSIS"
	echo "  	script.sh [OPTION]..."
	echo
	echo "DESCRIPTION"
	echo "	List pretty-formated system information"
	echo
	echo "	Optional arguments"
	echo
	echo "	-h, --help"
	echo "		Shows help"
	echo
	echo "	--host"
	echo " 		Shows pretty-fromated  host stats"
	echo
	echo "  	--user"
	echo "		Shows logged on users"
	echo
}

#Show users information
show_users() {
	clear
	echo "Root users:"
	echo "	$(grep 'x:0:' /etc/passwd | awk -F: '{print $1}')"
	echo
	echo "List of users:"
	echo "$(awk -F: '{print $1}' /etc/passwd)"
	echo
	echo "Logged on users:"
	echo "$(who | awk '{print $1}' | uniq)"
}

#Show system info
show_host_info() {
	clear
	echo "CPU(s): $(lscpu | grep "^CPU(" | awk '{print $2}')"
	echo
	echo "RAM:"
	echo "total: $(lsmem | grep "Total on" | awk -F: '{print $2}')"
	echo "used: $(free -h | grep "Mem" | awk '{print $3}' | sed 's/.$//')"
	echo
	echo "Disk info:"
	echo "$(df -h | grep "^/" | awk 'BEGIN {print "DISK\t\tTOTAL\t USED%"}{printf "%s\t %s\t  %s\n", $1, $2, $5}')"
	echo
	echo "Load average: $(cat /proc/loadavg | awk '{print $1, $2, $3}')"
	echo 
	echo "System time: $(uptime | awk '{print $1}')"
	echo 
	echo "Uptime: $(uptime | awk '{print $2, $3, $4}' | sed 's/.$//')"
	echo
}

show_host_info
#show_help
#show_users
