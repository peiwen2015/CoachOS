# Shoes Sprint v0.1

## Purpose

Move shoes from:

`a fixed dropdown list`

to:

`the first meaningful metadata task after import`

This sprint is not about full shoe intelligence yet.

It is about making shoes manageable, understandable, and worth filling in.

## Product Decision

Shoes should **not** be the first step after download.

Shoes should become the first metadata task **after the first batch of data is imported**.

The intended flow is:

```text
Import first FIT batch
  ↓
See Activity / Weekly / Monthly / Overview
  ↓
Notice missing shoe labels
  ↓
Quickly add current shoes
  ↓
Return to shoes / weekly / monthly with cleaner interpretation
```

## Sprint Goal

Make it easy for a first-time user to:

1. Understand why shoes matter
2. Add their current shoes without touching config files
3. Mark shoes as active or retired
4. Return to product surfaces with cleaner shoe-aware interpretation

## What This Sprint Must Answer

### 1. When do we remind the user to fill shoes?

Not during initial install.

Only after imported activities exist and shoe gaps become visible.

Expected trigger examples:

- Activity imported without shoe label
- Metadata page shows missing shoe labels
- Shoes page has no tracked shoes yet
- Weekly / Monthly / Overview cannot fully interpret because shoe context is missing

### 2. Where is the fastest place to fill shoes?

The user should be able to add shoes from a product surface, not from JSON.

v0.1 preferred path:

`Shoes page`

Optional secondary entry points:

- Metadata page: "先補鞋款"
- Overview / no-data follow-up hints
- Activity editing surface when shoe is empty

### 3. What is the minimum shoe management model?

For v0.1, each shoe only needs:

- display name
- active / retired status
- optional retire date

Do not require richer modeling yet.

Do not require brand / model / category at creation time.

If those are useful later, they should be earned by use.

## v0.1 Scope

### In Scope

- Empty public defaults for shoes
- Add shoe from UI
- List tracked shoes
- Mark shoe as active or retired
- Preserve retired shoes for historical activities
- Clear product hints when shoe metadata is missing

### Out of Scope

- Auto-detect shoe from FIT
- Shoe mileage recommendations
- Shoe replacement prediction
- Detailed shoe taxonomy
- Rich gear profile fields
- Multi-surface shoe wizard

## First User Experience

After first import, if no shoes exist:

```text
先補鞋款
鞋款是第一個最有感的標註。
補齊後，Activity、Weekly、Monthly 與鞋款判讀都會更乾淨。
```

Call to action:

`新增目前在用的鞋款`

If shoes exist but activities still miss labels:

```text
先補最近那批活動的鞋款，鞋款分析與訓練判讀會更準。
```

## Implementation Slice

### Slice A: Shoe creation

On the shoes page, allow:

- add a new shoe by name
- save it immediately into the shared metadata source

### Slice B: Shoe status

Allow each shoe to be:

- active
- retired

Retired shoes remain selectable for historical cleanup, but should no longer feel like current gear.

### Slice C: Missing-shoe guidance

Where shoe context is missing, surfaces should say so plainly and route the user to the shoes or metadata page.

## Definition of Done

Shoes Sprint v0.1 is done when:

- A new user can import data without setting shoes first
- The product clearly tells them why shoes are worth filling in
- They can add shoes from the UI
- They can retire shoes without deleting history
- Shoes no longer feel like a hidden config list

## Status

`Shoes Sprint v0.1`

- Status: Draft
- Scope: Shoes / Metadata / import follow-up
- Classification: Small Product Sprint
