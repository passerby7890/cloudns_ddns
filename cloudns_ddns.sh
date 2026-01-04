cat << 'EOF' > setup_cloudns_pro.sh
#!/bin/bash
# =================================================================
# ClouDNS Pro (Google SRE Standard)
# 特性：幂等性、健壮性 (带重试机制)、UTC+8 日志
# =================================================================

# 1. 权限检查
if [ "$EUID" -ne 0 ]; then echo "请使用 root 权限执行"; exit 1; fi

# 2. 交互输入
echo "------------------------------------------------"
echo "【高阶版】ClouDNS 定时切换脚本"
read -p "请输入 DDNS URL: " DDNS_URL
if [[ -z "$DDNS_URL" ]]; then echo "URL 不能为空"; exit 1; fi

echo -e "\n请设置执行时间 (东八区 UTC+8，24小时制)"
read -p "时 (0-23): " RUN_HOUR
read -p "分 (0-59): " RUN_MINUTE

# 简单验证
if ! [[ "$RUN_HOUR" =~ ^[0-9]+$ ]] || ! [[ "$RUN_MINUTE" =~ ^[0-9]+$ ]]; then
    echo "时间格式错误"; exit 1
fi

TARGET_SCRIPT="/usr/local/bin/cloudns_takeover.sh"
LOG_FILE="/var/log/cloudns_ddns.log"

# 3. 生成带有重试逻辑的核心脚本
cat > "$TARGET_SCRIPT" <<ENDSCRIPT
#!/bin/bash
# 目的: 强制更新 DNS 指向本机 IP (带重试机制)

MAX_RETRIES=3
RETRY_DELAY=10
COUNT=1

# 强制东八区时间
timestamp() { TZ='Asia/Shanghai' date '+%Y-%m-%d %H:%M:%S'; }

while [ \$COUNT -le \$MAX_RETRIES ]; do
    # 尝试更新
    HTTP_CODE=\$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "$DDNS_URL")
    
    if [ "\$HTTP_CODE" -eq 200 ]; then
        echo "\$(timestamp) [成功] 第 \$COUNT 次尝试: DNS 已指向本机。" >> $LOG_FILE
        # 成功后，简单清理日志并退出
        tail -n 50 $LOG_FILE > ${LOG_FILE}.tmp && mv ${LOG_FILE}.tmp $LOG_FILE
        exit 0
    else
        echo "\$(timestamp) [警告] 第 \$COUNT 次失败 (状态码: \$HTTP_CODE)，\${RETRY_DELAY}秒后重试..." >> $LOG_FILE
        sleep \$RETRY_DELAY
    fi
    ((COUNT++))
done

# 如果循环结束还没退出，说明彻底失败
echo "\$(timestamp) [严重错误] 已重试 \$MAX_RETRIES 次，全部失败。请检查网络或 URL。" >> $LOG_FILE
ENDSCRIPT

chmod +x "$TARGET_SCRIPT"

# 4. 写入 Crontab
TMP_CRON=$(mktemp)
crontab -l 2>/dev/null | grep -v "cloudns_takeover.sh" > "$TMP_CRON" || true
echo "$RUN_MINUTE $RUN_HOUR * * * $TARGET_SCRIPT" >> "$TMP_CRON"
crontab "$TMP_CRON"
rm -f "$TMP_CRON"

echo "------------------------------------------------"
echo "✅ 设置完成 (Pro版)"
echo "策略：每天 ${RUN_HOUR}:${RUN_MINUTE} 执行，若网络故障会自动重试 3 次。"
echo "------------------------------------------------"
EOF

chmod +x setup_cloudns_pro.sh && ./setup_cloudns_pro.sh
