# CoachOS v1.4.1 正式發布

CoachOS v1.4.1 是 `Workout Sequence Intelligence Product Layer` 的修補版發布。

## 中文

如果說 `v1.4.0` 是把訓練序列理解正式帶進產品，那 `v1.4.1` 做的事情，就是把這套產品背後的資料補完整、補穩定。

這一版最重要的修正，是活動名稱與平均功率的回補。過去有些 FIT 檔其實有活動名稱，但轉成 Excel 或 SQLite 後沒有完整帶進來，導致活動頁在切換日期時，只剩今天那筆活動比較容易看到名稱。現在系統會從 FIT 的 workout name 回補活動名稱，並寫回 Excel 與 SQLite，舊資料也能重新變得可辨識。

平均功率也一樣。這次不再把分段功率當成官方平均功率來代算，而是直接使用活動層級的官方欄位；如果舊 SQLite 還沒有 `avg_power_w`，平台也會先補欄位再讀取，避免週回顧或活動頁在舊資料上當掉。

同時，這版也把 backfill 的保護邏輯補起來。以前已經手動標註過的課表類型、訓練目的、鞋款等資訊，不應該因為修補流程就被清掉，所以現在補資料會盡量只填缺值，不去覆蓋原本已經標好的內容。

最後，活動頁與 AI 交棒的文字也一起調整成更一致的口徑。平均功率只認活動層級官方值，連續跑步的描述也改得更貼近原始資料結構。

## English

CoachOS v1.4.1 is a repair release for the `Workout Sequence Intelligence Product Layer`.

The focus of this release is simple: make the data beneath the product more complete and more stable.

The most important fixes restore activity names from FIT workout names and backfill official average power from the activity-level FIT field. Older SQLite databases that were missing `avg_power_w` are handled safely, and backfill flows now preserve existing manual annotations instead of clearing them.

This makes the activity page, weekly review, and AI handoff more faithful to the source FIT file and more resilient when working with older records.

## 這個版本代表什麼

- `v1.4.0`：把 Workout Sequence Intelligence 送進產品
- `v1.4.1`：把資料回補與顯示口徑修穩
- 下一步：持續收斂到更穩定的日常使用與更一致的教練語言

## 目前版本狀態

- `v1.4.1` 已正式發布
- 活動名稱可由 FIT workout name 回補到 Excel / SQLite
- 平均功率以活動層級官方欄位為準
- backfill 會盡量保留既有手動標註
- 舊 SQLite 資料庫可安全開啟週回顧與活動頁

CoachOS 在 `v1.4.1` 之後，會繼續朝更乾淨的資料層與更一致的產品口徑前進。
