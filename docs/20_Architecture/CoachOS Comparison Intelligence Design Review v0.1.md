# CoachOS Comparison Intelligence Design Review v0.1

## 文件狀態

| 欄位 | 內容 |
|---|---|
| 文件類型 | Design review / implementation gate |
| 版本 | v0.1 |
| 審查對象 | `CoachOS Comparison Intelligence Evolution Specification v1.0` |
| 審查結論 | 通過 Phase 1 設計，進入 implementation spec |
| 審查範圍 | Comparison Context、Conditional Baseline、Anomaly、Similar Activities |

## 1. 總結結論

Evolution Specification 的產品方向成立，且與 CoachOS 現有的 Metadata-First、Semantic Layer 與 AI handoff 邊界一致。

目前可以進入 Phase 1，但必須遵守以下限制：

- Phase 1 只做 deterministic Similar Activities。
- Comparison Intent 必須在資料模型一開始就存在，即使第一個 UI 只開放 `longitudinal`。
- Baseline 先定義計算契約，不必在 Phase 1 實作完整統計。
- Anomaly 先定義 evidence schema；Phase 1 不提前實作所有異常判斷。
- AI 只解釋平台產生的比較集合與 evidence，不負責找活動或重新計算。

## 2. 審查一：Comparison Context 是否足夠

### 結論：概念足夠；需要明確的實作物件

Evolution Specification 已包含：

```text
comparison_intent
anchor_activity
comparison_scope
similarity_rules
baseline_rules
rule_version
```

Implementation spec 應將它固定成一個可序列化的 `ComparisonContext`，至少包含：

```json
{
  "comparison_intent": "longitudinal",
  "anchor_activity_id": 254,
  "comparison_scope": "activity",
  "similarity_rules": {
    "workout_type_code": "RECOVERY_RUN",
    "purpose_code": "RECOVERY",
    "distance_tolerance_pct": 15,
    "segment_structure": "continuous",
    "lookback_weeks": 12
  },
  "rule_version": "similar-activities-v2"
}
```

Phase 1 不需要立刻新增永久 SQLite table；可以先由查詢層建立 transient context，並把 context 編碼到 URL 或 handoff。Saved Comparison 才需要獨立的持久化模型。

### 必須避免

- 只用活動 ID 清單而沒有 intent 與 rules。
- 讓「相似活動」依賴 SQLite row order。
- 讓 AI 自由決定 similarity rules。

## 3. 審查二：Conditional Baseline 的計算邊界

### 結論：可實作，但必須先固定最小契約

Phase 2 的第一個 baseline profile 定義如下：

```text
同一 workout type
同一 primary training purpose
距離在 anchor 的 ±15%
continuous segment structure
最近 12 週
```

### 輸出欄位

| 欄位 | 定義 |
|---|---|
| `metric` | 被描述的活動指標 |
| `median` | Comparison Set 的中位數 |
| `p25` | 第 25 百分位 |
| `p75` | 第 75 百分位 |
| `sample_count` | 實際納入樣本數 |
| `baseline_window` | 起訖日期或 lookback 條件 |
| `rule_version` | 使用的規則版本 |
| `data_completeness` | 指標可用比例 |
| `status` | `ready` 或 `insufficient_baseline` |

### 最小樣本規則

- `n < 3`：`insufficient_baseline`，不可產生 typical range。
- `n >= 3`：可以產生 median 與 P25–P75，但必須顯示樣本數。
- 不在第一個 baseline 版本建立綜合 Efficiency Score。
- 不把 baseline 寫入 Runner Profile 作為永久能力值。

## 4. 審查三：Anomaly 與 evidence schema

### 結論：三層分類清楚；需要固定 evidence contract

```text
Data Anomaly
Context Anomaly
Performance Anomaly
```

每個 anomaly evidence 至少包含：

```json
{
  "anomaly_type": "performance",
  "metric": "avg_hr",
  "observed_value": 134,
  "expected_range": {"p25": 126, "p75": 128},
  "comparison_set_size": 8,
  "evidence": "observed value is outside the conditional typical range",
  "confidence": "medium",
  "rule_version": "baseline-v1"
}
```

### 責任分工

| 層級 | 平台責任 | AI 責任 |
|---|---|---|
| Data | 找出缺值、來源與映射問題 | 說明資料限制 |
| Context | 標記天氣、路線、距離或序列差異 | 解釋條件可能造成的影響 |
| Performance | 在 baseline 成立後標記偏離 | 提出可能的訓練原因與建議 |

Data Anomaly 或 Context Anomaly 存在時，不應直接宣告 Performance Anomaly。資料不足時應回傳 `not_assessable`，而不是猜測。

## 5. 審查四：Phase 1 Similar Activities 是否可獨立落地

### 結論：可以，且應限制在四個能力

Phase 1 入口可從單堂 Activity 開始：

```text
Activity → 找相似活動 → Similar Activities Comparison
```

### Phase 1 必做

- 以 anchor activity 建立 Comparison Context。
- 以既有治理欄位做 deterministic filter。
- 顯示納入活動與排除理由。
- 進入既有 Activity Comparison 表格。
- 將 intent、anchor 與 rules 帶入 AI handoff。

### Phase 1 不做

- 不做 AI matching。
- 不做 baseline 統計與 outlier 判斷。
- 不做 Saved Comparison。
- 不做首頁卡片。
- 不做週／月聚合。
- 不建立綜合 Efficiency Score。

### Phase 1 建議預設規則

```text
intent = longitudinal
workout_type = anchor workout type
primary_purpose = anchor primary purpose
distance = anchor distance ±15%
lookback = 12 weeks
sort = newest first
```

若 anchor 缺少 workout type、purpose 或 distance，平台應明確顯示無法建立完整 Similar Activities query 的原因，並允許回到自由比較。

## 6. Implementation Spec 必須補上的項目

進入程式開發前，下一份 implementation spec 必須定義：

- `ComparisonContext` 的欄位與序列化格式
- Similar Activities SQL／query contract
- 活動納入與排除理由
- workout type、training purpose、distance 的缺值規則
- rule version 的命名與變更策略
- handoff payload 的固定欄位
- baseline 與 anomaly 的預留介面
- Phase 1 驗收 fixture 與 deterministic expected results

## 7. 審查後的建議路線

```text
Design Review
  ↓
Implementation Spec
  ↓
Similar Activities deterministic query
  ↓
Intent-aware comparison handoff
  ↓
Conditional baseline
  ↓
Anomaly evidence
  ↓
Saved Comparison
```

本審查通過 Phase 1 的設計方向，但不代表後續 baseline、anomaly 或 Saved Comparison 已獲准直接實作；每一階段仍必須遵守本文件的邊界。
