#!/bin/bash

CLOUDFRONT_IP_RANGES_FILE_PATH="/etc/nginx/shared_server.conf.d/realip.conf"

CLOUDFRONT_REMOTE_FILE="https://ip-ranges.amazonaws.com/ip-ranges.json"
CLOUDFRONT_LOCAL_FILE="/var/tmp/cloudfront-ips"

if [ -f /usr/bin/fetch ];
then
    fetch $CLOUDFRONT_REMOTE_FILE --no-verify-hostname --no-verify-peer -o $CLOUDFRONT_LOCAL_FILE --quiet
else
    wget -q $CLOUDFRONT_REMOTE_FILE -O $CLOUDFRONT_LOCAL_FILE --no-check-certificate
fi

echo "# Amazon CloudFront IP Ranges" > $CLOUDFRONT_IP_RANGES_FILE_PATH
echo "# Generated at $(date) by $0" >> $CLOUDFRONT_IP_RANGES_FILE_PATH
echo "" >> $CLOUDFRONT_IP_RANGES_FILE_PATH


# Parse json and extract CLOUDFRONT IP ranges
RANGES=$(cat $CLOUDFRONT_LOCAL_FILE | jq -r '.prefixes[] | select(.service=="CLOUDFRONT") | .ip_prefix')

# Loop through the ranges, adding each to the file
while read -r line; do
    echo "set_real_ip_from $(line);" >> $CLOUDFRONT_IP_RANGES_FILE_PATH
done <<< "$RANGES"

echo "" >> $CLOUDFRONT_IP_RANGES_FILE_PATH

echo "# ELB IP Ranges" >> $CLOUDFRONT_IP_RANGES_FILE_PATH
echo "set_real_ip_from  10.0.0.0/8;" >> $CLOUDFRONT_IP_RANGES_FILE_PATH
echo "" >> $CLOUDFRONT_IP_RANGES_FILE_PATH

echo "real_ip_header X-Forwarded-For;" >> $CLOUDFRONT_IP_RANGES_FILE_PATH
echo "real_ip_recursive on;" >> $CLOUDFRONT_IP_RANGES_FILE_PATH
echo "" >> $CLOUDFRONT_IP_RANGES_FILE_PATH

rm -rf $CLOUDFRONT_LOCAL_FILE
