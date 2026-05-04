#!/bin/bash

# OCI ARM 인스턴스 자동 재시도 스크립트
# 성공할 때까지 10분마다 terraform apply 시도

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="$SCRIPT_DIR/retry.log"

echo "========================================" | tee -a "$LOG_FILE"
echo "시도 시각: $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOG_FILE"

cd "$SCRIPT_DIR"

terraform apply -auto-approve 2>&1 | tee -a "$LOG_FILE"

if [ ${PIPESTATUS[0]} -eq 0 ]; then
  echo "✅ 인스턴스 생성 성공!" | tee -a "$LOG_FILE"
  # 성공 시 cron 제거
  crontab -l | grep -v "retry.sh" | crontab -
  echo "✅ 스케줄 자동 제거 완료" | tee -a "$LOG_FILE"
else
  echo "❌ 용량 부족 - 다음 시도 대기 중..." | tee -a "$LOG_FILE"
fi
