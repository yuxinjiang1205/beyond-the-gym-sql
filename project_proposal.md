# Beyond the Gym: A SQL-Based Analysis of Personal Physical Activity Across Different Life Stages

> **Project Proposal Version 1 - 29/10/2026**

| Project detail | Description |
|---|---|
| Project Type | Personal Activity Data Analytics Portfolio |
| Author | Yuxin Jiang (Peter Jiang) |
| Primary Tool | SQL (SQLite / DBeaver) |
| Data Source | Apple Health |
| Study Period | 6 September 2024 – 27 October 2026 |

## 1. Project Background

This project builds upon my previous statistical portfolio that investigated whether attending the gym was associated with higher daily calorie expenditure. The original study used 15 daily observations and R (Studio) for statistical analysis. This project expands the investigation using approximately two years of Apple Health activity records collected while living in Canada, Taiwan, and Scotland.

Beyond gym attendance, the analysis explores how travel, employment, postgraduate studies, and major lifestyle changes relate to daily physical activity. The aim is to apply SQL to a real-world personal dataset, from data validation and preparation to exploratory analysis and interpretation.

## 2. Primary Research Question
For this project, I propose the following 4 research questions:
### RQ1 — Gym Attendance and Daily Active Calories

**Do gym days have higher average daily active calorie expenditure than non-gym days?**

This is the primary research question of this project. The objective is to compare daily active calories between days with and without recorded gym attendance.

The analysis will investigate:

- Differences in mean and median daily active calories.
- Variation in activity levels between the two groups (gym and non-gym).
- Whether some non-gym days exceed typical gym-day activity levels.

**Hypothesis:** Gym days are associated with higher average daily active calorie expenditure than non-gym days.

Gym attendance will initially be identified using Apple Health's Traditional Strength Training records, subject to validation of recording habits and data coverage. 
**Note: I signed up for the gym in Canada approximately on the 28th of September, 2024, so the records after on will be used for analysis.**

### RQ2 — Travel and Physical Activity

**Do non-gym days during extended travel periods have higher daily activity levels than ordinary non-gym days?**

Three travel periods will be considered:

- **4–17 December 2024:** France and London.
- **2–22 April 2025:** Italy.
- **25 September–7 October 2026:** London and other travel with family.

The analysis will primarily compare daily active calories, with daily step counts included if reliable data can be prepared.

### RQ3 — Physical Activity Across Different Life Stages

**How did physical activity patterns differ across periods of living in Canada, Taiwan, and Scotland?**

The three principal life stages are:

- **Canada:** Full-time retail sales associate, prolonged standing, and frequent gym attendance.
- **Taiwan:** Part-time English teaching, followed by a period without employment, alongside regular gym attendance.
- **Scotland:** Postgraduate studies, regular gym attendance, and changing weekday and weekend routines.

The analysis will explore differences in workout frequency, daily active calories, and activity patterns. These comparisons will be interpreted as differences between life stages rather than effects caused by different countries.

### RQ4 — Dissertation and Relocation Case Study

**How did workout frequency and daily physical activity change during the dissertation and relocation periods?**

Two major events will be examined:

- **Late June–August 2026:** High-stress dissertation period.
- **Late August–early September 2026:** Moving home and a temporary interruption of gym attendance.

The analysis will examine weekly workout frequency, workout duration, and trends in daily activity. Findings will describe observed changes without assuming that academic stress or relocation directly caused them.

## 3. Available Data

Two CSV datasets have already been extracted from Apple Health:

| Dataset | Records | Main Variables |
|---|---:|---|
| `workouts.csv` | 545 | Date, workout type, duration, workout active calories |
| `daily_activity.csv` | 781 | Date, daily active calories, exercise minutes |

Additional daily step-count data may be extracted if appropriate.

A small supplementary table will be created to identify travel periods and major life stages using known dates.

## 4. Proposed SQL Workflow

**Data Import → Data Validation → Data Preparation → Exploratory Analysis → Interpretation**

Planned SQL techniques include:

- Filtering, grouping, and conditional aggregation.
- JOINs between daily activity and workout records.
- CTEs for organising analytical queries.
- Window functions for weekly trends and rolling averages.
- Comparisons across workout categories and lifestyle periods.

Data quality checks will address missing dates, duplicate records, incomplete observations, and the distinction between recorded workouts and confirmed gym attendance.

## 5. Optional Extension

### Bayesian Analysis

A simple Bayesian analysis may be added if it provides meaningful insight beyond the SQL exploratory analysis. It is not a mandatory component of the project.

## 6. Expected Deliverables

The final portfolio will contain:

1. A documented SQLite database and SQL analysis scripts.
2. Clearly defined research questions and methodology.
3. Tables and visualisations presenting the main findings.
4. A discussion of findings, limitations, and practical insights.
5. A GitHub repository demonstrating the analytical workflow.

**Project principle:** Reliable data interpretation and practical SQL skills take priority over unnecessary analytical complexity. I aim to apply technical SQL skills in real-life problems.
