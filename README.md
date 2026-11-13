# Beyond the Gym — README

**Version:** 1  
**Author:** Peter Jiang (Yuxin Jiang)  
**Last Updated:** 13/11/2026  

---

## 1. Project Overview

**Beyond the Gym** is my personal data analytics portfolio that investigates my daily activity levels across different life stages in Canada, Taiwan, and Scotland using SQL.

The data used in this project was exported from the Apple Health application, covering the period from 6 September 2024 to 27 October 2026. The project explores the relationships between daily active calorie expenditure and several factors, including strength training, travelling, and different life stages.

## 2. Research Questions

This project addresses the following four research questions:

### RQ1 — Gym Attendance and Daily Active Calories

**Do gym days have higher average daily active calorie expenditure than non-gym days?**

The analysis compared daily active calorie expenditure between Gym Days and Non-Gym Days, identified using Apple Health's Traditional Strength Training records.

**Note:** I joined a gym in Canada around 28 September 2024, so the analysis used records from that date onwards.

### RQ2 — Travel and Physical Activity

**Do non-gym days during extended travel periods have higher daily activity levels than ordinary non-gym days?**

The analysis compared Non-Gym Days during three selected extended travel periods with other Non-Gym Days:

- **4–17 December 2024:** France and London.
- **6–22 April 2025:** Italy.
- **25 September–8 October 2026:** London and other travel with family.

### RQ3 — Physical Activity Across Different Life Stages

**How did physical activity patterns differ across periods of living in Canada, Taiwan, and Scotland?**

The analysis examined three life stages with different daily routines and responsibilities:

- **Canada:** Full-time retail employment.
- **Taiwan:** Part-time English teaching and a period without employment.
- **Scotland:** Postgraduate studies in Artificial Intelligence.

The comparisons focused on observed differences between life stages rather than causal effects of living in different countries.

### RQ4 — Dissertation and Physical Activity

**How did strength-training behaviour and daily physical activity differ between the early and intensive dissertation periods?**

The analysis compared two 60-day periods:

- **Early Dissertation:** 1 May–29 June 2026.
- **Intensive Dissertation:** 30 June–28 August 2026.

The comparison focused on recorded strength-training behaviour and daily active calorie expenditure.

---

## 3. Tools & Analytical Methods

### 3.1 Tools Used

Python was used to inspect the original Apple Health XML file and extract relevant data into two CSV datasets: workout records and daily activity summaries.

SQLite was the main database used throughout this project for data analysis, while DBeaver was used to write and execute SQL queries.

### 3.2 Data Processing and SQL Analysis

During the data inspection stage, Python was used to examine the XML structure and identify relevant attributes. After selecting the required variables, two CSV datasets were extracted and filtered to match the study period before being imported into SQLite.

Before conducting the main analysis, data quality checks were performed to identify missing values, duplicate records, date discrepancies, and inconsistent measurement units.

For RQ1–RQ4, SQL techniques including Common Table Expressions (CTEs), LEFT JOINs, CASE expressions, aggregate functions, and window functions were used to classify observations, compare different groups, and calculate descriptive statistics.

---

## 4. Key Findings

The four research questions revealed several findings about the relationship between recorded strength training and overall daily active calorie expenditure.

| Research Question | Key Findings |
|---|---|
| **RQ1 — Gym Attendance** | Gym Days recorded approximately **41.0% higher mean daily active calorie expenditure** than Non-Gym Days. However, **21.43% of Non-Gym Days** exceeded the Gym Day median. |
| **RQ2 — Extended Travel** | Non-Gym Days during the selected extended travel periods recorded **22.5% higher mean daily active calorie expenditure** than other Non-Gym Days. |
| **RQ3 — Life Stages** | Canada recorded the highest mean daily active calorie expenditure (**814.29 kcal**), while Taiwan recorded the lowest (**430.73 kcal**), despite having the highest strength-training frequency (**84.14%**). |
| **RQ4 — Dissertation Periods** | Mean daily active calorie expenditure decreased by **9.46%** during the Intensive Dissertation period, while differences in recorded strength-training frequency and duration were relatively modest. |

Overall, the findings suggest that although recorded strength training is associated with higher daily active calorie expenditure, gym attendance alone does not fully represent daily physical activity patterns. Activities outside the gym and differences in daily routines should also be considered when interpreting overall activity levels.

For a more detailed discussion of the results, see the [Project Overall Conclusion](reports/project_overall_conclusion.md).

---

## 5. Repository Structure

The repository is organised into the following folders and files:

- **[`sql_scripts/`](sql_scripts/)** — Contains SQL scripts for data quality checks and analyses of RQ1–RQ4.
- **[`reports/`](reports/)** — Contains data inspection, data quality assessment, research documentation, and the [Overall Project Conclusion](reports/project_overall_conclusion.md).
- **[`project_proposal.md`](project_proposal.md)** — Outlines the research background, objectives, and study design.
