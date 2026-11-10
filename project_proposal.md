# Beyond the Gym: A SQL-Based Analysis of Personal Physical Activity Across Different Life Stages

> **Project Proposal Version 2 - 10/11/2026**

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

The data was collected from the 6th of September, 2024, which was the date I started using Apple Watch, to the 27th of October, 2026. This peroid spans from life in Canada, Taiwan, and Scotland.

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
- **6–22 April 2025:** Italy.
- **25 September–8 October 2026:** London and other travel with family.

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

### 3.1 Workout Dataset

| Selected Column       | XML Source        | Purpose                                                   |
| --------------------- | ----------------- | --------------------------------------------------------- |
| `startDate`           | Workout           | Identify workout dates and times                          |
| `workoutActivityType` | Workout           | Identify workout categories                               |
| `duration`            | Workout           | Measure workout duration                                  |
| `durationUnit`        | Workout           | Identify duration units                                   |
| `active_calories`     | WorkoutStatistics | Measure active calories burned during individual workouts |
| `calorie_unit`        | WorkoutStatistics | Identify energy units                                     |

The `active_calories` value was extracted from the `sum` attribute of the `WorkoutStatistics` element with the type `HKQuantityTypeIdentifierActiveEnergyBurned`. Heart-rate and basal-energy statistics were excluded because they were not required to answer the current research questions.

### 3.2 Daily Activity Dataset

| Selected Column          | XML Source      | Purpose                                  |
| ------------------------ | --------------- | ---------------------------------------- |
| `dateComponents`         | ActivitySummary | Identify observation dates               |
| `activeEnergyBurned`     | ActivitySummary | Measure daily active calorie expenditure |
| `activeEnergyBurnedUnit` | ActivitySummary | Identify energy units                    |
| `appleExerciseTime`      | ActivitySummary | Examine daily exercise minutes           |
| `appleStandHours`        | ActivitySummary | Examine daily stand-hour patterns        |

Exercise minutes and stand hours were retained to support comparisons across different lifestyle periods. Activity goal-related attributes were excluded because the study focused on actual activity measurements rather than goal achievement.

## 4. Proposed Analytical Workflow

This project will adopt a structured, research-driven approach to analysing personal physical activity data using SQL. The workflow will prioritise understanding the dataset before making analytical decisions, ensuring that findings are supported by reliable data and clearly defined assumptions.

### Stage 1 — Data Understanding

The analysis will begin with an examination of the imported datasets to establish a clear understanding of their structure and contents.

This stage will involve:

* Identifying the available tables, columns, and data types.
* Examining representative records to understand how information is stored.
* Establishing the meaning and measurement units of relevant variables.
* Understanding the level of detail represented by each dataset, particularly the distinction between individual workout records and daily activity summaries.

**Objective:** Develop a clear understanding of the available data and determine how it can support the research questions.

### Stage 2 — Data Quality Assessment

Once the datasets are understood, their quality and suitability for analysis will be evaluated.

This stage will examine potential issues such as missing values, duplicate records, inconsistent dates, unexpected numerical values, and gaps in data coverage.

Particular attention will be given to the reliability of workout records as indicators of gym attendance and the availability of daily activity measurements.

**Objective:** Identify data quality issues and establish which observations can be used reliably in subsequent analyses.

### Stage 3 — Data Preparation and Integration

Following the quality assessment, the datasets will be prepared for analysis.

Individual workout records will be summarised at the daily level where necessary, allowing them to be integrated appropriately with daily activity data.

Additional contextual information, including travel periods and major lifestyle changes, will be incorporated using clearly defined date ranges.

Any transformations, exclusions, or assumptions will be documented to maintain transparency and reproducibility.

**Objective:** Produce a consistent analytical dataset that supports comparisons between gym and non-gym days and across different lifestyle contexts.

### Stage 4 — Research-Driven Exploratory Analysis

SQL will be used to investigate the research questions established in this proposal.

The analysis will focus on four areas:

1. **Gym Attendance:** Comparing daily active calorie expenditure between gym and non-gym days.
2. **Travel Behaviour:** Examining whether non-gym days during extended travel periods differ from ordinary non-gym days.
3. **Life Stages:** Exploring physical activity patterns across periods of living in Canada, Taiwan, and Scotland.
4. **Lifestyle Changes:** Investigating changes in workout frequency and daily activity during the dissertation and relocation periods.

Analytical methods and SQL techniques will be selected according to the requirements of each research question rather than predetermined solely to demonstrate specific SQL functions.

**Objective:** Identify meaningful patterns, differences, and trends in physical activity while remaining guided by the available evidence.

### Stage 5 — Interpretation and Documentation

The findings will be evaluated in relation to the original research questions and hypotheses.

Interpretation will consider relevant limitations, including incomplete activity records, differences in lifestyle circumstances, and the inability to establish causal relationships from observational data alone.

The final project will document its methodology, SQL queries, analytical findings, and limitations in a GitHub repository.

**Objective:** Present a transparent, reproducible, and clearly communicated analysis suitable for a professional data analytics portfolio.

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
