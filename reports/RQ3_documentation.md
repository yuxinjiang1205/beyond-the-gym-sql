# RQ3: Physical Activity Patterns Across Different Life Stages

**Version:** 1  
**Author:** Peter Jiang (Yuxin Jiang)  
**Last Updated:** 13/11/2026  

---

## 1. Research Question and Objectives

**How did physical activity patterns differ across periods of living in Canada, Taiwan, and Scotland?**

This analysis examines physical activity patterns across three life stages between 6 September 2024 and 27 October 2026. Using personal Apple Health data, it explores differences in daily active calorie expenditure, recorded strength-training frequency, and training duration under varying work, study, and lifestyle circumstances.

The analysis has four objectives:

1. Compare mean and median daily active calorie expenditure.
2. Compare recorded strength-training day percentages.
3. Compare mean and median strength-training duration per training day.
4. Examine monthly variations in these three measures.

The analysis is descriptive, focusing on observed differences between life stages rather than establishing causal relationships between lifestyle circumstances and physical activity.

---

## 2. Data Preparation and Classification

### 2.1 Analysis Period

The analysis covers **6 September 2024 to 27 October 2026**, comprising 781 recorded daily observations across 782 calendar days. One missing observation (14 April 2025) was identified and was not imputed.

### 2.2 Life Stage Classification and Background

Daily observations were classified into three life stages using SQL `CASE WHEN` expressions.

| Life Stage | Period | Observations |
|---|---|---:|
| Canada | 2024-09-06 – 2025-04-22 | 228 |
| Taiwan | 2025-04-23 – 2025-09-14 | 145 |
| Scotland | 2025-09-15 – 2026-10-27 | 408 |
| **Total** | | **781** |

The three stages reflected different employment, academic, and lifestyle circumstances:

**Canada:** Full-time retail employment in Banff involved prolonged standing and movement throughout working hours. Daily routines also included walking to work, shops, and the gym, alongside IELTS preparation.

**Taiwan:** Part-time English teaching was combined with regular gym attendance and home-based preparation for postgraduate study. Daily errands generally involved shorter journeys and convenient public transport.

**Scotland:** Postgraduate study at the University of Stirling shaped daily routines, including campus activities, shopping trips, and travel to Glasgow. The stage also included dissertation work and relocation to Glasgow.

These descriptions are based on retrospective personal recollections. Life stage classifications represent broader periods rather than exact geographical locations, with travel periods retained within their respective stages.

The strength-training day classification followed the methodology established in RQ1 and subsequently applied in RQ2.

### 2.3 Daily Strength-Training Duration Aggregation

The workout dataset contained 19 dates with two recorded strength-training workouts: 14 in Canada, one in Taiwan, and four in Scotland.

To avoid treating multiple workout records on the same date as separate training days, recorded durations were aggregated using `SUM(duration)` and `GROUP BY` date, producing one duration value per strength-training day.

Only recorded strength-training days were included in duration calculations. Days without corresponding strength-training records were excluded rather than assigned zero minutes.

### 2.4 Data Validation

The analysis identified **489 recorded strength-training days**: 131 in Canada, 122 in Taiwan, and 236 in Scotland. These counts were consistent with the previously calculated training frequencies.

No NULL values were identified in daily active calorie expenditure, while earlier data quality checks confirmed consistent duration units and no zero or negative workout durations.

Potential overlap between multiple workout recordings on the same date was not independently verified and remains a limitation of the duration analysis.

---

## 3. Descriptive Statistical Analysis

The analysis compared three measures across the Canada, Taiwan, and Scotland life stages: daily active calorie expenditure, recorded strength-training frequency, and strength-training duration.

### 3.1 Daily Active Calorie Expenditure

Mean and median daily active calorie expenditure were calculated for each life stage using the methods established in RQ1. All recorded daily observations were included, regardless of strength-training activity.

### 3.2 Strength-Training Frequency and Duration

Strength-training frequency was calculated as the percentage of recorded days containing at least one Traditional Strength Training session.

Mean and median training duration were calculated using daily aggregated workout durations. Unlike daily active calorie expenditure, duration calculations included only recorded strength-training days.

SQLite window functions (`ROW_NUMBER()` and `COUNT() OVER()`) were used to calculate median duration, following the approach established in earlier analyses.

### 3.3 Monthly Analysis

Monthly statistics were calculated by grouping observations by life stage and calendar month. The analysis included:

- Mean daily active calorie expenditure.
- Percentage of recorded strength-training days.
- Mean strength-training duration per training day.

Months spanning two life stages were analysed separately. Monthly results were used to examine variations within each stage rather than relying exclusively on overall averages.

---

## 4. Results

### 4.1 Overall Life Stage Comparison

The analysis identified distinct physical activity patterns across the three life stages.

| Metric | Canada | Taiwan | Scotland |
|---|---:|---:|---:|
| Daily observations | 228 | 145 | 408 |
| Mean daily active calories (kcal) | **814.29** | 430.73 | 502.13 |
| Median daily active calories (kcal) | **833.89** | 439.97 | 506.53 |
| Recorded strength-training days | 131 | 122 | 236 |
| Strength-training day percentage | 57.46% | **84.14%** | 57.84% |
| Mean training duration (min) | **83.10** | 59.26 | 55.92 |
| Median training duration (min) | **75.94** | 60.37 | 60.07 |

### 4.2 Key Findings

**Daily active calorie expenditure:** Canada recorded the highest mean (814.29 kcal) and median (833.89 kcal), while Taiwan recorded the lowest values. Scotland fell between the two stages.

**Strength-training frequency:** Taiwan had the highest proportion of recorded strength-training days (84.14%), compared with 57.46% in Canada and 57.84% in Scotland. Despite similar training-day percentages in Canada and Scotland, their daily active calorie expenditure differed substantially.

**Strength-training duration:** Canada recorded the longest mean duration per training day (83.10 minutes), exceeding Taiwan by 23.84 minutes and Scotland by 27.18 minutes. Its median duration was also the highest (75.94 minutes), although the differences were smaller. Taiwan and Scotland had nearly identical median durations of 60.37 and 60.07 minutes, respectively.

### 4.3 Monthly Activity Patterns

**Canada:** January 2025 recorded the highest monthly mean daily active calorie expenditure (960.99 kcal). Mean training duration was relatively high in October 2024 (91.58 minutes), November 2024 (89.96 minutes), and January 2025 (91.28 minutes). April 2025 recorded only three strength-training days, limiting the interpretation of its monthly duration average.

**Taiwan:** Strength-training frequency remained consistently high between May and August 2025, ranging from 80.65% to 93.55%. During the same period, mean training duration decreased progressively from 61.58 to 56.79 minutes.

**Scotland:** Monthly strength-training frequency varied considerably throughout the stage. Mean daily active calorie expenditure reached 390.64 kcal in July 2026 and 417.31 kcal in August, before increasing to 529.96 kcal in September and 582.25 kcal in October. Despite this increase, recorded strength-training frequency was 33.33% in both September and October.

Overall, the results demonstrate that differences in strength-training frequency, training duration, and daily active calorie expenditure did not consistently follow the same patterns across life stages.

---

## 5. Discussion and Contextual Interpretation

### 5.1 Canada: High Daily Activity and Longer Training Duration

Canada recorded the highest daily active calorie expenditure and the longest average strength-training duration, although its training frequency was considerably lower than Taiwan's.

During my time in Canada, I worked in retail, which required frequent standing and walking. Walking was also an important part of my daily routine, including commuting to work, grocery shopping, and going to the gym. These activities may help explain the higher daily active calorie expenditure.

The longer recorded training durations were also consistent with my personal recollections of spending more time at the gym. However, the available data cannot determine how much each activity contributed to the overall calorie expenditure.

### 5.2 Taiwan: High Training Frequency but Lower Daily Activity

Taiwan recorded the highest strength-training frequency but the lowest mean daily active calorie expenditure. This was an interesting contrast, as attending the gym more frequently did not necessarily mean having higher daily active calories.

During this period, I worked fewer hours, spent more time studying at home, and generally had shorter daily journeys. These differences in my daily routine may help explain the lower activity levels outside the gym, although their individual contributions were not measured.

Despite the higher training frequency, the median training duration remained close to 60 minutes, which was similar to Scotland.

### 5.3 Scotland: Changing Activity Patterns During Postgraduate Study

Scotland recorded a strength-training frequency similar to Canada, but its training durations and daily active calorie expenditure were lower. The monthly analysis also showed considerable changes throughout this life stage.

Daily active calorie expenditure was relatively low during July and August 2026, which coincided with my dissertation work and changes in my daily routine. However, daily active calories increased in September and October, even though recorded strength-training frequency was lower.

Moving to Glasgow, travelling, and changes in everyday walking may help explain these differences. However, the analysis cannot determine how much each factor contributed to the changes.

### 5.4 Frequency, Duration, and Overall Activity

The results showed that strength-training frequency, workout duration, and daily active calorie expenditure did not always follow the same patterns.

Canada recorded longer training durations and higher daily active calories, while Taiwan had the highest training frequency but the lowest daily active calories. Scotland also showed that daily active calorie expenditure could change even when strength-training frequency was relatively low.

These findings suggest that strength-training frequency alone is not enough to describe my overall daily activity patterns. Workout duration and daily active calorie expenditure also need to be considered.

---

## 6. Limitations

**Observational Study Design:** This analysis was based on my personal Apple Health records across three life stages. The results describe differences in my activity patterns, but they cannot establish causal relationships. In addition, the findings may not be representative of individuals with different lifestyles.

**Unequal Observation Periods:** The three life stages covered different lengths of time and numbers of observations. Although averages and percentages were used for comparison, differences in seasonal coverage and incomplete months may have affected the results.

**Measurement and Classification:** Daily active calories recorded by Apple Health are estimated values. Traditional Strength Training records were used to identify training days, but they may not capture every gym visit. In addition, recorded workout duration does not directly measure training intensity.

**Workout Duration Aggregation:** Some dates contained multiple strength-training records, so their durations were added together to calculate daily training duration. However, potential overlaps between workout records were not independently checked. This may have resulted in overestimated training durations.

**Contextual Interpretation:** My explanations about employment, study, commuting, and lifestyle changes were based on personal recollections rather than directly measured activities. Travel periods were also included within their respective life stages, which may have influenced the observed results.
---

## 7. Conclusion

The analysis identified distinct physical activity patterns across the three life stages. Canada recorded the highest daily active calorie expenditure and longest strength-training duration, whereas Taiwan demonstrated the highest training frequency despite having the lowest overall daily activity levels. Scotland showed greater monthly variation, with training frequency and daily active calorie expenditure following different patterns.

These findings highlight that strength-training frequency alone does not fully represent physical activity patterns. Considering training duration alongside daily active calorie expenditure provides a more comprehensive understanding of how recorded activity differed across life stages.
