# Running Intelligence Platform v1.0.0

Running Intelligence Platform 的第一個正式版本。

這次發布把跑步資料、產品語意和對外入口收斂成一條穩定的本機產品鏈路。

## Summary

`v1.0.0` 是 Running Intelligence Platform 的正式起點。
它不是單純的資料工具，而是一個以跑者與教練視角設計的本機產品。

## Highlights

- `資料匯入工具` 正式納入產品流程，負責 `FIT -> Excel -> SQLite`
- `Running Intelligence Platform` 成為對外主名稱
- `Semantic Layer v1.0` 成為 Dashboard 與 Query Layer 的產品語意層
- `SQLite Schema v1.0` 完成真實資料驗證
- `Metadata Repository v1.1` 成為名詞與規則的治理基礎
- 核心資料鏈路固定為 `FIT -> Excel -> SQLite -> Semantic Layer -> Dashboard`

## Product Surfaces

- `Activity`
- `Overview`
- `Weekly`
- `Monthly`

`Journey` 目前保留在程式裡，但暫時不作為公開產品面。

## What it answers

- 這堂課真正練到了什麼？
- 這週身體學到了什麼？
- 這個月目前位於哪個訓練位置？
- 今天最該關心的是什麼？

## Notes

- 這是本機優先、knowledge-first 的跑步分析產品
- 設計理念是先治理資料，再讓頁面長出來
- `v1.0.0` 是產品對外的正式起點

## For GitHub Release

You can paste this release note directly into GitHub Release.
