# CoachOS v1.6.0 — Comparison Intelligence

## 版本定位

CoachOS v1.6.0 將活動比較從「並列數據」提升為可解釋的 Comparison Intelligence：平台先辨識可比較的訓練行為，再把有 provenance 的 evidence 交給 AI 延伸分析。

## 主要更新

### Similar Activities

- 依課表類型、訓練目的、距離與時間範圍建立 deterministic 相似活動集合。
- 每筆納入／排除結果提供可解釋 evidence、rule version 與固定排序。
- 多段課表保留為補充上下文，不再因為包含多個分段而直接排除。

### 分層比較與 Conditional Baseline

- 將資料分為 `whole_activity`、`primary_work` 與 `strides`。
- 配速、心率、功率與跑姿優先使用主段；訓練負荷使用整堂活動；Strides 建立獨立 baseline。
- 支援主段前半／後半比較，避免 WU、Recovery、CD 稀釋品質課判讀。

### Anomaly 與訓練行為 evidence

- anomaly evidence 包含 scope、偏離方向、實務偏離門檻與資料來源。
- 分開呈現 `performance_deviation`、`role_fit`、`execution_pattern` 與 `rep_consistency`。
- 支援 `stable_power_faster_second_half`、`higher_power_faster_second_half`、`late_acceleration` 等固定行為命名。
- 沒有 Strides 的活動不會被誤判為資料遺失。

### Longitudinal Behavior Summary

- 彙整最近 6 堂的主段 pattern、Strides role fit、逐組一致性與 late acceleration 次數。
- 目前只提供行為出現次數，不產生能力分數、效率分數、drift score 或 composite score。

### AI Handoff 與治理

- AI handoff 明確標示每個數值所屬 scope。
- 保留 `context = not_assessable` 邊界，不對天氣、路線或鞋款做未驗證推論。
- AI 只負責解釋平台 evidence，不回寫原始活動數據。

## 驗證

- Comparison Intelligence 測試 15 項全部通過。
- 已驗證 HM Tempo、Easy、Easy + Strides 的主段、前後半與逐組 evidence。
