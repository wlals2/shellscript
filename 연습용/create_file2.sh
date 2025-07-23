#!/bin/bash

# ANSI 컬러 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 사용법 함수
usage() {
  echo -e "${YELLOW}Usage:${NC} $0 <파일명> <내용>"
  echo "특수문자가 있을 때는 반드시 \"따옴표\"로 감싸서 입력하세요."
  echo -e "예시: $0 \"output.txt\" \"foo\$USER & bar\""
  exit 1
}

# 인자 확인
if [ "$#" -ne 2 ]; then
  echo -e "${RED}[✗] 인자 개수가 올바르지 않습니다.${NC}"
  usage
fi

FILENAME="$1"
CONTENT="$2"

# 파일 존재 시 경고
if [ -f "$FILENAME" ]; then
  echo -e "${YELLOW}[!] ${FILENAME} 파일이 이미 존재합니다. 덮어쓰시겠습니까? (y/n)${NC}"
  read -r yn
  case $yn in
    [Yy]*) ;;
    *) echo -e "${RED}작업을 취소합니다.${NC}"; exit 3;;
  esac
fi
# 파일 생성
if echo "$CONTENT" > "$FILENAME"; then
  echo -e "${GREEN}[✔] ${FILENAME} 파일이 성공적으로 생성되었습니다.${NC}"
else
  echo -e "${RED}[✗] 파일 생성 실패: ${FILENAME}${NC}"
  exit 2
fi
