# CoachOS v1.6.3 Release Announcement

## 繁體中文

CoachOS v1.6.3 已發布。

這是一個針對 v1.6.2 的修補版本。v1.6.2 的鞋款分類保留功能本身正確，但初始化資料庫時使用了不相容的 SQLite row 讀取方式，導致資料匯入工具無法啟動。v1.6.3 已修正這個問題。

現在從 CoachOS 進入資料匯入工具時，應可正常開啟 FIT 下載頁，並保留「只下載今天」的預設選項。鞋款分類也會在後續 FIT 匯入中持續保留。

## English

CoachOS v1.6.3 is released.

This is a patch release for v1.6.2. The shoe-category preservation feature introduced in v1.6.2 was correct, but it exposed an incompatible SQLite row access pattern during import-studio initialization, preventing the tool from starting. v1.6.3 fixes this regression.

Entering the data import tool from CoachOS now opens the FIT download page normally, with “Download today only” still selected by default. Existing manual shoe categories will also remain preserved during future FIT imports.
