# Linux Shell Scripts Collection

리눅스/유닉스 실무 환경에서 바로 사용할 수 있는 **쉘 스크립트(sh, bash 등)모음** 서버관리, 자동화, 모니터링, 데이터 백업 등 현업에서 유용한 스크립트를 정리했습니다.

---

## 📁 폴더/파일 구조
``` bash
shellscripts/
├── backup_home.sh # 홈 디렉토리 백업
├── disk_alert.sh # 디스크 용량 모니터링 및 경고
├── hello.sh # 샘플/테스트용 Hello World
├── logcheck.sh # 시스템 로그 자동 체크
├── logs_alert.sh # 로그 용량 감시/경고
├── rsync_backup.sh # rsync 기반 백업 자동화
├── sysinfo.sh # 시스템 정보 요약 출력


---

## 🛠️ 각 스크립트 설명

| 파일명            | 설명                                
|-------------------|--------------------------------------
| backup_home.sh    | 홈디렉토리 전체를 백업(압축/타겟 지정 가능) 
| disk_alert.sh     | 디스크 사용량 임계치 초과시 경고/메일 발송  
| hello.sh          | Hello World 예제 (사용법 연습용)           
| logcheck.sh       | 시스템 로그(예: /var/log/messages) 체크     
| logs_alert.sh     | 로그 디렉토리/파일별 용량 자동 감시         
| rsync_backup.sh   | rsync로 빠른 증분 백업 수행                
| sysinfo.sh        | 시스템 핵심 정보(호스트, IP, CPU 등) 출력   

---

## ⚡ 사용 방법

1. **권한 부여**
   ```bash
   chmod +x shellscripts/*.sh
