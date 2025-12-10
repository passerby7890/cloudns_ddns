# ClouDNS Daily Auto-Updater (Bash Script)

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
git clone [https://github.com/您的帳號/專案名稱.git](https://github.com/passerby7890/cloudns_ddns.git)
cd 專案名稱
