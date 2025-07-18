#!/bin/bash
HOST=$(hostname)
DATE=$(date)
echo "Subject: [$HOST] 시스템 상태 리포트" 
echo ""
echo "날짜: $DATE"
echo "===== CPU ====="
top -b -n1 | head -10
echo ""
echo "===== 메모리 ====="
free -h
echo ""
echo "===== 디스크 ====="
df -h
echo ""
echo "===== 네트워크 ====="
ip addr
~

