# CoachOS Comparison Intelligence Evolution Specification v1.0

## 文件狀態

| 欄位 | 內容 |
|---|---|
| 文件類型 | Product evolution / intelligence architecture specification |
| 版本 | v1.0 |
| 狀態 | Draft for review |
| 前置文件 | `CoachOS Activity Comparison Product Specification v1.0` |
| 目前實作狀態 | Activity Comparison MVP；本文件定義後續演進方向 |

## 1. 產品定位

Activity Comparison 不是用來比較哪一次跑得比較快，而是透過可比較的歷史活動，理解同一類訓練是否正在變得更穩定、更有效率，以及它的生理成本是否正在改變。

產品演進路徑：

```text
Compare → Understand → Benchmark → Detect → Track
```

這條路徑將目前的手動比較工具，逐步發展成 Comparison Intelligence，並最終支援 Longitudinal Intelligence。

## 2. Intelligence hierarchy

| 層級 | 核心問題 | 主要輸出 |
|---|---|---|
| Activity Intelligence | 這堂課真正留下了什麼？ | 單堂活動判讀 |
| Comparison Intelligence | 同一類訓練，我正在怎麼改變？ | 比較集合、差異、基準、異常 |
| Weekly Intelligence | 這週真正練到了什麼？ | 週訓練脈絡與下一步 |
| Monthly Intelligence | 我目前位於哪個訓練位置？ | 月度趨勢與訓練定位 |
| Longitudinal Intelligence | 長期能力到底往哪裡走？ | Saved Comparison 長期追蹤 |

Comparison Intelligence 是 Activity 與 Weekly 之間的中間層；它不是另一種報表，而是把同類活動串成可解釋的訓練演進證據。

## 3. Comparison Context

「相似」不是客觀唯一的結果，必須由比較意圖與規則共同定義。

### 3.1 核心欄位

```text
comparison_intent
anchor_activity
comparison_scope
similarity_rules
baseline_rules
rule_version
```

### 3.2 Comparison Intent

| Intent | 目的 | 典型問題 |
|---|---|---|
| `longitudinal` | 同類課長期演進 | Recovery 是否更穩定？ |
| `training_role` | 相同訓練角色比較 | LSD 後的 Recovery 是否完成吸收？ |
| `shoe` | 鞋款影響比較 | 不同鞋款下的輸出與成本有何差異？ |
| `cross_workout` | 不同課型橫向比較 | Recovery、Easy、Tempo 是否形成不同刺激層級？ |
| `free` | 使用者自由探索 | 這幾堂活動有什麼差異？ |

AI handoff 必須知道 `comparison_intent`，因為同類縱向比較與跨課型比較的分析問題不同。

### 3.3 Similarity Rules

Similarity rules 應以可驗證、可重跑的 deterministic 條件為主，不應一開始依賴 AI matching。

示例：

```yaml
comparison_intent: longitudinal
anchor_activity: 2026-09-07
similarity_rules:
  workout_type: Recovery Run
  purpose: Recovery
  distance_tolerance_pct: 15
  segment_structure: continuous
  lookback: 12 weeks
rule_version: v1
```

未來可加入課表結構、前一堂訓練角色、鞋款、路線與環境條件，但每個條件都必須能說明來源與排除理由。

### 3.4 Segment-aware comparison

課表結構不是只用來判斷活動是否相似，也決定哪些數據可以互相比較。Comparison Set 必須支援 `metric_scope`：

```text
whole_activity
primary_work
strides
```

對有結構的活動：

- `whole_activity` 用於總距離、總時間、訓練負荷與整體成本。
- `primary_work` 用於 Easy／Tempo／LSD 的主要輸出與跑姿比較。
- `strides` 僅與其他 Strides 段比較，不得混入 Easy 或 Tempo 主段。
- WU、Recovery、CD 不得稀釋 `primary_work` 的配速、心率、功率與跑姿。

同一 Comparison Set 可以同時存在多個 baseline layer：`primary_work` 用於 Easy／Tempo／LSD 主體，`whole_activity` 用於訓練負荷與整體成本，`strides` 用於次要神經肌肉刺激。Easy + Strides 必須特別拆成 Easy 有氧主體與 Strides；Tempo／Threshold 拆成品質主段；LSD 保留連續長跑主體。若是沒有結構化分段的連續活動，可明確將整堂活動視為 primary work；若有結構但指定段落無法辨識，則回傳 `not_assessable`，不得靜默混用整堂平均值。

Baseline 與 anomaly evidence 必須逐 metric 回傳 `metric_scope`、資料完整度、觀測值、典型範圍與偏離方向，不能只在整組比較上提供一個全域 scope。

下一階段的 segment-aware evidence 優先順序為：`primary_work` 前半／後半比較，接著才是可辨識的 Strides 逐組比較。前者用於觀察心率漂移、功率維持與 GCT／步幅變化；後者用於觀察組間失速與動作一致性。若來源資料無法可靠切出組別，只回傳 aggregate，不得推測。

只有在前後半功率仍位於固定 band 內時，才可產生 efficiency-like observation；若後半同時提高功率，平台只能描述「輸出提高下的 HR 變化」，不得直接標為 drift。Strides 則以組間一致性與最後一組突增作為 execution evidence，aggregate 只作摘要。

Strides behavior 需要 `segment_intent`：`activation`、`mechanics`、`speed_exposure` 或 `fast_relaxed`。Intent 必須帶有 `source` 與 `confidence`；若沒有使用者設定，平台只能從活動標籤 deterministic 推導並標示低信心。Role fit 只能描述執行是否符合意圖，不能判定訓練對錯。

## 4. Conditional Baseline

Baseline 必須是 Comparison Set 的統計描述，不是 Runner Profile 裡永久不變的能力值。

```text
Baseline = statistical description of a governed Comparison Set
```

### 4.1 Baseline 輸出

第一階段優先支援 robust baseline：

- median
- P25–P75 typical range
- sample count `n`
- baseline window
- comparison rules
- data completeness

示例：

```text
Recovery / 5–7K / continuous / last 8 runs
Pace median: 7:03/km
Typical range: 7:00–7:06/km
Sample count: 8
```

### 4.2 Baseline 原則

- 不以單一平均值代表整組訓練。
- 不把不同課型或不同訓練角色混成一個基準。
- 基準必須能回溯到實際 Comparison Set。
- 基準必須標示樣本數與規則版本。
- 樣本不足時顯示 `insufficient_baseline`，不得製造精準感。

## 5. Anomaly Taxonomy

平台負責發現差異，AI 負責解釋差異。異常必須分成三層，不得混為單一 outlier。

### 5.1 Data Anomaly

資料本身不完整或來源不可靠，例如：

- 缺少平均功率
- FIT 欄位不存在
- 匯入欄位未映射
- 不同資料來源混用
- 單位或解析結果異常

### 5.2 Context Anomaly

活動條件與比較集合不同，例如：

- 極端高溫或濕度
- 強風
- 特殊路線或地形
- 距離明顯不同
- 前一堂訓練角色不同

### 5.3 Performance Anomaly

在資料完整且條件可比較時，實際表現偏離 typical range，例如：

- 配速明顯偏快但心率未同步升高
- 相同配速下心率明顯升高
- 功率、步幅或 GCT 明顯偏離
- 訓練負荷超出同類活動常態

### 5.4 Anomaly record

未來平台層至少應保留：

```text
anomaly_type
metric
observed_value
expected_range
evidence
confidence
```

Data Anomaly 不得被誤判為 Performance Anomaly。

## 6. Context Metrics

比較表應維持可讀性，不把所有上下文欄位塞入主表。

### Primary Metrics

- Pace
- Heart Rate
- Power
- Training Load
- Cadence
- Stride Length
- Ground Contact Time

### Context Metrics

- Temperature
- Humidity
- RPE / Garmin Feeling
- Stamina start / end / delta
- Previous activity
- Previous training role
- Route or terrain context

### Provenance

- source system
- source field
- missingness reason
- repair or backfill status
- calculation version

Context Metrics 應進入平台判讀與 AI handoff，但不必全部出現在主比較表。

## 7. Derived Metrics 邊界

本演進階段不預設建立單一綜合 Efficiency Score。

不同課型的「好」有不同定義：

- Recovery：生理成本低、輸出穩定
- Tempo：目標輸出維持時間增加
- LSD：後段衰減小、跑姿保持
- Strides：動作切換清楚且代謝成本可控

優先順序應為：

```text
Baseline → Deviation → Coach Interpretation
```

只有在實際案例證明某個 derived metric 能穩定改善決策後，才考慮形成課型專屬指標；不得因為欄位很多就製造單一分數。

## 8. Saved Comparison

### 8.1 類型

| 類型 | 說明 | 識別示例 |
|---|---|---|
| Manual Comparison | 固定活動 ID 的一次性比較 | `activity-7-12-31` |
| Query Comparison | 由條件動態產生比較集合 | `query-recovery-6k-last12-v1` |
| Saved Comparison | 可持續更新的長期觀察面板 | `saved-recovery-efficiency-v1` |

### 8.2 Saved Comparison 輸出

首頁或其他高層頁面未來可顯示：

```text
Recovery Efficiency
最近 8 次
HR ↓ 2 bpm · Power stable · Load ↓ 8%
Status: Stable / Improving
```

卡片只顯示結論摘要；點入後必須能查看完整 Comparison Evidence、基準規則與異常原因。

### 8.3 可追溯性

Saved Comparison 必須保存：

- query definition
- rule version
- baseline version
- last refresh time
- included activity IDs
- excluded activity IDs 與理由
- platform interpretation
- optional AI interpretation

規則或算法變更時，不應覆蓋舊結果而失去歷史可追溯性。

## 9. AI 與治理邊界

CoachOS 應維持四層分離：

```text
Facts → Derived Metrics → Platform Interpretation → AI Interpretation
```

- Facts：原始活動與來源資料
- Derived Metrics：由明確規則計算的統計與偏差
- Platform Interpretation：CoachOS 根據治理規則發現的模式與異常
- AI Interpretation：外部 AI 對平台 evidence 的解釋與延伸建議

AI 不得默默修改活動事實、正式訓練標註、Comparison Set 或 baseline。AI 回覆仍應以獨立的比較上下文保存。

## 10. 演進優先順序

### Phase 1：Understand

- 保持手動活動比較 MVP
- 完成比較上下文識別
- 改善資料 provenance 與缺值說明

### Phase 2：Benchmark

- Compare Similar Activities
- Comparison Intent
- deterministic similarity rules
- conditional median / typical range baseline

### Phase 3：Detect

- Data Anomaly
- Context Anomaly
- Performance Anomaly
- platform-side deviation evidence

### Phase 4：Track

- Query Comparison
- Saved Comparison
- 長期自動更新
- 首頁比較卡片

### 延後項目

- 單一綜合 Efficiency Score
- 完全由 AI 決定比較集合
- 未定義條件下的週／月聚合比較

## 11. 驗收原則

- [ ] 每個 Similar Activities 結果都能說明使用的規則。
- [ ] 每個 baseline 都能回溯到 Comparison Set、樣本數與規則版本。
- [ ] Data、Context、Performance anomaly 不混用。
- [ ] 平台先產生差異 evidence，AI 再解釋。
- [ ] 缺值與資料修復狀態可被辨識。
- [ ] 不以單一分數取代課型脈絡。
- [ ] Saved Comparison 可重跑、可更新、可追溯。
- [ ] AI interpretation 不回寫正式活動資料。
