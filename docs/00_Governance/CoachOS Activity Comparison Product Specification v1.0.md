# CoachOS Activity Comparison Product Specification v1.0

## 文件狀態

| 欄位 | 內容 |
|---|---|
| 文件類型 | Product / UX / AI handoff specification |
| 版本 | v1.0 |
| 狀態 | Draft for review |
| 目前範圍 | Activity comparison |
| 未納入本版 | 鞋款分類規則、週比較、月比較的實際聚合邏輯 |

## 1. 產品目的

讓跑者可以把多堂活動放在同一個可讀、可複製、可延伸的比較上下文中，快速回答：

- 不同活動的數據差異是什麼？
- 配速、心率、功率、步態與訓練負荷是否一致？
- 哪些差異值得交給 AI 進一步分析？
- AI 產生的分析與比較圖，如何回存到同一組比較上下文？

本功能是「活動比較」產品面，不取代單堂活動判讀，也不把 AI 回覆寫回原始活動資料。

## 2. 使用者流程

```text
比較頁 → 從全部活動多選 → 更新比較表 → 複製提示給外部 AI
       → 貼回 AI 文字分析並儲存 → 複製圖片提示 → 上傳並保存比較圖
```

### 2.1 活動選取

- 頁面必須列出所有可用活動，依活動開始時間由新到舊排列。
- 左側以單一 column 列出活動，每筆活動以 checkbox 選取，允許多選。
- 右側即時顯示目前已選活動，勾選或取消後不需重新整理即可更新，讓使用者能確認沒有選錯活動。
- 每筆選項至少顯示活動名稱／類型、開始時間與距離。
- 更新比較表後，已選活動必須保留在 URL 上下文中。
- 沒有選取活動時，頁面顯示空狀態，不產生空的 AI handoff。

### 2.2 比較表

比較表以「一筆活動一列」呈現，欄位至少包括：

| 顯示欄位 | 語意來源 |
|---|---|
| 日期 | `activity_start_time` |
| 活動 | `activity_name`，缺值時使用 `activity_type` |
| 鞋款 | `shoe_display_name` |
| 距離 | `distance_km` |
| 時間 | `duration_sec` |
| 平均配速 | `avg_pace_sec_per_km` |
| 平均心率 | `avg_hr` |
| 最大心率 | `max_hr` |
| 平均功率 | `avg_power_w` |
| 訓練負荷 | `training_load` |
| 平均步頻 | `avg_cadence_spm` |
| 平均步幅 | `avg_stride_length_mm` |
| 平均觸地時間 | `avg_gct_ms` |

欄位缺值必須顯示為可辨識的缺值符號，不得以 0 代替。表格可水平捲動，但活動名稱與數值不可被壓縮到無法閱讀。

### 2.3 課表分段比較

整堂活動平均不一定能代表品質訓練。當活動具有可驗證的課表結構時，比較上下文必須區分：

| Scope | 用途 | 例子 |
|---|---|---|
| `whole_activity` | 總距離、總時間、訓練負荷與整體成本 | WU + Main + Recovery + CD |
| `primary_work` | 主要有氧或品質主段的配速、心率、功率與跑姿 | 5K Tempo + 3K Tempo |
| `strides` | 短加速段的步頻、步幅、功率與 GCT | Easy + Strides 的 Strides |

規則：

- Tempo／Threshold：`primary_work` 排除 WU、Recovery、CD。
- LSD：`primary_work` 比較連續長跑主體；整堂負荷仍保留於 `whole_activity`。
- Easy + Strides：Easy 有氧主體與 Strides 分開，不把短加速段混入 Easy 平均。
- 無法可靠辨識分段時，必須標示「僅提供整堂活動比較」，不得猜測主段。
- AI handoff 必須明確標示每個數值屬於哪個 scope。
- Conditional Baseline 必須分層：配速、心率、功率與跑姿優先使用 `primary_work`；訓練負荷使用 `whole_activity`；Strides 另存為 `strides` baseline，不得混入主段。
- Anomaly evidence 必須逐 metric 標示 scope、觀測值、典型範圍、偏離值與判定理由。
- 若有可靠的課表分段，AI handoff 可提供 `primary_work` 前半／後半比較，用於觀察 HR drift、功率維持與 GCT 變化；這不是另一個 baseline。
- 若資料能辨識每一組 Stride，應提供逐組 evidence；不能辨識時只提供 Strides aggregate，不得自行推測組數。
- 前後半 evidence 必須先檢查功率是否仍在同一比較區間；功率已提高時，UI 與 AI handoff 顯示為「輸出提高下的變化」，不得直接稱為心率漂移。
- Strides aggregate 只作摘要；若逐組資料存在，主要判讀應以組間一致性與最後一組突增為優先。
- `segment_intent` 必須記錄意圖值、來源與信心；由活動標籤推導的意圖只能作為低信心比較上下文，不得當成使用者明確設定。
- `performance_deviation`（偏離 baseline 的方向）與 `role_fit`（是否符合訓練角色）必須分開呈現；偏離 baseline 不等於執行錯誤。
- 前後半與 Strides 組間行為應使用固定命名 contract，避免 AI 重新從 raw metrics 猜測執行模式。

## 3. 比較上下文與識別

本版的比較範圍為 `activity`。比較上下文由範圍與活動識別組成：

```text
comparison_scope = activity
comparison_identifier = activity-<sorted activity_id joined by hyphen>
```

例如選取活動 12、7、31 時，識別為 `activity-7-12-31`。活動順序只影響表格排序，不應造成另一份 AI 回覆或圖檔附件。識別不可依賴 SQLite row order。

## 4. AI 交棒規格

比較頁的 AI 交棒顯示介面必須沿用既有 Activity、Weekly 與 Monthly 的共用模式：使用「AI 延伸分析」區段標題、`AI 交棒` 標記、說明文字、可展開的「先看會交出去的內容」區塊，以及「複製給 AI」按鈕。比較頁不得另造一套視覺或互動語言。

### 4.1 文字分析 handoff

系統提供只讀的比較提示，內容必須包含比較範圍，以及每筆活動的日期、名稱、距離、時間、配速、心率、功率、訓練負荷與步態數據，並要求 AI：

- 比較差異與相似處
- 找出異常值並提出可能原因
- 給出下一步訓練建議
- 不只重述表格

使用者按下「複製給 AI」後，可將完整提示貼到外部 AI。平台不在本版直接呼叫特定 AI provider。

### 4.2 AI 回覆保存

- 使用者可將 AI 完整回覆貼回比較頁。
- 系統沿用既有 AI 回覆解析規則，優先保存最後一個 `running-intelligence-reply`、Markdown 區塊，最後才使用完整文字。
- 回覆以 `surface=compare` 與比較識別保存。
- 保存的 AI 文字不得修改原始活動、語意層或 SQLite 活動數據。
- 重新整理或重新進入同一組比較活動時，應能看到上次保存的回覆。

### 4.3 圖片生成與保存

系統提供只讀圖片生成提示，要求外部 AI 以日期為 X 軸，呈現距離、配速、平均心率與訓練負荷，以活動名稱作為圖例，清楚標示單位，且不捏造比較表以外的數據。

圖片由外部 AI 產生後，使用者可在同一比較上下文上傳保存。圖片附件與 AI 文字共用 `surface=compare` 和比較識別，但保存在附件目錄，不寫入 SQLite。

## 5. 缺值與資料邊界

- 比較資料直接取自 `activity_review_view`，確保與單堂活動頁使用相同的語意欄位。
- `avg_power_w` 必須使用 FIT 活動層級的官方平均功率；舊 SQLite 若欄位為空，匯入／修復流程應依 `garmin_activity_id` 從對應 FIT 回填，不得以 `critical_power_w` 代替。
- 沒有鞋款、功率或步態資料時，顯示缺值，不推測、不補造。
- 活動名稱缺值時使用活動類型；兩者皆缺時使用「未命名活動」。
- 本版不做距離、日期、鞋款或訓練類型的自動配對與篩選。
- 本版不計算平均值、趨勢線或統計顯著性；先提供逐活動並列比較。

## 6. 週／月比較預留

後續沿用同一頁面的選取、比較表、AI handoff 與附件保存流程：

| 範圍 | 預留值 | 未來識別示例 |
|---|---|---|
| 活動 | `activity` | `activity-7-12-31` |
| 週 | `week` | `week-2026-W32` |
| 月 | `month` | `month-2026-08` |

週／月版本需要另行定義時間邊界、活動聚合、比較欄位、缺值規則與是否允許跨週／跨月選取。在規則核准前，UI 可顯示預留入口，但不得假裝已支援週／月比較。

## 7. 驗收條件

- [ ] 導覽列可進入「比較」頁。
- [ ] 活動清單包含全部活動，且可多選。
- [ ] 更新比較表後，選取狀態不遺失。
- [ ] 比較表每筆活動一列，欄位可讀且缺值不被誤判為 0。
- [ ] 沒有選取時顯示空狀態。
- [ ] 比較提示可複製給外部 AI。
- [ ] AI 回覆可貼回並保存到該比較上下文。
- [ ] 同一比較上下文可上傳、查看與刪除圖片附件。
- [ ] 活動原始資料與 SQLite schema 不因 AI 保存而改變。
- [ ] 週／月比較仍清楚標示為預留，不產生未定義的聚合結果。
- [ ] 有結構活動的 handoff 不以 WU／Recovery／CD 稀釋品質主段數據。

## 8. 非目標

- 不處理鞋款分類新增、重選或分類持久化。
- 不在本版內建 AI API 金鑰或直接呼叫外部 AI。
- 不在本版自動生成或解讀圖片內容。
- 不把 AI 推論回寫成活動的正式訓練標註。
