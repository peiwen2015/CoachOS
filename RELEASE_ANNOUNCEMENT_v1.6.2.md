# CoachOS v1.6.2 Release Announcement

## 繁體中文

CoachOS v1.6.2 已發布。

這次更新改善鞋款管理體驗。鞋款總覽現在位於鞋款狀態之前，並分成「服役中」與「已退役」兩個表格，讓目前使用中的鞋款與歷史鞋款更容易分辨。

同時修正一個重要的資料持久性問題：FIT 匯入時，如果匯入資料沒有鞋款分類，過去可能會把使用者已設定的分類清空。v1.6.2 會保留既有手動分類，只有在新資料確實提供非空白分類時才更新。

注意：先前已被清空的分類值無法由系統可靠推測，請在鞋款頁重新設定一次；之後重新匯入 FIT 不會再消失。

## English

CoachOS v1.6.2 is released.

This release improves shoe management. The shoe overview now appears before shoe status management and is split into two tables: “Active” and “Retired”.

It also fixes an important persistence issue: when FIT import data did not contain a shoe category, it could previously overwrite an existing manual category with a blank value. v1.6.2 preserves existing manual categories and only updates them when a non-empty imported value is available.

Categories that were already cleared cannot be reliably inferred by the system and must be set again once on the shoe page. Future FIT imports will preserve them.
