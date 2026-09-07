# CoachOS v1.5.1

## Comparison Intelligence

- 新增 Similar Activities、Conditional Baseline 與 metric-level anomaly evidence。
- 比較資料分為整堂活動、品質主段與 Strides，避免 WU、Recovery、CD 稀釋主段判讀。
- 新增主段前半／後半 execution pattern、Strides 逐組一致性與 segment intent。
- AI handoff 會明確標示 performance deviation、role fit、rep consistency 與近期行為重複摘要。
- 不加入未驗證的效率分數、drift score 或 composite score。

## 鞋款分類修正

- 鞋款分類改為可複選，同一雙鞋可以同時標記為日常訓練、長跑、節奏跑或比賽等用途。
- 修正鞋款分類儲存後重新載入時無法正確保持的問題。
- 分類以 JSON 陣列儲存在既有 `shoe.category` 欄位，並相容既有單一分類資料。
- 鞋款分類選單完整顯示所有分類選項，不需要在小型清單中滾動。
- 鞋款總覽表中每個分類各佔一行，避免多分類文字壓縮後面的統計欄位。
- 鞋款分類標準詞彙調整為 Recovery、Easy / Aerobic、Steady / Progression、Long Run、Tempo / Threshold / HM Pace、Speed / Interval / Strides、Race。
- 舊分類不再出現在選單中；既有鞋款需要重新選擇新分類，不進行自動猜測轉換。

## 發布狀態

- `v1.5.0` 已正式發布。
- 本文件記錄本次 GitHub patch release 的內容。
