#!/bin/bash

# Monitor MX Record
# This script will check the MX record of a domain name against a predefined value for a given list of domains.
# It will sort the mx records for the domain numerically by priority and use the lowest value.

# Usage
# Make the file executable and copy it into /etc/cron.hourly
# chmod +x monitor_mx_records.sh; mv monitor_mx_records.sh /etc/cron.hourly/monitor_mx_records.sh;
# It assumes that dig is installed (yum install bind-utils, apt install dig -y)

# To check the expected record for a domain e.g. google.com
# dig google.com MX +short | sort -n | head -n1 | awk '{print $NF}' | tr '[:upper:]' '[:lower:]'

# live will send an email
LIVE=1; # yes=1, no=0;

# will send message to this email address
EMAIL=monitor@domain.com;

# MX_RECORDS is an associative array of domain as key and expected mx record as value. MX_RECORDS['domain']='expected_value';
unset MX_RECORDS; # empty array
declare -A MX_RECORDS; # declare associative array

# Add your own domains and expected mx records below below

# Zoho
MX_RECORDS['zoho.com']='smtpin.zoho.com.';

# Office365 / Exchange
MX_RECORDS['microsoft.com']='microsoft-com.mail.protection.outlook.com.';

# Gmail
MX_RECORDS['google.com']='aspmx.l.google.com.';

# Loop through associative array
# DOMAIN is the key
# ${MX_RECORDS[$DOMAIN]} is the value
for DOMAIN in "${!MX_RECORDS[@]}";
do

   MX_RECORD=$(dig $DOMAIN MX +short | sort -n | head -n1 | awk '{print $NF}' | tr '[:upper:]' '[:lower:]');
   EXPECTED_MX_RECORD=${MX_RECORDS[$DOMAIN]};

   # test {MX_RECORD} = $EXPECTED_MX_RECORD && "yes match" || "no match"
   if [ $LIVE -eq 0 ]; then
     echo $MX_RECORD | xargs -I{MX_RECORD} test {MX_RECORD} = $EXPECTED_MX_RECORD && : || echo "Subject: MX record for $DOMAIN, $MX_RECORD does not match $EXPECTED_MX_RECORD";
   elif [ $LIVE -eq 1 ]; then
     echo $MX_RECORD | xargs -I{MX_RECORD} test {MX_RECORD} = $EXPECTED_MX_RECORD && : || echo "Subject: MX record for $DOMAIN, $MX_RECORD does not match $EXPECTED_MX_RECORD" | tee /dev/stderr | sendmail $EMAIL;
   else
     : # do nothing
   fi

done

