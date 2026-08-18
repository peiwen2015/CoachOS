# CoachOS Chart Rendering Contract v0.1

## Purpose

This document defines the stable payload contract between chart semantics and the front-end renderer.

It ensures chart surfaces can render without understanding SQL, metric formulas, or training logic.

The contract is intended to support:

- web
- mobile
- future chart cards
- future AI-assisted briefing surfaces

## Contract Boundary

This contract is responsible for:

- payload shape
- chart status
- series structure
- reference band structure
- annotations
- verdict structure
- drill-down identifiers
- schema versioning
- missing-data behavior

This contract is not responsible for:

- formula governance
- raw data cleaning
- SQL view logic
- visual styling
- pixel-level layout
- AI-generated freeform coach text

## Rendering Principles

1. The renderer should consume a stable JSON-like envelope.
2. The renderer should not infer chart meaning from label text.
3. The renderer should not re-derive training metrics from raw rows.
4. The renderer should treat `status` and `confidence` as first-class fields.
5. The renderer should support partial and estimated outputs without breaking layout.
6. The renderer should display verdict and evidence separately.
7. The renderer should use the same contract for web, mobile, and chart cards.

## Shared Envelope

Every chart payload should use the same outer shape.

```json
{
  "chart_id": "weekly_training_load",
  "schema_version": "0.1",
  "generated_at": "2026-07-20T08:00:00Z",
  "athlete_id": "athlete_123",
  "status": "available",
  "title": "週訓練負荷趨勢",
  "decision_question": "最近的訓練負荷是否穩定且合理？",
  "period": {
    "start_date": "2026-05-04",
    "end_date": "2026-07-19",
    "timezone": "Asia/Taipei"
  },
  "summary": {},
  "axes": {},
  "series": [],
  "reference_bands": [],
  "annotations": [],
  "verdict": {},
  "data_quality": {},
  "drill_down": {},
  "empty_state": {}
}
```

## Status Values

The `status` field must use one of these values:

```text
available
partial
estimated
not_applicable
insufficient_data
invalid
error
```

### Status Semantics

- `available`: the chart can render normally
- `partial`: the chart can render, but some fields are missing
- `estimated`: the chart relies on one or more estimated values
- `not_applicable`: the activity or period is not suitable for this chart
- `insufficient_data`: there is not enough data for a reliable chart
- `invalid`: the data failed quality rules
- `error`: the system failed during rendering or fetch

`error` must not be used as a synonym for missing data.

## Series Contract

Every series should use the same structure.

```json
{
  "series_id": "training_load",
  "label": "訓練負荷",
  "type": "line",
  "unit": "load",
  "axis": "left",
  "display_precision": 0,
  "hidden_by_default": false,
  "source_method": "coachos_derived",
  "data_quality_status": "available",
  "points": [
    {
      "x": "2026-07-13",
      "y": 412,
      "status": "available",
      "source": "coachos_derived"
    }
  ]
}
```

### Series Fields

- `series_id`
- `label`
- `type`
- `unit`
- `axis`
- `display_precision`
- `hidden_by_default`
- `source_method`
- `data_quality_status`
- `points`

### Series Types

Recommended values:

```text
line
bar
area
scatter
band
threshold
```

## Reference Band Contract

Reference bands are used for targets, acceptable ranges, and baseline windows.

```json
{
  "band_id": "target_load_range",
  "label": "建議負荷區間",
  "axis": "left",
  "start_x": "2026-07-13",
  "end_x": "2026-07-19",
  "lower": 360,
  "upper": 460,
  "unit": "load",
  "status": "estimated",
  "method": "provisional_rule_v0.1"
}
```

### Band Fields

- `band_id`
- `label`
- `axis`
- `start_x`
- `end_x`
- `lower`
- `upper`
- `unit`
- `status`
- `method`

## Annotation Contract

Annotations should encode events, warnings, and noteworthy milestones.

```json
{
  "annotation_id": "load_spike_2026_w29",
  "type": "warning",
  "x": "2026-07-13",
  "label": "負荷增幅偏高",
  "detail": "較前一週增加 24%",
  "rule_id": "weekly_load_change_warning_v0.1",
  "severity": "medium"
}
```

### Annotation Types

```text
info
positive
warning
critical
event
target
```

## Verdict Contract

Verdicts should be machine-readable, not just pretty copy.

```json
{
  "status": "warning",
  "code": "LOAD_INCREASE_HIGH",
  "headline": "本週負荷增加偏快",
  "message": "本週訓練負荷較上週增加 24%，高於目前建議範圍。",
  "confidence": "medium",
  "rule_id": "weekly_load_change_warning_v0.1",
  "evidence": [
    {
      "metric": "load_change_wow_pct",
      "value": 24,
      "unit": "%"
    }
  ],
  "limitations": [
    "急性／慢性負荷模型尚未納入"
  ]
}
```

### Verdict Fields

- `status`
- `code`
- `headline`
- `message`
- `confidence`
- `rule_id`
- `evidence`
- `limitations`

### Verdict Confidence

Recommended values:

```text
high
medium
low
unknown
```

## Data Quality Contract

The renderer should receive data quality as a separate object.

```json
{
  "overall_status": "partial",
  "completeness_score": 0.86,
  "confidence": "medium",
  "missing_fields": [
    "average_power_w"
  ],
  "estimated_fields": [],
  "invalid_fields": [],
  "coverage": {
    "heart_rate_pct": 96.4,
    "pace_pct": 99.8,
    "power_pct": 0
  },
  "limitations": [
    "本次分析未使用跑步功率"
  ]
}
```

### Data Quality Fields

- `overall_status`
- `completeness_score`
- `confidence`
- `missing_fields`
- `estimated_fields`
- `invalid_fields`
- `coverage`
- `limitations`

## Drill-Down Contract

The renderer should expose drill-down metadata, not raw business logic.

```json
{
  "enabled": true,
  "target_type": "week",
  "target_id": "2026-W29",
  "fields": [
    "pace",
    "heart_rate",
    "power",
    "cadence",
    "elevation"
  ],
  "notes": [
    "點擊後可展開週內活動明細"
  ]
}
```

### Drill-Down Fields

- `enabled`
- `target_type`
- `target_id`
- `fields`
- `notes`

## Empty State Contract

Charts should define how to render when there is no data.

```json
{
  "title": "目前沒有足夠資料",
  "message": "這張圖需要更多完整活動才能顯示。",
  "action_label": "查看最近活動",
  "action_target": "/?page=activity"
}
```

## Global Render Contract

All chart payloads should support the following fields where relevant:

- `title`
- `decision_question`
- `period`
- `summary`
- `axes`
- `series`
- `reference_bands`
- `annotations`
- `verdict`
- `data_quality`
- `drill_down`
- `empty_state`

### Axes Contract

The `axes` object should define the visible chart coordinate system.

Recommended keys:

- `x`
- `y_left`
- `y_right`

Each axis should describe:

- label
- unit
- display format
- scale type

## Chart-Specific Payloads

### 1. Weekly Training Load Trend

Recommended `summary`:

```json
{
  "current_week_load": 412,
  "previous_week_load": 332,
  "change_wow_pct": 24.1,
  "current_week_distance_km": 48.2,
  "current_week_duration_hr": 5.1,
  "acute_load": 412,
  "chronic_load": 356,
  "acute_chronic_ratio": 1.16,
  "trend_direction": "up",
  "phase_label": "build"
}
```

Recommended `series`:

- weekly load
- weekly distance
- weekly duration
- acute load or chronic load baseline if available

Recommended `reference_bands`:

- recent baseline band
- suggested load band

Recommended `annotations`:

- spike warning
- recovery week
- race week
- taper week

Recommended `verdict`:

- `status`: available, partial, or warning
- `code`: `LOAD_STABLE`, `LOAD_INCREASE_HIGH`, `LOAD_UNDERDONE`

### 2. Goal vs Actual Workout Completion

Recommended `summary`:

```json
{
  "planned_segments": 12,
  "completed_segments": 11,
  "target_compliance_pct": 92.4,
  "late_session_fade_pct": 5.8,
  "missed_targets": 1,
  "best_block_compliance_pct": 98.0,
  "worst_block_compliance_pct": 71.5
}
```

Recommended `series`:

- target band
- actual pace or effort
- per-segment completion line or bars

Recommended `reference_bands`:

- target pace range
- target effort range

Recommended `annotations`:

- missed interval
- slow start
- late fade

Recommended `verdict`:

- `status`: available, partial, warning, or insufficient_data
- `code`: `WORKOUT_ON_TARGET`, `WORKOUT_PARTIAL`, `WORKOUT_OFF_TARGET`

### 3. Pace and Heart Rate Decoupling

Recommended `summary`:

```json
{
  "first_half_avg_pace_sec_per_km": 315,
  "second_half_avg_pace_sec_per_km": 325,
  "first_half_avg_hr": 145,
  "second_half_avg_hr": 155,
  "pace_change_pct": 3.2,
  "heart_rate_change_pct": 6.9,
  "aerobic_decoupling_pct": 10.1,
  "sample_quality_status": "sufficient"
}
```

Recommended `series`:

- pace trend
- heart rate trend
- optional power trend

Recommended `reference_bands`:

- stable-effort band
- acceptable drift band

Recommended `annotations`:

- route distortion
- heat warning
- late drift

Recommended `verdict`:

- `status`: available, partial, estimated, or insufficient_data
- `code`: `STABLE`, `MODERATE_DRIFT`, `CLEAR_DRIFT`

### 4. Weekly Intensity Distribution

Recommended `summary`:

```json
{
  "period_type": "rolling_4w",
  "low_intensity_share_pct": 72.0,
  "moderate_intensity_share_pct": 18.0,
  "high_intensity_share_pct": 10.0,
  "dominant_band": "low",
  "zone_system": "workout_type_intensity_category"
}
```

Recommended `series`:

- stacked bars by intensity band
- one series per intensity category

Recommended `reference_bands`:

- low-dominant target range
- balance range

Recommended `annotations`:

- intensity overload
- unusually hard week

Recommended `verdict`:

- `status`: available, partial, or warning
- `code`: `LOW_DOMINANT`, `BALANCED`, `HIGH_INTENSITY_HEAVY`

## Payload Versioning

The `schema_version` field should change when:

- a required field is added
- a required field is removed
- field meaning changes
- status semantics change

The renderer should be able to reject unsupported versions gracefully.

## Compatibility Rule

The chart renderer should only depend on this contract and not on direct SQL shape.

Semantic view changes should be isolated behind the rendering payload builder.

## Relationship to Other Documents

This document should be read together with:

- [`CoachOS Chart Priorities v0.1.md`](../00_Governance/CoachOS%20Chart%20Priorities%20v0.1.md)
- [`CoachOS Chart Requirements Specification v0.1.md`](../00_Governance/CoachOS%20Chart%20Requirements%20Specification%20v0.1.md)
- [`CoachOS Chart Semantic View and Data Field Mapping v0.1.md`](../00_Governance/CoachOS%20Chart%20Semantic%20View%20and%20Data%20Field%20Mapping%20v0.1.md)
- [`CoachOS Chart Semantic View SQL Draft v0.1.sql`](../30_Physical_Model/CoachOS%20Chart%20Semantic%20View%20SQL%20Draft%20v0.1.sql)
- [`CoachOS Chart API Payload Examples v0.1.md`](./CoachOS%20Chart%20API%20Payload%20Examples%20v0.1.md)
- [`Monthly Coach Briefing v0.1.md`](./Monthly%20Coach%20Briefing%20v0.1.md)

## Status

`CoachOS Chart Rendering Contract v0.1`

- Status: Draft
- Scope: Chart payload envelope, render-time state, and chart-card interoperability
- Classification: Architecture / Rendering Contract
