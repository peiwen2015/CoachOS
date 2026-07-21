# CoachOS v1.4.2

CoachOS v1.4.2 is a refinement release for the `Workout Sequence Intelligence Product Layer`.

## What This Release Means

This release clarifies the boundary between monthly adaptation judgment and workout-sequence structure.

Monthly Review owns the overall month-level position. Workout Sequence Intelligence provides supporting context about the roles individual workouts played and which roles carried the available sequence load.

The product no longer treats the most common recovery mission by workout count as proof that the entire month was an absorption month. This keeps normal build months with many easy or recovery runs from being mislabeled.

## 中文

CoachOS v1.4.2 是 `Workout Sequence Intelligence Product Layer` 的語意收斂版本。

這一版主要修正月回顧與訓練序列理解之間的判讀邊界。月回顧負責回答「這個月整體走到哪裡」，訓練序列理解則負責補充「各堂課在前後訓練中扮演什麼角色，以及哪些角色承擔了主要的可用負荷」。

過去如果恢復課在堂數上最多，頁面可能直接把整個月說成「以吸收為主的調整月」。但對多數跑者來說，恢復跑與輕鬆跑本來就常常是多數；真正推動月度負荷的，可能是少數建立能力的課程。因此這一版不再用恢復課堂數單獨決定月度位置。

## Highlights

- 月回顧主判讀與訓練結構分開
- 以各序列角色的可用訓練負荷補充堂數分布
- 月度吸收判讀優先於局部訓練序列結果
- 6 月等資料不完整的月份會明確提示序列證據不足
- 月回顧與訓練序列理解的可見文字統一為中文
- 更新架構文件，正式記錄月度聚合邊界

## English Summary

`v1.4.2` keeps the monthly verdict owned by Monthly Adaptation and turns Workout Sequence Intelligence into supporting structure rather than a competing month-level verdict.

The release also adds available sequence-load contribution, makes incomplete sequence evidence explicit, and removes visible English role labels from the monthly sequence surface.

## Release Readiness

This release is considered ready when:

- a build month with many recovery runs is not mislabeled as an absorption month
- an absorption month is not overridden by partial Build evidence
- monthly verdict and training structure are visibly distinct
- the monthly sequence surface is readable in Chinese
- existing dashboard and Narrative Engine tests continue to pass
