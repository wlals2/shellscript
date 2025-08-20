# Linux Shell Scripts Collection

리눅스/유닉스 운영에서 자주 쓰는 **백업, 모니터링, 점검, 자동화** 스크립트 모음입니다.  
팀 온보딩/표준 운영절차(SOP)에 쉽게 녹여 쓸 수 있도록 **간단한 설치·사용 예시와 크론/서비스 실행 템플릿**을 제공합니다.

---

## 📚 목차
- [특징](#-특징)
- [폴더/파일 구조](#-폴더파일-구조)
- [빠른 시작](#-빠른-시작)
- [스크립트별 설명 & 사용법](#-스크립트별-설명--사용법)
  - [backup_home.sh](#backup_homesh--홈-디렉토리-백업)
  - [disk_alert.sh](#disk_alertsh--디스크-용량-경고)
  - [hello.sh](#hellosh--샘플hello-world)
  - [logcheck.sh](#logchecksh--시스템-로그-자동-체크)
  - [logs_alert.sh](#logs_alertsh--로그-디렉토리용량-감시)
  - [rsync_backup.sh](#rsync_backupsh--증분-백업-자동화)
  - [sysinfo.sh](#sysinfosh--시스템-정보-요약)
- [스케줄링 템플릿(cron/systemd)](#-스케줄링-템플릿cronsystemd)
- [알림 연동(메일/Slack)](#-알림-연동메일slack)
- [보안 & 운영 팁](#-보안--운영-팁)
- [기여 방법](#-기여-방법)
- [라이선스](#-라이선스)

---

## ✅ 특징
- **즉시 사용 가능**: 실행 권한만 주면 바로 동작
- **운영 친화적**: 로그·임계치·알림 연동 환경변수로 제어
- **표준화**: 공통 디렉토리/로그 규칙과 스케줄 템플릿 제공
- **가독성**: 각 스크립트 목적·옵션·예시를 README에 정리

---

## 📁 폴더/파일 구조
> 실제 저장 위치나 폴더명은 자유롭게 변경 가능합니다.

```bash
$REPO_ROOT/
├─ backup/                     # 백업 관련
│  ├─ backup_home.sh          # 홈 디렉토리 백업
│  └─ rsync_backup.sh         # rsync 증분/스냅샷 백업
│
├─ monitor/                    # 모니터링/알림
│  ├─ disk_alert.sh           # 디스크 임계치 경고
│  ├─ logcheck.sh             # 시스템 로그 키워드 점검
│  └─ logs_alert.sh           # 로그 디렉토리 용량 감시
│
├─ system/                     # 시스템 확인/점검
│  └─ sysinfo.sh              # 시스템 요약 정보
│
├─ examples/                   # 연습/테스트
│  ├─ hello.sh                # Hello World
│  ├─ create_file2.sh
│  └─ create_file3.sh
│
└─ aws/                        # AWS 연동 유틸(선택)
   ├─ logger.sh               # 리소스 로거
   ├─ s3.sh                   # S3 업/다운로드
   ├─ s3push_slack.sh         # S3 결과 Slack 알림
   └─ uploader.sh             # 업로더
```