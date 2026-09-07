# CoachOS Anomaly Detection Phase 3 Implementation Task Breakdown v1.0

## 開發契約

`CoachOS Anomaly Detection Phase 3 Implementation Specification v1.0`

## Slice A：Domain contract

- 建立 `detect_comparison_anomalies(comparison_result, baseline)`。
- 固定 `anomaly-detection-v1`。
- 不依賴 HTML 或 SQLite 重新搜尋。

## Slice B：Data anomaly

- 測試 metric missing、metric unavailable、insufficient metric data。
- 保留 observed value 為 null，不轉成 0。
- 將 baseline limitation 傳遞至 performance status。

## Slice C：Context anomaly

- 盤點現有 context 欄位與 provenance。
- 沒有可靠欄位時回傳 `not_assessable`。
- 不從活動名稱或 AI 文字推測天氣、路線或地形。

## Slice D：Performance anomaly

- 實作固定 Tukey fence。
- 只接受 Phase 2 的 ready metric。
- 測試 clear、flagged、not_assessable 三種狀態。

## Slice E：Presentation and handoff

- 在 Similar Activities context 顯示資料提醒、情境資料與表現偏離。
- 將 evidence 帶入 AI handoff。
- 技術細節放在可展開區塊。

## 完成條件

所有 Slice 與驗收測試通過後，才可進入 Efficiency Score 或 Saved Comparison 的設計；Phase 3 本身不實作這兩項能力。
