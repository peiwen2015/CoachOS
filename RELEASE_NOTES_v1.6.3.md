# CoachOS v1.6.3 Release Notes

## 版本摘要

v1.6.3 是 v1.6.2 的修補版本，修正鞋款分類持久性功能造成資料匯入工具啟動失敗的回歸問題。

## 本次更新

- 修正資料匯入工具啟動時的 SQLite row 讀取錯誤。
- 修正後，從 CoachOS 進入資料匯入工具可正常啟動，不會再持續顯示「資料匯入工具目前沒有成功啟動，請稍後再試一次」。
- 保留 v1.6.2 的鞋款分類持久性修正：FIT 匯入不會以空白值覆蓋既有手動分類。
- 保留從 CoachOS 進入資料匯入工具時預設選取「只下載今天」。

## 驗證

- 匯入工具初始化成功。
- `/download-fit?download_mode=today` 可正常開啟。
- Comparison Intelligence tests：15 tests passed。
- `fit_to_excel.py`、`app.py` 與 `analysis_platform/dashboard_app.py` 通過 Python compile check。

## 資料治理

- 本版本不會自動猜測先前已清空的鞋款分類；需要使用者在鞋款頁重新設定。
- mRelay 建置產物與本機 SQLite 資料庫不包含在此版本提交中。
