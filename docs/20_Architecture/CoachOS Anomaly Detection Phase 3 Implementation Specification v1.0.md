# CoachOS Anomaly Detection Phase 3 Implementation Specification v1.0

## 文件狀態

| 欄位 | 內容 |
|---|---|
| 文件類型 | Implementation specification |
| 版本 | v1.0 |
| 狀態 | Implemented and validated — initial scope |
| 前置能力 | Phase 1 Similar Activities、Phase 2 Conditional Baseline |
| 目標能力 | 可追溯的資料、情境與表現異常 evidence |

## 1. Phase 3 成功標準

給定一個已完成的 Similar Activities comparison result 與 Conditional Baseline，CoachOS 能以固定規則辨識資料限制、可比較性限制與表現偏離，並對每一筆結果回傳可驗證 evidence。

平台負責發現差異；AI 只負責解釋差異與提出訓練建議。

## 2. 範圍與邊界

### 必做

- 建立 `detect_comparison_anomalies(comparison_result, baseline)` service boundary。
- 分開產生 `data`、`context`、`performance` 三類 anomaly evidence。
- 缺值、資料來源或欄位不可用時回傳 `not_assessable`，不得猜測。
- Performance anomaly 只能使用 baseline 已成立且資料可比較的指標。
- 每筆 evidence 保留 metric、observed value、expected range、reason 與 rule version。
- 將 anomaly evidence 顯示於 Similar Activities context，並帶入 AI handoff。

### 明確不做

- 不修改 activity facts、Semantic Layer、Runner Profile 或 SQLite 正式活動資料。
- 不將 data/context anomaly 自動轉成 performance anomaly。
- 不做天氣推論；沒有可靠環境資料時 context status 為 `not_assessable`。
- 不做 Efficiency Score、綜合 anomaly score、Saved Comparison 或週／月 anomaly。

## 3. Input contract

Phase 3 只接受 Phase 1 與 Phase 2 的輸出，不重新搜尋活動或重算 baseline：

```python
def detect_comparison_anomalies(comparison_result: dict, baseline: dict) -> dict:
    ...
```

輸入必須包含：

- `comparison_result.status = ok`
- Phase 1 `included` 活動與其 context
- Phase 2 baseline、baseline rule version 與 metric completeness
- 每個活動的 `metric_scope`；至少區分 `whole_activity`、`primary_work`、`strides`

若輸入不完整，回傳 `status = not_assessable`，並列出缺少的輸入。

## 4. Anomaly evidence schema

每筆 evidence 至少包含：

```json
{
  "anomaly_type": "data | context | performance",
  "status": "clear | flagged | not_assessable",
  "activity_id": 254,
  "metric": "avg_power_w",
  "metric_scope": "primary_work",
  "scope_label": "品質主段",
  "observed_value": null,
  "expected_range": null,
  "deviation": null,
  "reason_code": "metric_missing",
  "reason": "平均功率沒有資料",
  "rule_version": "anomaly-detection-v1"
}
```

`flagged` 只表示平台發現偏離，不代表原因已確定。

## 5. 三層 detection rules

### 5.1 Data anomaly

Data anomaly 只描述資料品質：

- comparison metric 缺值：`flagged / metric_missing`
- 全部樣本缺值：`flagged / metric_unavailable`
- baseline metric 少於 3 個可用值：`flagged / insufficient_metric_data`
- baseline 不存在或 comparison set 不足：`not_assessable / baseline_unavailable`

Data anomaly 不得改寫原始值，也不得把缺值當成 0。

### 5.2 Context anomaly

第一版只讀取已存在且有明確來源的 context 欄位。若資料模型沒有溫度、濕度、路線、地形或前一堂訓練角色：

- 回傳 `not_assessable`
- reason code 為 `context_field_unavailable`
- 不產生「天氣造成」或「路線造成」的推論

距離差異已由 Phase 1 similarity rules 處理，不在 Phase 3 重複標示為 context anomaly。

### 5.3 Performance anomaly

只有在同時符合以下條件時才可評估：

1. baseline status 為 `ready`。
2. 該 metric status 為 `ready`。
3. 該活動該 metric 有值。
4. 沒有阻止判讀的 data/context limitation。
5. 活動與 baseline 使用相同的 `metric_scope`。

`metric_scope` 必須逐筆 evidence 回傳，不得只依賴 baseline 的全域 scope。對 Easy + Strides：Easy／有氧主體使用 `primary_work`，Strides 使用 `strides`，訓練負荷使用 `whole_activity`。若指定 scope 不存在，回傳 `scope_unavailable` 與 `not_assessable`，不得靜默改用整堂平均值。

段落缺席與段落資料缺失必須分開：

- `segment_not_present`：活動本身沒有該段落，例如純 Easy 沒有 Strides；資料 evidence 為 `not_assessable`，不計入 Data Anomaly summary。
- `segment_present_but_missing_data`：活動有該段落，但段落指標不完整；資料 evidence 為 `flagged`。

Summary 必須回傳 `performance_flagged_scope`，列出真正觸發表現偏離的 scope（`primary_work`、`strides` 或 `whole_activity`），避免使用者把 Strides 異常誤解成 Easy 整堂異常。

Phase 3 的 segment behavior evidence 另外提供：

- `primary_work` 前半／後半：只有前後半功率差在固定 band 內時，才描述 HR、配速與 GCT 變化；功率已明顯改變時不得稱為 cardiovascular drift。
- `strides` 逐組一致性：提供組數、配速／功率／GCT 範圍與最後一組是否突然加速；這是執行模式 evidence，不是對訓練對錯或 fitness 的自動判定。
- Strides behavior 可附帶 `segment_intent`、`intent_source`、`intent_confidence` 與 `role_fit`；低信心的推導 intent 只能作為提示，不可升級為 anomaly 原因。
- Performance evidence 必須額外回傳 `direction`／`performance_deviation`：`above_typical`、`below_typical` 或 `within_typical`。這只描述相對 baseline 的方向，與 `role_fit` 完全分離。
- Primary work behavior evidence 必須使用 `execution_pattern` 命名，例如 `stable_power_faster_second_half`、`higher_power_faster_second_half`、`stable_power_higher_hr_second_half`，不得使用 `drift` 或 `efficiency_improvement` 作為 deterministic label。
- Strides behavior evidence 必須使用 `rep_consistency`：`consistent`、`variable`、`late_acceleration` 或 `progressive`。

對 Tempo／Threshold／LSD，`primary_work` 不得包含 WU、Recovery、CD；對 Easy + Strides，Easy 與 Strides 必須分開評估。

第一版使用 deterministic Tukey fences：

```text
IQR = P75 - P25
lower_fence = P25 - 1.5 × IQR
upper_fence = P75 + 1.5 × IQR
```

觀測值超出 fence 才標示 `flagged`；落在 fence 內為 `clear`。不以單一指標產生總分。

為避免把極小的統計波動放大成教練上的異常，`flagged` 還必須通過 practical significance gate。第一版門檻為：配速 2 秒／公里、平均心率 2 bpm、功率 5 W、訓練負荷 10、步頻 1 spm、步幅 10 mm、GCT 3 ms。若超出 Tukey fence 但未達門檻，回傳 `status=clear`、`reason_code=statistical_only`，並保留 `statistical_flagged=true` 與 `practical_threshold`。

`training_load` 的唯一來源是 activity snapshot 的整堂活動欄位；segment metrics 沒有該欄位時不得回傳 `metric_missing`。

## 6. Evaluation order

固定依下列順序執行：

1. 驗證 comparison result 與 baseline contract。
2. 對每堂活動檢查 data completeness。
3. 評估可用的 context fields；沒有欄位則明確回傳 `not_assessable`。
4. 僅對資料完整且 baseline ready 的 metric 評估 performance fence。
5. 產生 activity-level summary，但不產生綜合分數。

若 data anomaly 阻止某 metric 的判讀，該 metric 的 performance evidence 必須為 `not_assessable`，不可標成 `clear`。

## 7. Output contract

```json
{
  "status": "ready",
  "rule_version": "anomaly-detection-v1",
  "comparison_set_size": 7,
  "summary": {
    "data": "clear",
    "context": "not_assessable",
    "performance": "clear",
    "performance_flagged_scope": [],
    "behavior": "ready"
  },
  "activities": [
    {
      "activity_id": 254,
      "evidence": []
    }
  ],
  "context_reference": {
    "comparison_rule_version": "similar-activities-v2",
    "baseline_rule_version": "conditional-baseline-v1"
  }
}
```

## 8. UI 與 AI handoff

UI 使用自然語言顯示：

- 「資料提醒」：哪些指標缺資料
- 「情境資料」：目前沒有足夠環境資料可判斷
- 「表現偏離」：哪個指標超出近期典型範圍

技術 rule version、reason code 與 fence 數值放在可展開細節。

AI handoff 必須說明：

- anomaly 是平台依固定規則發現的偏離，不是確定原因
- `not_assessable` 不可被解讀成正常或異常
- AI 可解釋可能原因，但不得改寫 anomaly evidence 或正式活動資料

## 9. Test-first acceptance

- [ ] 非 `ok` comparison result 回傳 `not_assessable`。
- [ ] baseline 不足時不產生 performance anomaly。
- [ ] 缺值產生 data evidence，不當成 0。
- [ ] 沒有指定段落時回傳 `segment_not_present`，不列為 Data Anomaly。
- [ ] 有段落但缺少指標時回傳 `segment_present_but_missing_data`。
- [ ] Summary 回傳 `performance_flagged_scope`。
- [ ] 相同功率區間才產生前後半 HR／配速 behavior evidence。
- [ ] Strides 可辨識逐組時產生組間一致性與最後一組突增 evidence。
- [ ] metric 可用值不足時 performance evidence 為 `not_assessable`。
- [ ] 沒有 context 欄位時回傳 context `not_assessable`，不猜測天氣或路線原因。
- [ ] Tukey fence 使用固定 1.5 × IQR。
- [ ] fence 內為 `clear`，超出 fence 為 `flagged`。
- [ ] 每筆 evidence 包含 rule version、observed value 與 reason。
- [ ] detection 不查詢 included set 以外的活動。
- [ ] detection 不修改 SQLite 正式資料。
- [ ] 不產生綜合 anomaly score、Efficiency Score 或 Saved Comparison。
