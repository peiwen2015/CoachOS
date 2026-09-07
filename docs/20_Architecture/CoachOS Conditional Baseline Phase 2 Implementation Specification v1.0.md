# CoachOS Conditional Baseline Phase 2 Implementation Specification v1.0

## 文件狀態

| 欄位 | 內容 |
|---|---|
| 文件類型 | Implementation specification |
| 版本 | v1.0 |
| 狀態 | Implemented and validated |
| 前置能力 | Phase 1 deterministic Similar Activities |
| 目標能力 | Comparison Set 的 conditional robust baseline |

## 1. Phase 2 成功標準

給定一個已通過 Phase 1 的 Similar Activities comparison set，CoachOS 能在明確的規則與樣本數邊界下，產生可追溯的個人 conditional baseline，且不把 baseline 誤當成 Runner 的永久能力值。

## 2. Phase 2 範圍

### 必做

- 使用 Phase 1 的 included comparison set 作為唯一樣本來源。
- 計算各比較指標的 median。
- 計算 P25–P75 typical range。
- 回傳 sample count、baseline window、rule version 與 data completeness。
- 在樣本不足時回傳 `insufficient_baseline`。
- 將 baseline 結果顯示於 Similar Activities comparison context。
- 將 baseline context 帶入 AI handoff，但不讓 AI 重算 baseline。

### 明確不做

- 不做 Performance Outlier Detection。
- 不做 Data／Context Anomaly engine。
- 不做綜合 Efficiency Score。
- 不做 Saved Comparison。
- 不做週／月 baseline。
- 不改寫 Runner Profile、Activity facts 或正式訓練標註。

## 3. Baseline identity

Baseline 必須綁定 Comparison Context，不得以單一活動類型或 Runner 全域資料建立永久數值。

```text
baseline_identity =
  comparison_intent
  + anchor_activity_id
  + similarity_rules
  + rule_version
  + baseline_rule_version
  + included_activity_ids
```

建議 baseline rule version：

```text
conditional-baseline-v1
```

相同 comparison set、相同 baseline rule version 與相同資料快照，必須產生相同統計結果。

## 4. Input contract

Baseline 只接受 Phase 1 query result 的 `included` 活動，不得自行重新搜尋活動。

```json
{
  "comparison_result": {
    "status": "ok",
    "context": {},
    "included": [
      {"activity_id": 254, "match_status": "included"},
      {"activity_id": 249, "match_status": "included"}
    ]
  },
  "baseline_rule_version": "conditional-baseline-v1"
}
```

### 4.1 Metric scope

Conditional Baseline 必須對每個 metric 綁定 `metric_scope`，不可把不同 scope 的數值混成同一個基準。單一 comparison set 可以同時產生多個 stimulus layer：

| Scope | Baseline 用途 |
|---|---|
| `whole_activity` | 總距離、總時間、訓練負荷與整體成本 |
| `primary_work` | Easy／Tempo／LSD 主要主段的配速、心率、功率與跑姿 |
| `strides` | Easy + Strides 短加速段的步頻、步幅、功率與 GCT |

WU、Recovery、CD 不得進入 `primary_work` baseline。若主段無法由可靠結構欄位辨識，該 scope 回傳 `not_assessable`，不得使用整堂平均值冒充主段基準。

第一版的固定對應為：

| Metric | Scope |
|---|---|
| 配速、平均心率、平均功率、步頻、步幅、GCT | `primary_work` |
| 訓練負荷 | `whole_activity` |
| Strides 的配速、心率、功率與跑姿 | 另存於 `scope_baselines.strides`，以實際有 Strides 的活動作為樣本 |

連續、沒有可辨識課表分段的活動，可將 `whole_activity` 明確視為 `primary_work`；不可把有 WU／Recovery／CD 的結構化活動整堂平均值冒充主段。回傳不得只提供一個全域 `metric_scope`，必須在每個 metric 與每個 scope baseline 上提供 scope、資料完整度與不可評估原因。

`strides` baseline 不要求 Comparison Set 每一堂都有 Strides；只要有至少 3 堂可用的 Strides 樣本即可建立，並回傳獨立的 `sample_count`。沒有 Strides 的活動只在該 scope 標示 `not_assessable`，不影響 Easy／主段 baseline。

若 comparison result 不是 `ok`，或 included 為空，baseline status 必須為 `not_available`。

## 5. Metrics

### 5.1 第一版納入指標

| 指標 | SQLite／Semantic 欄位 | 單位 |
|---|---|---|
| 配速 | `avg_pace_sec_per_km` | sec/km |
| 平均心率 | `avg_hr` | bpm |
| 平均功率 | `avg_power_w` | W |
| 訓練負荷 | `training_load` | score |
| 平均步頻 | `avg_cadence_spm` | spm |
| 平均步幅 | `avg_stride_length_mm` | mm |
| 平均觸地時間 | `avg_gct_ms` | ms |

### 5.2 不納入第一版

- `max_hr`
- `training_effect_aerobic`
- `training_effect_anaerobic`
- `recovery_time_hr`
- Stamina delta
- 天氣欄位
- 任何跨活動推導的 Efficiency Score

這些欄位可以在後續經過 coaching case 驗證後加入，不因為資料存在就自動納入。

## 6. Calculation contract

對每一個 metric：

1. 只取 included activities 的非空值。
2. 以 deterministic numeric ordering 計算 median、P25、P75。
3. 保留 `available_count` 與 `sample_count`。
4. 不以 0 填補缺值。
5. 不因單一 metric 缺值而排除整堂活動。

### 6.1 Percentile method

第一版固定使用 linear interpolation percentile method，並在 implementation code 與測試 fixture 中固定，不依賴資料庫版本或 Python library 預設值。

對排序後的 n 個值，位置定義為：

```text
position = (n - 1) × percentile
```

若位置不是整數，使用相鄰值線性插值。

### 6.2 Output rounding

計算使用完整 numeric value，最後顯示才依欄位格式化：

- 配速：顯示為 `m:ss/km`
- 心率：四捨五入至整數 bpm
- 功率：四捨五入至整數 W
- 負荷：四捨五入至整數
- 步頻：一位小數 spm
- 步幅：四捨五入至整數 mm
- GCT：四捨五入至整數 ms

## 7. Sample boundary

### 7.1 Baseline status

| 條件 | Status | 行為 |
|---|---|---|
| included count = 0 | `not_available` | 不顯示 baseline |
| included count < 3 | `insufficient_baseline` | 顯示樣本不足，不產生 typical range |
| included count >= 3 | `ready` | 產生 metric baseline |

### 7.2 Metric-level completeness

Comparison set 可以整體 `ready`，但每一個 metric 仍需有自己的 completeness：

```text
data_completeness = available_count / sample_count
```

若某個 metric 的 available count 為 0：

```text
metric_status = not_available
```

若 available count 小於 3：

```text
metric_status = insufficient_data
```

不得以其他指標的值推估該 metric。

## 8. Output contract

```json
{
  "status": "ready",
  "baseline_rule_version": "conditional-baseline-v1",
  "comparison_set_size": 7,
  "baseline_window": {
    "start": "2026-07-27T05:02:00",
    "end": "2026-09-07T05:02:14"
  },
  "metrics": {
    "avg_pace_sec_per_km": {
      "status": "ready",
      "median": 422,
      "p25": 420,
      "p75": 424,
      "available_count": 7,
      "data_completeness": 1.0
    },
    "avg_power_w": {
      "status": "ready",
      "median": 219,
      "p25": 218,
      "p75": 222,
      "available_count": 7,
      "data_completeness": 1.0
    }
  },
  "context_reference": {
    "comparison_intent": "longitudinal",
    "anchor_activity_id": 254,
    "rule_version": "similar-activities-v2",
    "baseline_rule_version": "conditional-baseline-v1"
  }
}
```

## 9. API / service boundary

Baseline Layer 只接受 Phase 1 result，不負責建立 comparison set：

```python
def calculate_conditional_baseline(connection, comparison_result: dict) -> dict:
    ...
```

責任分工：

```text
Similar Activities Query
  → selects included set and evidence

Conditional Baseline
  → calculates median / P25 / P75 on included set

Presentation
  → formats values and explains sample size

AI Handoff
  → carries platform baseline as evidence
```

Baseline Layer 不得查詢「相似活動」以外的活動，也不得重新套用 similarity rules。

## 10. UI contract

在 Similar Activities 結果中增加「我的近期典型範圍」區塊，使用自然語言顯示：

```text
近 7 堂相近活動的典型範圍
配速：7:00–7:04/km
平均心率：126–128 bpm
平均功率：218–222 W
訓練負荷：72–80
```

UI 必須同時顯示：

- comparison set 有幾堂活動
- baseline 使用的時間範圍
- 個別指標的資料完整度
- 樣本不足或資料不可用的說明

技術欄位、rule version 與內部識別碼放在可展開細節，不作為主要使用者語言。

## 11. AI handoff contract

AI handoff 必須明確說明：

- 這是「符合條件的近期相近活動典型範圍」
- baseline 的 comparison set 大小
- 每個 metric 的 median 與 typical range
- 哪些 metric 有缺值
- baseline 不代表永久能力值
- AI 不得將 baseline 改寫成正式活動事實

AI 的責任是解釋 deviation 或訓練意義；Phase 2 不要求平台先產生 deviation 或 anomaly label。

## 12. Test-first acceptance

- [x] 相同 included set 與 rule versions 產生相同 baseline。
- [x] median、P25、P75 使用固定 percentile method。
- [x] `n < 3` 回傳 `insufficient_baseline`。
- [x] 缺值不被當成 0。
- [x] metric-level available count 與 completeness 正確。
- [x] 全部缺值的 metric 回傳 `not_available`。
- [x] 少於 3 個可用值的 metric 回傳 `insufficient_data`。
- [x] baseline 不查詢 comparison set 以外的活動。
- [x] baseline 不修改 SQLite 正式資料。
- [x] UI 顯示樣本數、時間範圍與自然語言 typical range。
- [x] AI handoff 帶出 baseline evidence 與限制。
- [x] 不產生 outlier、score 或 Saved Comparison。

## 13. Phase 2 release gate

只有在 calculation、missingness、determinism、service boundary 與 UI／handoff integration 全部通過後，才可進入 Phase 3：Anomaly Evidence。
