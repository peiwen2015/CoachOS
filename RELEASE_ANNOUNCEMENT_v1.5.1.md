# CoachOS v1.5.1 修正發布

## 中文

CoachOS v1.5.1 是針對 v1.5.0 鞋款管理功能的修正版。

本版同時完成 Comparison Intelligence 的第一個可用版本：活動可依主段、整堂活動與 Strides 分層比較，並提供 baseline、anomaly、execution pattern、role fit、rep consistency 與近期行為摘要。

這一版修正鞋款分類儲存後無法穩定保持的問題，並把鞋款分類改為可複選。一雙鞋現在可以同時標記為日常訓練、長跑、節奏跑或比賽等用途。分類選單也會完整顯示所有選項，不需要在清單內反覆拉動；鞋款總覽中的多個分類則各自佔一行，避免壓縮後面的統計欄位。

新的多分類資料以 JSON 陣列保存在既有資料欄位中，不需要改動資料庫表結構。既有舊分類不會自動猜測轉換，必須由使用者重新選擇新分類。

標準分類也收斂為七類：Recovery、Easy / Aerobic、Steady / Progression、Long Run、Tempo / Threshold / HM Pace、Speed / Interval / Strides、Race。這讓 EVO SL、舊 Boston 13 等同時跨越日常、穩定推進與品質訓練角色的鞋款，有更精準的歸類方式。

## English

CoachOS v1.5.1 is a patch release for the shoe management experience introduced in v1.5.0.

This release also delivers the first usable Comparison Intelligence layer: scoped activity comparison, conditional baselines, metric-level anomaly evidence, execution patterns, role fit, rep consistency, and recent behavior summaries.

This release fixes shoe categories not reliably persisting after save and changes shoe categories to multi-select. A shoe can now be classified for multiple roles such as daily training, long runs, tempo work, or racing. The selector displays all available options without requiring an inner scroll, and the shoe overview renders each selected category on its own line so later metrics remain readable.

New multi-category values are stored as a JSON array in the existing field without a database table change. Existing retired category values are not automatically guessed or migrated; the user must explicitly reclassify those shoes.

The standard vocabulary is now limited to seven training-role categories: Recovery, Easy / Aerobic, Steady / Progression, Long Run, Tempo / Threshold / HM Pace, Speed / Interval / Strides, and Race. This gives shoes such as the EVO SL and older Boston 13 a more precise way to represent their training roles.

## 發布狀態 / Release Status

- `v1.5.0` 已正式發布 / `v1.5.0` is already released.
- `v1.5.1` 本次完成 GitHub 版本更新 / `v1.5.1` is included in this GitHub release update.
