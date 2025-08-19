#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-""}"                      # ""(대화형) | "run"
LOG_DIR="${LOG_DIR:-"$HOME/resource-logs"}"
DISK_MOUNT="${DISK_MOUNT:-"/"}"
HOST="${HOSTNAME:-$(hostname)}"

log_loop() {
  mkdir -p "$LOG_DIR"

  # /proc/stat: user nice system idle iowait irq softirq steal guest guest_nice
  read -r _ u n s i io irq si st g gn < /proc/stat
  prev_idle=$((i + io))
  prev_non_idle=$((u + n + s + irq + si + st))
  prev_total=$((prev_idle + prev_non_idle))

  trap 'echo "종료 신호 수신. 로거 종료"; exit 0' INT TERM

  while true; do
    sleep 5

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
}

if [[ "$MODE" == "run" ]]; then
  log_loop
  exit 0
fi

# ===== 대화형 모드 =====
read -rp "백그라운드로 실행하시겠습니까? (Y/N): " answer
case "$answer" in
  [Yy])
    CHOSEN="$HOME/resource-logs"
    mkdir -p "$CHOSEN"

    OUT="$CHOSEN/runner.out"
    echo "리소스 로거를 백그라운드로 실행합니다..."
    nohup env LOG_DIR="$CHOSEN" DISK_MOUNT="$DISK_MOUNT" "$0" run >>"$OUT" 2>&1 &
    echo "✅ 실행 완료 (PID: $!)"
    echo "   데이터 로그: $CHOSEN/YYYYMMDD-HHMM.log"
    echo "   실행 로그   : $OUT"
    ;;
  [Nn])
    echo "실행을 취소했습니다."
    ;;
  *)
    echo "잘못된 입력입니다. Y 또는 N 을 입력해주세요."
    ;;
esac
