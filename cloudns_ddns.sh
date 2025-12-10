cat << 'EOF' > setup_cloudns_ddns.sh
#!/bin/bash

# =================================================================
# ClouDNS Auto-Updater (Ultimate Version)
# 功能：
# 1. 每日定時執行 (Time Schedule)
# 2. 開機自動執行 (Reboot Schedule) - 新增功能!
# 3. 自動時區校正 (Auto Timezone)
# =================================================================

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${GREEN}#################################################${NC}"
echo -e "${GREEN}#    ClouDNS DDNS 自動設定精靈 (雙重保險版)     #${NC}"
echo -e "${GREEN}#     (包含：每日定時 + 開機啟動 @reboot)       #${NC}"
echo -e "${GREEN}#################################################${NC}"

# 1. Root 檢查
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[錯誤] 請使用 root 權限執行 (sudo -i)${NC}"
  exit 1
fi

# 2. 時區校正
echo -e "\n${CYAN}>>> 校正系統時區為 Asia/Taipei ...${NC}"
if command -v timedatectl &> /dev/null; then
    timedatectl set-timezone Asia/Taipei
else
    ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime
fi

# 3. 輸入資料
echo -e "\n${YELLOW}【步驟 1】設定 DDNS 金鑰${NC}"
read -p "請輸入 ClouDNS Dynamic URL: " DDNS_URL
if [[ -z "$DDNS_URL" ]]; then echo -e "${RED}[錯誤] URL 不能為空！${NC}"; exit 1; fi

echo -e "\n${YELLOW}【步驟 2】設定每天執行時間${NC}"
read -p "每天幾點執行? (0-23): " RUN_HOUR
read -p "每天幾分執行? (0-59): " RUN_MINUTE

# 4. 部署腳本
TARGET_SCRIPT="/usr/local/bin/cloudns_daily_update.sh"
LOG_FILE="/var/log/cloudns_ddns.log"

cat > "$TARGET_SCRIPT" <<ENDSCRIPT
#!/bin/bash
# 執行時間: 每日 $RUN_HOUR:$RUN_MINUTE 及 開機啟動
NOW=\$(date '+%Y-%m-%d %H:%M:%S')

# 嘗試更新
RESPONSE=\$(curl -s -w "%{http_code}" "$DDNS_URL")

# 寫入日誌
if [[ "\$RESPONSE" == *"200"* ]]; then
    echo "\$NOW [成功] DDNS 更新完成 (HTTP 200)" >> $LOG_FILE
else
    echo "\$NOW [失敗] 連線異常 (狀態碼 \$RESPONSE)" >> $LOG_FILE
fi

# 清理舊日誌
tail -n 50 $LOG_FILE > ${LOG_FILE}.tmp && mv ${LOG_FILE}.tmp $LOG_FILE
ENDSCRIPT

chmod +x "$TARGET_SCRIPT"

# 5. 設定 Crontab (寫入雙重排程)
echo -e "\n${CYAN}>>> 正在寫入排程 (定時 + 開機啟動)...${NC}"

# 定義兩個排程指令
# 1. 每日定時
CRON_TIME="$RUN_MINUTE $RUN_HOUR * * * $TARGET_SCRIPT"
# 2. 開機後 60秒 執行 (sleep 60 是為了等待網路完全啟動)
CRON_BOOT="@reboot sleep 60 && $TARGET_SCRIPT"

# 清除舊的 -> 加入新的
(crontab -l 2>/dev/null | grep -v "cloudns_daily_update.sh"; echo "$CRON_TIME"; echo "$CRON_BOOT") | crontab -

echo -e "\n${GREEN}🎉 設定完成！${NC}"
echo -e "----------------------------------------------------"
echo -e "1. 每日定時: ${YELLOW}${RUN_HOUR}:${RUN_MINUTE}${NC} (Asia/Taipei)"
echo -e "2. 開機啟動: ${YELLOW}VPS 重啟後 60秒 自動執行${NC}"
echo -e "----------------------------------------------------"
echo -e "正在執行第一次測試..."
$TARGET_SCRIPT
echo -e "測試完成。"
EOF

chmod +x setup_cloudns_ddns.sh && ./setup_cloudns_ddns.sh
