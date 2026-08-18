# CoachOS v1.5.0 正式發布

CoachOS v1.5.0 是 `Training Visualization, Weekly Review, and Shoe Tracking` 的產品更新版本。

## 中文

CoachOS v1.5.0 把訓練資料的「看見」做得更完整：活動圖表開始有清楚的距離座標與網格線，週回顧可以依照跑者習慣使用滾動七天或固定週，而鞋款也不再只是總覽表中的一列資料。

這一版最直接的新功能，是點擊鞋款後可以進入鞋款摘要頁。頁面會顯示累積距離、活動數、使用時間、平均配速、平均心率、服役狀態與退役目標進度，並列出所有已追蹤活動。從活動清單可以直接回到單堂活動判讀，讓「哪雙鞋跑了什麼」變成一條連續的閱讀路徑。

週回顧也更誠實地處理進行中的週期。固定週尚未結束時，CoachOS 會顯示「本週進度」，不會提前替未完成的一週產生正式判讀或納入完整週基準比較。

同時，FIT 匯入流程現在會保留使用者手動維護的鞋款服役／退役狀態，避免每日匯入新資料時重新啟用已退役鞋款。圖表 schema、測試 fixtures 與相關資料模型文件也一併補齊，讓這些產品行為有清楚的資料契約可以依循。

## English

CoachOS v1.5.0 is a product release focused on training visualization, weekly review clarity, and shoe tracking.

Activity charts now provide distance-aware axes, tick labels, and grid lines. Weekly reviews can use either a rolling seven-day window or a fixed-week boundary, while incomplete fixed weeks are presented as current progress instead of being treated as completed coaching periods.

The most visible addition is the new shoe detail experience. Selecting a shoe opens a summary with total distance, activity count, tracked time, average pace, average heart rate, lifecycle status, and retirement progress when configured. The page also lists all activities tracked with that shoe, and each activity links back to its full activity review.

FIT imports now preserve manually managed shoe lifecycle state, including active and retired status. Supporting chart schemas, fixtures, and data model documentation are included so the new product surfaces remain grounded in explicit contracts.

## 這個版本代表什麼

- `v1.4.2`：把訓練序列理解與月回顧語意收斂清楚
- `v1.5.0`：讓圖表、週回顧與鞋款資料更容易被看懂、追蹤與回到細節
- 下一步：持續收斂鞋款適配、訓練視覺化與教練判讀之間的連結

## 目前版本狀態

- `v1.5.0` 已完成 CoachOS release commit
- 活動圖表支援距離座標、刻度與網格線
- 週回顧支援滾動七天與固定週模式
- 鞋款支援摘要頁與已追蹤活動明細
- FIT 匯入保留鞋款服役／退役狀態
- 圖表 schema、fixtures 與相關設計文件已納入版本

CoachOS v1.5.0 讓訓練資料不只被計算，也更容易沿著時間、活動與鞋款重新讀回來。
