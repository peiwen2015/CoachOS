# CoachOS Similar Activities Phase 1 Implementation Task Breakdown v1.0

## 文件狀態

| 欄位 | 內容 |
|---|---|
| 文件類型 | Test-first implementation plan |
| 版本 | v1.0 |
| 狀態 | Implemented and validated |
| 開發契約 | `CoachOS Similar Activities Phase 1 Implementation Specification v1.0` |
| 目標 | 可重現、可驗證、可解釋的 Similar Activities capability |

## 1. 開發完成定義

給定相同的 anchor activity、comparison intent、rule version 與資料快照，CoachOS 必須穩定產生相同的 Similar Activities 集合與順序，並對每一筆 included／excluded activity 提供可驗證 evidence。

未符合此定義前，不進入 Conditional Baseline 開發。

## 2. Implementation slices

### Slice A：Query domain contract

建立不依賴 HTML 的 query domain functions：

```python
build_comparison_context(connection, anchor_activity_id, comparison_intent="longitudinal")
find_similar_activities(connection, context)
comparison_result_to_activity_ids(result)
```

責任：

- 讀取 anchor 與 required fields
- 建立 `ComparisonContext`
- 固定 `rule_version`
- 驗證缺值與 unsupported intent

不負責：HTML、AI 文字、baseline、anomaly score。

### Slice B：Deterministic rule evaluator

依 implementation spec 的固定順序評估：

1. lookback window
2. workout type
3. primary purpose
4. distance tolerance
5. segment structure

每條規則都回傳：

```text
rule
status = pass | fail | not_evaluable
detail
```

### Slice C：Result ordering and truncation

- 排序固定為 `activity_start_time DESC, activity_id DESC`。
- anchor 是否保留由 context 的 `include_anchor` 決定；預設保留。
- 預設 `result_limit=12`。
- 回傳 candidate count、included before limit、result limit、truncated。

### Slice D：Evidence contract

每筆 candidate 必須回傳：

- activity ID
- match status
- 所有已評估規則的 evidence
- 排除時的主要原因
- metric missingness notes

Evidence 必須由 query layer 產生，presentation layer 不得自行推導「為什麼相似」。

### Slice E：Comparison page integration

- 從 Activity detail 提供「找相似活動」入口。
- 顯示 anchor、intent 與 rules 摘要。
- 顯示 included／excluded 活動與 evidence。
- 將 included IDs 帶入既有 Activity Comparison。
- 保留既有手動自由比較流程。

### Slice F：AI handoff integration

AI handoff 必須帶出：

- comparison intent
- anchor snapshot
- data snapshot reference
- rule version
- similarity rules
- included activities
- match evidence
- missingness notes

AI 不得收到一段沒有 query context 的裸 activity ID 清單。

## 3. Test-first plan

### 3.1 Context construction tests

- [ ] valid anchor 產生完整 context。
- [ ] intent 不是 `longitudinal` 時回傳 unsupported status 或明確拒絕。
- [ ] anchor 缺 workout type、purpose 或 distance 時回傳 `insufficient_anchor_context`。
- [ ] context 包含 anchor snapshot、data snapshot reference 與 rule version。
- [ ] 相同 anchor 與 intent 產生相同 context。

### 3.2 Rule evaluation tests

- [ ] 同 workout type、同 purpose、距離在 ±15%：included。
- [ ] workout type 不同：excluded，evidence 指出 type mismatch。
- [ ] primary purpose 不同：excluded，evidence 指出 purpose mismatch。
- [ ] 距離超過 ±15%：excluded，evidence 包含 anchor distance、candidate distance 與 delta。
- [ ] 超出 12 週：excluded，evidence 指出 lookback failure。
- [ ] 多個課表分段：仍可 included，structure evidence 作為補充說明，不得直接排除。
- [ ] structure 缺失：not evaluable，不得猜測為 continuous，也不得因此排除活動。

### 3.3 Determinism tests

- [ ] 同一資料快照重跑兩次，included IDs 與順序完全相同。
- [ ] 建立不同 SQLite insertion order 的 fixture，結果仍相同。
- [ ] 兩筆活動時間完全相同時，以 `activity_id DESC` tie-break。
- [ ] candidate 超過 12 筆時，截斷結果與 metadata 完全相同。
- [ ] anchor 的輸入順序或 URL 順序改變，不改變結果集合。

### 3.4 Evidence tests

- [ ] 每筆 included activity 具有所有 pass evidence。
- [ ] 每筆 excluded activity 具有至少一個 fail 或 not_evaluable evidence。
- [ ] evidence detail 不依賴 HTML formatting。
- [ ] missing metric 不會變成零值或 similarity failure。
- [ ] evidence 包含實際 rule version。

### 3.5 Integration tests

- [ ] Activity detail 可以建立 Similar Activities query。
- [ ] Similar Activities 結果可以導入既有比較表。
- [ ] AI handoff 包含 context、rules 與 evidence。
- [ ] query 執行不修改 activity、metadata 或 Semantic Layer。
- [ ] 原本的手動自由比較仍可正常使用。

## 4. Fixture minimum set

測試 fixture 至少包含：

| Fixture | 用途 |
|---|---|
| anchor recovery 6K | 基本成功案例 |
| same type / wrong purpose | purpose exclusion |
| same purpose / distance too far | distance exclusion |
| old activity | lookback exclusion |
| missing workout type | anchor／candidate missingness |
| missing power only | metric missingness but still included |
| same timestamp pair | deterministic tie-break |
| 13+ included candidates | truncation |

Fixture 應使用明確的 activity IDs、時間、workout type、purpose 與 distance，避免測試依賴真實資料目前的排序或數量。

## 5. Implementation order

```text
Tests / fixtures
  ↓
Context builder
  ↓
Rule evaluator
  ↓
Result ordering / truncation
  ↓
Evidence contract
  ↓
Query integration
  ↓
UI entry
  ↓
Comparison page integration
  ↓
AI handoff integration
```

任何 slice 若需要 baseline、outlier、score 或 Saved Comparison 才能完成，代表已超出 Phase 1 scope，應停止並回到本文件檢查邊界。

## 6. Release gate

Phase 1 只有在以下條件全部成立後才可標記完成：

- [x] query contract tests 全數通過。
- [x] determinism tests 全數通過。
- [x] evidence contract tests 全數通過。
- [x] integration tests 全數通過。
- [x] 手動自由比較未回歸。
- [x] AI handoff 可追溯至 context、rule version 與 evidence。
- [x] 沒有 baseline、outlier、score 或 Saved Comparison 行為混入。
