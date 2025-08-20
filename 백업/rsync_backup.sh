
#!/bin/bash

# 백업할 원본 디렉터리(실제 존재하는 경로로 수정)
SRC="/home/ubuntu/docs"

# 백업대상 경로 (로컬/원격 모두가능)
# 로컬 예시
DEST="/home/ubuntu/backup/docs"
# 원격 예시
# DEST="user@192.168.56.200:/backup/docs"

# 메일 수신자
EMAIL="yourgmail.com"

# 로그 임시파일
LOGFILE="/tmp/rsync_backup.log"

# 백업 디렉터리 미리 생성
mkdir -p "$DEST"

# rsync 실행 (로컬/원격 모두 동작)
rsync -avz --delete "$SRC/" "$DEST/" > "$LOGFILE" 2>&1
RETVAL=$?

if [ $RETVAL -eq 0 ]; then
	SUBJECT="백업 완료: $SRC -> $DEST"
else
	SUBJECT="백업 실패: $SRC -> $DEST"
fi

#메일 발송 (msmtp 활용)
{
	echo "Subject: $SUBJECT"
	echo ""
	cat "$LOGFILE"
} | msmtp "$EMAIL"

rm -f "$LOGFILE"


