# Running Intelligence Platform

Running Intelligence Platform 是一個本機優先、knowledge-first 的跑步分析產品。

它不是用 AI 直接生成一段看起來像教練的文字，而是先把跑步資料治理好，再用 deterministic 的方式，把每一堂課、每一週、每一個月整理成真正有教練意義的判讀。

目前產品包含兩個一起工作的部分：

- `RAC`：把 Garmin FIT 轉成 Excel 與 SQLite
- `Running Intelligence Platform`：把資料變成 Activity / Weekly / Monthly / Overview 的教練式回顧

這個產品想回答的不是：

- 今天跑了多少？
- 配速多少？
- 負荷多少？

而是：

- 這堂課真正練到了什麼？
- 這週身體學到了什麼？
- 這個月目前位於哪個訓練位置？
- 今天最該關心的是什麼？

如果一般跑步平台是在幫你讀數據，

Running Intelligence Platform 想做的，是幫跑者慢慢學會像教練一樣理解訓練。

## Current product surfaces

- `Activity`
- `Overview`
- `Weekly`
- `Monthly`

## Current status

- Monthly: stable
- Weekly: beta
- Overview: beta
- Activity: MVP, but already functioning as a real event-driven entry

## Product philosophy

We don’t design products. We discover them.

不是先發明一個漂亮的架構，再把產品塞進去。  
而是先讓真實使用情境逼出第一個問題，再讓頁面自己長出來。

這也是為什麼：

- Monthly 最後回答的是「我現在在哪？」
- Weekly 最後回答的是「這週，我到底練到了什麼？」
- Activity 最後回答的是「這堂課，我真正練到了什麼？」
- Overview 最後回答的是「今天，我最該關心的是什麼？」

這個 repo 目前是公開整理的起點。下一步會是把產品、文件、版本與入口再收得更乾淨，讓整體更像一個真正一致的 running product，而不是幾個分散的小工具。
