# CoachOS v1.3.6 Release Summary

## Short Summary

CoachOS v1.3.6 is a calibration release for `Connected Coach Knowledge`.

This version fixes activity max heart rate so Activity shows the true `活動最高心率` instead of accidentally inheriting the athlete max-HR setting, adds batch repair for existing SQLite and Excel artifacts, and further aligns user-facing Chinese terminology across Activity, AI handoff, prompts, and import tools.

## Highlights

- 修正 Activity 頁最大心率顯示邏輯，改為真實 `活動最高心率`
- 可批次修補既有 SQLite 與 Excel 的心率與欄位標籤
- `Critical Power (W)` 改為 `個人臨界功率`
- 訓練效果、訓練負荷、恢復時間、體力等欄位中文口徑更一致
- `split` 相關可見文字統一成 `分段 / 原始分段`
- AI 交棒、圖卡 prompt、首頁與批次工具的產品語言更一致

## Suggested Git Commit Message

`release: prepare CoachOS v1.3.6 calibration update`

## Suggested Release Title

`CoachOS v1.3.6 — Data Calibration and Language Consistency`
