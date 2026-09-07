# CoachOS Longitudinal Behavior Summary Phase 4 Implementation Specification v1.0

## 1. 目的

在既有 Comparison Intelligence comparison set 上，統計最近 N 堂的 execution pattern、Strides role fit 與 rep consistency。這一階段只描述行為重複，不建立能力分數、效率分數、趨勢線或 Saved Comparison。

## 2. Input contract

```python
def build_longitudinal_behavior_summary(anomaly_result: dict, limit: int = 6) -> dict:
    ...
```

輸入必須是已完成 Phase 3 anomaly 與 behavior evidence 的結果。活動順序沿用 comparison result 的 deterministic 新到舊順序；只取前 `limit` 堂，不重新搜尋 SQLite。

## 3. Output contract

```json
{
  "status": "ready",
  "sample_count": 6,
  "requested_limit": 6,
  "primary_execution_pattern_counts": {
    "stable_power_faster_second_half": 3
  },
  "strides_rep_consistency_counts": {
    "consistent": 2,
    "late_acceleration": 1
  },
  "strides_role_fit_counts": {
    "fits_role": 2,
    "review": 1
  },
  "strides_role_fit_rate": 0.6667,
  "late_acceleration_count": 1,
  "interpretation": "描述近期行為重複情況，不代表能力分數或趨勢結論"
}
```

沒有足夠 behavior evidence 時回傳 `not_assessable`。沒有 Strides 的活動不計入 Strides role fit 分母，也不視為 failure。

## 4. Governance rules

- `performance_deviation`、`role_fit`、`execution_pattern` 與 `rep_consistency` 必須保持不同欄位。
- 次數統計不是趨勢判定；不得輸出 improving、declining 或 score。
- 不因 `late_acceleration` 自動判定訓練錯誤，只呈現重複次數供 AI 解釋。
- Context 維持既有 `not_assessable` contract，不在本階段擴充天氣、路線或鞋款資料。
- 本階段不建立 Saved Comparison 或跨週／月聚合。

## 5. AI handoff

Handoff 應顯示最近 N 堂的行為計數，並明確說明這些是 observation counts，不是能力分數或訓練趨勢結論。

## 6. Acceptance criteria

- [ ] 最近 N 堂依既有 deterministic 順序截取。
- [ ] 主段 pattern、Strides consistency、role fit 分別計數。
- [ ] 沒有 Strides 的活動不進入 role fit 分母。
- [ ] `late_acceleration` 只作描述，不自動升級為 anomaly。
- [ ] 不產生 composite score、trend label 或 Saved Comparison。
