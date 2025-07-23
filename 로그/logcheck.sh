#!/bin/bash

if grep -i "error" /var/log/syslog > /tmp/error.log; then
	if [ -s /tmp/error.logs ]; then
		mail -s "에러 로그 발견" fw4568@naver.com < /tmp/errors.log
	fi
fi
