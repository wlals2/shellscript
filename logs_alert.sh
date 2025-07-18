#!/bin/bash

EMAIL="fw4568@gmail.com"
LOGFILE="/var/log/syslog"
KEYWORDS="error|fail|critical"
TMPFILE="/tmp/log_alert.txt"
OFFSETFILE="/tmp/log_offset.txt"

# 오프셋 파일 없으면 0으로 초기화
if [ ! -f $OFFSETFILE ]; then
    echo 0 > $OFFSETFILE
fi

# 이전 오프셋 가져오기
OFFSET=$(cat $OFFSETFILE)

# 파일 크기(바이트) 측정
FILESIZE=$(stat -c %s $LOGFILE)

# 파일이 더 작아졌으면(로그 rotate된 경우), 처음부터
if [ "$FILESIZE" -lt "$OFFSET" ]; then
    OFFSET=0
fi

# 새로 추가된 부분만 읽기
tail -c +$((OFFSET+1)) $LOGFILE | grep -aEi "$KEYWORDS" > $TMPFILE

# 오프셋(마지막 읽은 위치) 갱신
echo $FILESIZE > $OFFSETFILE

# 내용이 있으면 메일 발송
if [ -s $TMPFILE ]; then
    cat $TMPFILE | msmtp $EMAIL
fi

rm -f $TMPFILE
