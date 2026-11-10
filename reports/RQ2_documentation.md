# RQ2: Extended Travel vs Non-Travel Periods — Daily Active Calorie Expenditure on Non-Gym Days

**Version:** 2 (Draft)  
**Author:** Peter Jiang (Yuxin Jiang)  
**Analysis Status:** Completed  
**Documentation Status:** Under Review

---

## 1. Research Question

**Do non-gym days during extended travel periods have higher daily activity levels than ordinary non-gym days?**

This analysis investigates the relationship between extended travel periods and daily active calorie expenditure using personal Apple Health data. The primary hypothesis is that Non-Gym Days occurring during extended travel periods are associated with higher daily active calorie expenditure than Non-Gym Days outside those periods. Unlike RQ1, which compared Gym Days and Non-Gym Days, RQ2 focuses exclusively on days without recorded Traditional Strength Training activity.

The analysis focuses on three aspects:

1. Identifying Non-Gym Days within predefined extended travel periods.
2. Comparing mean and median daily active calorie expenditure between travel and non-travel groups.
3. Examining how travel-related activities may contribute to differences in daily physical activity.

---

## 2. Data Preparation and Classification

### 2.1 Analysis Period

To maintain consistency with RQ1, the analysis covers:

**28 September 2024 – 27 October 2026 (inclusive)**

Within this period:

- Expected calendar days: **760**
- Recorded daily activity observations: **759**
- Missing daily activity date: **14 April 2025**

The missing observation was previously identified during the Data Quality Assessment and was not imputed.

### 2.2 Defining Extended Travel Periods

Three extended travel periods were identified using confirmed personal travel dates.

| Travel Period | Start Date | End Date | Calendar Days |
|---|---|---|---:|
| France and London | 2024-12-04 | 2024-12-17 | 14 |
| Italy | 2025-04-06 | 2025-04-22 | 17 |
| UK travel with family | 2026-09-25 | 2026-10-08 | 14 |
| **Total** | | | **45** |

Both departure and return dates were included in each travel period. Travel Days were classified using SQL `CASE WHEN` expressions and inclusive `BETWEEN` conditions.

| travel_day | Classification |
|---|---|
| 0 | Outside the predefined extended travel periods |
| 1 | Within a predefined extended travel period |

Travel classification was based on the confirmed calendar dates rather than the amount of physical activity recorded on individual days.

### 2.3 Gym Day Classification

The analysis retained the Gym Day classification established in RQ1, using Apple Health records labelled:

`HKWorkoutActivityTypeTraditionalStrengthTraining`

Distinct strength-training dates were extracted from `workouts_analysis` and joined with the daily activity dataset. Only observations classified as Non-Gym Days (`gym_day = 0`) were included in the RQ2 comparison.

### 2.4 Data Integration

Common Table Expressions (CTEs) were used to prepare and integrate the datasets and produce the final statistical summary. The completed query uses six CTEs:

| CTE | Purpose |
|---|---|
| `travel_days` | Assign Travel Day classifications and retrieve daily active calories |
| `gym_date` | Extract distinct Traditional Strength Training dates |
| `joined_table` | Integrate travel, gym, and daily activity classifications |
| `table_for_median` | Rank Non-Gym observations and calculate group sizes for median analysis |
| `mean_summary` | Calculate observation counts and mean daily active calories by travel group |
| `median_summary` | Calculate median daily active calories by travel group |

The `LEFT JOIN` operation preserved all recorded daily activity observations while identifying dates with corresponding strength-training records. The resulting dataset contained:

- `date`
- `travel_day`
- `gym_day`
- `daily_active_calories`

The classification results were validated against RQ1:

| Classification | Observations |
|---|---:|
| Gym Days | 479 |
| Non-Gym Days | 280 |
| **Total** | **759** |

The results matched the previously confirmed RQ1 classifications.

### 2.5 Comparison Groups

The primary analysis was restricted to:

`gym_day = 0`

The remaining observations were divided into two groups.

| Group | travel_day | gym_day | Observations |
|---|---|---|---:|
| Non-Gym Non-Travel Days | 0 | 0 | 237 |
| Non-Gym Travel Days | 1 | 0 | 43 |
| **Total** | | | **280** |

The three predefined travel periods contained **45 calendar days**, of which **44 had recorded daily activity observations**. Among these 44 recorded Travel Days:

- **43** were Non-Gym Days.
- **1** was a Gym Day.

The single Gym Day was excluded from the primary comparison. The combined total of 280 Non-Gym Days was consistent with RQ1.

### 2.6 Measurement

The primary variable was:

`daily_activity_analysis.activeEnergyBurned`

This variable represents recorded daily active energy expenditure, measured in kilocalories (kcal). Daily active calories were used instead of summing individual workout calories to avoid double-counting energy expenditure already included in the daily activity summary.

---

## 3. Descriptive Statistical Analysis

The analysis compared the two Non-Gym groups using:

- **Observation Count:** Number of recorded daily activity observations.
- **Mean:** Average daily active calorie expenditure.
- **Median:** The middle value of daily active calorie expenditure.

SQLite was used to perform the calculations.

### 3.1 Mean Calculation

Mean daily active calorie expenditure was calculated using SQL's `AVG()` function. The query applied `WHERE gym_day = 0` to retain Non-Gym Days before grouping observations by `travel_day`. The `COUNT(*)` function was used to confirm the number of observations in each group.

### 3.2 Median Calculation

Because the SQLite environment did not provide a built-in median aggregate function, median values were calculated using CTEs and window functions. The analysis used:

- `ROW_NUMBER() OVER (PARTITION BY travel_day ORDER BY daily_active_calories ASC)` to assign ordered positions within each group.
- `COUNT(*) OVER (PARTITION BY travel_day)` to calculate the number of observations in each group.

The middle observation or observations were selected using:

```sql
WHERE row_num IN (
    (group_count + 1) / 2,
    (group_count + 2) / 2
)
```

The formula accommodates both odd and even group sizes through SQLite's integer division. The `AVG()` function was then applied to the selected middle observation or observations to obtain the median.

For the current comparison:

| Group | Observations | Median Position |
|---|---:|---:|
| Non-Gym Non-Travel Days | 237 | 119 |
| Non-Gym Travel Days | 43 | 22 |

Both groups contained an odd number of observations.

### 3.3 Final Statistical Summary

The final SQL query combined the `mean_summary` and `median_summary` CTEs using `travel_day` as the join key. The resulting table reports the observation count, mean, and median for each Non-Gym comparison group. Mean and median values were rounded to two decimal places for presentation, while the calculations were performed on the original recorded values.

---

## 4. Results

### 4.1 Descriptive Statistics

| Measurement | Non-Gym Non-Travel Days | Non-Gym Travel Days |
|---|---:|---:|
| Number of Days | 237 | 43 |
| Mean Daily Active Calories | 440.12 kcal | **539.31 kcal** |
| Median Daily Active Calories | 393.62 kcal | **541.09 kcal** |

Both mean and median daily active calorie expenditure were higher for Non-Gym Travel Days.

### 4.2 Mean Comparison

Non-Gym Travel Days recorded higher average daily active calorie expenditure than Non-Gym Non-Travel Days. The mean daily active calorie expenditure was:

- **440.12 kcal** on Non-Gym Non-Travel Days.
- **539.31 kcal** on Non-Gym Travel Days.

This represents a difference of approximately **99.18 kcal per day**, with Non-Gym Travel Days recording **22.5% higher mean daily active calorie expenditure**. The result supports the primary research hypothesis that Non-Gym Days during extended travel periods were associated with higher average daily active calorie expenditure.

### 4.3 Median Comparison

The median comparison showed a similar pattern. The median daily active calorie expenditure was:

- **393.62 kcal** on Non-Gym Non-Travel Days.
- **541.09 kcal** on Non-Gym Travel Days.

The median difference was approximately **147.47 kcal**, representing **37.5% higher median daily active calorie expenditure** for Non-Gym Travel Days. The median difference was proportionally larger than the mean difference. This finding indicates that higher daily active calorie expenditure during the selected travel periods was reflected in both measures of central tendency.

### 4.4 Mean and Median Comparison

For Non-Gym Travel Days:

- Mean: **539.31 kcal**
- Median: **541.09 kcal**

The two values were relatively close, differing by approximately **1.78 kcal**.

For Non-Gym Non-Travel Days:

- Mean: **440.12 kcal**
- Median: **393.62 kcal**

The mean exceeded the median by approximately **46.50 kcal**. This suggests that some relatively high daily active calorie observations may have influenced the Non-Travel group mean. Overall, the results demonstrate a consistent difference in central tendency between the two comparison groups, with Non-Gym Travel Days recording higher values in both measures.

---

## 5. Discussion

The descriptive findings support the proposed hypothesis that Non-Gym Days during extended travel periods are associated with higher daily active calorie expenditure. Both mean and median comparisons showed higher activity levels during the selected travel periods. The mean difference was approximately **99.18 kcal per day (22.5%)**, while the median difference was approximately **147.47 kcal (37.5%)**.

One possible explanation is that extended travel periods involve greater amounts of movement throughout the day, particularly through walking and sightseeing. For example, exploring unfamiliar cities, visiting attractions, and moving between destinations may contribute to higher daily active calorie expenditure without structured gym sessions. Travel-related activity patterns may therefore differ from ordinary daily routines, even when gym attendance is absent in both groups.

The findings also complement RQ1. RQ1 established that Gym Days generally recorded higher daily active calorie expenditure than Non-Gym Days. RQ2 extends this investigation by examining differences **within the Non-Gym group**, demonstrating that daily active calorie expenditure can vary substantially according to the activity context.

In particular, the higher mean and median recorded during extended travel periods suggest that everyday activities outside structured strength training can make a substantial contribution to daily physical activity. These findings reinforce the central theme of *Beyond the Gym*: understanding physical activity through a broader range of daily experiences rather than gym attendance alone.

---

## 6. Limitations

### 6.1 Travel Classification Scope

The analysis included three predefined extended travel periods rather than every travel-related activity during the study period. Shorter domestic trips and day trips, including the Liverpool trip in October 2026 and sightseeing activities in Stirling and Edinburgh, were not included in the Travel Day classification.

Consequently, the Non-Gym Non-Travel group may contain observations involving travel or sightseeing activities outside the selected periods. The findings therefore reflect differences between the **three selected extended travel periods and dates outside those periods**. A future sensitivity analysis could examine whether including shorter trips changes the results.

### 6.2 Unequal Group Sizes

The analysis included:

- **237 Non-Gym Non-Travel Days**
- **43 Non-Gym Travel Days**

Unequal group sizes do not invalidate the descriptive comparison, and no observations were removed to balance the groups. However, the smaller Travel Group contains fewer observations and represents only three extended travel periods.

Additionally, observations within the same trip may reflect shared circumstances and should not automatically be treated as independent travel experiences. These considerations would be relevant to any future inferential analysis.

### 6.3 Missing Data

One daily activity observation was missing during the Italy travel period:

**14 April 2025**

As a result, the analysis included 44 recorded Travel Days rather than the full 45 calendar days. The missing observation was not imputed.

All available daily active calorie observations were retained without modification, including zero and potentially unusual values identified during the Data Quality Assessment. The missing observation and unusual recorded values may influence the descriptive statistics.

### 6.4 Observational Study Design and Generalisability

This analysis is based on my personal Apple Health data, reflecting my individual lifestyle, travel experiences, and physical activity patterns. As the dataset represents only one individual, the findings are specific to my personal circumstances and cannot be generalised to broader populations.

Furthermore, the analysis is observational and does not establish a causal relationship between travel and daily active calorie expenditure. No inferential statistical testing was conducted, as the primary objective was to explore and describe patterns within my own activity data.

---

## 7. Conclusion

The analysis found that Non-Gym Days during the three predefined extended travel periods recorded higher daily active calorie expenditure than Non-Gym Days outside those periods. Non-Gym Travel Days recorded approximately **99.18 kcal higher mean daily active calorie expenditure**, representing a difference of **22.5%** compared with Non-Gym Non-Travel Days.

The median comparison supported the same pattern. The Travel Group recorded a median of **541.09 kcal**, compared with **393.62 kcal** for the Non-Travel Group, representing a difference of approximately **147.47 kcal (37.5%)**. Both measures of central tendency support the primary hypothesis that Non-Gym Days during the selected extended travel periods were associated with higher daily active calorie expenditure.

The findings suggest that physical activity outside structured strength-training sessions, particularly during travel, can contribute substantially to recorded daily active energy expenditure. Overall, RQ2 extends the findings of RQ1 by demonstrating that differences in activity context are associated with meaningful variations in daily active calories, even among days without recorded gym activity. This provides further insight into the broader purpose of *Beyond the Gym*: examining how physical activity is distributed across different aspects of everyday life.

---

## 8. RQ2 Completion Status

**Analysis Status: Completed**  
**SQL Script: Organised and Uploaded**  
**Documentation: Version 2 (Draft) — Under Review**

The following analyses were completed using SQLite:

- Classification of three predefined extended travel periods.
- Integration of Travel Day and Gym Day classifications.
- Validation of Gym Day and Non-Gym Day observation counts.
- Identification of the two RQ2 comparison groups.
- Mean daily active calorie comparison.
- Median calculation using `ROW_NUMBER()` and `COUNT() OVER()`.
- Consolidation of observation counts, means, and medians into a final SQL summary table.
- Interpretation of descriptive findings and methodological limitations.

The completed analysis provides a descriptive answer to RQ2. The final SQL script has been organised and uploaded; the documentation remains under review before finalisation.

### Potential Extensions

Further analysis could examine:

- The inclusion of shorter trips through a sensitivity analysis.
- Differences between Non-Gym Travel Days and Non-Travel Gym Days.

These extensions are outside the scope of the current primary RQ2 analysis. The completed analysis provides a foundation for subsequent research questions examining physical activity across different life stages and lifestyle events.
