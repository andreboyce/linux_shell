#!/bin/bash

# Monitor mx record
# This script will check the mx record of a domain name against a predefined value for a given list of domains.
# It will sort the mx records for the domain numerically by priority and use the lowest value.

# To check the expected record for a domain e.g. google.com
# dig +short google.com MX | sort -n | head -n 1 | awk -F' ' '{print $2}' | tr '[:upper:]' '[:lower:]'

# live will send an email
LIVE=1; # yes=1, no=0;

# will send message to this email address
EMAIL=monitor@domain.com;

# MX_RECORDS is an associative array fo domain as key and expected mx record as value. MX_RECORDS['domain']='expected_value';
unset MX_RECORDS; # empty array
declare -A MX_RECORDS; # declare associative array

# Zoho
MX_RECORDS['zoho.com']='smtpin.zoho.com.';

# Office365 / Exchange
MX_RECORDS['microsoft.com']='microsoft-com.mail.protection.outlook.com.';

# Gmail
MX_RECORDS['google.com']='aspmx.l.google.com.';

# loop through associative array
# DOMAIN is the key
# ${MX_RECORDS[$DOMAIN]} is the value
for DOMAIN in "${!MX_RECORDS[@]}";
do

   MX_RECORD=$(dig +short $DOMAIN MX | sort -n | head -n 1 | awk -F' ' '{print $2}' | tr '[:upper:]' '[:lower:]');
   EXPECTED_MX_RECORD=${MX_RECORDS[$DOMAIN]};

   # test {} = $EXPECTED_MX_RECORD && "match" || "no macth"
   if [ $LIVE -eq 0 ]; then
     echo $MX_RECORD | xargs -I{} test {} = $EXPECTED_MX_RECORD && : || echo "Subject: MX record for $DOMAIN, $MX_RECORD does not match $EXPECTED_MX_RECORD";
   elif [ $LIVE -eq 1 ]; then
     echo $MX_RECORD | xargs -I{} test {} = $EXPECTED_MX_RECORD && : || echo "Subject: MX record for $DOMAIN, $MX_RECORD does not match $EXPECTED_MX_RECORD" | tee /dev/stderr | sendmail $EMAIL;
   else
     : # do nothing
   fi

done

