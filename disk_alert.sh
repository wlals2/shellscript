#!/bin/bash

THRESHOLD=80
EMAIL="fw4568@gmail.com"
DATE=$(date '+%F %T')
HOST=$(hostname)
LOGFILE="/var/log/disk_usage_alert.log"

df -h | grep '^/dev/' | while read -r line; do
	USAGE=$(echo $line | awk '{print $5}' | tr -d '%' )
	PARTITION=$(echo $line | awk '{print $1}')
	ALERT_FLAG="/tmp/diskalert-$(echo $PARTITION | tr '/' '_')"


	if [ "$USAGE" -gt "$THRESHOLD"]; then
		if [ ! -f "$ALERT_FLAG" ]; then
			MSG="Subject: [$HOST][경고] 디스크 용량 초과($USAGE%) - $PARTITION

$DATE 기준 $PAIRTITION 사용률: $USAGE%
---------------------------
$line
"
		echo -e "$DATE [ALERT] $PARTITION 사용량 $USAGE%초과 ($line)" >> $LOGFILE
		echo -e "$MSG" | msmtp "$EMAIL"
		touch "$ALERT_FLAG"
	fi
	else
		[ -f "$ALERT_FLAG" ] && rm -f "$ALERT_FLAG"
	fi
done
