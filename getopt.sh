#!/bin/bash

#Check root priveleges, if not - exit
if [[ $EUID -ne 0 ]]; then
	echo "error: Permition denided SUDO needed"
	exit 1
fi

#Show help information
show_help() {
	echo
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
	echo "	--help"
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
	echo
	echo -e "$(tput setaf 1)Root users:$(tput sgr 0)"
	echo -e "\t$(grep 'x:0:' /etc/passwd | awk -F: '{print $1}')"
	echo
	echo -e "$(tput setaf 1)List of users:$(tput sgr 0)"
	echo "$(awk -F: '{print $1}' /etc/passwd)"
	echo
	echo -e "$(tput setaf 1)Logged on users:$(tput sgr 0)"
	echo "$(who | awk '{print $1}' | uniq)"
	echo
}

get_ip_stats() {
interfaces=$(cat /proc/net/dev | grep ":" | awk '{print $1}' | sed 's/.$//')

echo -e "$(tput setaf 2)INT\tSTAT\tIP\t\tRS\tTR\tRS_ERR\tTR_ERR$(tput sgr 0)"

for interface in $interfaces
do
    status=$(ip link | grep $interface: | awk '{print $9}')
    if [[ $interface = "lo" ]]
        then
            ip=$(ip addr | grep $interface | grep inet | grep host | awk '{print $2}')
        else
            ip=$(ip addr | grep $interface | grep inet | awk '{print $4}')
    fi

reseive=$(cat /proc/net/dev | grep $interface | awk '{print $3}')
transmit=$(cat /proc/net/dev | grep $interface | awk '{print $11}')
reseive_err=$(cat /proc/net/dev | grep $interface | awk '{print $4}')
transmit_err=$(cat /proc/net/dev | grep $interface | awk '{print $12}')

echo -e "$(tput setaf 1)$interface$(tput sgr 0)\t$status\t$ip\t$reseive\t$transmit\t$reseive_err\t$transmit_err"

done

}

#Show system info
show_host_info() {
	echo
	echo -e "$(tput setaf 1)CPU(s):$(tput sgr 0) $(lscpu | grep "^CPU(" | awk '{print $2}')"
	echo
	echo -e "$(tput setaf 1)RAM:$(tput sgr 0)"
	echo "total: $(lsmem | grep "Total on" | awk -F: '{print $2}' | sed -e 's/^[[:space:]]*//')"
	echo "used: $(free -h | grep "Mem" | awk '{print $3}' | sed 's/.$//')"
	echo
	echo -e "$(tput setaf 1)Disk info:$(tput sgr 0)"
	echo "$(df -h | grep "^/" | awk 'BEGIN {print "DISK\t\tTOTAL\t USED%"}{printf "%s\t %s\t  %s\n", $1, $2, $5}')"
	echo
	echo -e "$(tput setaf 1)Load average:$(tput sgr 0) $(cat /proc/loadavg | awk '{print $1, $2, $3}')"
	echo 
	echo -e "$(tput setaf 1)System time:$(tput sgr 0) $(uptime | awk '{print $1}')"
	echo 
	echo -e "$(tput setaf 1)Uptime:$(tput sgr 0) $(uptime | awk '{print $2, $3, $4}' | sed 's/.$//')"
	echo
	get_ip_stats
	echo
	echo -e "$(tput setaf 1)Listen ports:$(tput sgr 0)\n$(ss -tulpn | grep LISTEN | awk '{print $5}' | awk -F: '{print $2}')"
	echo
}


#Declare keys for getopt
OPTS=$(getopt -o "" -l "help,host,user" -- "$@")

#Show help if no args
if [[ $# -eq 0 ]]; then
	show_help
	exit 0
fi

#Parse argumetns
eval set -- "$OPTS"

while true; do
	case "$1" in
		--help)
			show_help
			exit 0 ;;
		--host)
			show_host_info
			shift ;;
		--user)
			show_users
			shift ;;
		--)
			break ;;
		*)
			echo "Wrong argument"
			exit 1 ;;
	esac
done	

set --

