#!/usr/bin/env bash
set -euo pipefail

# ---- 설정(환경변수로 덮어쓰기 가능) ----
BUCKET="${BUCKET:-sample-s3-jimin}"
S3_PREFIX="${S3_PREFIX:-uploads/$(hostname)}"
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL: your slack webhook URL
DELETE_ON_SUCCESS="${DELETE_ON_SUCCESS:-}"   # 1 이면 성공 후 로컬 파일 삭제

# ---- 인자 체크 ----
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <file-to-upload>"
  echo "Ex) BUCKET=sample-s3-jimin $0 /path/to/file.txt"
  exit 1
fi

FILE="$1"
if [[ ! -f "$FILE" ]]; then
  echo "[ERR] No such file: $FILE"
  # 실패 알림
  curl -sS -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\":x: 업로드 실패 (파일 없음)\n• 파일: $FILE\n• 호스트: $(hostname)\n• 시각: $(date '+%Y-%m-%d %H:%M:%S')\"}" \
    "$SLACK_WEBHOOK_URL" >/dev/null || true
  exit 2
fi

# ---- S3 키/메타 ----
BASENAME="$(basename "$FILE")"
KEY="$S3_PREFIX/$BASENAME"
SIZE="$(stat -c %s -- "$FILE" 2>/dev/null || echo "?")"

# mime-type 추정(없으면 기본)
if command -v file >/dev/null 2>&1; then
  CT="$(file --brief --mime-type -- "$FILE" 2>/dev/null || echo application/octet-stream)"
else
  CT="application/octet-stream"
fi

# ---- 업로드 ----
if "$AWS_BIN" s3 cp "$FILE" "s3://$BUCKET/$KEY" --only-show-errors --content-type "$CT"; then
  # 검증
  if "$AWS_BIN" s3api head-object --bucket "$BUCKET" --key "$KEY" >/dev/null 2>&1; then
    # 성공 알림
    curl -sS -X POST -H 'Content-type: application/json' \
      --data "{\"text\":\":white_check_mark: 업로드 성공\n• 파일: $BASENAME (${SIZE}B)\n• S3: s3://$BUCKET/$KEY\n• 호스트: $(hostname)\n• 시각: $(date '+%Y-%m-%d %H:%M:%S')\"}" \
      "$SLACK_WEBHOOK_URL" >/dev/null || true

    # 성공 시 삭제 옵션
    if [[ "$DELETE_ON_SUCCESS" == "1" ]]; then
      rm -f -- "$FILE" || true
    fi
    exit 0
  else
    # 검증 실패
    curl -sS -X POST -H 'Content-type: application/json' \
      --data "{\"text\":\":warning: 검증 실패(head-object)\n• 파일: $BASENAME\n• S3: s3://$BUCKET/$KEY\n• 호스트: $(hostname)\n• 시각: $(date '+%Y-%m-%d %H:%M:%S')\"}" \
      "$SLACK_WEBHOOK_URL" >/dev/null || true
    exit 3
  fi
else
  # 업로드 실패
  curl -sS -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\":x: 업로드 실패\n• 파일: $BASENAME (${SIZE}B)\n• 대상: s3://$BUCKET/$KEY\n• 호스트: $(hostname)\n• 시각: $(date '+%Y-%m-%d %H:%M:%S')\"}" \
    "$SLACK_WEBHOOK_URL" >/dev/null || true
  exit 4
fi
