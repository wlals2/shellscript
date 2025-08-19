#!/bin/bash

file="$1"

# S3에서 파일 가져오기
aws s3 cp "s3://sample-s3-jimin/$file" "./$file" --region ap-northeast-2

# 다운로드 성공 시에만 추가 작업
if [ $? -eq 0 ]; then
    echo "파일 다운로드 성공: $file"

    # 확장자가 .sh 인 경우 실행 권한 부여
    if [[ "$file" == *.sh ]]; then
        chmod 755 "./$file"
        echo "실행 권한 부여 완료: $file"
    fi
else
    echo "파일 다운로드 실패: $file"
fi
