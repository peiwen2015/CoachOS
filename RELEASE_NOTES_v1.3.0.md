# CoachOS v1.3.0

CoachOS v1.3.0 is the release that turns confirmed Activity knowledge into connected coaching behavior across the product.

## What This Release Means

This release moves CoachOS from a learning loop that only exists at the Activity surface to a connected loop that changes later coaching.

The important product shift is:

- not just storing metadata
- not just showing a confirmation state
- but making confirmed knowledge change later interpretation

In other words:

`A confirmed activity changes later coaching.`

## 中文

CoachOS v1.3.0 的主題是 `Connected Coach Knowledge`。這一版的重點不是再多收一組資料，而是讓跑者在 Activity 裡確認的知識，真的回流到後面的教練判讀。現在，Activity 的確認結果會影響 Weekly / Monthly 的判讀文字，Weekly / Monthly 會讀 confirmed Coach Knowledge，而不只是原始數據；Weekly / Monthly 的 AI handoff 也會一起帶上相同的知識脈絡。另一方面，Activity 標註頁會先提供建議值，讓標註更快，但仍保留明確確認，而且 provenance 會保留，讓來源看得見是手動標註還是 Coach Knowledge 建議。這代表 `v1.2.0` 讓 CoachOS 學會了，而 `v1.3.0` 則讓 CoachOS 把學到的東西連起來，真的影響後面的判讀，讓跑者不只是把資料填進系統，而是在實際教 CoachOS。

## English

CoachOS v1.3.0 is themed `Connected Coach Knowledge`. The focus of this release is not collecting another round of data; it is making the knowledge a runner confirms inside Activity flow back into later coaching judgments. Activity confirmations now affect the reasoning text in Weekly and Monthly, which read confirmed Coach Knowledge instead of only the raw data. Weekly and Monthly AI handoff also carry the same knowledge context. On the metadata side, Activity tagging can start from suggested values so the workflow is faster, while still requiring explicit confirmation, and provenance remains visible so the app can tell whether a value came from a manual edit or a Coach Knowledge suggestion. In short, `v1.2.0` taught CoachOS how to learn, and `v1.3.0` connects what CoachOS learned so later coaching actually changes. That way, the runner is not just filling in fields, but genuinely teaching CoachOS.

## Notes

- `v1.2.0` remains the released truth for the previous milestone
- `v1.3.0` is the milestone that connects confirmed knowledge to Weekly / Monthly reasoning and AI handoff
- Suggested values in metadata editing are hints, not hidden overwrites
- `Coach Memory` is intentionally not part of this release

## Release Readiness

This release is ready when the connected loop feels stable on real data and the runner can clearly see that a confirmation changed later coaching.
