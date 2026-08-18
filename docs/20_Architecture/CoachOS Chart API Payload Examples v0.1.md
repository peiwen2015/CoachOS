# CoachOS Chart API Payload Examples v0.1

## Purpose

This document provides concrete payload examples for the chart rendering contract.

It exists to make the contract testable before dashboard implementation begins.

The examples are intentionally boring and deterministic.

They should be suitable for:

- front-end component development
- contract tests
- Storybook or equivalent fixture-driven UI review
- screenshot regression tests

## Relationship to Other Documents

This document should be read together with:

- [`CoachOS Chart Rendering Contract v0.1.md`](./CoachOS%20Chart%20Rendering%20Contract%20v0.1.md)
- [`CoachOS Chart Semantic View and Data Field Mapping v0.1.md`](../00_Governance/CoachOS%20Chart%20Semantic%20View%20and%20Data%20Field%20Mapping%20v0.1.md)
- [`CoachOS Chart Semantic View SQL Draft v0.1.sql`](../30_Physical_Model/CoachOS%20Chart%20Semantic%20View%20SQL%20Draft%20v0.1.sql)
- [`CoachOS Chart Requirements Specification v0.1.md`](../00_Governance/CoachOS%20Chart%20Requirements%20Specification%20v0.1.md)

## Example Set

Each MVP chart includes:

- `available`
- `partial`
- `insufficient_data`
- one chart-specific fallback case

The chart-specific fallback case is the one that matters most for implementation.

## 1. Weekly Training Load Trend

### 1.1 Available

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
  "summary": {
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
  },
  "axes": {
    "x": {
      "label": "週次",
      "unit": "week",
      "scale": "time"
    },
    "y_left": {
      "label": "負荷 / 里程",
      "unit": "load|km",
      "scale": "linear"
    }
  },
  "series": [
    {
      "series_id": "weekly_training_load",
      "label": "訓練負荷",
      "type": "line",
      "unit": "load",
      "axis": "left",
      "display_precision": 0,
      "hidden_by_default": false,
      "source_method": "coachos_derived",
      "data_quality_status": "available",
      "points": [
        { "x": "2026-05-04", "y": 298, "status": "available", "source": "weekly_training_load_view" },
        { "x": "2026-05-11", "y": 316, "status": "available", "source": "weekly_training_load_view" },
        { "x": "2026-05-18", "y": 340, "status": "available", "source": "weekly_training_load_view" },
        { "x": "2026-05-25", "y": 355, "status": "available", "source": "weekly_training_load_view" },
        { "x": "2026-06-01", "y": 372, "status": "available", "source": "weekly_training_load_view" },
        { "x": "2026-06-08", "y": 384, "status": "available", "source": "weekly_training_load_view" },
        { "x": "2026-06-15", "y": 401, "status": "available", "source": "weekly_training_load_view" },
        { "x": "2026-06-22", "y": 389, "status": "available", "source": "weekly_training_load_view" },
        { "x": "2026-06-29", "y": 395, "status": "available", "source": "weekly_training_load_view" },
        { "x": "2026-07-06", "y": 402, "status": "available", "source": "weekly_training_load_view" },
        { "x": "2026-07-13", "y": 412, "status": "available", "source": "weekly_training_load_view" },
        { "x": "2026-07-20", "y": 0, "status": "available", "source": "weekly_training_load_view" }
      ]
    }
  ],
  "reference_bands": [
    {
      "band_id": "recent_baseline",
      "label": "近期基準",
      "axis": "left",
      "start_x": "2026-06-15",
      "end_x": "2026-07-13",
      "lower": 380,
      "upper": 405,
      "unit": "load",
      "status": "estimated",
      "method": "4w_trailing_average"
    }
  ],
  "annotations": [
    {
      "annotation_id": "week_2026_07_13",
      "type": "warning",
      "x": "2026-07-13",
      "label": "負荷增幅偏高",
      "detail": "較前一週增加 24%",
      "rule_id": "weekly_load_change_warning_v0.1",
      "severity": "medium"
    }
  ],
  "verdict": {
    "status": "warning",
    "code": "LOAD_INCREASE_HIGH",
    "headline": "本週負荷增加偏快",
    "message": "本週訓練負荷較上週增加 24%，高於目前建議範圍。",
    "confidence": "medium",
    "rule_id": "weekly_load_change_warning_v0.1",
    "evidence": [
      { "metric": "current_week_load", "value": 412, "unit": "load" },
      { "metric": "change_wow_pct", "value": 24.1, "unit": "%" }
    ],
    "limitations": [
      "急性／慢性負荷模型尚未納入"
    ]
  },
  "data_quality": {
    "overall_status": "available",
    "completeness_score": 0.98,
    "confidence": "high",
    "missing_fields": [],
    "estimated_fields": [
      "acute_chronic_ratio"
    ],
    "invalid_fields": [],
    "coverage": {
      "training_load_pct": 100,
      "distance_pct": 100,
      "duration_pct": 100
    },
    "limitations": []
  },
  "drill_down": {
    "enabled": true,
    "target_type": "week",
    "target_id": "2026-W29",
    "fields": [
      "activity_id",
      "date",
      "distance_km",
      "duration_sec",
      "training_load",
      "activity_type"
    ],
    "notes": [
      "點擊後可查看週內活動清單"
    ]
  },
  "empty_state": {
    "title": "目前沒有足夠資料",
    "message": "這張圖需要至少數週完整訓練資料。",
    "action_label": "查看最近活動",
    "action_target": "/?page=activity"
  }
}
```

### 1.2 Partial

```json
{
  "chart_id": "weekly_training_load",
  "schema_version": "0.1",
  "generated_at": "2026-07-20T08:00:00Z",
  "athlete_id": "athlete_123",
  "status": "partial",
  "title": "週訓練負荷趨勢",
  "decision_question": "最近的訓練負荷是否穩定且合理？",
  "period": {
    "start_date": "2026-06-01",
    "end_date": "2026-07-19",
    "timezone": "Asia/Taipei"
  },
  "summary": {
    "current_week_load": 288,
    "previous_week_load": 301,
    "change_wow_pct": -4.3,
    "current_week_distance_km": 41.5,
    "current_week_duration_hr": 4.2,
    "phase_label": "build"
  },
  "axes": {
    "x": { "label": "週次", "unit": "week", "scale": "time" },
    "y_left": { "label": "負荷 / 里程", "unit": "load|km", "scale": "linear" }
  },
  "series": [
    {
      "series_id": "weekly_distance",
      "label": "週里程",
      "type": "line",
      "unit": "km",
      "axis": "left",
      "display_precision": 1,
      "hidden_by_default": false,
      "source_method": "coachos_derived",
      "data_quality_status": "partial",
      "points": [
        { "x": "2026-06-01", "y": 32.1, "status": "available", "source": "weekly_training_load_view" },
        { "x": "2026-06-08", "y": 35.8, "status": "available", "source": "weekly_training_load_view" },
        { "x": "2026-06-15", "y": 38.4, "status": "available", "source": "weekly_training_load_view" },
        { "x": "2026-06-22", "y": 36.0, "status": "available", "source": "weekly_training_load_view" },
        { "x": "2026-06-29", "y": 39.0, "status": "available", "source": "weekly_training_load_view" },
        { "x": "2026-07-06", "y": 41.2, "status": "available", "source": "weekly_training_load_view" },
        { "x": "2026-07-13", "y": 41.5, "status": "available", "source": "weekly_training_load_view" }
      ]
    }
  ],
  "reference_bands": [],
  "annotations": [],
  "verdict": {
    "status": "info",
    "code": "LOAD_PARTIAL",
    "headline": "負荷趨勢可判讀，但負荷欄位不完整",
    "message": "本週可顯示里程與時間趨勢，但部分訓練負荷資料缺失。",
    "confidence": "medium",
    "rule_id": "weekly_load_partial_v0.1",
    "evidence": [
      { "metric": "change_wow_pct", "value": -4.3, "unit": "%" }
    ],
    "limitations": [
      "部分活動未提供 training load"
    ]
  },
  "data_quality": {
    "overall_status": "partial",
    "completeness_score": 0.71,
    "confidence": "medium",
    "missing_fields": [
      "weekly_training_load",
      "acute_chronic_ratio"
    ],
    "estimated_fields": [],
    "invalid_fields": [],
    "coverage": {
      "training_load_pct": 54,
      "distance_pct": 100,
      "duration_pct": 100
    },
    "limitations": [
      "訓練負荷資料不足"
    ]
  },
  "drill_down": {
    "enabled": true,
    "target_type": "week",
    "target_id": "2026-W28",
    "fields": [
      "activity_id",
      "distance_km",
      "duration_sec",
      "training_load"
    ],
    "notes": [
      "可查看哪些活動缺少 training load"
    ]
  },
  "empty_state": {
    "title": "目前沒有足夠資料",
    "message": "這張圖仍可部分顯示，但完整負荷判讀需要更多資料。",
    "action_label": "查看最近活動",
    "action_target": "/?page=activity"
  }
}
```

### 1.3 Insufficient Data

```json
{
  "chart_id": "weekly_training_load",
  "schema_version": "0.1",
  "generated_at": "2026-07-20T08:00:00Z",
  "athlete_id": "athlete_123",
  "status": "insufficient_data",
  "title": "週訓練負荷趨勢",
  "decision_question": "最近的訓練負荷是否穩定且合理？",
  "period": {
    "start_date": "2026-06-29",
    "end_date": "2026-07-19",
    "timezone": "Asia/Taipei"
  },
  "summary": {},
  "axes": {},
  "series": [],
  "reference_bands": [],
  "annotations": [],
  "verdict": {
    "status": "unknown",
    "code": "LOAD_INSUFFICIENT",
    "headline": "資料不足，暫時無法判讀負荷趨勢",
    "message": "目前可用週數太少，還無法建立可靠的趨勢與基準。",
    "confidence": "low",
    "rule_id": "weekly_load_insufficient_v0.1",
    "evidence": [],
    "limitations": [
      "至少需要 4 週以上可用資料"
    ]
  },
  "data_quality": {
    "overall_status": "insufficient_data",
    "completeness_score": 0.18,
    "confidence": "low",
    "missing_fields": [
      "training_load_history"
    ],
    "estimated_fields": [],
    "invalid_fields": [],
    "coverage": {
      "training_load_pct": 18,
      "distance_pct": 100,
      "duration_pct": 100
    },
    "limitations": [
      "歷史週數不足"
    ]
  },
  "drill_down": {
    "enabled": false,
    "target_type": "week",
    "target_id": null,
    "fields": [],
    "notes": []
  },
  "empty_state": {
    "title": "資料還不夠",
    "message": "先累積更多完整訓練週期，這張圖才會可靠。",
    "action_label": "查看最近活動",
    "action_target": "/?page=activity"
  }
}
```

### 1.4 Chart-Specific Fallback

```json
{
  "chart_id": "weekly_training_load",
  "schema_version": "0.1",
  "generated_at": "2026-07-20T08:00:00Z",
  "athlete_id": "athlete_123",
  "status": "partial",
  "title": "週訓練負荷趨勢",
  "decision_question": "最近的訓練負荷是否穩定且合理？",
  "period": {
    "start_date": "2026-07-06",
    "end_date": "2026-07-19",
    "timezone": "Asia/Taipei"
  },
  "summary": {
    "current_week_distance_km": 44.9,
    "current_week_duration_hr": 4.6,
    "trend_direction": "flat"
  },
  "axes": {
    "x": { "label": "週次", "unit": "week", "scale": "time" },
    "y_left": { "label": "里程 / 時間", "unit": "km|hr", "scale": "linear" }
  },
  "series": [
    {
      "series_id": "weekly_distance",
      "label": "週里程",
      "type": "line",
      "unit": "km",
      "axis": "left",
      "display_precision": 1,
      "hidden_by_default": false,
      "source_method": "coachos_derived",
      "data_quality_status": "available",
      "points": [
        { "x": "2026-07-06", "y": 43.8, "status": "available", "source": "weekly_training_load_view" },
        { "x": "2026-07-13", "y": 44.9, "status": "available", "source": "weekly_training_load_view" }
      ]
    },
    {
      "series_id": "weekly_duration",
      "label": "週訓練時間",
      "type": "line",
      "unit": "hr",
      "axis": "right",
      "display_precision": 1,
      "hidden_by_default": false,
      "source_method": "coachos_derived",
      "data_quality_status": "available",
      "points": [
        { "x": "2026-07-06", "y": 4.5, "status": "available", "source": "weekly_training_load_view" },
        { "x": "2026-07-13", "y": 4.6, "status": "available", "source": "weekly_training_load_view" }
      ]
    }
  ],
  "reference_bands": [],
  "annotations": [],
  "verdict": {
    "status": "partial",
    "code": "LOAD_FALLBACK_DISTANCE_ONLY",
    "headline": "目前無法顯示負荷，但可先看里程與時間",
    "message": "training load 缺失，因此此圖降級為距離與時間趨勢。",
    "confidence": "medium",
    "rule_id": "weekly_load_fallback_v0.1",
    "evidence": [
      { "metric": "current_week_distance_km", "value": 44.9, "unit": "km" },
      { "metric": "current_week_duration_hr", "value": 4.6, "unit": "hr" }
    ],
    "limitations": [
      "training load unavailable"
    ]
  },
  "data_quality": {
    "overall_status": "partial",
    "completeness_score": 0.63,
    "confidence": "medium",
    "missing_fields": [
      "weekly_training_load",
      "acute_chronic_ratio"
    ],
    "estimated_fields": [],
    "invalid_fields": [],
    "coverage": {
      "training_load_pct": 0,
      "distance_pct": 100,
      "duration_pct": 100
    },
    "limitations": [
      "降級為里程與時間趨勢"
    ]
  },
  "drill_down": {
    "enabled": true,
    "target_type": "week",
    "target_id": "2026-W29",
    "fields": [
      "activity_id",
      "distance_km",
      "duration_sec"
    ],
    "notes": [
      "可先檢查週內活動是否都有完整 training load"
    ]
  },
  "empty_state": {
    "title": "目前沒有足夠資料",
    "message": "這張圖已降級為距離與時間，不再顯示負荷判讀。",
    "action_label": "查看最近活動",
    "action_target": "/?page=activity"
  }
}
```

## 2. Goal vs Actual Workout Completion

### 2.1 Available

```json
{
  "chart_id": "workout_completion",
  "schema_version": "0.1",
  "generated_at": "2026-07-20T08:00:00Z",
  "athlete_id": "athlete_123",
  "status": "available",
  "title": "課表目標與實際完成",
  "decision_question": "這堂課是否按原定課表完成？",
  "analysis_mode": "goal_vs_actual",
  "planned_data_status": "authoritative",
  "workout_source": "coachos",
  "alignment_method": "exact_step_reference",
  "alignment_confidence": "high",
  "period": {
    "start_date": "2026-07-20",
    "end_date": "2026-07-20",
    "timezone": "Asia/Taipei"
  },
  "summary": {
    "planned_segments": 12,
    "completed_segments": 11,
    "target_compliance_pct": 92.4,
    "late_session_fade_pct": 5.8,
    "missed_targets": 1,
    "best_block_compliance_pct": 98.0,
    "worst_block_compliance_pct": 71.5
  },
  "axes": {
    "x": { "label": "區段", "unit": "segment", "scale": "ordinal" },
    "y_left": { "label": "配速 / 努力", "unit": "sec_per_km|bpm|w", "scale": "linear" }
  },
  "series": [
    {
      "series_id": "target_pace_band",
      "label": "目標配速區間",
      "type": "band",
      "unit": "sec_per_km",
      "axis": "left",
      "display_precision": 0,
      "hidden_by_default": false,
      "source_method": "coachos_planned",
      "data_quality_status": "available",
      "points": []
    },
    {
      "series_id": "actual_pace",
      "label": "實際配速",
      "type": "line",
      "unit": "sec_per_km",
      "axis": "left",
      "display_precision": 0,
      "hidden_by_default": false,
      "source_method": "coachos_derived",
      "data_quality_status": "available",
      "points": [
        { "x": "1", "y": 320, "status": "available", "source": "workout_execution_segment_view" },
        { "x": "2", "y": 314, "status": "available", "source": "workout_execution_segment_view" },
        { "x": "3", "y": 311, "status": "available", "source": "workout_execution_segment_view" }
      ]
    }
  ],
  "reference_bands": [
    {
      "band_id": "target_pace_range",
      "label": "課表目標區間",
      "axis": "left",
      "start_x": "1",
      "end_x": "12",
      "lower": 308,
      "upper": 318,
      "unit": "sec_per_km",
      "status": "available",
      "method": "planned_workout_segment_view"
    }
  ],
  "annotations": [
    {
      "annotation_id": "late_fade_block_4",
      "type": "warning",
      "x": "9",
      "label": "後段略慢",
      "detail": "最後三組配速略高於目標",
      "rule_id": "workout_late_fade_v0.1",
      "severity": "medium"
    }
  ],
  "verdict": {
    "status": "available",
    "code": "WORKOUT_ON_TARGET",
    "headline": "這堂課大致按原定完成",
    "message": "大多數區段都落在目標範圍內，後段出現輕微疲勞但未影響整體完成。",
    "confidence": "high",
    "rule_id": "workout_completion_v0.1",
    "evidence": [
      { "metric": "target_compliance_pct", "value": 92.4, "unit": "%" },
      { "metric": "missed_targets", "value": 1, "unit": "segment" }
    ],
    "limitations": []
  },
  "data_quality": {
    "overall_status": "available",
    "completeness_score": 0.97,
    "confidence": "high",
    "missing_fields": [],
    "estimated_fields": [],
    "invalid_fields": [],
    "coverage": {
      "planned_segments_pct": 100,
      "execution_segments_pct": 100
    },
    "limitations": []
  },
  "drill_down": {
    "enabled": true,
    "target_type": "activity",
    "target_id": "activity_8891",
    "fields": [
      "segment_id",
      "target_metric",
      "target_min",
      "target_max",
      "actual_pace_sec_per_km",
      "actual_duration_s",
      "average_heart_rate_bpm",
      "average_power_w"
    ],
    "notes": [
      "可查看每組與恢復段的細節"
    ]
  },
  "empty_state": {
    "title": "目前沒有足夠資料",
    "message": "這堂課有正式課表與執行資料，因此不會顯示空狀態。",
    "action_label": "查看最近活動",
    "action_target": "/?page=activity"
  }
}
```

### 2.2 Actual-Only

```json
{
  "chart_id": "workout_completion",
  "schema_version": "0.1",
  "generated_at": "2026-07-20T08:00:00Z",
  "athlete_id": "athlete_123",
  "status": "partial",
  "title": "課表目標與實際完成",
  "decision_question": "這堂課是否按原定課表完成？",
  "analysis_mode": "actual_only",
  "planned_data_status": "unavailable",
  "workout_source": null,
  "alignment_method": "inferred_pattern",
  "alignment_confidence": "medium",
  "period": {
    "start_date": "2026-07-20",
    "end_date": "2026-07-20",
    "timezone": "Asia/Taipei"
  },
  "summary": {
    "segment_count": 9,
    "stable_segment_count": 6,
    "late_session_fade_pct": 4.1,
    "actual_only": true
  },
  "axes": {
    "x": { "label": "區段", "unit": "segment", "scale": "ordinal" },
    "y_left": { "label": "配速 / 心率", "unit": "sec_per_km|bpm", "scale": "linear" }
  },
  "series": [
    {
      "series_id": "actual_pace",
      "label": "實際配速",
      "type": "line",
      "unit": "sec_per_km",
      "axis": "left",
      "display_precision": 0,
      "hidden_by_default": false,
      "source_method": "coachos_derived",
      "data_quality_status": "available",
      "points": [
        { "x": "1", "y": 326, "status": "available", "source": "workout_execution_segment_view" },
        { "x": "2", "y": 321, "status": "available", "source": "workout_execution_segment_view" }
      ]
    }
  ],
  "reference_bands": [],
  "annotations": [
    {
      "annotation_id": "no_plan_note",
      "type": "info",
      "x": "1",
      "label": "沒有正式課表",
      "detail": "改以實際執行分析",
      "rule_id": "workout_actual_only_v0.1",
      "severity": "low"
    }
  ],
  "verdict": {
    "status": "info",
    "code": "WORKOUT_ACTUAL_ONLY",
    "headline": "未取得正式課表，先看實際執行",
    "message": "這次沒有正式課表資料，因此不顯示達標判讀，只做分段穩定性分析。",
    "confidence": "medium",
    "rule_id": "workout_actual_only_v0.1",
    "evidence": [
      { "metric": "late_session_fade_pct", "value": 4.1, "unit": "%" }
    ],
    "limitations": [
      "未取得原始課表"
    ]
  },
  "data_quality": {
    "overall_status": "partial",
    "completeness_score": 0.82,
    "confidence": "medium",
    "missing_fields": [
      "planned_segments",
      "target_compliance_pct"
    ],
    "estimated_fields": [],
    "invalid_fields": [],
    "coverage": {
      "planned_segments_pct": 0,
      "execution_segments_pct": 100
    },
    "limitations": [
      "只能做 actual-only execution analysis"
    ]
  },
  "drill_down": {
    "enabled": true,
    "target_type": "activity",
    "target_id": "activity_8892",
    "fields": [
      "segment_id",
      "actual_pace_sec_per_km",
      "actual_duration_s",
      "average_heart_rate_bpm"
    ],
    "notes": [
      "不提供正式達標與未達標判斷"
    ]
  },
  "empty_state": {
    "title": "目前沒有足夠資料",
    "message": "這次沒有原始課表，因此只顯示實際執行分析。",
    "action_label": "查看最近活動",
    "action_target": "/?page=activity"
  }
}
```

### 2.3 Insufficient Data

```json
{
  "chart_id": "workout_completion",
  "schema_version": "0.1",
  "generated_at": "2026-07-20T08:00:00Z",
  "athlete_id": "athlete_123",
  "status": "insufficient_data",
  "title": "課表目標與實際完成",
  "decision_question": "這堂課是否按原定課表完成？",
  "analysis_mode": "goal_vs_actual",
  "planned_data_status": "unavailable",
  "workout_source": null,
  "alignment_method": "unavailable",
  "alignment_confidence": "low",
  "period": {
    "start_date": "2026-07-20",
    "end_date": "2026-07-20",
    "timezone": "Asia/Taipei"
  },
  "summary": {},
  "axes": {},
  "series": [],
  "reference_bands": [],
  "annotations": [],
  "verdict": {
    "status": "unknown",
    "code": "WORKOUT_INSUFFICIENT",
    "headline": "資料不足，暫時無法判斷完成度",
    "message": "目前沒有足夠的課表或執行資料，無法形成可靠判讀。",
    "confidence": "low",
    "rule_id": "workout_completion_insufficient_v0.1",
    "evidence": [],
    "limitations": [
      "planned and execution data both missing"
    ]
  },
  "data_quality": {
    "overall_status": "insufficient_data",
    "completeness_score": 0.12,
    "confidence": "low",
    "missing_fields": [
      "planned_segments",
      "execution_segments"
    ],
    "estimated_fields": [],
    "invalid_fields": [],
    "coverage": {
      "planned_segments_pct": 0,
      "execution_segments_pct": 0
    },
    "limitations": [
      "缺少課表與執行資料"
    ]
  },
  "drill_down": {
    "enabled": false,
    "target_type": "activity",
    "target_id": null,
    "fields": [],
    "notes": []
  },
  "empty_state": {
    "title": "資料還不夠",
    "message": "請先讓系統取得課表或更多執行資料。",
    "action_label": "查看最近活動",
    "action_target": "/?page=activity"
  }
}
```

### 2.4 Chart-Specific Fallback

Already covered by the `actual-only` payload above.

This is the required fallback case for the workout chart.

## 3. Pace and Heart Rate Decoupling

### 3.1 Available

```json
{
  "chart_id": "activity_decoupling",
  "schema_version": "0.1",
  "generated_at": "2026-07-20T08:00:00Z",
  "athlete_id": "athlete_123",
  "status": "available",
  "title": "配速與心率解耦",
  "decision_question": "這次跑步後段是否失去穩定性？",
  "period": {
    "start_date": "2026-07-18",
    "end_date": "2026-07-18",
    "timezone": "Asia/Taipei"
  },
  "summary": {
    "first_half_avg_pace_sec_per_km": 315,
    "second_half_avg_pace_sec_per_km": 325,
    "first_half_avg_hr": 145,
    "second_half_avg_hr": 155,
    "pace_change_pct": 3.2,
    "heart_rate_change_pct": 6.9,
    "aerobic_decoupling_pct": 10.1,
    "sample_quality_status": "sufficient"
  },
  "axes": {
    "x": { "label": "時間", "unit": "split", "scale": "ordinal" },
    "y_left": { "label": "配速", "unit": "sec_per_km", "scale": "linear" },
    "y_right": { "label": "心率", "unit": "bpm", "scale": "linear" }
  },
  "series": [
    {
      "series_id": "pace",
      "label": "配速",
      "type": "line",
      "unit": "sec_per_km",
      "axis": "left",
      "display_precision": 0,
      "hidden_by_default": false,
      "source_method": "activity_timeseries_view",
      "data_quality_status": "available",
      "points": [
        { "x": "1", "y": 311, "status": "available", "source": "activity_decoupling_view" },
        { "x": "2", "y": 313, "status": "available", "source": "activity_decoupling_view" },
        { "x": "3", "y": 318, "status": "available", "source": "activity_decoupling_view" },
        { "x": "4", "y": 323, "status": "available", "source": "activity_decoupling_view" }
      ]
    },
    {
      "series_id": "heart_rate",
      "label": "心率",
      "type": "line",
      "unit": "bpm",
      "axis": "right",
      "display_precision": 0,
      "hidden_by_default": false,
      "source_method": "activity_timeseries_view",
      "data_quality_status": "available",
      "points": [
        { "x": "1", "y": 142, "status": "available", "source": "activity_decoupling_view" },
        { "x": "2", "y": 144, "status": "available", "source": "activity_decoupling_view" },
        { "x": "3", "y": 151, "status": "available", "source": "activity_decoupling_view" },
        { "x": "4", "y": 156, "status": "available", "source": "activity_decoupling_view" }
      ]
    }
  ],
  "reference_bands": [
    {
      "band_id": "stable_drift_band",
      "label": "穩定區間",
      "axis": "left",
      "start_x": "1",
      "end_x": "4",
      "lower": 0,
      "upper": 5,
      "unit": "%",
      "status": "available",
      "method": "stability_threshold_v0.1"
    }
  ],
  "annotations": [
    {
      "annotation_id": "heat_warning",
      "type": "warning",
      "x": "3",
      "label": "心率開始上升",
      "detail": "後段出現明顯漂移",
      "rule_id": "decoupling_warning_v0.1",
      "severity": "medium"
    }
  ],
  "verdict": {
    "status": "warning",
    "code": "CLEAR_DRIFT",
    "headline": "後段效率開始下降",
    "message": "後半段配速變慢、心率升高，顯示明顯的有氧漂移。",
    "confidence": "high",
    "rule_id": "activity_decoupling_v0.1",
    "evidence": [
      { "metric": "aerobic_decoupling_pct", "value": 10.1, "unit": "%" }
    ],
    "limitations": [
      "路線與溫度會影響漂移結果"
    ]
  },
  "data_quality": {
    "overall_status": "available",
    "completeness_score": 0.94,
    "confidence": "high",
    "missing_fields": [],
    "estimated_fields": [],
    "invalid_fields": [],
    "coverage": {
      "heart_rate_pct": 97,
      "pace_pct": 100,
      "split_pct": 100
    },
    "limitations": []
  },
  "drill_down": {
    "enabled": true,
    "target_type": "activity",
    "target_id": "activity_9921",
    "fields": [
      "split_index",
      "split_distance_m",
      "elapsed_time_sec",
      "avg_hr",
      "avg_power_w",
      "elevation_gain_m"
    ],
    "notes": [
      "點擊後可查看每公里或每段的細節"
    ]
  },
  "empty_state": {
    "title": "目前沒有足夠資料",
    "message": "這張圖需要足夠的分段或樣本資料。",
    "action_label": "查看最近活動",
    "action_target": "/?page=activity"
  }
}
```

### 3.2 Partial

```json
{
  "chart_id": "activity_decoupling",
  "schema_version": "0.1",
  "generated_at": "2026-07-20T08:00:00Z",
  "athlete_id": "athlete_123",
  "status": "partial",
  "title": "配速與心率解耦",
  "decision_question": "這次跑步後段是否失去穩定性？",
  "period": {
    "start_date": "2026-07-18",
    "end_date": "2026-07-18",
    "timezone": "Asia/Taipei"
  },
  "summary": {
    "sample_quality_status": "partial"
  },
  "axes": {
    "x": { "label": "時間", "unit": "split", "scale": "ordinal" },
    "y_left": { "label": "配速", "unit": "sec_per_km", "scale": "linear" },
    "y_right": { "label": "心率", "unit": "bpm", "scale": "linear" }
  },
  "series": [
    {
      "series_id": "pace",
      "label": "配速",
      "type": "line",
      "unit": "sec_per_km",
      "axis": "left",
      "display_precision": 0,
      "hidden_by_default": false,
      "source_method": "activity_timeseries_view",
      "data_quality_status": "partial",
      "points": [
        { "x": "1", "y": 318, "status": "available", "source": "activity_decoupling_view" },
        { "x": "2", "y": 321, "status": "available", "source": "activity_decoupling_view" }
      ]
    }
  ],
  "reference_bands": [],
  "annotations": [],
  "verdict": {
    "status": "info",
    "code": "STABLE_WITH_LIMITS",
    "headline": "目前看起來穩定，但心率覆蓋不完整",
    "message": "配速趨勢可讀，但心率資料不足，只能做有限判讀。",
    "confidence": "medium",
    "rule_id": "activity_decoupling_partial_v0.1",
    "evidence": [],
    "limitations": [
      "心率覆蓋率不足"
    ]
  },
  "data_quality": {
    "overall_status": "partial",
    "completeness_score": 0.67,
    "confidence": "medium",
    "missing_fields": [
      "heart_rate_bpm"
    ],
    "estimated_fields": [],
    "invalid_fields": [],
    "coverage": {
      "heart_rate_pct": 44,
      "pace_pct": 100,
      "split_pct": 100
    },
    "limitations": [
      "心率覆蓋不足"
    ]
  },
  "drill_down": {
    "enabled": true,
    "target_type": "activity",
    "target_id": "activity_9922",
    "fields": [
      "split_index",
      "split_distance_m",
      "elapsed_time_sec"
    ],
    "notes": [
      "此圖不提供強判讀"
    ]
  },
  "empty_state": {
    "title": "目前沒有足夠資料",
    "message": "配速有資料，但心率不足，無法形成完整解耦判讀。",
    "action_label": "查看最近活動",
    "action_target": "/?page=activity"
  }
}
```

### 3.3 Insufficient Data

```json
{
  "chart_id": "activity_decoupling",
  "schema_version": "0.1",
  "generated_at": "2026-07-20T08:00:00Z",
  "athlete_id": "athlete_123",
  "status": "insufficient_data",
  "title": "配速與心率解耦",
  "decision_question": "這次跑步後段是否失去穩定性？",
  "period": {
    "start_date": "2026-07-18",
    "end_date": "2026-07-18",
    "timezone": "Asia/Taipei"
  },
  "summary": {},
  "axes": {},
  "series": [],
  "reference_bands": [],
  "annotations": [],
  "verdict": {
    "status": "unknown",
    "code": "DRIFT_INSUFFICIENT",
    "headline": "資料不足，無法判讀解耦",
    "message": "目前缺少足夠的心率或分段資料。",
    "confidence": "low",
    "rule_id": "activity_decoupling_insufficient_v0.1",
    "evidence": [],
    "limitations": [
      "heart-rate sampling too sparse"
    ]
  },
  "data_quality": {
    "overall_status": "insufficient_data",
    "completeness_score": 0.21,
    "confidence": "low",
    "missing_fields": [
      "heart_rate_bpm"
    ],
    "estimated_fields": [],
    "invalid_fields": [],
    "coverage": {
      "heart_rate_pct": 18,
      "pace_pct": 100,
      "split_pct": 28
    },
    "limitations": [
      "心率取樣太稀疏"
    ]
  },
  "drill_down": {
    "enabled": false,
    "target_type": "activity",
    "target_id": null,
    "fields": [],
    "notes": []
  },
  "empty_state": {
    "title": "資料還不夠",
    "message": "這張圖需要更多心率與分段資料。",
    "action_label": "查看最近活動",
    "action_target": "/?page=activity"
  }
}
```

### 3.4 Chart-Specific Fallback

Already covered by the `partial` and `insufficient_data` payloads above.

## 4. Weekly Intensity Distribution

### 4.1 Available

```json
{
  "chart_id": "weekly_intensity_distribution",
  "schema_version": "0.1",
  "generated_at": "2026-07-20T08:00:00Z",
  "athlete_id": "athlete_123",
  "status": "available",
  "title": "週訓練強度分布",
  "decision_question": "我的訓練是否仍以低強度為主？",
  "period": {
    "start_date": "2026-06-22",
    "end_date": "2026-07-19",
    "timezone": "Asia/Taipei"
  },
  "summary": {
    "period_type": "rolling_4w",
    "low_intensity_share_pct": 72.0,
    "moderate_intensity_share_pct": 18.0,
    "high_intensity_share_pct": 10.0,
    "dominant_band": "low",
    "zone_system": "workout_type_intensity_category"
  },
  "axes": {
    "x": { "label": "強度", "unit": "category", "scale": "ordinal" },
    "y_left": { "label": "佔比", "unit": "%", "scale": "linear" }
  },
  "series": [
    {
      "series_id": "intensity_distribution",
      "label": "強度分布",
      "type": "bar",
      "unit": "%",
      "axis": "left",
      "display_precision": 0,
      "hidden_by_default": false,
      "source_method": "training_balance_view",
      "data_quality_status": "available",
      "points": [
        { "x": "Recovery", "y": 14, "status": "available", "source": "weekly_intensity_distribution_view" },
        { "x": "Easy", "y": 58, "status": "available", "source": "weekly_intensity_distribution_view" },
        { "x": "Moderate", "y": 18, "status": "available", "source": "weekly_intensity_distribution_view" },
        { "x": "Hard", "y": 10, "status": "available", "source": "weekly_intensity_distribution_view" }
      ]
    }
  ],
  "reference_bands": [
    {
      "band_id": "low_dominant_range",
      "label": "低強度主導",
      "axis": "left",
      "start_x": "Recovery",
      "end_x": "Easy",
      "lower": 65,
      "upper": 80,
      "unit": "%",
      "status": "available",
      "method": "training_balance_policy_v0.1"
    }
  ],
  "annotations": [],
  "verdict": {
    "status": "available",
    "code": "LOW_DOMINANT",
    "headline": "訓練仍以低強度為主",
    "message": "最近 4 週的訓練結構仍由低強度活動主導。",
    "confidence": "high",
    "rule_id": "weekly_intensity_distribution_v0.1",
    "evidence": [
      { "metric": "low_intensity_share_pct", "value": 72.0, "unit": "%" }
    ],
    "limitations": []
  },
  "data_quality": {
    "overall_status": "available",
    "completeness_score": 0.96,
    "confidence": "high",
    "missing_fields": [],
    "estimated_fields": [],
    "invalid_fields": [],
    "coverage": {
      "zone_pct": 100,
      "classification_pct": 100
    },
    "limitations": []
  },
  "drill_down": {
    "enabled": true,
    "target_type": "period",
    "target_id": "rolling_4w",
    "fields": [
      "activity_id",
      "workout_type",
      "training_purpose",
      "duration_sec",
      "training_load"
    ],
    "notes": [
      "可切換到最近 7 天或單堂課"
    ]
  },
  "empty_state": {
    "title": "目前沒有足夠資料",
    "message": "這張圖需要可用的強度分類或區間資料。",
    "action_label": "查看最近活動",
    "action_target": "/?page=activity"
  }
}
```

### 4.2 Fallback

```json
{
  "chart_id": "weekly_intensity_distribution",
  "schema_version": "0.1",
  "generated_at": "2026-07-20T08:00:00Z",
  "athlete_id": "athlete_123",
  "status": "partial",
  "title": "週訓練強度分布",
  "decision_question": "我的訓練是否仍以低強度為主？",
  "period": {
    "start_date": "2026-06-22",
    "end_date": "2026-07-19",
    "timezone": "Asia/Taipei"
  },
  "summary": {
    "period_type": "rolling_4w",
    "dominant_band": "low",
    "zone_system": "workout_type_intensity_category"
  },
  "axes": {
    "x": { "label": "強度", "unit": "category", "scale": "ordinal" },
    "y_left": { "label": "活動數", "unit": "count", "scale": "linear" }
  },
  "series": [
    {
      "series_id": "intensity_distribution",
      "label": "強度分布",
      "type": "bar",
      "unit": "count",
      "axis": "left",
      "display_precision": 0,
      "hidden_by_default": false,
      "source_method": "training_balance_view",
      "data_quality_status": "partial",
      "points": [
        { "x": "Recovery", "y": 4, "status": "available", "source": "weekly_intensity_distribution_view" },
        { "x": "Easy", "y": 16, "status": "available", "source": "weekly_intensity_distribution_view" },
        { "x": "Moderate", "y": 2, "status": "available", "source": "weekly_intensity_distribution_view" },
        { "x": "Hard", "y": 1, "status": "available", "source": "weekly_intensity_distribution_view" }
      ]
    }
  ],
  "reference_bands": [],
  "annotations": [
    {
      "annotation_id": "zone_fallback",
      "type": "info",
      "x": "Easy",
      "label": "改採活動分類",
      "detail": "缺少 zone 資料，因此改用 workout_type intensity category",
      "rule_id": "weekly_intensity_fallback_v0.1",
      "severity": "low"
    }
  ],
  "verdict": {
    "status": "info",
    "code": "INTENSITY_FALLBACK",
    "headline": "缺少 zone 資料，先以活動分類代替",
    "message": "目前沒有可靠的心率 zone 或功率 zone，因此改用活動分類來估算強度分布。",
    "confidence": "medium",
    "rule_id": "weekly_intensity_fallback_v0.1",
    "evidence": [],
    "limitations": [
      "no heart-rate zone table",
      "no power zone table"
    ]
  },
  "data_quality": {
    "overall_status": "partial",
    "completeness_score": 0.73,
    "confidence": "medium",
    "missing_fields": [
      "heart_rate_zone",
      "power_zone"
    ],
    "estimated_fields": [],
    "invalid_fields": [],
    "coverage": {
      "classification_pct": 100,
      "zone_pct": 0
    },
    "limitations": [
      "改用 workout_type intensity category"
    ]
  },
  "drill_down": {
    "enabled": true,
    "target_type": "period",
    "target_id": "rolling_4w",
    "fields": [
      "activity_id",
      "workout_type",
      "training_purpose"
    ],
    "notes": [
      "此圖使用 fallback zone system"
    ]
  },
  "empty_state": {
    "title": "目前沒有足夠資料",
    "message": "這張圖沒有 zone 資料，因此只能顯示分類分布。",
    "action_label": "查看最近活動",
    "action_target": "/?page=activity"
  }
}
```

### 4.3 Insufficient Data

```json
{
  "chart_id": "weekly_intensity_distribution",
  "schema_version": "0.1",
  "generated_at": "2026-07-20T08:00:00Z",
  "athlete_id": "athlete_123",
  "status": "insufficient_data",
  "title": "週訓練強度分布",
  "decision_question": "我的訓練是否仍以低強度為主？",
  "period": {
    "start_date": "2026-07-13",
    "end_date": "2026-07-19",
    "timezone": "Asia/Taipei"
  },
  "summary": {},
  "axes": {},
  "series": [],
  "reference_bands": [],
  "annotations": [],
  "verdict": {
    "status": "unknown",
    "code": "INTENSITY_INSUFFICIENT",
    "headline": "資料不足，無法形成強度分布",
    "message": "目前沒有足夠的 zone 或活動分類資料。",
    "confidence": "low",
    "rule_id": "weekly_intensity_insufficient_v0.1",
    "evidence": [],
    "limitations": [
      "insufficient classification data"
    ]
  },
  "data_quality": {
    "overall_status": "insufficient_data",
    "completeness_score": 0.16,
    "confidence": "low",
    "missing_fields": [
      "intensity_category"
    ],
    "estimated_fields": [],
    "invalid_fields": [],
    "coverage": {
      "classification_pct": 16,
      "zone_pct": 0
    },
    "limitations": [
      "分類資料不足"
    ]
  },
  "drill_down": {
    "enabled": false,
    "target_type": "period",
    "target_id": null,
    "fields": [],
    "notes": []
  },
  "empty_state": {
    "title": "資料還不夠",
    "message": "請先累積更多已分類的活動。",
    "action_label": "查看最近活動",
    "action_target": "/?page=activity"
  }
}
```

### 4.4 Chart-Specific Fallback

Already covered by the `fallback` payload above.

## Fixture File List

Recommended machine-readable fixtures:

- `fixtures/charts/weekly-training-load.available.json`
- `fixtures/charts/weekly-training-load.partial.json`
- `fixtures/charts/weekly-training-load.insufficient-data.json`
- `fixtures/charts/weekly-training-load.distance-time-fallback.json`
- `fixtures/charts/workout-completion.available.json`
- `fixtures/charts/workout-completion.actual-only.json`
- `fixtures/charts/workout-completion.insufficient-data.json`
- `fixtures/charts/activity-decoupling.available.json`
- `fixtures/charts/activity-decoupling.partial.json`
- `fixtures/charts/activity-decoupling.insufficient-data.json`
- `fixtures/charts/weekly-intensity.available.json`
- `fixtures/charts/weekly-intensity.fallback.json`
- `fixtures/charts/weekly-intensity.insufficient-data.json`

## Schema Alignment

The payload examples are expected to satisfy the chart schemas in `schemas/charts/`.

If a fixture and a schema disagree, the schema should be treated as the tighter contract.

## Status

`CoachOS Chart API Payload Examples v0.1`

- Status: Draft
- Scope: Example payloads for chart renderer and API contract validation
- Classification: Architecture / API Examples
