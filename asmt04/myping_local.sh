#!/bin/bash
##############################################
# Name: Rodion Yaryy
# Class: CS160B
# Professor: Peter Wood
# Date: 12/14/2015
# File Name: myping
# Description: Script that can run the "ping" command 
#              for several hosts at once and filter its output. 
#              This script is often called a "wrapper" script for ping.
#              syntax: myping  -p npack -h host1  [  host2   host3  ... ] 
##############################################


#export custom $PATH variable
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# This function is designed for universal usage handling. 
usage() {
  echo "syntax: $(basename "$0") myping  -p npack -h host1  [  host2   host3  ... ]" >&2
  exit 1;  
}

# This is a function for better error handling
error() {
  echo "$(basename "$0"): ERROR - $*" >&2
  usage  
  exit 1;  
}

[ "$#" -lt "4" ] && error "not enough arguments";

file=$(mktemp tmp.XXXXXXXXXXXXXXX)

while getopts “p:h:” opt
do
  case $opt in
    p)
      if ! [[ $OPTARG =~ ^-?[0-9]+$ ]] ; then 
        error "-p should be followed by an integer"
      else   
         packages=$OPTARG 
      fi
      ;;   
    h)
      ;;
    \?) 
      usage ;;   
   esac
done 

# make temporary file
file=$(mktemp tmp.XXXXXXXXXXXXXXX)

# After verifying that there are at least 4 arguments and that options are correct, 
# I shift 3 arguments to get to the list of hosts 
shift 3;

# put content in the temporary file
for i in $@; do 
  (ping -c $packages -q $i | tail -3 | tr '\n' ' ') >>$file 2>>$file
  echo ''>>$file
done 


# Display and sort output
cat $file | while read line
do
   if [[ $line == *"round-trip"* ]]; then  
      echo $line | awk '{ print $2 " " $6 " " $12 " " $18 }' | rev | cut -d/ -f2-5 | rev
   fi

   if [[ $line == *"Unknown host" ]]; then
      echo $line | awk '{ print $4 " Unknown host"}' | tr ':' " "
   fi

   if [[ $line == *"100.0% packet loss" ]]; then
      echo $line | awk '{ print $2 " Non-responding host"}' 
   fi   
done | sort -k4.8 -k2  | column -t

# If bash crashes unexpectedly - remove file
trap "rm -f $file" EXIT

# delete the temporary file 
rm $file
