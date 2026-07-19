# Workout Sequence Intelligence Validation v0.1

## Purpose

This document is not a new governance artifact.

It is the first working validation sheet for CoachOS Intelligence Training Phase.

Its purpose is to train and test Workout Sequence Reference Intelligence against real coaching cases.

The goal is not to prove that the worldview is already correct.

The goal is to let the worldview earn trust through repeated real cases.

## What Is Being Validated

This document does not validate only one ontology field.

It validates whether the current CoachOS intelligence stack can produce a more coach-like sequence explanation than activity-only analysis.

That means it tests:

- whether the knowledge philosophy really clarifies understanding
- whether the intelligence architecture really reduces upward reasoning burden
- whether the workout sequence domain is sufficient for real cases
- whether the reference intelligence is more helpful than activity-only reading

## Validation Rule

Each case must be evaluated on three axes:

### 1. Correctness

Did Workout Sequence Reference Intelligence identify the right sequence meaning?

This includes:

- mission category
- mission phrase
- mission status
- continuity state

Score:

- `0` = clearly wrong
- `1` = partially right or too coarse
- `2` = coach-credible and structurally right

### 2. Helpfulness

Did the sequence reading help the runner understand this workout better than activity-only analysis?

This includes:

- does it explain why the workout exists here
- does it help the runner understand what today did for the surrounding sequence
- does it feel more like coaching than isolated activity commentary

Score:

- `0` = not helpful
- `1` = somewhat helpful
- `2` = clearly more helpful than activity-only analysis

### 3. Learning

What did this case teach CoachOS about the current worldview?

This includes learning such as:

- whether ontology was sufficient
- whether context interpretation was weak
- whether mission wording was unclear
- whether domain boundaries were too coarse
- whether the worldview was right but the explanation was weak

Score:

- `0` = no useful learning captured
- `1` = local learning captured
- `2` = worldview-level learning captured clearly

## Validation Standard

A case should not be considered successful only because it is technically correct.

If it is correct but not helpful, the intelligence has not yet earned its place.

CoachOS should optimize for all three:

- correctness of sequence interpretation
- helpfulness of sequence understanding
- learning value for worldview refinement

## Working Constraint

No ontology expansion before twenty validated sequence cases.

This means:

- no new mission categories before repeated case pressure appears
- no new continuity states before repeated failure patterns appear
- no new abstract concepts merely to complete the model

The first responsibility is to test sufficiency, not completeness.

## Sprint 0 — Calibration Set

Before running the first twenty cases, CoachOS should begin with five gold cases.

The purpose of these first five cases is not coverage.

It is calibration.

These cases should become the stable first test set for any meaningful WSI refinement.

| Case | Sequence Type | Validation Focus |
|---|---|---|
| G01 | Tempo -> Rest -> Easy | Activate vs Absorb boundary |
| G02 | Easy -> LSD | Whether Prepare actually increases understanding |
| G03 | LSD -> Recovery | Whether Recover is more valuable than activity-only analysis |
| G04 | Rest -> Easy + Strides -> Threshold | Whether Activate and Prepare can coexist coherently |
| G05 | Easy run overcooked -> LSD | Whether Continuity State has real judgment value |

The first serious question of Sprint 0 is:

`Can the current workflow survive five gold cases without forcing ontology expansion or governance redesign?`

## Case Mix

The first validation batch should deliberately include different sequence patterns.

### Batch A — Recovery Continuity

Examples:

- Tempo -> Easy
- LSD -> Recovery
- Race -> Recovery

### Batch B — Activation Continuity

Examples:

- Rest -> Easy
- Recovery -> Easy + Strides
- Rest -> Easy + Strides

### Batch C — Preparation Continuity

Examples:

- Easy -> LSD
- Easy -> Threshold
- Easy -> Interval

### Batch D — Build Continuity

Examples:

- Easy -> Tempo -> Rest
- Easy -> Marathon Pace -> Easy
- Recovery -> Long Run with intent

### Batch E — Disrupted Continuity

Examples:

- easy day run too hard before long run
- intended activation day becomes overloaded
- recovery day too stressful to preserve sequence

## Initial Target

The first serious validation target should be:

- `20` validated workout-sequence cases minimum

The stronger target for this phase should be:

- `50` validated coaching cases before any new governance artifact is introduced

## Case Template

Each validation case should record:

### Case ID

Short stable identifier.

### Case Type

Choose one:

- Existing Pattern
- Boundary Pattern
- Novel Pattern

Purpose:

- `Existing Pattern` tests scope and generalization of current rules
- `Boundary Pattern` tests whether current rules need finer wording or tighter boundaries
- `Novel Pattern` tests whether the current reasoning model is missing a meaningful rule

### Research Intent

Each case should also declare its research intent.

This is separate from pattern type.

Pattern type describes the structural pattern being tested.

Research intent describes what the case is trying to accomplish for the research process.

Choose one:

- Discovery
- Generalization
- Falsification
- Regression

Purpose:

- `Discovery` finds a new pressure point, ambiguity, or candidate research question.
- `Generalization` tests whether an existing rule or refine holds across another case in the same family.
- `Falsification` attempts to shrink the current hypothesis space by testing whether an observed pressure reproduces outside its current scope.
- `Regression` checks whether the current reasoning model remains internally consistent against a certified baseline.

Pattern Type and Research Intent should be treated as orthogonal dimensions.

### Research Method Rule

`Stability Before Expansion`

New research intents, new rule categories, or new higher-level research dimensions should not be added simply because a single case feels unusual.

They should be added only when repeated evidence shows that the current framework can no longer describe the real research work being done.

This rule exists for the research method for the same reason that ontology expansion is constrained elsewhere in CoachOS:

- do not expand early
- do not classify for elegance alone
- prefer sufficiency over completeness until repeated case pressure proves otherwise

Examples:

| Pattern Type | Research Intent |
|---|---|
| Existing Pattern | Generalization |
| Boundary Pattern | Falsification |
| Novel Pattern | Discovery |

### Date / Sequence Window

The local sequence context being evaluated.

### Previous Workout

Most relevant prior workout.

### Current Workout

Workout being interpreted.

### Next Workout

Most relevant following workout.

### Activity-only Reading

What the current activity-level explanation would say without sequence intelligence.

### WSI Reading

- Mission Category
- Mission Phrase
- Mission Status
- Continuity State
- Sequence Reasoning

### Correctness Score

`0 / 1 / 2`

### Helpfulness Score

`0 / 1 / 2`

### Reviewer Confidence

How confident is the reviewer that this reading is the best current interpretation?

Score:

- `High` = little meaningful disagreement
- `Medium` = other plausible readings exist, but this one is currently stronger
- `Low` = the reading depends heavily on assumptions and needs more cases

### Learning Notes

What did this case teach the worldview?

Examples:

- Activate and Prepare are close here, but the real weakness is missing context interpretation rather than ontology.
- Mission Category is sufficient. Mission Phrase needs refinement.
- Continuity State is structurally right, but the explanation is not yet helpful enough for the runner.

### Research Note

Research Note should be used only when `Rule Impact = Challenges`.

Its purpose is not to invent new concepts early.

Its purpose is to mark a repeated pressure point that may deserve focused observation across later cases.

No scoring without reasoning.

Every Correctness score, every Helpfulness score, and every Confidence level should be accompanied by a short explanation of why.

### Rule Impact

How does this case affect the current reasoning rules?

Choose one:

- Supports
- Refines
- Challenges

Then explain why.

### Refinement Decision

Choose one:

- keep as is
- clarify wording
- refine reasoning rule
- revisit domain boundary
- revisit ontology later
- refine worldview interpretation

## First Twenty Case Plan

The first twenty cases should be distributed like this:

| Bucket | Target Cases | Purpose |
|---|---:|---|
| Recovery continuity | 4 | Test whether lighter days still carry sequence meaning |
| Activation continuity | 4 | Test whether re-entry days are read as mission days rather than generic easy runs |
| Preparation continuity | 4 | Test whether pre-key-workout days improve next-workout understanding |
| Build continuity | 4 | Test whether key sessions are interpreted through surrounding sequence rather than alone |
| Disrupted continuity | 4 | Test whether WSI still works when the sequence is imperfect |

## Success Signal

Workout Sequence Reference Intelligence should be considered promising only if repeated cases show:

- correctness is usually `2` or strong `1`
- helpfulness is usually `2` more often than activity-only analysis
- reviewer confidence trends upward across repeated similar cases
- learning notes repeatedly identify where the worldview should refine without forcing premature ontology expansion
- runners can understand today's role in sequence more clearly than before

## Sprint 0 Findings

Sprint 0 should now be treated as complete.

Its result is not only that five gold cases worked.

Its result is that five gold cases collectively exposed a stable reasoning model.

### Finding 1 — Mission Is Role, Not Event

Mission is not inferred from workout type or single-day execution alone.

Mission is determined by the role a workout plays inside the surrounding sequence.

This is why:

- Easy Run may become `Activate`
- Easy Run may become `Prepare`
- Recovery Run may become `Recover`

The same workout label does not imply one fixed mission.

### Finding 2 — WSI Uses Layered Judgment Rather Than One-Step Judgment

Sprint 0 shows that WSI separates three different layers of judgment:

- `Mission Category` answers: what role did today serve?
- `Mission Status` answers: how well was that role fulfilled?
- `Continuity State` answers: what state did the sequence end up in?

These fields are not interchangeable.

G05 is the clearest proof:

- Mission Category = `Prepare`
- Mission Status = `Partial`
- Continuity State = `Overloaded`

### Finding 3 — Context Changes Judgment Strength, Not Mission Direction

Forward context does not define mission.

It calibrates how strongly continuity can be declared.

This is why:

- missing forward context may lead to `Maintained`
- successful next-workout evidence may justify `Ready`
- continued recovery afterward may confirm `Maintained`
- overconsuming freshness may justify `Overloaded`

### Finding 4 — Detail Should Land in Explanation Before Ontology

G04 shows that one workout may contain multiple functional characteristics without requiring a new mission category.

The primary mission should still be selected by sequence role.

Finer detail can often be expressed in:

- mission phrase
- sequence reasoning

before ontology expansion is justified.

### Finding 5 — Execution Quality Belongs Inside Sequence Judgment

G05 shows that execution quality can change mission completion and continuity outcome without changing mission category.

That means WSI does not need a new mission whenever a preparation day is executed too heavily.

It can preserve:

- mission category

while adjusting:

- mission status
- continuity state

## Reasoning Contract After Sprint 0

The current WSI reasoning contract can now be described as:

```text
Sequence Context
    ↓
Determine Sequence Role
    ↓
Select Primary Mission
    ↓
Explain Mechanism (Mission Phrase)
    ↓
Evaluate Mission Status
    ↓
Assess Continuity State
    ↓
Generate Coach Explanation
```

This should now be treated as the working reasoning flow for Batch 20.

## Sprint 0 Reasoning Rules

The following rules should now be treated as the first working reasoning model for Workout Sequence Intelligence.

They are not permanent truths.

They are stable working hypotheses supported by the Sprint 0 gold cases.

| Rule | Supported by |
|---|---|
| Mission is determined by sequence function, not workout label. | G01, G02, G04 |
| Forward context calibrates continuity rather than defining mission. | G01, G02, G03 |
| Mission Completion != Sequence Completion. | G03, G05 |
| Primary mission is selected by sequence role; secondary functional characteristics belong in the mission phrase. | G04 |
| Execution quality is reflected through Mission Status and Continuity State without changing Mission Category. | G05 |

Batch 20 should begin by testing, refining, or challenging these rules rather than reasoning from zero every time.

## Rule Stability Tracking

Batch 20 should not only accumulate cases.

It should track whether the current reasoning rules are becoming more stable.

Every five new cases should update a simple rule-stability view like this:

| Rule | Supports | Refines | Challenges |
|---|---:|---:|---:|
| Rule 1 | 0 | 0 | 0 |
| Rule 2 | 0 | 0 | 0 |
| Rule 3 | 0 | 0 | 0 |
| Rule 4 | 0 | 0 | 0 |
| Rule 5 | 0 | 0 | 0 |

This turns Batch 20 from a case log into a reasoning-model maturity check.

The goal is not that every case produces a new rule.

The healthier pattern is:

- many `Supports`
- some `Refines`
- occasional `Challenges`

If every new case keeps forcing refinement, the reasoning model is still unstable.

If support gradually dominates while refinement becomes more targeted, the model is maturing.

## Failure Signal

This validation should be treated as failing if repeated cases show:

- sequence reading merely restates activity facts
- mission category is often arbitrary
- continuity state feels decorative rather than useful
- helpfulness remains low even when correctness is acceptable
- ontology grows faster than real understanding improves

## Current Working Mode

This document should be used in product mode, not governance mode.

That means the expected rhythm is:

```text
5 gold cases
    ↓
calibrate workflow
    ↓
then 10 real cases
    ↓
apply WSI
    ↓
evaluate
    ↓
capture learning
    ↓
refine worldview
    ↓
test again
```

Architecture changes should be evidence-driven, not idea-driven.

Validation is the method.

Training is the purpose.

Each new Batch 20 case should answer four questions:

1. Was the judgment correct?
2. Was it more helpful than activity-only analysis?
3. What did the worldview learn?
4. Did this case support, refine, or challenge the current reasoning rules?

## Batch 20 Cases

### Case 01 — Existing Pattern Pressure Test

**Pattern Type**

Existing pattern.

**Research Intent**

Generalization.

This case should be treated as another example of the Tempo -> Rest -> Easy family rather than a brand-new sequence pattern.

Its value is not new ontology pressure.

Its value is scope testing:

`Can the current reasoning model stay stable when the easy re-entry day also contains strides?`

**Date / Sequence Window**

2026-07-08 -> 2026-07-09 -> 2026-07-10 -> 2026-07-11

**Previous Workout**

2026-07-08 Tempo Run / Threshold / 10.005 km / Training Load 228 / RPE 3 - 中等

**Current Workout**

2026-07-10 Easy Run + Strides / Aerobic Base / 8.197 km / Training Load 138 / RPE 3 - 中等

**Next Workout**

2026-07-11 Recovery Run / Recovery / 11.05 km / Training Load 114 / RPE 2 - 輕鬆

**Activity-only Reading**

這是一堂帶 strides 的輕鬆跑。它不只是把強度降回來，也帶一點重新喚醒步頻與節奏感的意味，因此如果只看 Activity，會被理解成一堂偏向 re-entry 的 easy day。

**WSI Reading**

- Mission Category: Activate
- Mission Phrase: Reconnect aerobic rhythm by reopening leg turnover
- Mission Status: Completed
- Continuity State: Maintained
- Sequence Reasoning: 這堂課雖然帶有 strides，但它在這個 sequence 裡的主要任務仍然不是 `Prepare`，因為隔天不是 Threshold，而是另一堂 Recovery Run。前一堂 Tempo 與中間休息日決定了今天首先要完成的是把訓練節奏重新接回來，而不是為下一堂關鍵課預做鋪路。Strides 在這裡更像 activation mechanism，而不是主 mission 的證據。因此這堂課最合理的 reading 仍是 `Activate`，而後續 sequence 因為隔天仍回到 Recovery，所以 continuity 維持在 `Maintained`，而不是提升到 `Ready`。

**Correctness**

- Score: 2
- Why: 這個案例和 G01 同屬 Tempo -> Rest -> Easy 家族，但現在 easy day 內多了 strides。後續並沒有接 Threshold，而是接 Recovery，這使 `Prepare` 的證據不足。最穩定的 reading 仍是 `Activate`，只是 mechanism 比 G01 更明確。

**Helpfulness**

- Score: 2
- Why: Activity-only 只能說這是一堂帶 strides 的 easy run。WSI 則能回答「為什麼這裡的 strides 不等於 Prepare」以及「它在整段 sequence 裡完成的是什麼角色」，因此仍然比單看 Activity 更有幫助。

**Reviewer Confidence**

- Score: Medium
- Why: 主要 mission 的判斷相當穩，但這個案例和 G04 很接近，因此仍有相鄰讀法張力。信心維持 Medium，不是因為證據不足，而是因為這正是一個用來測試規則邊界的例子。

**Learning Notes**

Case learning: `Easy + Strides` 並不天然等於 `Prepare`。當 next workout 不是關鍵品質課時，strides 可以只作為 `Activate` 的 mechanism，而不改變 primary mission。

Rule learning: 這個案例支持 Rule 1 與 Rule 4，並細化它們的適用範圍。Sequence role 仍然先於 workout elements；secondary functional characteristics 仍然可以落在 mission phrase，而不必升格成另一個 mission。

Epistemic learning: 這個案例也支持克制性判斷。WSI 沒有因為看到 strides 就過度宣告 `Prepare` 或 `Ready`。

**Rule Impact**

- Supports
- Why: 這個案例沒有挑戰目前推理模型，反而支持它在更複雜的「既有 pattern 變體」上仍能維持一致。

**Refinement Decision**

- keep as is

### Case 02 — Boundary Pattern Test

**Pattern Type**

Boundary Pattern.

**Research Intent**

Discovery.

This case should be treated as a boundary test between `Recover` and `Prepare`.

Its value is not to invent a new mission.

Its value is to clarify which sequence role should remain primary when both directions are plausible.

**Date / Sequence Window**

2026-05-13 -> 2026-05-14 -> 2026-05-15

**Previous Workout**

2026-05-13 Marathon Pace / Race Simulation / 11.015 km / Training Load 275 / RPE 4 - 有點難

**Current Workout**

2026-05-14 Recovery Run / Recovery / 6.014 km / Training Load 70 / RPE 3 - 中等

**Next Workout**

2026-05-15 Tempo Run / Threshold / 10.009 km / Training Load 240 / RPE 3 - 中等

**Activity-only Reading**

這是一堂恢復跑。它本身負荷很低，主要是在前一堂 HM-specific / marathon-pace 課之後把壓力降下來，因此如果只看 Activity，會自然讀成一堂標準 recovery day。

**WSI Reading**

- Mission Category: Recover
- Mission Phrase: Recover from prior quality load while preserving the next threshold entry
- Mission Status: Completed
- Continuity State: Ready
- Sequence Reasoning: 這堂課位在前一堂品質課與下一堂 Threshold 之間，確實帶有 `Prepare` 的味道，但它的 primary sequence role 仍然應該先是 `Recover`。原因是這堂課的第一責任不是主動建立明天的能力條件，而是先把 5/13 HM-specific 課留下的壓力往下拉，避免疲勞直接延伸到 5/15。由於這堂 recovery day 的負荷非常低，而且隔天 Threshold 也實際順利完成，因此較穩定的 reading 是：`Recover` 作為 primary mission 已完成，而「保留下一堂課入口」則可留在 mission phrase 與 continuity outcome 中，而不需要把 primary mission 改成 `Prepare`。

**Correctness**

- Score: 2
- Why: 這個案例的邊界壓力很真實，但 sequence order 仍然支持 `Recover` 作為 primary mission。若把它直接讀成 `Prepare`，會低估前一堂 11K 品質課帶來的疲勞背景。最自然的 reading 是先完成 recovery，再因執行品質足夠好而讓 continuity 進入 `Ready`。

**Helpfulness**

- Score: 2
- Why: Activity-only 只能說這是一堂恢復跑。WSI 則把更重要的 sequence tension 說了出來：今天不只是「恢復」，而是「在恢復 prior quality 的同時，不破壞下一堂 threshold 的入口」。這讓 Runner 會更理解，為什麼這堂課看起來很輕，卻仍然對整段訓練很重要。

**Reviewer Confidence**

- Score: Medium
- Why: 這是一個真正的 boundary case。`Prepare` 不是錯誤讀法，但目前證據更支持 `Recover` 為 primary mission、`Prepare` 為次級功能。Medium 代表邊界存在，但主判讀仍然可站住。

**Learning Notes**

Case learning: Recovery 與 Prepare 可以同時存在於同一案例中，但不必因此引入雙 mission。這個案例支持把 `Prepare` 留在 mission phrase 與 continuity outcome，而不是升格成 primary mission。

Rule learning: 這個案例細化了 Rule 4。當兩種功能同時合理時，primary mission 不是由「下一堂課存在」決定，而是由當前 sequence 中最先需要被完成的功能決定。在這裡，先完成的是 recovery obligation，其次才是保留 threshold entry。

Epistemic learning: 這個案例不是 challenge，而是 refine。它要求 WSI 對「primary mission 的選擇順序」說得更清楚，但沒有迫使當前 ontology 失效。

**Rule Impact**

- Refines
- Why: 它沒有推翻現有規則，但它把 `primary mission` 的判定標準說得更清楚了：當 Recover 與 Prepare 競爭時，primary mission 應優先對應當前 sequence 中最直接、最先需要完成的 obligation。

**Refinement Decision**

- refine reasoning rule

### Case 03 — Existing Pattern Generalization Test

**Pattern Type**

Existing Pattern.

**Research Intent**

Generalization.

This case should be treated as a second test of the refined recovery-before-prepare rule rather than a novel pattern.

Its purpose is to see whether the obligation-order reading from Case 02 can generalize when the previous key workout is `Tempo` and the next key workout is `LSD`.

**Date / Sequence Window**

2026-07-02 -> 2026-07-03 -> 2026-07-04

**Previous Workout**

2026-07-02 Tempo Run / Threshold / 10.012 km / Training Load 228 / RPE 3 - 中等

**Current Workout**

2026-07-03 Recovery Run / Recovery / 5.007 km / Training Load 75 / RPE 3 - 中等

**Next Workout**

2026-07-04 LSD / Endurance / 18.005 km / Training Load 262 / RPE 5 - 困難

**Activity-only Reading**

這是一堂恢復跑。它本身負荷很低，主要是在前一堂節奏課之後把壓力降下來，因此如果只看 Activity，會被理解成一堂標準的 recovery day。

**WSI Reading**

- Mission Category: Recover
- Mission Phrase: Recover from prior threshold load while preserving long-run entry
- Mission Status: Completed
- Continuity State: Ready
- Sequence Reasoning: 這堂課同時位在前一堂 Tempo 與下一堂 LSD 之間，確實也帶有 `Prepare` 的影子，但它在 sequence 裡的第一責任仍然是先處理前一堂 Threshold 帶來的疲勞義務。今天的 Recovery Run 距離短、負荷低，而且隔天 LSD 也確實順利成立，因此最穩定的 reading 是：primary mission 先是 `Recover`，而「保留長距離入口」則落在 mission phrase 與 continuity outcome。也就是說，今天先完成 recovery obligation，再讓 continuity 有充分證據升到 `Ready`。

**Correctness**

- Score: 2
- Why: 這個案例與 Case 02 共享同一個決策難點：Recovery 與下一堂關鍵課之間會自然浮現 `Prepare` 的誘惑。但 sequence order 仍然支持 `Recover` 優先，因為如果前一堂品質負荷沒有先被妥善消化，下一堂 LSD 的入口就不應被直接宣告為 preparation outcome。Recovery 本身完成得很乾淨，而隔天 LSD 也成功完成，因此 `Recover -> Ready` 是可信的。

**Helpfulness**

- Score: 2
- Why: Activity-only 只會說這堂恢復跑很輕。WSI 則進一步回答了：為什麼它輕、它先服務哪一個 obligation、以及它如何把 sequence 送進隔天的長距離。這比單純描述 recovery 更像教練式理解。

**Reviewer Confidence**

- Score: High
- Why: 這個案例的前後文完整，而且它不是像 Case 02 那樣處於 `Threshold` 明天即到的高張力邊界。前一堂 Tempo 與下一堂 LSD 讓 obligation ordering 更清楚，後續證據也支持 `Ready`，因此信心可以提升到 High。

**Learning Notes**

Case learning: 這個案例支持 `Case 02` 所細化出的 obligation-order reading，並顯示它不只適用於 `Recovery -> Threshold`，也能外推到 `Recovery -> LSD`。

Rule learning: `Every Refine should earn a future Support.` 這個案例正是對 Case 02 refine 的支持。它說明當 Recovery 位在前一堂品質課與下一堂關鍵課之間時，primary mission 仍可穩定先落在 `Recover`，而 preparation function 交由 mission phrase 與 continuity outcome承接。

Epistemic learning: 這個案例也支持克制性。WSI 並沒有因為下一堂是 LSD 就直接把 primary mission 改寫成 `Prepare`；它仍然遵守當前 sequence obligation 的先後順序。

**Rule Impact**

- Supports
- Why: 這個案例不是在創造新邊界，而是在證明 Case 02 的 refine 確實提升了既有規則的外推能力。

**Refinement Decision**

- keep as is

### Case 04 — Novel Pattern Test

**Pattern Type**

Novel Pattern.

**Research Intent**

Discovery.

This case should be treated as the first real test of a `Build`-centered current workout inside Batch 20.

Its purpose is not to re-evaluate support-day missions.

Its purpose is to test whether WSI can explain a key quality workout as a sequence mission, rather than only handling the easier support-day interpretations around it.

**Date / Sequence Window**

2026-05-12 -> 2026-05-13 -> 2026-05-14 -> 2026-05-15

**Previous Workout**

2026-05-12 Easy Run / Aerobic Base / 9.079 km / Training Load 221 / RPE 3 - 中等

**Current Workout**

2026-05-13 Marathon Pace / Race Simulation / 11.015 km / Training Load 275 / RPE 4 - 有點難

**Next Workout**

2026-05-14 Recovery Run / Recovery / 6.014 km / Training Load 70 / RPE 3 - 中等

**Forward Context**

2026-05-15 Tempo Run / Threshold / 10.009 km / Training Load 240 / RPE 3 - 中等

**Activity-only Reading**

這是一堂馬拉松配速課。只看 Activity 的話，最自然的 reading 會是：今天完成了一堂有明確配速意圖的品質訓練，留下了可辨識的耐力與節奏刺激。

**WSI Reading**

- Mission Category: Build
- Mission Phrase: Build marathon pace durability without breaking threshold continuity
- Mission Status: Completed
- Continuity State: Maintained
- Sequence Reasoning: 這堂課在 sequence 裡不是 support day，而是當前的主刺激本身。前一天的 Easy Run 把身體帶進可工作的狀態，今天的 Marathon Pace 課則直接負責建立比賽節奏耐受與穩定輸出能力，因此 primary mission 應落在 `Build`，而不是 `Prepare` 或 `Activate`。但它完成 mission 之後，sequence 並不會立刻進入 `Ready`，因為隔天仍然需要一堂 Recovery Run 來吸收與整理刺激，之後才順利銜接到 5/15 的 Threshold。這使得目前最穩定的 reading 是：`Build` 已完成，而 continuity 被保留在一個仍然 coherent、但尚未直接宣告 ready-for-next-quality 的 `Maintained` 狀態。

**Correctness**

- Score: 2
- Why: 這堂課若不讀成 `Build`，就會錯過 sequence 中最核心的角色。它不是為下一堂課鋪路的 support day，而是這一段訓練本身要主動創造能力的主刺激。把它讀成 `Build marathon pace durability` 與前後文相符，也與後續 Recovery -> Threshold 的 sequence 成立方式一致。

**Helpfulness**

- Score: 2
- Why: Activity-only 只能說今天完成了一堂馬拉松配速課。WSI 則能把它放回整段 block：今天是主刺激、隔天需要 recovery、之後還要再進 Threshold。這讓 Runner 更能理解今天不是單日表現，而是整個品質序列中的建構點，因此明顯更有教練感。

**Reviewer Confidence**

- Score: Medium
- Why: `Build` 作為 primary mission 幾乎沒有疑義，真正存在張力的是 continuity state。`Maintained` 目前是最穩定且最克制的選項，但它也顯示目前 vocabulary 對「成功推進了訓練、但尚未進入 ready state」的表達仍偏保守，因此信心保留在 Medium。

**Learning Notes**

Case learning: 這是第一個清楚以 key workout 本身作為 current mission 的案例。它支持 `Build` 不只是 ontology 中的理論類別，而是能在真實 sequence 中承擔 primary mission。

Rule learning: 目前的 reasoning contract 可以處理 `Build` 作為 primary mission，但 build-day 的 continuity 解釋比 support-day 更依賴對「局部完成」與「整段 sequence 尚待吸收」的分離表達。

Epistemic learning: 這個案例也提醒 WSI 要保持克制。即使後續 Recovery 與 Threshold 都順利發生，也不代表 5/13 當下就應直接宣告 `Ready`。把 continuity 暫時留在 `Maintained`，雖然略保守，但比過度宣告更誠實。

**Rule Impact**

- Challenges
- Why: 這個案例沒有挑戰 `Build` mission 本身，但它開始挑戰現有 continuity vocabulary 是否足以自然表達「sequence 被成功推進，但下一步仍需吸收」這種 build-day 狀態。這不一定要求新增 ontology，但確實對目前模型形成第一個像樣的壓力測試。

**Refinement Decision**

- keep observing before refining

**Research Note**

This case should be watched over the next few Batch 20 cases for one specific question:

`Can successful build-day continuity be explained cleanly with the current continuity-state set, or does repeated pressure reveal a missing distinction between preserved continuity and advanced continuity?`

### Case 05 — Existing Pattern Reproduction Test

**Pattern Type**

Existing Pattern.

**Research Intent**

Generalization.

This case should be treated as a direct follow-up pressure test to Case 04 rather than a new ontology problem.

Its purpose is to test whether the continuity-vocabulary pressure seen in a `Build`-centered sequence appears again under a different build workout type.

**Date / Sequence Window**

2026-05-25 -> 2026-05-26 -> 2026-05-27 -> 2026-05-28

**Previous Workout**

2026-05-25 Recovery Run / Recovery / 7.1 km / Training Load 169 / RPE 3 - 中等

**Current Workout**

2026-05-26 Progression Run / Aerobic Build / 11.009 km / Training Load 288 / RPE 4 - 有點難

**Next Workout**

2026-05-27 Recovery Run / Recovery / 7.008 km / Training Load 132 / RPE 3 - 中等

**Forward Context**

2026-05-28 Long Run / Endurance / 9.02 km / Training Load 212 / RPE 4 - 有點難

**Activity-only Reading**

這是一堂漸速跑。只看 Activity 的話，最自然的 reading 會是：今天完成了一堂逐步推進強度的品質課，留下了明確的有氧到節奏耐受刺激。

**WSI Reading**

- Mission Category: Build
- Mission Phrase: Build aerobic progression strength without breaking long-run continuity
- Mission Status: Completed
- Continuity State: Maintained
- Sequence Reasoning: 這堂課和 Case 04 一樣，不是 support day，而是這段 sequence 裡的主刺激之一。前一天的 Recovery Run 提供了進入品質課的空間，今天的 Progression Run 則直接負責建立漸進輸出與有氧推進能力，因此 primary mission 仍應落在 `Build`。但它完成 build mission 之後，sequence 並不會立刻轉成 `Ready`，因為隔天仍安排了 Recovery Run，表示這段刺激仍需要先被吸收與整理，之後才順利接到 5/28 的長跑。因此目前最穩定也最克制的 reading 仍然是：`Build` 已完成，而 continuity 被保留在 `Maintained`，而不是過早升格成 `Ready`。

**Correctness**

- Score: 2
- Why: 這堂課若不讀成 `Build`，就會錯過它作為本段主刺激的角色。與 Case 04 相比，它不是馬拉松配速課，而是漸速跑，但 sequence function 相同：今天負責直接建立能力，而不是只為下一堂課做 support。把它讀成 `Build`，同時保留後續仍需 absorption 的判斷，是目前最符合前後脈絡的 reading。

**Helpfulness**

- Score: 2
- Why: Activity-only 只能說今天完成了一堂漸速跑。WSI 則能回答這堂課在整段 sequence 中的工作：今天主動推進能力，隔天先吸收，再接下一堂長跑。這比單純說「今天跑得不錯」更像教練在安排一段小型 block。

**Reviewer Confidence**

- Score: Medium
- Why: `Build` 作為 primary mission 仍然穩固，真正不確定的地方和 Case 04 一樣，落在 continuity vocabulary 是否足以自然表達「成功推進 sequence，但尚未 ready」這種 build-day outcome。因此目前仍維持 Medium。

**Learning Notes**

Case learning: 這個案例重現了 Case 04 的核心張力。不同 build workout type 仍可能把 sequence 留在同一種中介狀態：mission clearly completed, but continuity not yet naturally expressible as `Ready`.

Rule learning: 這個案例沒有對 `Build` mission 造成壓力，反而支持 `Build` 已經是可運作的 primary mission category。真正持續承壓的是 continuity outcome vocabulary，尤其是在 build day 後緊接 recovery、再銜接下一堂關鍵課的情境中。

Epistemic learning: 這個案例支持克制性。WSI 沒有因為後續還有長跑就把今天 retroactively 說成 `Prepare`，也沒有因為當前 build 完成就直接宣告 `Ready`。

**Rule Impact**

- Challenges
- Why: 這是第二個 build-centered case，再次把壓力集中在 continuity vocabulary，而不是 mission ontology 或 reasoning contract。當同樣的壓力可在不同 build workout type 中重現時，它就更像一個真正的研究問題，而不再只是單一案例的特殊性。

**Refinement Decision**

- continue observation

**Research Note**

Case 04 and Case 05 together should now be treated as an active observation pair.

If a third build-centered case produces the same tension, continuity vocabulary should become an explicit refinement candidate rather than a one-off concern.

## Batch 20 — First Cycle Interim Reading

The first five Batch 20 cases should now be treated as the completion of the first research cycle rather than merely the first five examples.

They form a complete evidence chain:

`Supports -> Refines -> Supports -> Challenges -> Repeated Challenges`

This means Batch 20 is no longer only testing whether WSI can work.

It is now beginning to show how the reasoning model behaves under extension, refinement, and repeated pressure.

### What Currently Looks Stable

- Mission is role, not workout label.
- Layered judgment remains coherent across cases:
  - Mission Category
  - Mission Status
  - Continuity State
- Primary mission can be selected through sequence obligation ordering rather than surface workout semantics alone.
- `Build` can now be treated as a real primary mission, not merely an ontology placeholder.

### What Is Still Being Refined

- The obligation-order reading introduced in Case 02 has now earned a future support in Case 03.
- This means the refine did not behave like a patch.
- It generalized cleanly across another recovery-between-quality context.

### What Is Now an Active Research Question

Build-centered cases are now applying repeated pressure to continuity vocabulary.

Case 04 and Case 05 both support the same provisional working conclusion:

`Build mission is stable. Continuity vocabulary is under repeated pressure.`

This does not yet justify vocabulary expansion.

It does justify active observation.

### Active Research Question

`Can the current continuity-state vocabulary distinguish successful sequence progression from readiness after build-centered workouts?`

At the current stage, this should remain a research question rather than a new rule.

### Interim Working Conclusion

After the first five Batch 20 cases:

- mission ontology remains sufficient
- reasoning contract remains structurally intact
- existing rules remain usable
- the first repeated research pressure has emerged at the continuity-vocabulary layer

### Reasoning Model v1.0 Established

The current Workout Sequence reasoning model should now be treated as `Reasoning Model v1.0`.

This does not mean the model is final.

It means the model has now earned baseline status for future regression and refinement.

At this point:

- the current reasoning contract has remained internally consistent across Sprint 0 and the first Batch 20 cycle
- stable rules have emerged and remained usable
- refined rules have already demonstrated one successful generalization
- active research questions have been isolated without forcing ontology expansion

From this point forward, future regression should be understood as:

`Does Reasoning Model v1.0 remain internally consistent under additional real cases?`

not merely:

`Do individual older cases still look right?`

The next step should therefore be:

1. rerun G01-G05 as the current regression suite
2. update the first Rule Stability Tracking snapshot
3. continue Batch 20 only after confirming no gold-case drift

This keeps the training loop evidence-driven and prevents Batch 20 from turning into uncontrolled case accumulation.

## Reasoning Model v1.0 Certification Round 1

The first regression pass after Sprint 0 and the first Batch 20 cycle should now be treated as:

`Reasoning Model v1.0 Certification Round 1`

Its purpose is not to rediscover the five gold cases.

Its purpose is to confirm that:

- the gold baseline remains internally consistent
- the first Batch 20 refinements did not introduce worldview drift
- working-asset refinement did not silently contaminate foundational assets

### Certification Result

**Consistency**

Consistent.

The current reasoning model remains aligned with G01-G05.

None of the first-cycle Batch 20 findings require a reinterpretation of the original gold-case readings.

**Drift**

No observable drift.

The obligation-order refinement remains compatible with the existing gold cases.

The repeated build-day pressure affects continuity vocabulary as an active research area, but it does not force a rewrite of:

- Sprint 0 findings
- the current reasoning contract
- the original gold-case mission readings

**Confidence**

Confidence increased through successful regression.

The model now has:

- stable mission logic across calibration and batch generalization
- one refine that successfully earned future support
- one active research pressure that remains isolated without forcing ontology expansion

This means Reasoning Model v1.0 should now be treated as certified against Regression Round 1.

## Rule Stability Snapshot #1

This snapshot should be read after Regression Round 1, not before it.

It reflects rules that remain usable after the first Batch 20 cycle and successful gold-case consistency review.

| Rule | Supports | Refines | Challenges | Current Reading |
|---|---:|---:|---:|---|
| Rule 1 | 1 | 0 | 0 | Stable |
| Rule 2 | 0 | 0 | 0 | Stable |
| Rule 3 | 0 | 0 | 0 | Stable |
| Rule 4 | 2 | 1 | 0 | Refining toward stability |
| Rule 5 | 0 | 0 | 0 | Stable |

### Snapshot Interpretation

- Rule 1 remains stable and continues to generalize.
- Rule 4 is currently the most actively maturing rule:
  - refined once in Case 02
  - supported again in Case 03
  - additionally reinforced by Case 01
- Rule 2, Rule 3, and Rule 5 were not materially stressed by the first Batch 20 cycle, but they remain consistent with the current model and showed no regression pressure.

### Active Research Pressure

The first repeated research pressure is not yet a new rule.

It is an active question at the continuity-vocabulary layer:

`Can the current continuity-state vocabulary distinguish successful sequence progression from readiness after build-centered workouts?`

At the end of Certification Round 1, this pressure should still be treated as:

- observed twice
- not yet canonical
- not yet sufficient to justify ontology expansion

## Research Intent Snapshot #1

At the current stage, case selection should not be driven only by workout type or mission family.

It should also consider whether the research-intent distribution is becoming too narrow.

Current observed distribution:

| Research Intent | Count | Cases |
|---|---:|---|
| Discovery | 2 | Case 02, Case 04 |
| Generalization | 3 | Case 01, Case 03, Case 05 |
| Falsification | 1 | Case 07 |
| Regression | 1 | Certification Round 1 |

### Snapshot Reading

- Discovery is already present and functioning.
- Generalization is currently the dominant mode, which is expected in an early production cycle.
- Falsification has now appeared and materially reduced uncertainty.
- Regression has already become a certified part of the method rather than an ad hoc rerun step.

### Working Guidance for Case Selection

Before selecting the next case, CoachOS should first ask:

`Which research intent is currently underrepresented, and what kind of case would most meaningfully test it?`

This does not mean future case selection must be numerically balanced.

It means case selection should now be conscious of research-method coverage, not only training-pattern coverage.

### Current Working Hypothesis

The current four research intents should now be treated as a stable working set:

- Discovery
- Generalization
- Falsification
- Regression

They should not be expanded unless repeated later cases show that meaningful research work can no longer be naturally described within this set.

## Batch 20 / Case 06 — Post-Certification Evidence

### Case 06 — Existing Pattern Reproduction Test

**Pattern Type**

Existing Pattern.

This case should be treated as the first post-certification pressure test of the current reasoning model.

Its purpose is not to reopen certification.

Its purpose is to determine whether the build-centered continuity-vocabulary pressure now appears for a third time under a different build workout type and a more endurance-heavy forward context.

**Date / Sequence Window**

2026-04-14 -> 2026-04-15 -> 2026-04-16 -> 2026-04-17 -> 2026-04-18

**Previous Workout**

2026-04-14 Easy Run / Aerobic Base / 8.751 km / Training Load 220 / RPE 3 - 中等

**Current Workout**

2026-04-15 Interval / Quality Build / 10.981 km / Training Load 237 / RPE 3 - 中等

**Next Workout**

2026-04-16 Recovery Run / Recovery / 6.01 km / Training Load 122 / RPE 3 - 中等

**Forward Context**

2026-04-17 Long Run / Endurance / 10.011 km / Training Load 240 / RPE 3 - 中等
2026-04-18 LSD / Endurance / 16.011 km / Training Load 274 / RPE 4 - 有點難

**Activity-only Reading**

這是一堂間歇課。只看 Activity 的話，最自然的 reading 會是：今天完成了一堂明確的品質刺激，留下了可辨識的速度耐受與有氧上限刺激。

**WSI Reading**

- Mission Category: Build
- Mission Phrase: Build interval strength while preserving weekend endurance continuity
- Mission Status: Completed
- Continuity State: Maintained
- Sequence Reasoning: 這堂課和 Case 04、Case 05 一樣，不是 support day，而是當前 sequence 裡的主刺激之一。前一天的 Easy Run 提供了進入品質課的工作空間，今天的 Interval 則直接負責建立強度輸出與品質刺激，因此 primary mission 仍然應落在 `Build`。但它完成 build mission 之後，sequence 並不會自然直接進入 `Ready`，因為隔天仍安排了 Recovery Run，而後面又接著兩堂 endurance-oriented 課。這代表今天的 build 成功推進了訓練，但這份推進仍需要先被吸收與整理，才能轉成更高把握的 readiness。因此目前最穩定的 reading 仍是：`Build` 已完成，而 continuity 保持在 `Maintained`，而不是直接升格為 `Ready`。

**Correctness**

- Score: 2
- Why: 若不把這堂課讀成 `Build`，就會錯過它作為本段主刺激的角色。與 Case 04 的 Marathon Pace、Case 05 的 Progression Run 不同，這裡是 Interval，但 sequence function 相同：今天負責直接建立能力，而不是只服務下一堂課。把它讀成 `Build`，同時保留後續仍需 absorption 的 sequence judgment，是目前最符合前後脈絡的 reading。

**Helpfulness**

- Score: 2
- Why: Activity-only 只能說今天完成了一堂間歇品質課。WSI 則能回答這堂課在整段 sequence 中的作用：今天主動建立刺激，隔天先吸收，再接週末的 endurance block。這會比單日訓練分析更能幫助 Runner 理解今天不是孤立事件，而是整段訓練推進的一部分。

**Reviewer Confidence**

- Score: Medium
- Why: `Build` 作為 primary mission 仍然穩固。真正持續存在的不確定性，依然不是 mission，而是 continuity vocabulary 是否足以自然表達「build 已成功推進訓練，但 readiness 尚未形成」這類 sequence outcome。因此信心維持 Medium。

**Learning Notes**

Case learning: 這個案例再次重現了 build-centered sequence 的同一張力，而且這次不是 Marathon Pace 或 Progression Run，而是 Interval。這代表目前的壓力不依賴特定 workout type，而更像 build-day continuity interpretation 的一般性問題。

Rule learning: `Build` 已經跨三種不同 workout type 站穩作為 primary mission category。真正反覆承壓的不是 mission ontology，也不是 reasoning contract，而是 continuity vocabulary 在 build-day context 下的表達力。

Epistemic learning: 這個案例再次支持克制性。WSI 沒有因為後面還有 weekend endurance block 就把今天 retroactively 改寫成 `Prepare`，也沒有因為 build 已完成就直接宣告 `Ready`。

**Rule Impact**

- Challenges
- Why: 這是第三個 build-centered case，再次把壓力集中在 continuity vocabulary，而不是 mission ontology 或 reasoning contract。此時這個壓力已不應再被視為單一案例現象，而應視為一個需要後續 refinement 的明確研究方向。

**Refinement Decision**

- refine worldview interpretation

**Research Note**

This is now the third build-centered case producing the same continuity-state tension.

At this point, continuity vocabulary should no longer be treated as a one-off observation.

The next priority is to determine whether this refinement candidate is Build-specific or generalizable across mission families.

## Build Family Knowledge Consolidation #1

This consolidation should be treated as a knowledge checkpoint, not a new framework.

Its purpose is to turn the combined evidence from Case 04 through Case 07 into reusable build-family knowledge.

The question here is no longer:

`Can Build function as a real primary mission?`

The question now is:

`What build-family knowledge is stable enough to reuse after repeated evidence and cross-family falsification?`

### 1. What We Now Know

- `Build` is a stable primary mission rather than a support-role description.
  - Across the current evidence, build-day workouts are not being read as disguised preparation or activation days.
- Build mission has already generalized across multiple workout types.
  - Marathon Pace
  - Progression Run
  - Interval
- The main tension in build-family cases is not `Mission Category`.
  - The repeated pressure sits at the `Continuity State` layer.
- Successful build execution does not automatically imply immediate readiness.
  - A build day can clearly complete its mission while still leaving the surrounding sequence in `Maintained` rather than `Ready`.

### 2. What We Still Do Not Know

- Whether the current continuity-state vocabulary is ultimately sufficient for the full range of build-family outcomes.
- Whether the observed build-family pressure appears only in the currently observed pattern shape, or across a broader set of build-centered sequences.
- Where the failure boundary of build continuity interpretation actually sits:
  - when is `Maintained` the right outcome?
  - when should a build-centered sequence become `Ready`?
  - under what conditions would a build mission materially fail sequence continuity?

### 3. What Can Now Be Treated as Reusable Knowledge

The following build-family readings should now be treated as reusable knowledge:

`Build can serve as a true primary mission across multiple workout types.`

`Successful build execution does not necessarily imply immediate readiness.`

`Build-day continuity pressure currently appears to sit at the continuity-vocabulary layer rather than at the mission layer.`

Case 04 first exposed this pressure.

Case 05 and Case 06 reproduced it across different build workout types.

Case 07 then showed that the same pressure did not reproduce in the tested Recover-family falsification case.

Taken together, these cases move the current build-family reading from:

- repeated observation

to:

- localized reusable interpretation

### 4. Remaining Research Gap

The next build-family research gap is not mission identity.

It is continuity boundary strength.

The next meaningful question should be:

`When a build mission is clearly completed, what evidence is sufficient for continuity to remain Maintained, and what evidence would justify Ready or reveal real sequence failure?`

This means future build-family cases should now prioritize:

- stronger continuity boundary pressure
- conditions where absorption is cleaner or more immediate
- possible counterexamples where build completion does or does not translate into readiness

At the end of this consolidation, the current working conclusion is:

`Build is now established as reusable mission-family knowledge, but the continuity boundary after successful build remains unresolved.`

## Batch 20 / Case 07 — Boundary Falsification Test

### Case 07 — Boundary Falsification Test

**Pattern Type**

Boundary Pattern.

This case should be treated as a falsification test rather than a support-building case.

Its purpose is to test whether the continuity-vocabulary pressure observed across three `Build` cases can be reproduced in a non-Build mission family.

If the pressure does not reproduce here, the current working hypothesis should narrow toward:

`Current evidence localizes the observed continuity-vocabulary pressure to the Build mission family. Further validation across additional mission families remains necessary.`

**Date / Sequence Window**

2026-04-15 -> 2026-04-16 -> 2026-04-17 -> 2026-04-18

**Previous Workout**

2026-04-15 Interval / Quality Build / 10.981 km / Training Load 237 / RPE 3 - 中等

**Current Workout**

2026-04-16 Recovery Run / Recovery / 6.01 km / Training Load 122 / RPE 3 - 中等

**Next Workout**

2026-04-17 Long Run / Endurance / 10.011 km / Training Load 240 / RPE 3 - 中等

**Forward Context**

2026-04-18 LSD / Endurance / 16.011 km / Training Load 274 / RPE 4 - 有點難

**Activity-only Reading**

這是一堂恢復跑。只看 Activity 的話，最自然的 reading 會是：它負責把前一堂間歇課的強度拉下來，讓身體回到比較可持續的狀態。

**WSI Reading**

- Mission Category: Recover
- Mission Phrase: Recover from interval load while preserving weekend endurance entry
- Mission Status: Completed
- Continuity State: Ready
- Sequence Reasoning: 這堂課和 Case 02、Case 03 一樣，位在前一堂品質課與後續關鍵課之間，但它的 primary mission 仍然清楚是 `Recover`。與 build-centered cases 不同，這裡的 sequence meaning 本來就不是「今天主動推進訓練、之後再等待吸收」，而是「先把前一堂 Interval 的壓力安全地下拉，讓後面的 endurance block 可以順利成立」。由於 4/17 Long Run 與 4/18 LSD 都實際完成，而這堂 Recovery Run 的負荷也沒有顯示額外干擾，因此目前的 continuity vocabulary 已足以自然表達這個 outcome：`Recover` 完成後，sequence 可以可信地進入 `Ready`，而不需要一個介於 `Maintained` 與 `Ready` 之間的新狀態。

**Correctness**

- Score: 2
- Why: 這個案例的 mission 判讀非常穩。前一堂是明確的 Interval，當前是 Recovery，後面接 Long Run 與 LSD，最自然的 sequence role 就是先完成 recovery obligation，再讓後續 endurance block 順利展開。`Recover -> Ready` 在這裡是可信且完整的。

**Helpfulness**

- Score: 2
- Why: Activity-only 只能說這堂課很像標準 recovery day。WSI 則能把更重要的 sequence meaning 說出來：今天不是單純降負荷，而是在為整個週末 endurance block 恢復出一個可工作的入口。這比單看當天更有教練感，也更能幫助 Runner 理解這堂課為什麼重要。

**Reviewer Confidence**

- Score: High
- Why: 這個案例的前後文完整，而且 unlike the build-centered cases, `Ready` 在這裡不顯得過度宣告。Recovery mission 本來就以恢復 readiness 為主要結果，因此目前 vocabulary 在這個 mission family 下運作自然，信心可以拉到 High。

**Learning Notes**

Case learning: 這個案例沒有重現 build-centered continuity pressure。相同的 `Maintained vs Ready` vocabulary 在 `Recover` mission family 中仍然足夠自然，沒有出現「mission clearly completed, but continuity not yet expressible」的中介張力。

Rule learning: 這個案例支持目前模型在非-Build family 下仍然穩定，並收斂了 Case 04-06 所產生的研究假設。也就是說，目前 evidence 更支持把已觀察到的 continuity-vocabulary pressure 暫時定位在 Build mission family，而不是把它視為跨 mission family 的普遍問題。

Epistemic learning: 這個案例是有價值的 falsification attempt，因為它試圖在最容易出現前後 obligation 的非-Build family 中重現同樣壓力，但沒有成功。這使研究範圍得以縮小，而不是持續模糊擴大。

**Rule Impact**

- Supports
- Why: 這個案例支持當前 reasoning model 在 `Recover` family 中仍然足夠完整，也支持把 continuity-vocabulary pressure 暫時收斂為一個目前定位於 Build mission family 的 working hypothesis，而不是全面性的 vocabulary failure。

**Refinement Decision**

- keep as is

## Batch 20 / Case 08 — Rule-centered Falsification Test

### Case 08 — Rule-centered Falsification Test

**Research Goal**

This case attempts to falsify Rule 1.

If Rule 1 survives this sequence, confidence in sequence-role reasoning should increase.

If Rule 1 fails, its scope should be refined rather than defended.

**Pattern Type**

Boundary Pattern.

**Research Intent**

Falsification.

This case should not begin with a preferred answer.

It should begin with a rule-level question:

`Can Rule 1 survive a sequence where the workout label says Easy, but the surrounding obligations may point elsewhere?`

**Date / Sequence Window**

2026-05-23 -> 2026-05-24 -> 2026-05-25 -> 2026-05-26

**Previous Workout**

2026-05-23 LSD / Endurance / 18.009 km / Training Load 289 / RPE 5 - 困難

**Current Workout**

2026-05-24 Easy Run / Aerobic Base / 7.007 km / Training Load 152 / RPE 3 - 中等

**Next Workout**

2026-05-25 Recovery Run / Recovery / 7.1 km / Training Load 169 / RPE 3 - 中等

**Forward Context**

2026-05-26 Progression Run / Aerobic Build / 11.009 km / Training Load 288 / RPE 4 - 有點難

**Activity-only Reading**

這是一堂輕鬆跑。只看 Activity 的話，最自然的 reading 會是：長距離之後用一堂中等負荷的 easy run 把節奏延續回來，既不是主刺激，也不像明確的恢復跑。

**WSI Reading**

- Mission Category: Recover
- Mission Phrase: Recover from long-run fatigue while preserving the next build entry
- Mission Status: Completed
- Continuity State: Maintained
- Sequence Reasoning: 這個案例真正要測的不是 Easy Run 看起來像什麼，而是 sequence obligation 指向什麼。前一堂是明確的 LSD，後面又先接一堂 Recovery Run，之後才進入 Progression Run。這表示 5/24 雖然標成 Easy Run，但它所在的位置更像一段仍在持續中的 recovery sequence，而不是單純的 aerobic maintenance。它的第一責任不是建立新能力，也不是主動為 5/26 做 preparation，而是先把 5/23 長距離留下的疲勞壓力往下拉，同時不破壞後面的 build entry。因此目前最可信的 reading 是：primary mission 應落在 `Recover`，而不是繼承 `Easy` 這個 workout label；由於隔天仍然還需要另一堂 Recovery Run，continuity 也較適合維持在 `Maintained`，而不是過早宣告 `Ready`。

**Correctness**

- Score: 2
- Why: 這個案例的價值就在於它讓 workout label 與 sequence role 分開。若直接把 5/24 因為標成 Easy 就讀成 `Maintain` 或 `Activate`，會低估前一堂 18K LSD 的殘餘壓力，也會忽略隔天仍然安排 Recovery 的事實。把它讀成 `Recover`，更能反映 surrounding obligations 的先後順序。

**Helpfulness**

- Score: 2
- Why: Activity-only 只能說這是一堂長距離之後的 easy day。WSI 則能回答更重要的事：這堂課的 sequence function 不是 generic easy mileage，而是 recovery process 的一部分。這會讓 Runner 更理解為什麼一堂標成 Easy 的課，實際上仍然在替前一天的長距離善後。

**Reviewer Confidence**

- Score: Medium
- Why: 這是一個真正的 rule-centered falsification case。`Recover` 是目前最可信的 reading，但這裡也存在 `Maintain` 的相鄰可能性，因此信心不應過早拉到 High。Medium 代表這個案例足夠有壓力，但目前證據仍支持 Rule 1 可以站住。

**Learning Notes**

Case learning: 這個案例支持一個更精確的表述：sequence role 應由 surrounding obligations 推導，而不是由 workout label 繼承。`Easy` 不是 mission，它只是表面型態；mission 仍要回到前後 sequence 去判定。

Rule learning: 如果這個案例成立，那 Rule 1 的可信度會上升，因為它不只適用於 `Easy -> Prepare` 或 `Easy -> Activate`，也適用於 `Easy -> Recover` 這種較反直覺的情境。換句話說，Rule 1 承受的不是單一 mission family 的壓力，而是真正的 label-role mismatch 壓力。

Epistemic learning: 這個案例提醒我們不要把 falsification case 寫成答案導向案例。這裡真正被驗證的是 Rule 1，而不是 `Easy can become Recover` 這一句話本身。

**Rule Impact**

- Supports
- Why: 目前 evidence 支持 Rule 1 可以在這種 label-role mismatch 的情境下存活。sequence role 仍然是由 surrounding obligations 決定，而不是由 workout label 自動繼承。

**Refinement Decision**

- keep as is

## Batch 20 / Case 09 — Imperfect Preparation Discovery Test

### Case 09 — Imperfect Preparation Discovery Test

**Pattern Type**

Boundary Pattern.

**Research Intent**

Discovery.

This case is not selected because `Easy + Strides` is inherently special.

It is selected because the current evidence gap sits in a different place:

`Can the current model absorb a preparation-family case where the pre-quality day is structurally suitable, but physiologically heavier than an ideal preparation day?`

In other words, this case tests whether the current model can describe imperfect preparation without forcing a new research question outside the Build family.

**Date / Sequence Window**

2026-05-18 -> 2026-05-19 -> 2026-05-20 -> 2026-05-21

**Previous Workout**

2026-05-18 Recovery Run / Recovery / 6.011 km / Training Load 113 / RPE 3 - 中等

**Current Workout**

2026-05-19 Easy Run / Aerobic Base / 9.103 km / Training Load 243 / RPE 3 - 中等
Workout structure: `8K Aerobic Steady + Strides`

**Next Workout**

2026-05-20 Interval / VO2max / 10.644 km / Training Load 261 / RPE 3 - 中等
Workout structure: `10K Cruise Interval`

**Forward Context**

2026-05-21 Recovery Run / Recovery / 5.01 km / Training Load 98 / RPE 3 - 中等

**Activity-only Reading**

這不是一堂純粹的 easy jog，而是一堂帶有 steady feel 與 strides 的前置課。只看 Activity 的話，最自然的 reading 會是：今天用一堂偏穩定、帶一點腿部喚醒的有氧課，把身體帶進明天的 Cruise Interval。

**WSI Reading**

- Mission Category: Prepare
- Mission Phrase: Prepare for cruise-interval entry by reopening aerobic rhythm and leg turnover without over-consuming freshness
- Mission Status: Partial
- Continuity State: Maintained
- Sequence Reasoning: 這堂課前面接的是 Recovery，後面接的是明確的 Interval，sequence obligation 很自然會把 primary mission 拉向 `Prepare`，而不是 `Activate` 或 `Maintain`。但它同時又不是一堂乾淨、低成本的 preparation day。`8K Aerobic Steady + Strides` 本身留下了偏高的 training load（243）、較高的有氧刺激（TE 4.2）與一些額外的神經肌肉工作，因此今天確實有在為 5/20 的 Cruise Interval 建立進場狀態，但也明顯消耗了比理想 preparation day 更多的 freshness。隔天 Interval 仍然完成，且後面能接回 Recovery，表示 sequence 沒有被打斷；只是這份 continuity 更像「成功維持住」，而不是「被乾淨地送進 Ready」。因此目前最穩定的 reading 是：`Prepare` 仍是正確 primary mission，但 mission 只算 `Partial`，continuity 保留在 `Maintained`。

**Correctness**

- Score: 2
- Why: 前後 sequence 很清楚地把這堂課放在 `Prepare` family，而不是 generic easy mileage。若把它讀成 `Activate`，會低估明天明確存在的 Interval obligation；若直接讀成完整 `Prepare -> Ready`，又會低估今天自身偏高的生理成本。`Prepare / Partial / Maintained` 目前最能同時容納這三件事。

**Helpfulness**

- Score: 2
- Why: Activity-only 只能說這是一堂為 Interval 做準備的 steady + strides day。WSI 則把更關鍵的 sequence meaning 說清楚了：今天的問題不是「有沒有準備」，而是「準備得夠不夠乾淨」。這比單純描述 workout structure 更像教練在看 sequence quality。

**Reviewer Confidence**

- Score: Medium
- Why: `Prepare` 作為 primary mission 幾乎沒有疑義，但 `Partial` 與 `Maintained` 的組合帶有一定判斷性。因為隔天 Interval 確實完成，代表 preparation 沒有失敗；但今天本身的負荷也明顯高於理想 prep day，所以還不能把信心拉到 High。

**Learning Notes**

Case learning: 這個案例顯示 preparation-family 的壓力不一定來自 mission category，而可能來自「preparation quality」本身。也就是說，mission 可以正確，sequence 也可以維持，但 mission completion 仍然可能只有 `Partial`。

Rule learning: 這個案例支持 Rule 1、Rule 4 與 Rule 5 的共同運作。Primary mission 仍由 sequence role 決定；steady + strides 這些次級功能仍落在 mission phrase；而執行品質的差異則透過 `Mission Status` 與 `Continuity State` 吸收，而不需要改寫 mission category。

Epistemic learning: 這個案例沒有迫使目前模型產生第二個 active research question。它更像是在告訴我們：現有模型已經可以處理「不完美但仍成立的 preparation day」，因此目前跨 mission-family 的新壓力仍未被觀察到。

**Rule Impact**

- Supports
- Why: 這個案例沒有推翻任何既有規則，也沒有產生新的重複壓力。相反地，它支持目前模型能在 preparation family 裡處理一個更不乾淨、但仍可解釋的 edge case，而不需要新增 ontology 或 vocabulary。

**Refinement Decision**

- keep as is

## Case 10 Selection Note

This note should be treated as research planning rather than case drafting.

Its job is not to pre-commit the answer.

Its job is to explain why the next case deserves evidence capacity, and what kind of knowledge gain it is expected to produce.

### Research Intent

Generalization.

### Reason

Case 09 already showed that the current model can absorb an imperfect preparation-day reading without creating a second active research question.

That means the next highest-value move is not another immediate discovery attempt.

It is to test whether this new preparation-family reading has real scope beyond one specific `steady + strides -> interval` sequence.

The current uncertainty is no longer:

`Can imperfect preparation exist?`

The current uncertainty is:

`Does the current model read imperfect preparation consistently across different next-workout families?`

### Candidate Pattern

Preparation-family sequence with a heavier-than-ideal pre-key day, but with a different next-workout type from Case 09.

Most promising candidate shape:

`Recovery -> Easy / Steady -> LSD`

Current strongest candidate:

`2026-05-21 Recovery -> 2026-05-22 Easy Run -> 2026-05-23 LSD`

Why this candidate is worth selecting:

- it remains inside the `Prepare` mission family
- it is not a copy of the `Interval` entry case
- the current day is again heavier than an ideal prep day (`10.01 km`, `training load 247`, `RPE 4`)
- the following key workout is `LSD`, which tests whether imperfect preparation can generalize beyond quality-entry sequences into endurance-entry sequences

### Expected Knowledge Contribution

This case is expected to contribute primarily in two ways:

1. `Scope expansion`

   If the current model can explain this sequence cleanly, then the imperfect-preparation reading from Case 09 should no longer be treated as a single-case edge reading.

2. `Rule confidence increase`

   If the case supports the same structure again, confidence should increase that `Prepare / Partial / Maintained` is not tied to one workout pair, but is a reusable preparation-family interpretation.

This case is not currently expected to create a new active research question.

It is expected to test whether the knowledge gained in Case 09 is local or reusable.

## Batch 20 / Case 10 — Imperfect Preparation Generalization Test

### Case 10 — Imperfect Preparation Generalization Test

**Pattern Type**

Existing Pattern.

**Research Intent**

Generalization.

This case should not be treated as a search for new pressure.

It should be treated as a scope-expansion test:

`Can the imperfect-preparation reading from Case 09 generalize beyond a quality-entry sequence into an endurance-entry sequence?`

Its value is not novelty.

Its value is reusability.

**Date / Sequence Window**

2026-05-21 -> 2026-05-22 -> 2026-05-23

**Previous Workout**

2026-05-21 Recovery Run / Recovery / 5.01 km / Training Load 98 / RPE 3 - 中等

**Current Workout**

2026-05-22 Easy Run / Aerobic Base / 10.01 km / Training Load 247 / RPE 4 - 有點難
Workout structure: `10K steady aerobic run`

**Next Workout**

2026-05-23 LSD / Endurance / 18.009 km / Training Load 289 / RPE 5 - 困難

**Activity-only Reading**

這不是一堂單純的放鬆 easy run，而是一堂偏 steady 的有氧課。只看 Activity 的話，最自然的 reading 會是：今天用一堂偏穩定、略有成本的 aerobic run，替明天的 LSD 把節奏接起來。

**WSI Reading**

- Mission Category: Prepare
- Mission Phrase: Prepare for long-run entry by restoring aerobic continuity without over-consuming endurance freshness
- Mission Status: Partial
- Continuity State: Maintained
- Sequence Reasoning: 這堂課前面接的是 Recovery，後面接的是明確的 LSD，因此 sequence obligation 仍然會把 primary mission 拉向 `Prepare`。它的工作不是單純累積里程，而是替隔天的長距離建立進場狀態。但和理想的 prep day 不同，這堂 10K steady aerobic run 本身留下了偏高的 training load（247）、較高的有氧刺激（TE 4.5），而且 RPE 也來到 `4 - 有點難`。這表示它確實完成了 preparation function，但不是以低成本方式完成。隔天 LSD 仍然成立，說明 sequence continuity 沒有失敗；只是這份 continuity 更像被維持住，而不是被乾淨送進 `Ready`。因此目前最穩定的 reading 仍然是：`Prepare` 為正確 primary mission，mission status 為 `Partial`，continuity state 維持在 `Maintained`。

**Correctness**

- Score: 2
- Why: 前後 sequence 讓 `Prepare` 幾乎沒有疑義。若把它讀成 `Maintain`，會低估隔天 LSD 這個明確存在的 forward obligation；若直接讀成 `Prepare -> Ready`，則又會忽略今天本身偏高的生理成本。`Prepare / Partial / Maintained` 仍然最能同時容納 sequence role 與 execution cost。

**Helpfulness**

- Score: 2
- Why: Activity-only 只能說這是一堂稍微偏重的 pre-LSD aerobic run。WSI 則把更有教練價值的問題說清楚了：今天不是「有沒有準備」，而是「這個準備是不是太有成本」。這讓 Runner 更容易理解為什麼一堂看似普通的 steady run，仍然值得放回 sequence 中重新判讀。

**Reviewer Confidence**

- Score: Medium
- Why: 這個案例的 mission 判定很穩，但 `Partial / Maintained` 仍然帶有判斷性，因為隔天 LSD 確實順利完成。這使它更像一個 scope-expansion case，而不是一個零爭議 case。

**Learning Notes**

Case learning: 這個案例支持 `Case 09` 的核心 reading 不是局部現象。Preparation-family 的不完美執行，並不只出現在 `steady + strides -> interval` 這種品質課入口，也會出現在 `steady aerobic -> LSD` 這種 endurance-entry sequence。

Rule learning: 這個案例增加的是既有知識的可信度，而不是新的知識類型。它支持目前模型可以把 preparation-family 中的 execution cost，穩定地吸收到 `Mission Status` 與 `Continuity State`，而不需要改寫 `Mission Category`。

Epistemic learning: 這個案例沒有創造第二個 active research question。它主要增加的是 scope：目前 evidence 更支持把 `Prepare / Partial / Maintained` 視為一個可重用的 preparation-family interpretation，而不是 Case 09 的單點讀法。

**Rule Impact**

- Supports
- Why: 這個案例支持 Case 09 所建立的 reading 可以 generalize 到不同 next-workout family。它沒有推翻規則，也沒有產生新的跨 family 壓力，因此主要增加的是 rule confidence 與 scope。

**Refinement Decision**

- keep as is

## Preparation Family Knowledge Consolidation #1

This consolidation should be treated as a knowledge checkpoint, not a new framework.

Its purpose is to turn the combined evidence from Case 09, Case 10, and Case 11 into reusable preparation-family knowledge.

The question here is no longer:

`Can imperfect preparation exist?`

The question now is:

`What preparation-family knowledge is stable enough to reuse after these cases?`

### 1. What We Now Know

- `Prepare` remains a sequence-role judgment, not a workout-label judgment.
  - Across the current cases, the current workout is still read primarily through the next key obligation rather than through the label `Easy Run`.
- Preparation quality can be imperfect without invalidating the primary mission.
  - A preparation day may still correctly serve `Prepare` even when its own execution cost is higher than ideal.
- Execution cost should not change `Mission Category`.
  - It should be absorbed through `Mission Status` and `Continuity State`.
- Preparation-family currently supports at least two reusable successful interpretations:
  - `Prepare / Partial / Maintained`
  - `Prepare / Completed / Ready`
- The distinction is driven by preparation quality as evidenced through the following sequence, rather than by workout label alone.
  - `Prepare / Partial / Maintained` describes a preparation day that remains usable, but not cleanly.
  - `Prepare / Completed / Ready` describes a preparation day that preserves enough freshness to send the sequence into a genuinely workable next-step state.

### 2. What We Still Do Not Know

- Where the true preparation-family failure boundary sits.
- What evidence is sufficient to distinguish:
  - `Completed / Ready`
  - `Partial / Maintained`
  - a genuinely failed preparation sequence
- Whether there is a true preparation-family counterexample where the current model becomes too coarse or the current boundary description breaks down.

### 3. What Can Now Be Treated as Reusable Knowledge

The following readings should now be treated as reusable preparation-family knowledge:

`A preparation day can be structurally correct, but physiologically costly. In such cases, Mission Category may remain Prepare, while Mission Status drops to Partial and Continuity State remains Maintained rather than Ready.`

`A preparation day can also be non-trivial in workload yet still preserve enough freshness for the following key workout to remain clearly workable. In such cases, Mission Category may remain Prepare, Mission Status may be Completed, and Continuity State may rise to Ready.`

Case 09 established that this reading can exist.

Case 10 showed that it can generalize beyond one specific next-workout type.

Case 11 then showed that preparation-family knowledge is not exhausted by the imperfect-preparation branch alone.
It also has a successful boundary branch in which preparation remains costly but still crosses the threshold into `Completed / Ready`.

Taken together, these cases move preparation-family knowledge from:

- a single reusable branch

to:

- a small but structured family-level interpretation with more than one stable successful outcome

### 4. Remaining Research Gap

The next preparation-family research gap is no longer existence or success-boundary discovery.

It is failure-boundary definition.

The next meaningful question should be:

`Under what conditions does preparation stop being merely Partial but usable, and become a genuine sequence failure?`

This means future preparation-family cases should now prioritize:

- stronger failure-boundary pressure
- possible counterexamples
- cases where the next key workout does not merely survive, but is clearly compromised, flattened, shortened, or deprived of its intended coaching role

At the end of this consolidation, the current working conclusion is:

`Preparation-family knowledge now supports at least two reusable successful interpretations, but its true failure boundary is still unknown.`

### Current Working Mode for Preparation Family

Preparation family should now be treated as being in `Observation Mode`.

This means:

- its current reusable knowledge should remain active
- its open failure boundary should remain explicitly acknowledged
- no new preparation-family case should be forced merely because an open gap exists

The next preparation-family case should be selected only if a genuinely strong counterexample appears.

Until then, the current unknown should remain unknown.

## Case 11 Research Planning — Target Knowledge Gap

This note should not begin with a candidate case.

It should begin with the next most valuable unknown.

Its purpose is to decide which knowledge gap should be reduced next, before any concrete sequence is selected.

### Current Mission Family Research Gaps

| Mission Family | Established Knowledge | Open Research Gap | Maturity |
|---|---|---|---|
| Build | `Build` is a stable primary mission; successful build does not imply immediate `Ready`; repeated pressure is localized at the continuity layer | Build continuity boundary: what evidence is sufficient for `Maintained` to become `Ready`, and what conditions truly break continuity after successful build? | Medium-high |
| Prepare | `Prepare` can be imperfect; `Prepare / Partial / Maintained` is reusable; `Prepare / Completed / Ready` is also now supported as a reusable successful interpretation | Preparation failure boundary: when does preparation stop being usable, and what evidence marks true sequence failure rather than costly-but-successful preparation? | Medium-high |
| Recover | Recover-family knowledge has multiple case-level readings, but has not yet been consolidated into a reusable mission-family interpretation | Recover family identity discovery: what evidence makes Recover a stronger explanation than generic Easy continuity? | Medium |
| Activate | Activate-family knowledge has appeared in case reasoning, but has not yet formed a consolidated family-level knowledge layer | Activate family discovery: what evidence distinguishes true activation from nearby preparation or generic easy continuity? | Medium |

### Target Knowledge Gap

`Preparation failure boundary`

### Why Now

This is the highest-value next question because the preparation family has already completed a clean knowledge sequence:

`Existence -> Generalization -> Reusable Interpretation`

Case 09 established that imperfect preparation can exist.

Case 10 showed that this reading can generalize beyond one specific next-workout type.

The next natural step is therefore not more scope expansion.

It is to identify the boundary at which imperfect preparation stops being usable.

Compared with the current Build-family gap, this question is more directly falsifiable:

- it asks where a reusable interpretation fails
- it can likely be answered by a stronger counterexample
- it completes the preparation-family chain more cleanly:

`Existence -> Generalization -> Failure Boundary`

### Evidence Needed

The next case should provide a preparation-family sequence where:

- the current day still structurally belongs to `Prepare`
- the execution cost is high enough to create real sequence risk
- the following key workout is meaningfully compromised, flattened, or forced into a weaker-than-intended outcome

The goal is not to prove that preparation can be imperfect.

The goal is to observe the point where preparation ceases to be merely costly and becomes genuinely non-usable.

### Selection Criteria

A sequence should be considered a strong Case 11 candidate only if it satisfies most of the following:

- `Previous workout` creates a clear need for re-entry or preservation rather than direct build
- `Current workout` still looks like a preparation-day structure on paper
- `Current workout` carries unusually high load, effort, or physiological cost for a prep day
- `Next workout` still exists as a key obligation, but its execution shows visible compromise
- the sequence creates a real possibility that `Prepare / Partial / Maintained` may no longer be sufficient

### Expected Knowledge Contribution

Case 11 should ideally contribute one of two things:

1. `Boundary clarification`

   It shows where imperfect preparation remains usable and where it no longer does.

2. `Failure detection`

   It reveals the first true preparation-family counterexample, allowing the current reusable interpretation to gain a real failure edge.

At this stage, Case 11 should be selected to reduce uncertainty in the preparation family, not simply to add another interesting sequence.

### Decision Criterion

The purpose of Case 11 is not merely to observe another difficult preparation day.

Its purpose is to determine whether the current preparation-family knowledge should remain unchanged or be revised.

The current knowledge should remain unchanged if:

- the case can still be naturally explained as `Prepare / Partial / Maintained`
- the preparation remains usable even if it is costly or imperfect
- the new evidence narrows the failure boundary without forcing a different family-level interpretation

The current preparation-family knowledge should be revised if:

- the case can no longer be naturally explained as `Prepare / Partial / Maintained`
- the sequence shows a coach-credible alternative reading that is more stable than the current interpretation
- the current preparation-family reading fails not just locally, but in a way that reveals a missing or incorrect boundary description

In other words:

- if the case still fits, uncertainty should shrink
- if the case no longer fits, knowledge should change

## Case 11 Candidate Review

This review should be treated as candidate screening rather than case selection.

Its purpose is to identify which real sequence is most likely to apply meaningful pressure to the current preparation-family decision criterion.

The question here is not:

`Which sequence looks interesting?`

It is:

`Which sequence is most likely to produce the evidence needed to test the preparation failure boundary?`

### Candidate A

- `Sequence`
  - 2026-04-20 Recovery -> 2026-04-21 Easy Run (`8K Z2 + Strides`) -> 2026-04-22 Marathon Pace (`10K HM Pace`) -> 2026-04-23 Recovery
- `Knowledge Gap Fit`
  - Strong fit. This is clearly a preparation-family sequence leading into a key workout.
- `Decision Criterion Pressure`
  - Stronger than prior support cases. The preparation day is materially non-trivial (`training load 192`, structured strides), while the following key workout appears comparatively flatter than other build-quality entries (`training load 208`, moderate RPE, simpler HM-pace realization).
- `Evidence Quality`
  - High. Sequence structure is complete on both sides, and both current and next workouts have explicit workout structures.
- `Alternative Readings`
  - Real alternative readings exist:
    - current day may still fit `Prepare / Partial / Maintained`
    - or the next key workout may represent an early sign that preparation was no longer cleanly usable
- `Why it is not just another Support Case`
  - Unlike Case 09 and Case 10, the following key workout does not obviously read as a clean success. This creates real pressure on whether the current preparation-family interpretation remains sufficient.
- `Reviewer Priority`
  - High

### Candidate B

- `Sequence`
  - 2026-04-13 Recovery -> 2026-04-14 Easy Run (`8K Z2 + Strides`) -> 2026-04-15 Interval (`10K Cruise Interval`) -> 2026-04-16 Recovery
- `Knowledge Gap Fit`
  - Moderate to strong fit. It clearly belongs to the same imperfect-preparation family as Case 09.
- `Decision Criterion Pressure`
  - Moderate. The preparation day is costly (`training load 220`), but the next Interval still looks structurally competent and does not obviously show degraded execution.
- `Evidence Quality`
  - High. The sequence is complete and both current and next workouts have explicit structure.
- `Alternative Readings`
  - Some tension exists between:
    - reusable imperfect preparation
    - potentially over-costly preparation
  - but the next workout still appears more successful than compromised
- `Why it is not just another Support Case`
  - It carries stronger physiological cost than many prep days, but it still risks becoming another scope-expansion case rather than a true boundary test.
- `Reviewer Priority`
  - Medium

### Candidate C

- `Sequence`
  - 2026-05-11 Recovery -> 2026-05-12 Easy Run (`8K Aerobic Steady + Strides`) -> 2026-05-13 Marathon Pace (`11K HM Specific`) -> 2026-05-14 Recovery
- `Knowledge Gap Fit`
  - Moderate fit. It is clearly a preparation-family sequence before a major key workout.
- `Decision Criterion Pressure`
  - Moderate. The prep day is costly (`training load 221`), but the following HM-specific workout appears clearly successful (`training load 275`, RPE 4), which reduces failure-boundary pressure.
- `Evidence Quality`
  - High. Both current and next workouts are explicitly structured and the surrounding sequence is complete.
- `Alternative Readings`
  - Very limited. Most readings still naturally fall back into `Prepare / Partial / Maintained` or even a stronger usable-preparation interpretation.
- `Why it is not just another Support Case`
  - In practice, it may still be exactly that: another support case with little chance of overturning the current preparation-family knowledge.
- `Reviewer Priority`
  - Low

### Candidate D

- `Sequence`
  - 2026-07-13 Recovery -> 2026-07-14 Easy Run (`8K Eazy + Strides`) -> 2026-07-15 Tempo (`10K HM Tempo`)
- `Knowledge Gap Fit`
  - Moderate fit. It is a preparation-family sequence with meaningful structure.
- `Decision Criterion Pressure`
  - Low to moderate. The prep day carries some cost (`training load 206`), but the next tempo day still looks strong and intentional (`training load 242`, RPE 4).
- `Evidence Quality`
  - Medium to high. The sequence is clear, but the forward context is shorter than some other candidates.
- `Alternative Readings`
  - Limited. This sequence appears more likely to reinforce reusable imperfect preparation than to expose failure.
- `Why it is not just another Support Case`
  - It may slightly broaden scope, but it is unlikely to supply the failure-boundary evidence currently needed.
- `Reviewer Priority`
  - Low

### Current Candidate Reading

At the current stage:

- Candidate A is the strongest fit for `Preparation failure boundary`
- Candidate B remains a useful backup if a second medium-pressure case is desired
- Candidates C and D are more likely to add confidence than to reduce the key uncertainty

The current working recommendation is:

`Case 11 should most likely be selected from Candidate A unless a stronger preparation-family counterexample is later identified.`

## Post-Case 11 Research Priority

After the revision of Preparation Family Knowledge, the next research move should not be assumed to be another preparation-family case.

Current priority should be determined by two conditions:

1. `Does the open gap have a genuinely strong candidate?`
2. `Would the next case improve overall mission-family knowledge balance?`

At the current stage, Preparation Family has:

- reusable interpretation
- success-boundary clarification
- explicit unknown failure boundary

This makes it suitable for observation rather than forced immediate continuation.

The next primary research focus should therefore shift toward:

`Recover Family Identity Discovery`

unless a clearly stronger preparation-family counterexample appears.

The first Recover-family question should not be:

`What kinds of recovery exist?`

It should be:

`What evidence makes Recover a better explanation than generic Easy continuity?`

Recover identity should therefore be tested through competitive reading pressure, not through descriptive definition alone.

The first Recover-family discovery case should ideally be a sequence where:

- an activity-only reading would naturally classify the workout as a generic Easy Run
- but the surrounding sequence may reveal a stronger recovery obligation

Only after that identity question becomes stable should Recover-family research expand toward subtype or boundary questions.

## Recover Family Identity Discovery — Research Planning

This planning note should remain intentionally short.

Recover is not yet at the same maturity stage as Prepare.

The purpose here is not to deepen a mature family.

It is to test whether Recover has earned the right to become one.

### 1. Identity Question

`What evidence makes Recover a stronger explanation than generic Easy continuity?`

### 2. Why Now

Recover has already appeared across multiple case-level readings, but it still exists primarily inside local sequence interpretation rather than as reusable mission-family knowledge.

The next step is therefore not to expand Recover.

It is to determine whether Recover deserves to stand as an independent Mission Family at all.

### 3. Evidence Needed

- The activity-only reading should naturally default to a generic Easy Run.
- The surrounding sequence should provide a clear recovery obligation.
- Reading the workout as `Recover` should preserve important sequence meaning that would be lost if it were treated as generic Easy continuity.

### 4. Success Criterion

This first Recover-family discovery should be considered successful if:

- `Recover` consistently becomes the stronger reading than generic Easy continuity
- the sequence explanation becomes meaningfully more coach-like than activity-only interpretation
- Recover begins to earn recognition as an independent Mission Family rather than a descriptive variant of Easy

If this does not happen, the correct response is not forced expansion.

It is continued observation.

## Recover Family Identity Discovery — Candidate Screening

This screening step should not begin by asking which recovery-looking workout is most representative.

It should begin by asking which candidate applies the strongest pressure to the Recover-vs-Easy distinction.

The purpose of this step is not to choose the most interesting recovery day.

It is to identify which sequence is most capable of testing Recover identity.

### Screening Priority

Recover candidate screening should evaluate candidates in this order:

1. `Identity Pressure`
2. `Evidence Quality`
3. `Alternative Reading`

### 1. Identity Pressure

This is the primary screening dimension.

The key question is:

`If this workout were forced into a generic Easy reading, how much sequence meaning would be lost?`

Suggested working labels:

- `Strong`
- `Medium`
- `Weak`

Strong identity pressure means:

- activity-only would naturally call it Easy
- but the surrounding sequence strongly suggests recovery obligation
- and reading it as Easy would clearly flatten or erase important coaching meaning

### 2. Evidence Quality

The candidate should ideally include:

- a complete surrounding sequence
- clear prior load or fatigue context
- enough forward sequence evidence to evaluate whether recovery interpretation improves understanding

### 3. Alternative Reading

The candidate should have at least one plausible competing reading.

For the first Recover-family discovery, the main competitor is:

- `generic Easy continuity`

If no meaningful competitor exists, the case may be too easy to establish identity.

### Working Constraint

Recover candidate screening should not yet aim to produce family-level knowledge.

Its purpose is only to locate:

- the first strong identity case

After that first discovery case, Recover should still require at least one later generalization case before any family-level consolidation is considered.

The current expected path is:

`Recover Identity Research Planning -> Candidate Screening -> Case 12 (Discovery) -> Case 13 (Generalization) -> Recover Family Knowledge Consolidation #1`

### Round 1 Candidate Pool

The first screening round should remain small and high-pressure.

The goal is not to collect many recovery-like workouts.

It is to surface the few sequences where forcing a generic Easy reading would erase the most sequence meaning.

### Candidate A

- `Sequence`
  - 2026-05-23 LSD -> 2026-05-24 Easy Run (`7K Easy Reset`) -> 2026-05-25 Recovery Run -> 2026-05-26 Progression Run
- `Identity Pressure`
  - Strong
- `Why it is worth screening`
  - Activity-only would naturally read 5/24 as a light reset-style easy day.
  - But sequence context suggests the athlete may still be inside an active recovery obligation from the prior LSD, especially because the following day is explicitly Recovery rather than a direct return to build.
- `Evidence Quality`
  - High. The surrounding sequence is complete and the following progression day gives useful forward context.
- `Alternative Reading`
  - Strong competition exists between:
    - generic Easy continuity
    - genuine Recover obligation
- `Reviewer Priority`
  - High

### Candidate B

- `Sequence`
  - 2026-04-27 Recovery Run -> 2026-04-28 Easy Run (`8K Z2 + Strides`) -> 2026-04-29 Recovery Run -> 2026-04-30 Recovery Run
- `Identity Pressure`
  - Strong
- `Why it is worth screening`
  - Activity-only could easily read 4/28 as another aerobic or activation-flavored easy day because of the `Z2 + Strides` structure.
  - But the surrounding sequence remains heavily recovery-shaped on both sides, which may make `Recover` the stronger explanation.
- `Evidence Quality`
  - High. The local sequence is unusually coherent and gives clear recovery context before and after.
- `Alternative Reading`
  - Strong competition exists between:
    - activation-like Easy reading
    - genuine Recover obligation
- `Reviewer Priority`
  - High

### Candidate C

- `Sequence`
  - 2026-05-04 Recovery Run -> 2026-05-05 Easy Run (`8K Aerobic Run`) -> 2026-05-06 Recovery Run -> 2026-05-07 Progression Run
- `Identity Pressure`
  - Medium
- `Why it is worth screening`
  - The current workout looks generically easy on paper, but the sequence still contains explicit recovery context on both sides before the eventual progression day.
- `Evidence Quality`
  - Medium-high. The surrounding context is usable, though less forceful than Candidate A or B.
- `Alternative Reading`
  - Plausible competition exists between:
    - generic Easy continuity
    - low-grade Recover reading
- `Reviewer Priority`
  - Medium

### Candidate D

- `Sequence`
  - 2026-04-07 Easy Run (`8K Z2 Base`) -> 2026-04-09 Easy Run (`10K Z2 + 測速段`) -> 2026-04-10 Recovery Run -> 2026-04-11 LSD
- `Identity Pressure`
  - Weak to Medium
- `Why it is worth screening`
  - The current day is more likely to remain generic Easy continuity, but it offers a useful lower-pressure comparison point if the stronger candidates prove ambiguous.
- `Evidence Quality`
  - Medium. The broader sequence is readable, but the recovery obligation is less direct.
- `Alternative Reading`
  - The Easy reading may still dominate too naturally, which limits its value as a first identity case.
- `Reviewer Priority`
  - Low

### Current Screening Reading

At the current stage:

- Candidate A and Candidate B are the strongest identity-pressure candidates
- Candidate C is a reasonable secondary boundary case
- Candidate D is better treated as a fallback comparison than as the first discovery case

The current working recommendation is:

`Recover Case 12 should most likely be selected from Candidate A or Candidate B.`

### Reviewer Comparison

This comparison should remain intentionally short.

Its purpose is not to reopen screening.

Its purpose is to choose the best first Recover identity case.

| Dimension | Candidate A | Candidate B |
|---|---|---|
| Identity Pressure | Very strong | Strong |
| Alignment with current identity question | Very high | Medium-high |
| Main competing reading | Generic Easy continuity | Activate / Easy |
| Suitability as first discovery case | Best fit | Better as follow-up |

### Reviewer Recommendation

`Candidate A should be selected as Case 12 because it directly tests the current Recover identity question without introducing additional competition from Activate. Candidate B remains highly valuable, but it is better suited as a follow-up generalization or adjacent boundary case after Recover identity has first been established.`

## Batch 20 / Case 12 — Recover Identity Validation Test

### Case 12 — Recover Identity Validation Test

**Research Goal**

This case attempts to validate Recover identity.

The question is not whether Recover can exist.

The question is whether Recover provides a more coach-credible explanation than generic Easy continuity in this sequence.

**Pattern Type**

Boundary Pattern.

**Research Intent**

Discovery.

This case should be treated as an identity-validation case rather than a generic recovery example.

Its purpose is not to discover a new kind of recovery.

Its purpose is to test whether `Recover` can out-explain `Easy` when the workout itself looks like an easy day, but the surrounding sequence suggests that recovery obligation is still active.

**Date / Sequence Window**

2026-05-23 -> 2026-05-24 -> 2026-05-25 -> 2026-05-26

**Previous Workout**

2026-05-23 LSD / Endurance / 18.009 km / Training Load 289 / RPE 5 - 困難

**Current Workout**

2026-05-24 Easy Run / Aerobic Base / 7.007 km / Training Load 152 / RPE 3 - 中等
Workout structure: `7K Easy Reset`

**Next Workout**

2026-05-25 Recovery Run / Recovery / 7.1 km / Training Load 169 / RPE 3 - 中等

**Forward Context**

2026-05-26 Progression Run / Aerobic Base / 11.009 km / Training Load 288 / RPE 4 - 有點難

**Activity-only Reading**

只看 Activity，這是一堂很自然會被讀成 generic easy day 的課。名稱本身就是 `Easy Reset`，負荷也不像品質課，因此最直覺的 reading 會是：長距離之後用一堂輕鬆跑把節奏接回來，替後面的訓練保留一點連續性。

**WSI Reading**

- Mission Category: Recover
- Mission Phrase: Recover from long-run fatigue while preserving the later return to build
- Mission Status: Completed
- Continuity State: Maintained
- Sequence Reasoning: 這個案例真正要測的不是 5/24 像不像 easy run，而是如果把它只讀成 generic easy continuity，會不會把整段 sequence 的恢復義務讀扁。前一天是明確的 LSD，隔天不是直接回到 build，而是又安排了一堂 `Recovery Run`，之後才接 `Progression Run`。這表示 5/24 比較像 recovery process 的中段，而不是單純重新開始累積 mileage 的 easy day。若讀成 `Easy`，sequence story 會變成「LSD 後稍微緩和一下再繼續」；但若讀成 `Recover`，sequence story 會變成「LSD 留下的疲勞義務尚未完成，恢復不是一天，而是一段」。目前證據更支持後者，因此 `Recover` 是比 generic easy continuity 更有教練意義的 reading。由於 5/24 與 5/25 共同完成了 recovery obligation，之後 5/26 才重新進入 progression build，因此目前最穩定的 reading 是：`Recover` 已完成當天應負責的部分任務，並讓整段 sequence 維持在 `Maintained`，而不是提早宣告 `Ready`。

**Correctness**

- Score: 2
- Why: 這個案例的關鍵不是它有多輕鬆，而是 surrounding sequence 明確顯示 recovery obligation 仍在延續。若硬讀成 `Easy`，會低估 5/23 LSD 的殘餘疲勞，也會忽略 5/25 再次安排 Recovery Run 的事實。`Recover` 比 `Easy` 更能解釋這段 sequence 為什麼長成這樣。

**Helpfulness**

- Score: 2
- Why: Activity-only 只能說這是一堂長距離後的 easy reset。WSI 則能把更重要的教練意義說出來：今天不是單純「跑輕鬆」，而是在履行一個還沒完成的 recovery obligation。這讓 Runner 更能理解為什麼恢復有時候不是一天，而是一段過程。

**Reviewer Confidence**

- Score: Medium
- Why: `Recover` 在這裡已經比 `Easy` 更有解釋力，但這仍是 Recover-family 的第一個 identity case。它足以提供第一份支持證據，但還不足以讓 Recover 立刻進入 reusable mission-family knowledge。

**Learning Notes**

Case learning: 這個案例顯示 Recover 並不是由低強度本身定義，而是由 surrounding sequence 中仍未完成的 recovery obligation 定義。即使活動表面看起來像 easy day，只要 recovery process 尚在延續，`Recover` 仍可能是更好的解釋。

Knowledge learning: 這個案例提供了 Recover 作為獨立 Mission Family 的第一份 identity evidence。它支持 `Recover` 不只是 generic Easy 的描述變體，而是能在特定 sequence 中承擔更完整的教練意義。

Epistemic learning: 這個案例還不足以宣告 Recover-family knowledge 已成立。它只說明 `Recover` 可能已經賺到獨立身份，但仍需要後續 generalization case 來確認這不是單一序列的局部成功。

**Rule Impact**

- Supports
- Why: 這個案例支持目前 Recover identity planning 所提出的核心問題，也支持 sequence-role reading 持續優於 workout-label reading。它沒有迫使新規則出現，但提供了第一個明確的 Recover identity evidence point。

**Refinement Decision**

- keep as is

## Recover Identity Generalization — Research Planning

This planning note should not ask for another similar recovery-looking case.

It should ask whether the identity established in Case 12 can survive a different sequence shape.

The purpose here is not workout repetition.

It is identity generalization.

### 1. Generalization Question

`Can Recover remain a stronger explanation than generic Easy continuity across a meaningfully different sequence structure?`

### 2. Why Now

Case 12 provided the first identity evidence for Recover.

What it did **not** prove is whether that identity is local to one specific `LSD -> Easy -> Recovery -> Build` shape, or whether it can survive across another sequence in which the recovery obligation arises for a different reason.

The next step is therefore not to consolidate Recover.

It is to test whether the newly earned identity can generalize.

### 3. Evidence Needed

- The current workout should still look naturally readable as a generic Easy Run at the activity-only level.
- The surrounding sequence should create a real recovery obligation, but through a different structure from Case 12.
- Reading the workout as `Recover` should preserve important sequence meaning that would be flattened if the workout were treated as generic Easy continuity.
- The value of `Recover` should come from sequence obligation, not from simply repeating the same LSD-driven pattern.

### 4. Success Criterion

This first Recover generalization step should be considered successful if:

- `Recover` again becomes the stronger explanation than generic Easy continuity
- the stronger reading is supported by a sequence shape that is meaningfully different from Case 12
- the identity evidence begins to detach from one local pattern and move toward reusable mission-family status

If this does not happen, the correct response is not forced consolidation.

It is to keep Recover in identity-testing mode until a second convincing sequence supports the same reading.

## Recover Identity Generalization — Candidate Screening

This screening note should remain narrow.

Its job is not to catalog every recovery-looking sequence.

Its job is to identify which candidate can most credibly test whether `Recover` survives beyond the specific local pattern established in Case 12.

### Screening Focus

The current working question is:

`Which candidate most clearly tests whether Recover still preserves sequence meaning better than generic Easy continuity when the recovery obligation is supported by a meaningfully different sequence structure?`

This is still a reviewer lens, not a rule.

Candidate quality should therefore be judged by evidence strength, not by how neatly a case matches the current working hypothesis.

### Round 1 Candidate Pool

#### Candidate A

`2026-04-25 Long Run -> 2026-04-27 Recovery Run -> 2026-04-28 Easy Run -> 2026-04-29 Recovery Run -> 2026-04-30 Recovery Run`

- Current workout: `2026-04-28 Easy Run / Aerobic Base / 8.786 km / Training Load 193 / Workout structure: 8K Z2 + Strides`
- Why it matters: 這個案例的 recovery obligation 不是單純來自「昨天的 LSD」，而是來自一個尚未完成的 multi-day recovery block。若把 4/28 只讀成 easy continuity，整段 sequence 很容易被讀成「恢復後重新接回節奏」；但若讀成 `Recover`，sequence story 會更像「前面累積的 endurance fatigue 還在處理中，4/28 只是 recovery process 的中段，而不是已經重新進入 build」。
- Main competing reading: `Easy`, with some `Activate` pull from strides.

#### Candidate B

`2026-05-03 Recovery Run -> 2026-05-04 Recovery Run -> 2026-05-05 Easy Run -> 2026-05-06 Recovery Run -> 2026-05-07 Progression Run`

- Current workout: `2026-05-05 Easy Run / Aerobic Base / 8.008 km / Training Load 124 / Workout structure: 8K Aerobic Run`
- Why it matters: 這個案例很乾淨，activity-only reading 幾乎一定會把 5/5 讀成普通 aerobic easy day；但 surrounding sequence 又明確顯示恢復義務仍未結束。問題在於，它雖然很容易支持 `Recover`，但它和 Case 12 仍然共享相近的「LSD 後 recovery process 延續」故事，因此 generalization 力度稍弱。
- Main competing reading: `Easy`.

#### Candidate C

`2026-05-10 Recovery Run -> 2026-05-11 Recovery Run -> 2026-05-12 Easy Run -> 2026-05-13 Marathon Pace -> 2026-05-14 Recovery Run`

- Current workout: `2026-05-12 Easy Run / Aerobic Base / 9.079 km / Training Load 221 / Workout structure: 8K Aerobic Steady + Strides`
- Why it matters: 這個案例的張力很高，但主要競爭者很快會從 `Easy` 轉向 `Prepare`。如果拿它做 Recover generalization，容易把 identity 問題混進 preparation reading，因此不適合作為 Recover identity 的第二個核心證據。
- Main competing reading: `Prepare`, then `Easy`.

#### Candidate D

`2026-04-12 Recovery Run -> 2026-04-13 Recovery Run -> 2026-04-14 Easy Run -> 2026-04-15 Interval -> 2026-04-16 Recovery Run`

- Current workout: `2026-04-14 Easy Run / Aerobic Base / 8.751 km / Training Load 220 / Workout structure: 8K Z2 + Strides`
- Why it matters: 這個案例也有 recovery context，但 sequence 主要往品質課收束，因此當前最自然的 higher-level reading 很可能會先被 `Prepare` 吸走。它可以作為相鄰邊界案例，但不是 Recover identity generalization 的最佳入口。
- Main competing reading: `Prepare`, then `Activate`.

### Reviewer Comparison

| Candidate | Identity Preservation | Evidence Quality | Alternative Reading Pressure | Suitability for first generalization |
| --- | --- | --- | --- | --- |
| A | Very high | High | Medium-high | Best fit |
| B | High | Very high | Medium | Strong fallback |
| C | Medium | High | Very high | Better for adjacent boundary work |
| D | Medium | Medium-high | Very high | Too preparation-shaped |

### Reviewer Recommendation

`Candidate A should be selected as Case 13 because it tests Recover identity against a sequence shape that is meaningfully different from Case 12 while still preserving strong identity pressure. Candidate B remains valuable, but it is better treated as a fallback generalization case if Candidate A proves too confounded by stride-driven activation pull.`

### Case 13 Selection

`Batch 20 / Case 13 should most likely be selected from Candidate A.`

## Batch 20 / Case 13 — Recover Identity Stress Test

### Case 13 — Recover Identity Stress Test

**Research Goal**

This case attempts to stress the newly established Recover identity.

The question is not whether Recover can exist.

The question is whether Recover remains the stronger explanation after the recovery obligation changes.

**Pattern Type**

Boundary Pattern.

**Research Intent**

Generalization.

This case should be treated as an identity-stress case rather than another simple recovery example.

Its purpose is not to repeat the same reading from Case 12.

Its purpose is to test whether `Recover` still out-explains generic `Easy` continuity when the surrounding sequence creates recovery obligation through a different structure.

**Date / Sequence Window**

2026-04-25 -> 2026-04-27 -> 2026-04-28 -> 2026-04-29 -> 2026-04-30

**Previous Workout**

2026-04-27 Recovery Run / Recovery / 6.011 km / Training Load 105 / RPE 3 - 中等
Immediate context is already recovery-focused, but the deeper obligation comes from 2026-04-25 Long Run / Endurance / 16.007 km / Training Load 259 / RPE 3 - 中等.

**Current Workout**

2026-04-28 Easy Run / Aerobic Base / 8.786 km / Training Load 193 / RPE 3 - 中等
Workout structure: `8K Z2 + Strides`

**Next Workout**

2026-04-29 Recovery Run / Recovery / 9.007 km / Training Load 215 / RPE 3 - 中等
Workout structure: `9K Aerobic Steady`

**Forward Context**

2026-04-30 Recovery Run / Recovery / 5.007 km / Training Load 61 / RPE 2 - 輕鬆
Workout structure: `5K Z1恢復跑`

**Activity-only Reading**

只看 Activity，4/28 很容易被讀成 generic easy continuity。它名義上是 `Easy Run`，結構又是 `Z2 + Strides`，最直覺的 reading 會是：前一天已經做完 Recovery，今天用一堂稍微把節奏打開的 easy day 接回訓練，為後續重新建立連續性做準備。

**WSI Reading**

- Mission Category: Recover
- Mission Phrase: Continue the unfinished recovery block before any real return to build
- Mission Status: Completed
- Continuity State: Maintained
- Sequence Reasoning: 這個案例真正要測的不是 4/28 看起來像不像 easy run，而是當 recovery obligation 的來源不再只是「昨天剛跑完 LSD」，`Recover` 是否仍然比 `Easy` 更能保住 sequence meaning。Case 12 的 recovery pressure 來自單一長距離之後的延續恢復；這裡則更像一個 multi-day recovery block：4/25 已經留下 endurance fatigue，4/27 先進入 Recovery，4/28 雖然表面上是 `Easy Run + Strides`，但後面不是重新回到品質課或 build，而是又接了兩天 `Recovery Run`。如果把 4/28 讀成 generic easy continuity，整段故事會變成「恢復後開始把節奏接回來」；但 sequence 事實更像是「恢復義務尚未完成，4/28 只是 recovery block 中一個仍帶 movement quality 的中段」。在這個 reading 下，strides 不足以把 primary mission 拉成 `Activate`，因為 sequence 並沒有立即把身體送進 build；相反地，它更像是在不打斷恢復方向的前提下，維持一點 movement quality。由於 4/29 與 4/30 都沒有顯示真正回到 build 的證據，因此目前最穩定的 reading 仍是：4/28 的 primary mission 是 `Recover`，當天任務已完成，但整段 continuity 仍只適合判為 `Maintained`，而不是 `Ready`。

**Correctness**

- Score: 2
- Why: 這個案例的關鍵在於，若讀成 `Easy`，4/28 會被誤認為 recovery 已經差不多結束、訓練開始重新向前推進；但後面連續兩天 Recovery 顯示事實並非如此。`Recover` 比 `Easy` 更能解釋為什麼 4/28 雖然有一點節奏感，整體 sequence 卻仍停留在恢復義務之中。

**Helpfulness**

- Score: 2
- Why: Activity-only 會把這堂課讀成普通 easy day，頂多加上一點 strides 的活化意味。WSI 則能把更有教練意義的資訊說清楚：今天不是恢復後的重新啟動，而是恢復尚未完成時的一個過渡中段。這讓 Runner 更容易理解，有些「看起來沒那麼慢的 easy run」仍然可能屬於 Recover，而不是已經回到一般連續性。

**Reviewer Confidence**

- Score: Medium
- Why: 這是 Recover identity 的第一個 generalization case，而不是第一個 existence case。證據已足以支持 `Recover` 在另一種 obligation source 下仍然成立，但 reusable mission-family status 還需要至少再一個不同情境的支持，才能更穩定地從 local identity evidence 轉成 family-level knowledge.

**Learning Notes**

Case learning: 這個案例顯示 Recover 不必依附於單一的「長距離隔天」模式。當 surrounding sequence 顯示 recovery block 尚未結束，即使當天課表表面上更像一堂帶 strides 的 easy run，`Recover` 仍可能是更有解釋力的 reading。

Knowledge learning: Case 12 建立的是 Recover identity；Case 13 補出的，是這個 identity 並不只局限於 LSD-driven one-day continuation。它開始支持 Recover 可以跨不同 recovery-obligation structure 維持自己的身份。

Epistemic learning: 這個案例提高了 Recover identity 的可信度，但還沒有讓 Recover-family 立刻進入 consolidation。它提供的是第一份可泛化的身份證據，而不是最終的 reusable family knowledge。

**Rule Impact**

- Supports
- Why: 這個案例支持 Recover identity generalization 的核心假設：當 supporting evidence 改變時，primary mission 仍可由 surrounding obligation 而不是 workout label 決定。它沒有迫使新規則出現，但明顯提高了 Recover identity 的 generalization confidence。

**Refinement Decision**

- keep as is

## Post-Case 13 Research Priority

Recover should not move into consolidation immediately after Case 13.

Case 12 and Case 13 together now support a stronger conclusion than simple identity existence:

- Case 12 established that `Recover` can out-explain generic `Easy` continuity when recovery obligation follows an LSD-driven continuation pattern.
- Case 13 established that the same identity can survive a different sequence structure in which recovery obligation is carried by a multi-day recovery block.

What remains unresolved is no longer basic identity.

It is identity robustness across fatigue-source change.

The next Recover question should therefore be:

`Does Recover remain the stronger explanation when the recovery obligation comes from a fundamentally different fatigue source rather than another endurance-fatigue pattern?`

Until that question is tested, Recover should be treated as having:

- Identity: established
- Generalization: promising but incomplete
- Family knowledge: not yet ready for first consolidation

## Recover Cross-Fatigue Identity — Research Planning

This planning note should not ask for another generic recovery case.

It should ask what the highest remaining uncertainty is after the Recover identity stress test.

### 1. Remaining Uncertainty

`Does Recover survive across fundamentally different recovery-obligation sources?`

Case 12 and Case 13 both support Recover under endurance-fatigue contexts.

What they do **not** yet prove is whether the same mission identity still holds when the fatigue source is meaningfully different, such as threshold residual fatigue or marathon-pace accumulation.

### 2. Why Now

Recover no longer needs another existence case.

It also does not need immediate consolidation.

The most valuable next step is to reduce the highest remaining uncertainty before family knowledge is frozen too early.

If Recover also survives a non-endurance fatigue source, its identity will no longer depend on one fatigue family.

That would materially strengthen the case for future Recover-family consolidation.

### 3. Evidence Needed

- The current workout should still look naturally readable as a generic Easy Run at the activity-only level.
- The surrounding sequence should create a real recovery obligation whose source is meaningfully different from the endurance-fatigue patterns already tested in Case 12 and Case 13.
- Reading the workout as `Recover` should preserve sequence meaning that would be flattened if the workout were treated as generic Easy continuity.
- The stronger reading should come from the changed fatigue source itself, not merely from repeating the same recovery-block shape with different dates.

### 4. Expected Knowledge Contribution

- Boundary clarification
- Cross-fatigue identity validation

### 5. Success Criterion

This next Recover step should be considered successful if:

- `Recover` again becomes the stronger explanation than generic Easy continuity
- the stronger reading is supported by a recovery obligation sourced from a meaningfully different fatigue family
- Recover identity becomes robust enough that first family-level consolidation is grounded in more than one fatigue source

If this does not happen, the correct response is not forced promotion or forced revision.

It is to keep Recover in targeted testing mode until the remaining uncertainty is honestly reduced.

## Recover Cross-Fatigue Identity — Candidate Screening

This screening note should stay narrow.

Its purpose is not to force Case 14 into existence.

Its purpose is to test whether there is currently a candidate strong enough to reduce the remaining uncertainty after Case 13.

### Screening Question

`Which candidate most reduces the remaining uncertainty after Case 13?`

At this stage, the key reviewer lens is not generic difference.

It is fatigue-source distance:

- Very high: threshold residual fatigue
- High: marathon-pace accumulation
- Low: another endurance variant
- Very low: another recovery-block variant

### Round 1 Candidate Pool

#### Candidate A — Threshold residual fatigue

`2026-06-03 Tempo Test -> 2026-06-04 Recovery -> 2026-06-05 unidentified easy-like day -> 2026-06-06 LSD -> 2026-06-08 Recovery`

- Why it matters: 這個候選理論上最有價值，因為如果 6/5 真能被讀成 `Recover`，Recover 就第一次跨進 threshold residual fatigue。
- Why it is weak right now: 當天缺乏明確 workout structure，後面又直接接 LSD，而不是另一段 recovery process。這讓 `Easy continuity` 或 `light reset before endurance` 仍然很強，尚不足以穩定支持 Recover identity。
- Current reviewer judgment: High uncertainty reduction potential, but evidence quality is not strong enough yet.

#### Candidate B — Marathon-pace / threshold-adjacent accumulation

`2026-06-15 Recovery -> 2026-06-16 Cruise Interval -> 2026-06-17 Easy + Strides -> 2026-06-18 HM Pace Run -> 2026-06-19 Recovery Run`

- Why it matters: 這個候選明顯來自非 endurance 的 fatigue source，理論上能對 Recover 做更遠距離的壓力測試。
- Why it is weak right now: 主要競爭者很快從 `Easy` 轉向 `Prepare`。由於 6/18 是明確的 HM Pace key workout，6/17 更自然地像前置準備，而不是恢復義務的延續。
- Current reviewer judgment: Strong fatigue-source distance, but mission competition is too high.

### Reviewer Comparison

| Candidate | Fatigue-source distance | Evidence quality | Competing mission pressure | Suitability for Case 14 |
| --- | --- | --- | --- | --- |
| A | Very high | Low-medium | Medium | Not yet strong enough |
| B | High | Medium-high | Very high (`Prepare`) | Better treated as non-Recover evidence |

### Screening Outcome

No current candidate is strong enough to justify immediate promotion into `Batch 20 / Case 14`.

The correct response is therefore not forced selection.

It is to keep Recover cross-fatigue testing in observation mode until a candidate appears that:

- retains strong activity-level readability as generic `Easy`
- preserves a clearly different fatigue source from Case 12 and Case 13
- does not immediately collapse into a stronger neighboring mission such as `Prepare`

## Post-Recover Cross-Fatigue Screening Priority

Recover should now be treated as being in `Observation Mode`.

This is not because Recover research failed.

It is because the current screening has already produced a valid negative result:

- the remaining uncertainty is clearly defined
- candidate screening was completed
- no sufficiently strong cross-fatigue candidate is currently available

At this stage, the correct knowledge-state reading is:

- Identity: established
- Generalization: supported within currently observed evidence
- Cross-fatigue robustness: still open
- Current status: observation, not forced continuation

The next primary research focus should therefore shift away from Recover.

The highest-value next question is now:

`Activate Family Identity Discovery`

This shift is justified not because Recover is complete, but because Activate remains at an earlier maturity stage:

- Recover now has identity evidence and negative-result screening discipline
- Activate still appears mainly inside case reasoning and has not yet earned independent mission-family status

Recover should only leave observation mode if:

- a genuinely strong cross-fatigue candidate appears
- or new evidence materially changes the current uncertainty landscape

## Activate Family Identity Discovery — Research Planning

This planning note should remain intentionally short.

Activate, like early-stage Recover, should not begin by expanding types.

It should begin by earning identity.

### 1. Identity Question

`What evidence makes Activate a stronger explanation than nearby Prepare or generic Easy continuity?`

### 2. Why Now

Activate has already appeared repeatedly in case reasoning, especially in sequences where a runner is being brought back into workable rhythm without yet being asked to absorb stimulus, build capacity, or prepare directly for the next key session.

What remains missing is not local readability.

What remains missing is proof that Activate deserves reusable mission-family status rather than remaining a case-level descriptive convenience.

After Recover entered observation mode, Activate now represents the mission family with the highest remaining uncertainty at the identity level.

### 3. Evidence Needed

- The current workout should still look plausibly readable as a generic Easy Run at the activity-only level.
- A nearby competing reading should exist, most likely `Prepare` or generic `Easy`, so that Activate must earn its interpretation rather than inherit it.
- The surrounding sequence should show that the workout's real job is to restore workable rhythm, reopen leg turnover, or reconnect training feel without yet taking on a full preparation obligation.
- Reading the workout as `Activate` should preserve sequence meaning that would be flattened if the day were treated as generic easy continuity or over-upgraded into `Prepare`.

### 4. Expected Knowledge Contribution

- Identity clarification
- Mission discrimination

### 5. Success Criterion

The first Activate step should be considered successful if:

- `Activate` becomes the stronger explanation than its nearby competing readings
- the stronger reading is supported by sequence obligation rather than by workout label alone
- Activate begins to earn recognition as an independent Mission Family rather than a mechanism hidden inside Easy or Prepare

If this does not happen, the correct response is not forced ontology expansion.

It is to keep Activate in identity-testing mode until a convincing sequence earns the distinction.

## Activate Family Identity Discovery — Candidate Screening

This screening note should remain narrow.

Its purpose is not to gather every activation-looking workout.

Its purpose is to identify which candidate creates the strongest mission competition between `Activate`, nearby `Prepare`, and generic `Easy` continuity.

### Screening Focus

The current reviewer question is:

`Which candidate most clearly forces Activate to earn its interpretation against nearby Prepare or generic Easy continuity?`

At this stage, candidate quality should be judged in this order:

1. `Mission Competition`
2. `Identity Pressure`
3. `Evidence Quality`

### Round 1 Candidate Pool

#### Candidate A

`2026-07-08 Tempo Run -> 2026-07-10 Easy Run + Strides -> 2026-07-11 Recovery Run -> 2026-07-12 Easy Run`

- Current workout: `2026-07-10 Easy Run / Aerobic Base / 8.197 km / Training Load 138 / Workout structure: 7K Eazy + Strides`
- Why it matters: 這是目前最乾淨的 Activate identity 候選。當天表面上非常像一堂 generic easy run，但前一堂是 Tempo，後面卻沒有直接接 key workout，而是回到 Recovery。這使 `Prepare` 雖然存在，但證據明顯較弱，`Activate` 必須主要和 `Easy` 競爭。
- Main competing reading: `Easy`, with lighter `Prepare` pressure.

#### Candidate B

`2026-07-13 Recovery Run -> 2026-07-14 Easy Run + Strides -> 2026-07-15 HM Tempo -> 2026-07-17 Easy Run`

- Current workout: `2026-07-14 Easy Run / Aerobic Base / 9.033 km / Training Load 206 / Workout structure: 8K Eazy + Strides`
- Why it matters: 這個候選的張力很高，因為同樣是帶 strides 的 easy day，但後面直接接 HM Tempo，`Prepare` 的競爭非常真實。如果 `Activate` 要在這裡贏，必須拿出非常強的 sequence evidence。
- Main competing reading: `Prepare`, then `Easy`.

#### Candidate C

`2026-06-08 Recovery -> 2026-06-09 Easy + Strides -> 2026-06-10 Cruise Interval -> 2026-06-11 Recovery`

- Current workout: `2026-06-09 / 9.502 km / Training Load 95 / Workout structure: 8K Easy + Strides`
- Why it matters: 這個候選介於 A 與 B 之間。它有明確的 easy-like surface，也有後續品質課，因此 `Activate` 與 `Prepare` 會真正競爭。但相較於 Candidate B，這裡的 preparation obligation 稍弱，因為前一天仍在 recovery flow 中。
- Main competing reading: `Prepare`, with real `Activate` pressure.

#### Candidate D

`2026-04-14 Easy Run + Strides -> 2026-04-15 Cruise Interval -> 2026-04-16 Recovery`

- Current workout: `2026-04-14 Easy Run / Aerobic Base / 8.751 km / Training Load 220 / Workout structure: 8K Z2 + Strides`
- Why it matters: 這個候選很適合當邊界案例，因為它幾乎把 `Prepare` 的證據堆滿。它對 Activate 的價值不在於建立身份，而在於提醒我們：不是所有帶 strides 的 easy day 都能被 Activate 拿下。
- Main competing reading: `Prepare`.

### Reviewer Comparison

| Candidate | Mission Competition | Identity Pressure | Evidence Quality | Suitability for first Activate identity case |
| --- | --- | --- | --- | --- |
| A | High | Very high | High | Best fit |
| B | Very high | High | High | Better as adjacent boundary case |
| C | High | High | Medium-high | Strong alternate candidate |
| D | Very high | Medium | High | Too preparation-shaped |

### Reviewer Recommendation

`Candidate A should be selected first because it gives Activate the cleanest chance to earn identity without being immediately overwhelmed by Prepare. Candidate B and Candidate C remain highly valuable, but they are better treated as follow-up competition cases once Activate has first shown that it can stand on its own.`

### Activate Screening Outcome

Unlike Recover cross-fatigue screening, Activate currently does appear to have at least one sufficiently strong candidate.

The next step may therefore proceed into a first Activate identity case if we want to convert this screening result into direct evidence.

## Mission Identity Interim Reading #1

This interim reading should stay small.

Its purpose is not to consolidate any mission family.

Its purpose is to stabilize what the current evidence already says about how mission identity is earned.

### 1. What Now Looks Stable

The following identity-level knowledge now appears stable enough to build on:

- `Recover` has shown that it can become stronger than generic `Easy` continuity when surrounding sequence obligation makes recovery meaning visible.
- `Recover` has also shown that this identity is not limited to one local pattern; it can survive across more than one recovery-obligation structure, even though cross-fatigue robustness remains open.
- `Activate` has now shown that it should not be read as `Prepare` merely because an easy day contains strides.
- `Activate` appears to require its own sequence obligation: restoring workable rhythm, reopening leg turnover, or reconnecting training feel without yet taking on a full preparation obligation.

At this stage, both families have earned more than local wording.

They have each earned at least one identity-level evidence point.

### 2. Identity Competition Currently Looks Different

The current evidence suggests that mission identity is not earned against the same neighboring reading in every family.

At the present stage:

| Mission Family | Main identity competition currently observed |
| --- | --- |
| Recover | `Easy` |
| Activate | `Prepare` |

This is not yet a reusable framework.

It is simply the most honest reading of the current evidence:

- Recover earns identity by replacing a too-flat `Easy` reading.
- Activate appears to earn identity by resisting premature promotion into `Prepare`.

### 3. Remaining Uncertainty

The next important unknowns are now clearer than they were before:

- `Recover`
  - Open question: cross-fatigue robustness
  - Current status: `Observation Mode`
- `Activate`
  - Open question: can identity survive across another competition shape beyond the first validated pattern?
  - Current status: identity established, generalization not yet tested

The current working conclusion is:

`Mission identity research is no longer case-driven. It is now driven by which remaining uncertainty is most worth reducing next.`

## Batch 20 / Case 14 — Activate Identity Validation Test

### Case 14 — Activate Identity Validation Test

**Research Goal**

This case attempts to determine whether Activate earns the stronger interpretation against nearby Prepare and generic Easy continuity.

The question is not whether Activate can exist.

The question is whether Activate wins because of sequence obligation rather than workout label.

**Pattern Type**

Boundary Pattern.

**Research Intent**

Discovery.

This case should be treated as an identity-validation case rather than a generic easy-with-strides example.

Its purpose is not to show that strides can exist inside an easy run.

Its purpose is to test whether the surrounding sequence makes `Activate` more coach-credible than either `Prepare` or generic `Easy`.

**Date / Sequence Window**

2026-07-08 -> 2026-07-10 -> 2026-07-11 -> 2026-07-12

**Previous Workout**

2026-07-08 Tempo Run / Threshold / 10.005 km / Training Load 228 / RPE 3 - 中等
Workout structure: `10K Tempo`

**Current Workout**

2026-07-10 Easy Run / Aerobic Base / 8.197 km / Training Load 138 / RPE 3 - 中等
Workout structure: `7K Eazy + Strides`

**Next Workout**

2026-07-11 Recovery Run / Recovery / 11.05 km / Training Load 114 / RPE 2 - 輕鬆

**Forward Context**

2026-07-12 Easy Run / Aerobic Base / 7.006 km / Training Load 75 / RPE 3 - 中等
Workout structure: `7K Recovery`

**Activity-only Reading**

只看 Activity，這是一堂很典型會被讀成 easy re-entry day 的課。它本身是 easy run，裡面又帶 strides，因此最直覺的 reading 會是：用一堂輕鬆但稍微喚醒步頻的課，把前一堂 Tempo 之後的節奏接回來。

**WSI Reading**

- Mission Category: Activate
- Mission Phrase: Reopen leg turnover and reconnect workable rhythm without yet taking on a preparation obligation
- Mission Status: Completed
- Continuity State: Maintained
- Sequence Reasoning: 這個案例真正要測的不是 7/10 像不像 easy run，而是 `Activate` 能不能在與 `Prepare` 的鄰近競爭中贏下來。前一堂是明確的 Tempo，因此 sequence 的確需要一堂把身體重新接回可工作節奏的課；而 strides 也讓 `Activate` 這個 reading 看起來有機制支撐。但如果它真的是 `Prepare`，後面理應要看到一堂更清楚的 key obligation 被承接起來。實際上，7/11 並不是品質課，而是 `Recovery Run`，7/12 也仍停留在 easy/recovery family。這表示 7/10 的任務不是替下一堂關鍵刺激鋪路，而是把 Tempo 之後的節奏、步頻與 running feel 重新打開，同時不把 sequence 過早推進到 preparation mode。若讀成 generic `Easy`，會低估 strides 與前一堂 Tempo 之間的 sequence relationship；若讀成 `Prepare`，又會過度宣告後續其實並未出現的 key-session obligation。因此目前最穩定的 reading 是：7/10 的 primary mission 應為 `Activate`，而且因為後續 sequence 仍停留在恢復與重新接回節奏的範圍內，continuity 最適合維持在 `Maintained`，而不是提升到 `Ready`。

**Correctness**

- Score: 2
- Why: 這個案例最關鍵的證據是後續 sequence 沒有把 7/10 接成 preparation chain。Tempo 之後的 easy + strides 很容易讓人誤以為是在替下一堂 key workout 預做鋪路，但 7/11 與 7/12 都沒有支持這件事。`Activate` 因此比 `Prepare` 更能解釋這堂課的實際角色。

**Helpfulness**

- Score: 2
- Why: Activity-only 最多只能說這是一堂帶 strides 的 easy run。WSI 則能幫 Runner 理解更細的教練意義：今天不是在準備下一堂課，而是在重新打開身體、恢復運作感，讓 sequence 不至於在 Tempo 後變得鈍掉。這比 generic easy continuity 更有指導性。

**Reviewer Confidence**

- Score: Medium
- Why: 這是 Activate 的第一個 identity case，不是 generalization case。證據已足以讓 `Activate` 贏過 `Prepare` 與 generic `Easy`，但還不足以立刻升格為 reusable mission-family knowledge。下一步仍需要另一個不同競爭形狀的案例來確認這不是單一路徑下的局部成功。

**Learning Notes**

Case learning: `Easy + Strides` 並不天然屬於 `Prepare`。當後續 sequence 沒有接向明確 key obligation，而只是維持在 recovery/easy family 中時，strides 更可能是 activation mechanism，而不是 preparation evidence。

Knowledge learning: 這個案例提供了 Activate 作為獨立 Mission Family 的第一份 identity evidence。它支持 Activate 並不是 generic Easy 的修辭變體，也不是只要看到 strides 就自動升格成 Prepare，而是一個可以由 sequence obligation 支撐的獨立 mission reading。

Epistemic learning: 這個案例還不足以宣告 Activate-family knowledge 已成立。它只說明 Activate 已經賺到第一份身份證據；後續仍需要競爭形狀不同的案例，來確認它不是只在單一 Tempo -> Easy + Strides -> Recovery pattern 中成立。

**Rule Impact**

- Supports
- Why: 這個案例支持 sequence role 持續優於 workout label，也支持 secondary workout elements 應先被視為 mechanism 而不是直接升格為 primary mission。它沒有迫使新規則出現，但為 Activate identity 增加了第一個直接證據點。

**Refinement Decision**

- keep as is

## Activate Identity Generalization — Research Planning

This planning note should not ask for another activation-looking workout.

It should ask whether the identity established in Case 14 can survive a different competition shape.

The purpose here is not workout repetition.

It is competition generalization.

### 1. Generalization Question

`Can Activate remain the stronger explanation when the competition shape changes?`

### 2. Why Now

Case 14 provided the first identity evidence for Activate.

What it did **not** prove is whether that identity is local to one specific `Tempo -> Easy + Strides -> Recovery` shape, or whether it can survive when the neighboring mission pressure changes.

The next step is therefore not to consolidate Activate.

It is to test whether the newly earned identity can remain stable when the surrounding sequence creates a different kind of competition.

### 3. Evidence Needed

- The current workout should still look naturally readable as a generic Easy Run at the activity-only level.
- A real neighboring mission competition should still exist, but it should arise through a meaningfully different competition shape from Case 14.
- Reading the workout as `Activate` should preserve important sequence meaning that would be flattened if the day were treated as generic `Easy` continuity or prematurely upgraded into `Prepare`.
- The stronger reading should come from changed competition structure, not from simply repeating another `Tempo -> Easy + Strides -> Recovery` pattern.

### 4. Expected Knowledge Contribution

- Boundary clarification
- Cross-competition identity validation

### 5. Success Criterion

This first Activate generalization step should be considered successful if:

- `Activate` again becomes the stronger explanation than its nearby competing readings
- the stronger reading is supported by a competition shape that is meaningfully different from Case 14
- Activate identity begins to detach from one local sequence pattern and move toward reusable mission-family status

If this does not happen, the correct response is not forced consolidation.

It is to keep Activate in identity-testing mode until a second convincing sequence supports the same reading.

## Activate Identity Generalization — Candidate Screening

This screening note should stay narrow.

Its purpose is not to find another workout that merely looks like Activate.

Its purpose is to test whether there is currently a candidate strong enough to reduce the remaining uncertainty after Case 14.

### Screening Question

`Which candidate most credibly tests whether Activate can remain the stronger explanation when the competition shape changes?`

At this stage, the key reviewer lens is not workout difference.

It is competition-shape difference:

- strong `Activate vs Prepare`
- mixed `Activate vs Prepare vs Easy`
- or any other shape that is meaningfully different from the lighter `Activate vs Easy` competition seen in Case 14

### Round 1 Candidate Pool

#### Candidate A — Strong Prepare competition

`2026-07-13 Recovery Run -> 2026-07-14 Easy Run + Strides -> 2026-07-15 HM Tempo -> 2026-07-17 Easy Run`

- Current workout: `2026-07-14 Easy Run / Aerobic Base / 9.033 km / Training Load 206 / Workout structure: 8K Eazy + Strides`
- Why it matters: 這個候選真正改變了 competition shape。Case 14 主要是 `Activate vs Easy`，這裡則幾乎直接變成 `Activate vs Prepare`。
- Why it is weak right now: 後面直接接 `HM Tempo`，而且 current day 自身負荷也不低，`Prepare` 的證據非常強。這讓它更像 Activate 的邊界案例，而不是目前最適合拿來支持 Activate generalization 的案例。
- Current reviewer judgment: Very strong competition-shape difference, but likely too Prepare-shaped to safely support Activate.

#### Candidate B — Mixed competition with lighter preparation pull

`2026-06-08 Recovery -> 2026-06-09 Easy + Strides -> 2026-06-10 Cruise Interval -> 2026-06-11 Recovery`

- Current workout: `2026-06-09 / 9.502 km / Training Load 95 / Workout structure: 8K Easy + Strides`
- Why it matters: 這個候選不像 Case 14 那麼乾淨，因為後面確實有品質課；但它又不像 Candidate A 那樣被 preparation evidence 完全壓過去。理論上，它有機會形成 `Activate vs Prepare` 的真實競爭。
- Why it is weak right now: 雖然 current load 很低，但 next-day `Cruise Interval` 讓 `Prepare` 仍然是非常自然的 reading。加上資料欄位在這段期間較不完整，證據強度不足以讓 Activate 穩定贏下來。
- Current reviewer judgment: Best current generalization candidate, but still not strong enough.

#### Candidate C — Prepare-dominant boundary

`2026-04-14 Easy Run + Strides -> 2026-04-15 Cruise Interval -> 2026-04-16 Recovery`

- Current workout: `2026-04-14 Easy Run / Aerobic Base / 8.751 km / Training Load 220 / Workout structure: 8K Z2 + Strides`
- Why it matters: 這個候選很有價值，因為它幾乎把 `Prepare` 的證據堆滿，可以清楚提醒我們 Activate 不是看到 strides 就能成立。
- Why it is weak right now: 它對 Activate 的 generalization 幫助不大，因為它主要證明的是 `Prepare` 何時該贏，而不是 Activate 在另一個 competition shape 中如何仍然成立。
- Current reviewer judgment: Useful as boundary control, not as the next identity-generalization case.

### Reviewer Comparison

| Candidate | Competition-shape distance | Evidence quality | Competing mission pressure | Suitability for Case 15 |
| --- | --- | --- | --- | --- |
| A | Very high | High | Very high (`Prepare`) | Too preparation-shaped |
| B | High | Medium | High (`Prepare`) | Closest fit, but not yet strong enough |
| C | High | High | Very high (`Prepare`) | Better as boundary control |

### Screening Outcome

No current candidate is strong enough to justify immediate promotion into `Batch 20 / Case 15`.

The correct response is therefore not forced selection.

It is to keep Activate identity generalization in observation mode until a candidate appears that:

- changes the competition shape more clearly than Case 14
- still preserves plausible `Activate` evidence
- does not immediately collapse into a stronger `Prepare` reading

## Batch 20 / Case 11 — Preparation Boundary Validation Test

### Case 11 — Preparation Boundary Validation Test

**Pattern Type**

Boundary Pattern.

**Research Intent**

Falsification.

This case should be treated as a boundary-validation case rather than a novelty case.

Its purpose is not to discover a new mission.

Its purpose is to test whether the current preparation-family knowledge remains sufficient when the preparation day is meaningfully non-trivial, but the following key workout still appears to hold together.

The real question is:

`Does this sequence still fit the current preparation-family interpretation, or does it reveal that the current boundary is drawn too coarsely?`

**Date / Sequence Window**

2026-04-20 -> 2026-04-21 -> 2026-04-22 -> 2026-04-23

**Previous Workout**

2026-04-20 Recovery Run / Recovery / 5.011 km / Training Load 90 / RPE 3 - 中等

**Current Workout**

2026-04-21 Easy Run / Aerobic Base / 8.767 km / Training Load 192 / RPE 3 - 中等
Workout structure: `8K Z2 + Strides`

**Next Workout**

2026-04-22 Marathon Pace / Race Simulation / 10.626 km / Training Load 208 / RPE 3 - 中等
Workout structure: `10K HM Pace`

**Forward Context**

2026-04-23 Recovery Run / Recovery / 6.012 km / Training Load 124 / RPE 3 - 中等

**Activity-only Reading**

只看 Activity 的話，這是一堂帶 strides 的前置 easy run，隔天接 HM Pace。最自然的 reading 會是：今天用一堂不算太輕的 Z2 + strides 課把節奏接回來，為明天的比賽配速課做準備。

**WSI Reading**

- Mission Category: Prepare
- Mission Phrase: Prepare for HM-pace entry by restoring rhythm and leg turnover while preserving enough freshness for the key session
- Mission Status: Completed
- Continuity State: Ready
- Sequence Reasoning: 這堂課前面接的是 Recovery，後面接的是明確的 HM Pace key workout，因此 sequence role 仍然很自然地把 primary mission 拉向 `Prepare`。真正需要判斷的不是 mission 是不是 `Prepare`，而是這個 preparation 的成本是否已經高到不再可用。和 Case 09、Case 10 相比，4/21 雖然不是極低成本的 prep day，但它的負荷（192）與刺激（TE 3.9）仍明顯低於那兩個 imperfect-preparation 案例；而隔天 HM Pace 結構完整、RPE 維持中等、後面也能自然接回 Recovery，表示 preparation 並沒有只是「勉強維持 sequence」，而是真的把 sequence 送進了可工作的 readiness。因此目前最穩定的 reading 是：`Prepare` 仍為 primary mission，而且在這個案例中 mission 已可視為 `Completed`，continuity 也可合理提升到 `Ready`。

**Correctness**

- Score: 2
- Why: 這個案例最重要的地方是它沒有落成另一個 `Prepare / Partial / Maintained`。若仍然這樣讀，反而會把 preparation family 的邊界畫得過窄。前一天 Recovery 提供了乾淨入口，當天 prep day 雖有明確工作量，但隔天 HM Pace 的結構、負荷與主觀感受都不像被明顯拖累，因此 `Completed / Ready` 比 `Partial / Maintained` 更符合證據。

**Helpfulness**

- Score: 2
- Why: Activity-only 只能說這是一堂為 HM Pace 做準備的 Z2 + strides。WSI 則更進一步回答了 preparation-family 真正重要的問題：什麼樣的前置課只是昂貴但仍成功，什麼樣的前置課才算不乾淨到只能算 partial。這比單純說「今天有做準備」更能幫 Runner 理解整段 sequence。

**Reviewer Confidence**

- Score: Medium
- Why: `Prepare` 很穩，但 `Completed / Ready` 是第一次明確把 preparation-family 的成功邊界往前推，因此仍需要保留一些審慎。這個 reading 很可信，但它本質上是在畫邊界，而不是在重複已知結論。

**Learning Notes**

Case learning: 這個案例顯示 preparation-family 並不是只會產生 `Partial / Maintained`。當 prep day 雖然有工作量，但仍保留足夠 freshness，且下一堂 key workout 的完成感沒有明顯被侵蝕時，preparation 可以合理成立為 `Completed / Ready`。

Knowledge learning: 這個案例不是新增新的 preparation-family 知識類型，而是把既有知識的成功邊界畫得更清楚。它顯示 `Prepare / Partial / Maintained` 並不是 preparation-family 的預設結果；它只是目前已知的 imperfect-preparation reading，而不是整個 family 的唯一讀法。

Epistemic learning: 這個案例沒有推翻目前的 preparation-family knowledge，反而使它變得更精確。Preparation failure boundary 仍未完全畫出，但 usable-success boundary 已經比 Case 09 和 Case 10 時更清楚。

**Rule Impact**

- Refines
- Why: 這個案例不是單純支持既有 reading，也不是推翻它。它細化了 preparation-family 知識的邊界：不是所有有成本的 prep day 都應落在 `Partial / Maintained`，當 sequence evidence 足夠時，`Completed / Ready` 也應被允許。

**Refinement Decision**

- refine worldview interpretation

## Batch 20 Rule

After Sprint 0, the next step is Batch 20.

However, every five new cases should trigger a rerun of the full gold-case calibration set.

The purpose of this rerun is regression control.

Any improvement in new cases should not silently degrade:

- G01
- G02
- G03
- G04
- G05

If a new refinement improves fresh cases but weakens the gold cases, the worldview has not improved cleanly.

It has drifted.

## Research Operating Mode

Case selection is driven by research gaps rather than by interesting workouts.

Every completed case should reduce uncertainty, strengthen confidence, or refine the current reasoning model.

## Validation Interim Reading #1

This reading should not be treated as a final report.

It is the first whole-document knowledge-state reading for `Workout Sequence Intelligence Validation v0.1`.

Its purpose is not to summarize every case.

Its purpose is to clarify what the validation now knows, what kind of knowledge has actually been produced, and where the highest remaining uncertainties still live.

### 1. Current Knowledge State

| Mission Family | Current Knowledge State |
|---|---|
| Build | Reusable Knowledge |
| Prepare | Reusable Knowledge |
| Recover | Observation |
| Activate | Observation |

This means the validation is no longer only accumulating case evidence.

It is now maintaining different knowledge states across mission families.

### 2. What Has Actually Changed

The most important changes are no longer case-local.

The validation has now demonstrated that:

- identity can be established through repeated sequence evidence rather than workout labels alone
- generalization does not have to succeed to be valuable
- negative results are valid research outputs when they shrink uncertainty honestly
- observation is a legitimate end state when no sufficiently strong evidence candidate exists

These changes matter more than any single mission-family result because they describe what the validation process itself has learned how to do.

### 3. Remaining Highest Uncertainties

| Mission Family | Highest Remaining Uncertainty |
|---|---|
| Build | Continuity Boundary |
| Prepare | Failure Boundary |
| Recover | Cross-fatigue Robustness |
| Activate | Cross-competition Robustness |

This table should not be read as a roadmap checklist.

It is a current reading of where the most meaningful unknown still sits inside each family.

### 4. Current Research Operating Mode

Current research is no longer driven by missing cases.

It is driven by the highest remaining uncertainty that can be meaningfully reduced.

That means:

- not every family needs the same number of cases
- not every unknown must be reduced immediately
- observation mode is a valid knowledge state, not a temporary failure state

At this stage, the validation has begun to manage knowledge state, not merely collect evidence.

## Status

`Workout Sequence Intelligence Validation v0.1`

- Status: Active
- Scope: First real-case validation sheet for Workout Sequence Reference Intelligence
- Classification: Architecture / Validation Working Document
