# CoachOS v1.3.6

CoachOS v1.3.6 is a refinement release for `Connected Coach Knowledge`.

## What This Release Means

This release tightens data truth and presentation consistency in daily use.

It does not introduce a new product milestone.

Instead, it makes the existing workflow more trustworthy in three practical ways:

- activity max heart rate is now read as activity truth, not athlete profile setting
- existing Excel and SQLite artifacts can be batch-repaired instead of manually rebuilt
- user-facing terminology is more consistent across Activity, AI handoff, prompts, and import tools

In other words:

`v1.3.6 makes CoachOS more internally consistent and easier to trust day to day.`

## 中文

CoachOS v1.3.6 不是新的產品主題版本，而是 `Connected Coach Knowledge` 的一次收斂修補。這一版的價值，不在於新增一條產品線，而在於把幾個日常使用中最容易讓人疑惑的地方校正回來，讓資料真實性與介面口徑更一致。

這次最重要的變化有三個。第一，活動頁的最大心率不再誤用個人最大心率，而是明確回到「活動最高心率」這個活動事實；既有 SQLite 與 Excel 也可以批次修補，不需要手動重跑全部資料。第二，Excel 欄位名稱與平台欄位名稱進一步對齊，例如個人臨界功率、有氧訓練效果、無氧訓練效果、訓練負荷、恢復時間、體力等欄位都改成更清楚的一致中文。第三，Activity、Overview、Weekly、Monthly、AI 交棒、圖卡 prompt、批次修補頁等產品面上的混用英文進一步收斂，讓整體使用體驗更像同一套產品，而不是不同時期語言混在一起。

這代表 v1.3.6 的重點不是擴張，而是校準：讓 CoachOS 在每天使用時，資料更可信、修補更容易、語言更一致。

## English

CoachOS v1.3.6 is not a new milestone theme. It is a refinement patch within the `Connected Coach Knowledge` line. The purpose of this release is to correct a few daily-use inconsistencies so the product feels more trustworthy and more coherent.

The most important changes are threefold. First, activity max heart rate is now treated as an activity fact instead of accidentally inheriting the athlete max-HR setting, and existing SQLite plus Excel artifacts can be batch-repaired without forcing a full rebuild. Second, Excel metadata labels and platform labels are now more consistent in Chinese, including critical power, training effect, training load, recovery time, and stamina-related fields. Third, visible product copy across Activity, Overview, Weekly, Monthly, AI handoff, training-card prompts, and repair tools has been tightened so the product reads more like one coherent system instead of a mix of older and newer wording.

In that sense, v1.3.6 is about calibration rather than expansion: more trustworthy data, easier repair, and more consistent language.

## Highlights

- Activity max heart rate now reflects true activity-level evidence
- Existing SQLite activity heart-rate values can be backfilled from split evidence
- Existing Excel files can be batch-repaired for heart-rate and terminology issues
- Batch repair tooling is available from the import tool page
- `Critical Power (W)` is clarified as `個人臨界功率`
- Training-effect and related Excel labels are now more consistent in Chinese
- Activity page, AI handoff, prompts, and import-tool wording are more consistently localized
- `split`-related visible wording is now aligned to `分段 / 原始分段`

## Notes

- `v1.3.6` remains part of the `Connected Coach Knowledge` line
- Workbook schema remains `v1.1`; this release improves interpretation, repairability, and presentation
- This release does not change the long-term roadmap or introduce `Memory / Belief`

## Release Readiness

This release is ready when:

- the activity page shows `活動最高心率` correctly
- existing SQLite and Excel artifacts can be repaired in batch
- major user-facing surfaces no longer mix old English labels with the newer Chinese product language
