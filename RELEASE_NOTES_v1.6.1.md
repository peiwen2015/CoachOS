# CoachOS v1.6.1 Release Notes

## 版本摘要

v1.6.1 是 v1.6.0 的修補版本，聚焦於比較分析交棒資料的完整性，以及資料匯入工具的預設操作路徑。

## 本次更新

- 比較活動交給 AI 的表格加入可用環境資料：氣溫、濕度、風速、風向與天氣描述。
- 比較活動交給 AI 的表格加入訓練上下文：鞋款、RPE、Garmin 感受、Stamina 起始值、結束值與下降量。
- 比較活動交給 AI 的表格加入路線相關摘要：活動名稱、爬升與下降；不輸出精確 GPS 座標。
- 缺少的環境或上下文欄位維持空白，讓 AI 知道資料不可用，而不是補猜資料。
- 從 CoachOS 進入資料匯入工具時，FIT 下載頁預設選取「只下載今天」。
- 修正首次從 CoachOS 進入資料匯入工具時，啟動頁面自動覆蓋下載 FIT 頁並跳回轉檔頁的問題。
- 更新比較功能規格與 Comparison Intelligence 演進規格，記錄 AI handoff 的上下文與隱私邊界。

## 驗證

- Comparison Intelligence tests：15 tests passed。
- `app.py` 與 `analysis_platform/dashboard_app.py` 通過 Python compile check。

## 相容性與資料治理

- 本版本不改變活動原始資料、SQLite schema 或既有比較規則版本。
- AI handoff 僅提供可追溯的活動級摘要；缺值不回填、不推測。
- 本版本不包含 mRelay 建置產物與本機 SQLite 資料庫。
