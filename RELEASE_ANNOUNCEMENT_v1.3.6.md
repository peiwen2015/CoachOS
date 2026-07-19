# CoachOS v1.3.6 正式發布

CoachOS v1.3.6 仍然屬於 `Connected Coach Knowledge` 這條產品線。

## 中文

CoachOS v1.3.6 的重點不是擴張新功能，而是把日常使用裡幾個最容易讓人困惑的地方校正回來，讓產品更可信、更一致。這一版最重要的修正，是把 Activity 頁上的最大心率明確拉回「活動最高心率」這個活動事實，而不再混用個人最大心率設定。這不只修正了活動頁顯示，也補上了既有 SQLite 與 Excel 的批次修補能力，所以以前已經轉好的資料，不需要整批砍掉重做，也可以補回正確值。

同時，v1.3.6 也把 Excel 與平台上的一些欄位口徑整理得更清楚。例如 `Critical Power (W)` 現在改成 `個人臨界功率`，而有氧訓練效果、無氧訓練效果、訓練負荷、恢復時間、體力等欄位，也都統一成更一致的繁體中文。這讓匯入工具、Activity、AI 交棒、圖卡 prompt 與批次修補頁開始說同一種語言，而不是混著舊名與新名。

如果說前面的版本是在把知識接進 CoachOS，那 v1.3.6 做的事情就是把這條鏈路校準乾淨：資料更真實、修補更容易、語言更一致。它不會改變產品方向，但會讓每天使用這套系統時，更容易相信畫面上看到的就是你真正該依靠的內容。

## English

CoachOS v1.3.6 remains part of the `Connected Coach Knowledge` line. This release is not about expanding the product with a new milestone theme. It is about correcting a few daily-use inconsistencies so the system feels more trustworthy and more coherent.

The most important fix in this release is that the Activity page now treats max heart rate as an activity fact instead of accidentally mixing it with the athlete max-HR setting. That correction now applies not only to new processing, but also to existing SQLite and Excel artifacts through a batch repair flow, so older converted data can be repaired without forcing a full rebuild.

At the same time, v1.3.6 makes Excel and platform terminology more consistent. `Critical Power (W)` is now clarified as `個人臨界功率`, and related fields such as aerobic training effect, anaerobic training effect, training load, recovery time, and stamina are now presented in more consistent Traditional Chinese across the import tool, Activity, AI handoff, training-card prompts, and repair flows.

If earlier versions were about connecting knowledge into CoachOS, v1.3.6 is about calibrating that chain: truer data, easier repair, and more consistent language. It does not change the roadmap, but it makes the product easier to trust in everyday use.

## 這個版本代表什麼

- `v1.3.5`：讓 Connected Coach Knowledge 真的能每天使用
- `v1.3.6`：把 daily use 裡最容易失真的地方校正乾淨
- 下一步仍然不是新增抽象，而是持續把產品面收斂到更穩定的日常工作流

## 目前版本狀態

- `v1.3.6` 已正式發布
- `v1.3.6` 仍屬於 `Connected Coach Knowledge`
- Workbook schema 仍維持 `v1.1`

如果你今天在 Activity 頁看到的是 `活動最高心率`，而不是一個被個人設定偷帶進來的數字，那這一版就完成了它最重要的工作。
