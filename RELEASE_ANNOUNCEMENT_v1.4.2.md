# CoachOS v1.4.2 正式發布

CoachOS v1.4.2 是訓練序列理解產品層的語意收斂版本。

## 中文

這一版處理的是一個看似小、但會直接影響信任感的問題：月回顧的整體判讀，和每堂課在訓練序列中的角色，不應該被混成同一個結論。

月回顧現在會保留自己的主判讀，回答這個月整體是在建構、吸收、平衡，還是需要留意；訓練序列理解則改成補充訓練結構，說明恢復、建立能力、準備下一堂與重新啟動等角色如何共同形成這個月。

這代表恢復跑堂數較多，不會再自動把整個月命名成吸收調整月。對 4、5 月這類「恢復課很多，但建立能力課承擔主要負荷」的月份，CoachOS 會同時保留兩個事實，而不是選錯其中一個。

對 6 月這類整體負荷已下降、但訓練序列資料不完整的月份，平台也會優先保留月度吸收判讀，並清楚標出序列證據仍不足。

## English

CoachOS v1.4.2 is a semantic refinement release for the Workout Sequence Intelligence product layer.

Monthly Review now owns the overall adaptation position, while Workout Sequence Intelligence explains the supporting workout structure. Recovery-heavy workout counts no longer redefine a build month, and partial sequence evidence no longer overrides an absorption reading.

The monthly sequence surface also uses Chinese coaching language throughout, so the product reads as one coherent coaching experience.

## 這個版本代表什麼

- `v1.4.0`：把訓練序列理解送進產品
- `v1.4.1`：把來源資料與回補流程修穩
- `v1.4.2`：把月回顧與訓練序列的判讀邊界說清楚
