#!/usr/bin/env bash
set -euo pipefail

# ===== 설정값(환경변수로 덮어쓰기 가능) =====
LOG_DIR="${LOG_DIR:-"$HOME/resource-logs"}"            # 로그 디렉터리
BUCKET="${BUCKET:-"your-bucket-ad"}"                  # S3 버킷명
S3_PREFIX="${S3_PREFIX:-"resource-logs/$(hostname)"}"  # S3 prefix (ex: resource-logs/myhost)

# 메일 알림 (mail 또는 mailx 중 있는 도구 사용) - 모든 결과에 대해 메일 보냄
MAIL_TO="${MAIL_TO:-"yourgmail"}"               # 수신자
MAIL_FROM="${MAIL_FROM:-"yourgmail"}"           # Envelope-From / From
MAIL_SUBJECT_PREFIX="${MAIL_SUBJECT_PREFIX:-"[uploader]"}"
MAIL_VERBOSE="${MAIL_VERBOSE:-""}"                     # 1이면 -v

# AWS CLI
AWS_BIN="${AWS_BIN:-"aws"}"
AWS_ARGS=()
[[ -n "${AWS_PROFILE:-}" ]] && AWS_ARGS+=(--profile "$AWS_PROFILE")

mkdir -p "$LOG_DIR"

# ===== 동시 실행 방지 락 =====
exec 9>"$LOG_DIR/.uploader.lock"
flock -n 9 || exit 0

# ===== 도우미 함수 =====
send_alert() {
  local subj="$1" msg="$2"; shift || true
  local vflag=()
  [[ -n "$MAIL_VERBOSE" ]] && vflag=(-v)

  if command -v mail >/dev/null 2>&1; then
    printf '%s\n' "$msg" | mail "${vflag[@]}" -r "$MAIL_FROM" -s "$subj" "$MAIL_TO" || true
  elif command -v mailx >/dev/null 2>&1; then
    printf '%s\n' "$msg" | mailx "${vflag[@]}" -r "$MAIL_FROM" -s "$subj" "$MAIL_TO" || true
  else
    echo "[WARN] mail/mailx 미설치: $msg"
  fi
}

now_human() { date '+%Y-%m-%d %H:%M:%S'; }

# ===== 현재 분 로그는 제외 =====
current="$(date '+%Y%m%d-%H%M').log"
shopt -s nullglob

for path in "$LOG_DIR"/*.log; do
  file="$(basename "$path")"
  [[ "$file" == "$current" ]] && continue

  key="$S3_PREFIX/$file"
  ts="$(now_human)"

  # 1) 업로드
  upload_rc=0
  if ! "$AWS_BIN" "${AWS_ARGS[@]}" s3 cp "$path" "s3://$BUCKET/$key" --only-show-errors; then
    upload_rc=$?
  fi

  if [[ $upload_rc -eq 0 ]]; then
    # 2) 업로드 검증(head-object)
    verify_rc=0
    if ! "$AWS_BIN" "${AWS_ARGS[@]}" s3api head-object --bucket "$BUCKET" --key "$key" >/dev/null 2>&1; then
      verify_rc=$?
    fi

    if [[ $verify_rc -eq 0 ]]; then
      rm -f -- "$path"
      msg="[OK] 업로드 성공
파일: $file
S3:   s3://$BUCKET/$key
호스트: $(hostname)
시각:  $ts"
      echo "$msg"
      send_alert "$MAIL_SUBJECT_PREFIX 성공: $file" "$msg"
    else
      msg="[WARN] S3 검증 실패
파일: $file
S3:   s3://$BUCKET/$key
호스트: $(hostname)
시각:  $ts"
      echo "$msg"
      send_alert "$MAIL_SUBJECT_PREFIX 검증 실패: $file" "$msg"
    fi
  else
    msg="[ERROR] 업로드 실패(rc=$upload_rc)
파일: $file
S3:   s3://$BUCKET/$key
호스트: $(hostname)
시각:  $ts"
    echo "$msg"
    send_alert "$MAIL_SUBJECT_PREFIX 업로드 실패: $file" "$msg"
  fi
done