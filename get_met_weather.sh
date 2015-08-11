#!/bin/sh


# 12/8/15 Jamie Kiely

#set -x


# Set the config variables

# *************************************************Configuration********************************************************
tmpFilePath="/tmp/tmp_files"
hostname=$(hostname)
date=$(date)



#Check for root user
#Only Root User can run script
if [ "$UID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi


#test if tmp file directory exists if not make it

[ -d $tmpFilePath ] || mkdir $tmpFilePath && chown root $tmpFilePath && chgrp root $tmpFilePath


# **********************************************************************************************************************
#Check if script is running and exit if it is

scriptname=$(basename $BASH_SOURCE)

# Use a lockfile containing the pid of the running process
# If script crashes and leaves lockfile around, it will have a different pid so
# will not prevent script running again.
#
lf=${tmpFilePath}/${scriptname}_pidLockFile
# create empty lock file if none exists
cat /dev/null >> $lf
read lastPID < $lf
# if lastPID is not null and a process with that pid exists , exit
[ ! -z "$lastPID" -a -d /proc/$lastPID ] && exit
echo not running
# save my pid in the lock file
echo $$ > $lf





# **********************************************************************************************************************


rm -rf $tmpFilePath/tmp_errors_$logFileName
rm -rf $tmpFilePath/email_server_$logFileName
rm -rf $tmpFilePath/filtered_tmp_errors_$logFileName




curl http://www.met.ie/latest/reports.asp > /tmp/index.html

#replace relative paths in download

sudo sed -i -r 's/<img src="/<img src="http:\/\/www.met.ie/g' /tmp/index.html
sudo sed -i -r 's/href="\//href="http:\/\/www.met.ie\//g' /tmp/index.html
sudo sed -i -r 's/src="\//src="http:\/\/www.met.ie\//g' /tmp/index.html
sudo sed -i -r 's/url\(\/ssi/url\("http:\/\/www.met.ie\/ssi/g' /tmp/index.html
sudo sed -i -r 's/image:url\(\/images/image:url\(http:\/\/www.met.ie\/images/g' /tmp/index.html


mv /tmp/index.html /var/www/html/mtt-test/
chown apache:apache /var/www/html/mtt-test/index.html 

