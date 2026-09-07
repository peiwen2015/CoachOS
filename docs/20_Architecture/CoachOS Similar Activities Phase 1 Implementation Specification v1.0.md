# CoachOS Similar Activities Phase 1 Implementation Specification v1.0

## 文件狀態

| 欄位 | 內容 |
|---|---|
| 文件類型 | Implementation specification |
| 版本 | v1.0 |
| 狀態 | Implemented and validated |
| 上位文件 | `CoachOS Comparison Intelligence Evolution Specification v1.0` |
| 設計審查 | `CoachOS Comparison Intelligence Design Review v0.1` |
| 目標能力 | Deterministic Similar Activities query |

## 1. Phase 1 成功標準

給定一堂 anchor activity 與 comparison intent，CoachOS 能以版本化、可驗證的 deterministic rules，穩定產生一組可解釋的 Similar Activities comparison set。

結果不只回傳 activity IDs，也必須回傳：

- 使用的 comparison context
- anchor activity
- 實際套用的 rules
- 每筆活動的納入或排除 evidence
- 結果排序與截斷資訊
- 資料品質與缺值狀態

## 2. Phase 1 範圍

### 必做

- 從單堂 Activity 以 anchor activity 建立 Similar Activities query。
- 支援 `longitudinal` comparison intent。
- 使用既有 Semantic Layer 欄位做 deterministic filtering。
- 將 similarity rules 與 rule version 固定保存於 query context。
- 回傳 included／excluded activity 與 evidence。
- 將 included activities 導入既有 Activity Comparison 表格。
- 將 query context 與 evidence 帶入 AI handoff。

### 明確不做

- 不使用 AI 進行活動配對。
- 不計算 conditional baseline、median、percentile 或 typical range。
- 不做 performance outlier 判斷。
- 不做 Data／Context／Performance anomaly 的完整平台能力。
- 不做 Saved Comparison 或首頁卡片。
- 不做週／月聚合。
- 不建立綜合 Efficiency Score。

## 3. 資料輸入與欄位依賴

### 3.1 主要資料來源

Similar Activities query 必須以 `activity_review_view` 作為主要語意來源，不直接依賴 dashboard 自行拼接 canonical tables。

### 3.2 Query 依賴欄位

| 用途 | 欄位 |
|---|---|
| Anchor identity | `activity_id`, `activity_start_time` |
| Activity type | `activity_type`, `activity_name` |
| Workout matching | `workout_type_code`, `workout_type_name_en`, `workout_type_name_zh` |
| Purpose matching | `primary_training_purpose_code`, `primary_training_purpose_name_en`, `primary_training_purpose_name_zh` |
| Distance matching | `distance_km` |
| Structure matching | `is_quality_session`, `is_long_run`, `is_recovery_focused`, future segment structure field |
| Context evidence | `temperature_c`, `humidity_pct`, `wind_speed_mps`, `shoe_code`, `shoe_display_name` |
| Output comparison | `duration_sec`, `avg_pace_sec_per_km`, `avg_hr`, `max_hr`, `avg_power_w`, `training_load`, `avg_cadence_spm`, `avg_stride_length_mm`, `avg_gct_ms` |

### 3.3 欄位來源原則

- workout type 與 training purpose 必須使用 Semantic Layer 已解析的欄位。
- `avg_power_w` 必須使用活動層級官方 FIT 平均功率；不得以 `critical_power_w` 或分段平均值代替。
- 缺值必須保留為缺值並進入 data quality evidence。
- Query 不得因缺少比較指標而默默排除活動；只有規則依賴欄位缺失時，才依缺值規則處理。

## 4. ComparisonContext schema

Phase 1 使用可序列化的 context object：

```json
{
  "comparison_intent": "longitudinal",
  "comparison_scope": "activity",
  "anchor_activity_id": 254,
  "anchor_snapshot": {
    "activity_start_time": "2026-09-07T05:02:14",
    "workout_type_code": "RECOVERY_RUN",
    "primary_purpose_code": "RECOVERY",
    "distance_km": 6.01
  },
  "data_snapshot_reference": "sqlite:running_analytics.sqlite",
  "similarity_rules": {
    "workout_type_code": "RECOVERY_RUN",
    "primary_purpose_code": "RECOVERY",
    "distance_tolerance_pct": 15,
    "segment_structure": "compatible",
    "lookback_weeks": 12,
    "include_anchor": true
  },
  "rule_version": "similar-activities-v2",
  "result_limit": 12
}
```

### 欄位契約

| 欄位 | 必填 | 說明 |
|---|---:|---|
| `comparison_intent` | 是 | Phase 1 固定支援 `longitudinal` |
| `comparison_scope` | 是 | Phase 1 固定為 `activity` |
| `anchor_activity_id` | 是 | SQLite activity identity；只作本機 query anchor |
| `anchor_snapshot` | 是 | 建立 query 時實際使用的 anchor identity fields |
| `data_snapshot_reference` | 是 | 產生結果時使用的資料快照參考 |
| `similarity_rules` | 是 | 實際執行的規則快照 |
| `rule_version` | 是 | 規則版本，不可省略 |
| `result_limit` | 是 | 結果最大筆數 |

Context 可先以 URL-safe JSON 或 query identifier 傳遞；Phase 1 不要求建立永久 Saved Comparison table。

## 5. Phase 1 similarity rules

### 5.1 預設規則

```text
intent = longitudinal
workout_type_code = anchor.workout_type_code
primary_purpose_code = anchor.primary_training_purpose_code
distance = anchor.distance_km ± 15%
segment_structure = compatible (context evidence only)
lookback = anchor.activity_start_time 往前 12 週
include_anchor = true
```

### 5.2 規則順序

規則必須以固定順序評估：

1. 活動日期在 lookback window 內。
2. 活動類型與 anchor 的 workout type 相同。
3. primary training purpose 相同。
4. 距離在容許範圍內。
5. 記錄課表結構 evidence；`longitudinal` 比較不因多個課表分段直接排除活動。若目前沒有可靠的結構欄位，回傳 `not_evaluable`，不得猜測。

### 5.3 Anchor 缺值

如果 anchor 缺少 workout type、primary purpose 或 distance：

- query status 回傳 `insufficient_anchor_context`
- 回傳缺少的欄位名稱
- 不產生看似精準的 Similar Activities 結果
- UI 可提供回到 `free` comparison 的入口

## 6. Query flow

```text
Activity detail
  ↓
建立 ComparisonContext
  ↓
讀取 anchor activity
  ↓
驗證 anchor required fields
  ↓
套用 lookback filter
  ↓
套用 workout type / purpose / distance rules
  ↓
記錄 structure evidence（僅作補充說明，不作硬性排除）
  ↓
產生 included / excluded evidence
  ↓
依 activity_start_time DESC 排序
  ↓
截斷至 result_limit
  ↓
回傳 Similar Activities result
  ↓
導入 Activity Comparison
```

Query 必須是 read-only，不得修改 activity、metadata、Semantic Layer 或任何正式訓練欄位。

## 7. Result contract

```json
{
  "status": "ok",
  "context": {},
  "anchor": {
    "activity_id": 254,
    "activity_start_time": "2026-09-07T05:02:14",
    "display_name": "6K Recovery Run"
  },
  "included": [
    {
      "activity_id": 249,
      "match_status": "included",
      "match_score": null,
      "evidence": [
        {"rule": "lookback_weeks", "status": "pass", "detail": "within 12 weeks"},
        {"rule": "workout_type_code", "status": "pass", "detail": "RECOVERY_RUN"},
        {"rule": "primary_purpose_code", "status": "pass", "detail": "RECOVERY"},
        {"rule": "distance_tolerance_pct", "status": "pass", "detail": "distance delta 0.0%"}
      ]
    }
  ],
  "excluded": [
    {
      "activity_id": 241,
      "match_status": "excluded",
      "evidence": [
        {"rule": "workout_type_code", "status": "fail", "detail": "different workout type"}
      ]
    }
  ],
  "truncation": {
    "candidate_count": 20,
    "included_before_limit": 14,
    "result_limit": 12,
    "truncated": true
  }
}
```

### 7.1 Score boundary

Phase 1 不產生 similarity score。`match_score` 必須為 `null`，避免使用者誤以為規則已經形成可比較的連續分數。

## 8. 排序與截斷

- 候選活動依 `activity_start_time DESC, activity_id DESC` 排序；`activity_id DESC` 是固定 tie-break。
- anchor 若納入結果，固定保留在結果集合中。
- `result_limit` 預設為 12。
- 超過上限時，回傳完整的 candidate count、included before limit 與 truncation status。
- 不得以 SQLite row order、activity name 或 SQLite internal insertion order 排序。
- 相同 data snapshot、anchor snapshot、intent 與 rule version 必須產生相同的 included 集合與順序。

## 9. 缺值與資料品質處理

### Query identity fields

若 workout type、purpose 或 distance 缺失，活動不能宣告為相似；須回傳：

```text
status = not_evaluable
reason = missing_required_similarity_field
field = <missing field>
```

### Comparison metrics

功率、步頻、步幅、GCT 等非 query identity 欄位缺失時：

- 活動仍可納入比較集合
- 該欄位在比較表顯示缺值
- evidence 標記 `metric_missing`
- 不以缺值作為 0 或推算值

### Data provenance

若欄位曾經由 repair／backfill 流程補回，result 可帶出 provenance reference；但不得改變 similarity pass/fail 結果，除非該欄位本身是 query identity field。

## 10. API / service boundary

Phase 1 建議將功能分成三層：

```text
Query Layer
  build_comparison_context(anchor, intent)
  find_similar_activities(context)

Presentation Layer
  render_similar_activity_result(result)
  render_activity_comparison(result.included)

AI Handoff Layer
  build_comparison_handoff(context, result, comparison_rows)
```

Query Layer 不應產生 HTML。Presentation Layer 不應自行重算 similarity rules。AI Handoff Layer 不應自行改寫 included／excluded 集合。

### 建議函式介面

```python
def build_comparison_context(connection, anchor_activity_id, comparison_intent="longitudinal") -> dict:
    ...

def find_similar_activities(connection, context: dict) -> dict:
    ...

def comparison_result_to_activity_ids(result: dict) -> list[int]:
    ...
```

## 11. UI 入口與 handoff

### UI 入口

單堂 Activity 頁增加「找相似活動」入口。入口必須顯示：

- anchor activity 名稱與日期
- comparison intent
- 將使用的規則摘要
- 產生結果前的缺值警告

### Similar Activities 結果

結果頁必須顯示：

- anchor activity
- 已套用的 rules
- 納入活動清單
- 每筆活動被納入的 evidence
- 被排除活動與主要排除理由
- 結果是否被截斷

使用者預設看到的內容必須使用活動名稱、日期、距離與自然語言說明；`activity_id`、欄位名稱、rule code 與 rule version 等技術資訊只能放在可展開的技術細節中。

納入活動可一鍵帶入既有 Activity Comparison 頁，沿用目前的比較表、AI handoff、AI 回覆與圖片保存流程。

### Handoff payload

AI handoff 必須包含：

- `comparison_intent`
- `anchor_activity`
- `rule_version`
- `similarity_rules`
- included activity list
- 每筆活動的 match evidence
- metric missingness notes

AI 不得被要求重新尋找相似活動或自行修改比較集合。

## 12. Rule versioning

Phase 1 規則版本命名：

```text
similar-activities-v2
```

任何以下變動都必須升版：

- workout type 或 purpose matching 定義
- distance tolerance
- lookback window
- structure rule
- sorting 或 truncation semantics
- 缺值處理方式

Rule version 必須進入 context、result 與 AI handoff，讓同一 query 未來可以重現。

## 13. 測試與驗收

### Fixture cases

- 同 workout type、同 purpose、距離在 ±15%：included。
- 同 workout type、不同 purpose：excluded。
- 同 purpose、距離超過 ±15%：excluded。
- 超過 12 週：excluded。
- 缺 workout type／purpose／distance：not evaluable。
- 功率缺失但 identity fields 完整：included，功率顯示缺值。
- 候選超過 result limit：結果排序與 truncation metadata 正確。
- 活動順序改變：context identifier 與結果集合不因 SQLite row order 改變。

### Phase 1 驗收

- [ ] 相同 anchor、相同 intent、相同 rule version 可重複得到相同結果。
- [ ] 每筆 included／excluded 活動都有可讀 evidence。
- [ ] 結果不依賴 SQLite internal row order。
- [ ] 缺值不被當成 0 或相似證據。
- [ ] Query Layer 不修改任何正式資料。
- [ ] AI handoff 可追溯到 context、rules 與結果 evidence。
- [ ] Phase 1 沒有 baseline、outlier、score 或 Saved Comparison 行為。
