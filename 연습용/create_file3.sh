# 1. 인자 개수 확인
if [ "$#" -ne 2 ]; then
    echo
    echo "[오류] 인자 개수가 올바르지 않습니다."
    echo "사용법: $0 <파일명> <내용>"
    echo "예시 : $0 result.txt \"내용을 입력하세요!\""
    echo
    exit 1
fi

filename="$1"
content="$2"

if [ -z filename ] || [ -z content  ] then
        echo
        echo "[오류] $filename or $content 비어있습니다."
        echo
        exit 2
        fi
echo "$content" > "$filename"

if [ $? -eq 0 ] then
        echo
                echo "[✔] $filename 파일이 성공적으로 생성되었습니다."
        echo
        else
                echo "[X] $filename 파일이 생성되지 않았습니다"
        exit 3
        fi
