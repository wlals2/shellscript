#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="${LOG_DIR:-"$HOME/resource-logs"}"   # 로그 저장 디렉터리
DISK_MOUNT="${DISK_MOUNT:-"/"}"              # 디스크 사용률을 볼 마운트 지점
HOST="${HOSTNAME:-$(hostname)}"

mkdir -p "$LOG_DIR"

# 초기 CPU 누적치 샘플
read -r _ u n s i io irq si st g gn < /proc/stat
prev_idle=$((i + io))
prev_non_idle=$((u + n + s + irq + si + st))
prev_total=$((prev_idle + prev_non_idle))

while true; do
  sleep 5

  # 현재 CPU 누적치 샘플
  read -r _ u n s i io irq si st g gn < /proc/stat
  idle_all=$((i + io))
  non_idle=$((u + n + s + irq + si + st))
  total=$((idle_all + non_idle))

  diff_total=$((total - prev_total))
  diff_idle=$((idle_all - prev_idle))
  cpu_usage=$(awk -v dt="$diff_total" -v di="$diff_idle" 'BEGIN{ if (dt>0) printf "%.1f", (1 - di/dt)*100; else print "0.0"}')

  mem_usage=$(awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END { if (t>0) printf "%.1f", (1 - a/t)*100; else print "0.0"}' /proc/meminfo)
  disk_usage=$(df -P "$DISK_MOUNT" | awk 'NR==2{gsub("%","",$5); printf "%.1f",$5}')

  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  out="$LOG_DIR/$(date '+%Y%m%d-%H%M').log"
  printf '%s host=%s cpu=%.1f%% mem=%.1f%% disk=%.1f%% mount=%s\n' \
         "$ts" "$HOST" "$cpu_usage" "$mem_usage" "$disk_usage" "$DISK_MOUNT" >> "$out"

  prev_total=$total
  prev_idle=$idle_all
done

read -rp "화면 출력으로 실행하시겠습니까? (Y/N): " answer

case "$answer" in
  [Yy])
    echo "리소스 로거를 실행합니다..."
    nohup LOG_DIR=/var/log/resource-logger DISK_MOUNT=/ /usr/local/bin/logger.sh >/dev/null 2>&1 &
    echo "실행 완료. 로그는 /var/log/resource-logger 에 저장됩니다."
    ;;
  [Nn])
    echo "실행을 취소했습니다."
    ;;
  *)
    echo "잘못된 입력입니다. Y 또는 N 을 입력해주세요."
    ;;
esac