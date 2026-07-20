# CoachOS v1.4.1

CoachOS v1.4.1 is a repair and data-completeness release for `Workout Sequence Intelligence`.

## What This Release Means

This release does not introduce a new product theme.

Instead, it makes the existing `Workout Sequence Intelligence` layer more trustworthy by repairing the data that feeds it:

- activity names are now recovered from FIT workout names and written back into Excel and SQLite
- average power is now backfilled from the official activity-level FIT field instead of being inferred from split values
- existing manual annotations are preserved during batch refresh and backfill flows
- older SQLite databases that were missing `avg_power_w` are handled safely

In other words:

`v1.4.1 makes CoachOS safer to backfill, safer to refresh, and more faithful to the source FIT file.`

## 中文

CoachOS v1.4.1 不是新的產品主題版本，而是一個以資料修補與回補完整性為核心的修正版。

這一版主要在處理兩件事。第一，過去部分活動雖然在 FIT 檔裡有活動名稱，但轉檔後沒有完整回寫到 Excel 與 SQLite，導致活動頁在切換日期時，只有部分日期會顯示名稱。現在活動名稱會優先從 FIT 裡的 workout name 回補，並寫入 Excel 與 SQLite，所以舊資料也能恢復成可辨識的活動名稱。

第二，平均功率現在改成以活動層級的官方欄位為準。FIT 檔如果有 `avg_power`，就會寫入 Excel 與 SQLite 的 `avg_power_w`；若舊資料庫原本還沒有這個欄位，平台也會先補欄位再讀取，避免因為欄位缺失而造成顯示錯誤或頁面當掉。

同時，這一版也強化了批次回補時的保護邏輯。過去已經透過標註功能填過的課表類型、訓練目的、鞋款等資訊，不應該因為 backfill 而被清掉，所以現在修補流程會採用補缺值策略，保留既有手動標註，只把缺的欄位補回來。

最後，AI 延伸分析與活動頁的文案也一起對齊。平均功率只會使用活動層級的官方值，不會把分段資料自行代算成官方平均；而原本單堂連續跑步的描述，也改成更精確的 `連續跑步起點／中段／收尾`，讓用詞跟資料結構一致。

如果說 `v1.4.0` 是把 `Workout Sequence Intelligence` 正式放進產品，`v1.4.1` 就是把這套產品真正接到可信的來源資料上。

## English

CoachOS v1.4.1 is a repair-focused release for `Workout Sequence Intelligence`.

The goal of this release is not to expand the product theme, but to make the existing coaching layer more reliable by repairing the data pipeline underneath it.

The key improvements are:

- activity names are restored from FIT workout names and written into both Excel and SQLite
- average power is written from the official activity-level FIT field instead of being inferred from split data
- existing manual metadata is preserved during backfill and batch refresh flows
- older SQLite databases missing `avg_power_w` are handled safely

This makes CoachOS more faithful to the source FIT file and more stable when you revisit older activities.

## Highlights

- FIT workout names now backfill `activity_name` into Excel and SQLite
- activity selector now shows named workouts for older dates instead of falling back to generic `跑步`
- activity-level average power is now written to `avg_power_w`
- backfill jobs preserve existing `課表類型`、`訓練目的`、`鞋款` and other manually annotated values
- older SQLite databases are automatically extended with `avg_power_w` when needed
- AI handoff text now treats average power as an official activity-level field
- continuous-run wording in the activity review is now `連續跑步起點／中段／收尾`
- the import and repair flow no longer clears previously saved metadata while filling missing fields

## Notes

- `v1.4.1` is the first repair release after `Workout Sequence Intelligence Product Layer`
- Workbook schema remains `v1.1`
- Excel remains intentionally simple; the new work is about making the existing fields trustworthy
- Average power should be read from the official activity-level field, not re-derived from split segments
- Existing manual annotations remain the source of truth when the backfill only needs to fill blanks

## Release Readiness

This release is considered ready when:

- older activities show their real activity names again
- average power appears in Excel and SQLite when the FIT file provides it
- manual annotations survive backfill and refresh operations
- the dashboard no longer crashes on older databases missing `avg_power_w`
- AI handoff uses the same average-power convention as the activity page
