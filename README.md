這是一個簡單、高效的 Bash 腳本，用於自動設定 **ClouDNS Dynamic DNS (DDNS)** 的定時更新任務。
專為需要 **固定每日時間執行** 且位於 **東八區 (UTC+8)** 的伺服器環境設計。

## ✨ 功能特點 (Features)

* **自動時區校正**：強制將系統時區設定為 `Asia/Taipei` (UTC+8)，確保定時任務準時執行。
* **每日定時**：互動式詢問每天幾點幾分執行，而非間隔循環。
* **一鍵部署**：自動產生執行腳本、設定權限、寫入 Crontab 排程。
* **日誌管理**：自動記錄更新狀態，並限制日誌行數，防止佔用空間。
* **隱私安全**：腳本透過互動輸入 URL，**不會**將您的金鑰硬編碼在腳本中。

## 🚀 使用方法 (Usage)

### 1. 下載腳本
```bash
git clone　https://github.com/passerby7890/cloudns_ddns.git
cd cloudns_ddns

2. 賦予執行權限
Bash
chmod +x cloudns_ddns.sh

3. 執行安裝
請使用 root 權限執行：
Bash
sudo ./cloudns_ddns.sh

4. 依照提示操作
輸入您的 ClouDNS Dynamic URL。
輸入您希望每天執行的時間（例如 08 點 30 分）。
腳本會自動完成剩餘設定。

📝 日誌查看 (Logs)
預設日誌路徑為：
Bash
tail -f /var/log/cloudns_ddns.log
