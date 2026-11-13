# RQ4: Early vs Intensive Dissertation Periods — Strength-Training Behaviour and Daily Physical Activity

**Version:** 1  
**Author:** Peter Jiang (Yuxin Jiang)  
**Last Updated:** 13/11/2026  

---

## 1. Research Question and Objectives

**How did strength-training behaviour and daily physical activity differ between the early and intensive dissertation periods?**

This analysis examines strength-training behaviour and daily physical activity during two stages of my MSc dissertation, covering the period from 1 May to 28 August 2026. Using personal Apple Health data, it investigates whether recorded strength-training patterns and overall daily active calorie expenditure differed between the early and intensive dissertation periods.

Regular strength training was an established part of my lifestyle before my dissertation. However, increasing academic demands raised questions about whether this routine could be maintained and how other forms of daily physical activity might differ as more time was allocated to dissertation work.

The analysis has four objectives:

1. Compare the percentage of recorded days containing Traditional Strength Training activity.
2. Compare mean and median strength-training duration per recorded training day.
3. Compare mean and median workout-specific active calorie expenditure per recorded strength-training day.
4. Compare mean and median overall daily active calorie expenditure across all recorded days.

The analysis is descriptive, focusing on observed differences between the two dissertation periods rather than establishing causal relationships between academic workload, perceived stress, and physical activity.

---

## 2. Data Preparation and Classification

### 2.1 Analysis Period

The analysis covers **1 May to 28 August 2026 (inclusive)**, comprising 120 recorded daily activity observations across 120 calendar days. The study period was divided into two equal 60-day intervals.

| Dissertation Period | Start Date | End Date | Daily Observations |
|---|---|---|---:|
| Early Dissertation | 2026-05-01 | 2026-06-29 | 60 |
| Intensive Dissertation | 2026-06-30 | 2026-08-28 | 60 |
| **Total** | | | **120** |

No missing daily activity observations were identified within the selected period. The equal observation periods provide a consistent basis for comparing recorded strength-training frequency and daily physical activity.

### 2.2 Dissertation Period Classification and Background

The two dissertation periods were defined using documented academic milestones rather than observed physical activity outcomes. Daily observations were classified using SQL `CASE WHEN` expressions and inclusive `BETWEEN` conditions.

The **Early Dissertation** period covers 1 May to 29 June 2026, representing the earlier stage of dissertation development. The **Intensive Dissertation** period begins on 30 June 2026, when a supervisory meeting identified substantial methodological issues requiring revisions to the research approach. Further significant feedback on the dissertation write-up was received on 12 August 2026, approximately two weeks before the submission deadline on 28 August.

These academic milestones provided the basis for defining the comparison periods. However, the classifications represent different stages of dissertation work rather than direct measurements of academic workload or perceived stress.

### 2.3 Strength-Training Classification and Daily Workout Aggregation

The analysis used two Apple Health datasets: `daily_activity_analysis`, containing daily activity dates and active calorie expenditure, and `workouts_analysis`, containing recorded workout types, durations, and workout-specific active calories.

Strength-training days were identified using records classified as `HKWorkoutActivityTypeTraditionalStrengthTraining`, following the methodology established in RQ1–RQ3. Calendar dates were extracted from `workouts_analysis.startDate` using `SUBSTRING()`. A recorded strength-training day was defined as a calendar date containing at least one Traditional Strength Training workout, while dates without a corresponding record were classified as days without recorded strength training.

Multiple strength-training records occurring on the same date were combined using `GROUP BY` and `SUM()`, producing one total duration and one total workout-specific active calorie value per recorded training day. This prevented multiple workout records from being counted as separate training days.

A `LEFT JOIN` was used when classifying training days to preserve all daily activity observations, including dates without recorded strength training. Workout duration and workout-specific active calorie calculations included only recorded strength-training days, while overall daily active calorie calculations included all observations regardless of training status.

Daily active calorie expenditure was obtained directly from `daily_activity_analysis.activeEnergyBurned`. Workout-specific active calories were analysed separately and were not added to the daily activity totals to avoid double-counting energy expenditure.

### 2.4 Data Validation

The analysis identified 65 recorded strength-training days across the two dissertation periods, consisting of 34 days in the Early Dissertation period and 31 days in the Intensive Dissertation period.

| Classification | Early Dissertation | Intensive Dissertation | Total |
|---|---:|---:|---:|
| Recorded Strength-Training Days | 34 | 31 | 65 |
| Days Without Recorded Strength Training | 26 | 29 | 55 |
| **Total Daily Observations** | **60** | **60** | **120** |

The classification totals were consistent with the 120 daily activity observations. Earlier data quality assessments identified no NULL values in the datasets and confirmed consistent measurement units for workout duration and active calorie expenditure.

Potential overlap between multiple workout recordings on the same date was not independently verified. This remains a limitation of the daily workout aggregation method.

---

## 3. Descriptive Statistical Analysis

The analysis compared recorded strength-training frequency, training duration, workout-specific active calorie expenditure, and overall daily active calorie expenditure between the two dissertation periods. All calculations were performed using SQLite.

### 3.1 Strength-Training Frequency

Strength-training frequency was calculated as the percentage of recorded days containing at least one Traditional Strength Training session. Differences between periods were expressed in percentage points.

### 3.2 Strength-Training Duration and Workout-Specific Active Calories

Mean and median training duration and workout-specific active calorie expenditure were calculated using daily aggregated strength-training records. Only recorded strength-training days were included.

Mean values were calculated using `AVG()`, while median values were obtained using SQLite window functions (`ROW_NUMBER()` and `COUNT() OVER()`), following the methodology established in RQ1–RQ3.

### 3.3 Overall Daily Active Calorie Expenditure

Mean and median daily active calorie expenditure were calculated using all recorded daily observations, regardless of strength-training activity.

A supplementary analysis compared mean daily active calories between days with and without recorded strength training. Median daily active calories were also calculated separately for recorded strength-training days.

Percentage changes were calculated relative to the Early Dissertation period. All comparisons were descriptive, and no statistical significance testing was performed.

---

## 4. Results

### 4.1 Overall Dissertation Period Comparison

The analysis identified differences in recorded strength-training frequency, workout-specific active calorie expenditure, and overall daily active calorie expenditure between the Early and Intensive Dissertation periods. Strength-training duration, however, remained relatively consistent.

| Metric | Early Dissertation | Intensive Dissertation |
|---|---:|---:|
| Daily observations | 60 | 60 |
| Recorded strength-training days | 34 | 31 |
| Strength-training day percentage | 56.67% | 51.67% |
| Mean training duration (min) | 55.88 | 54.28 |
| Median training duration (min) | 60.13 | 60.03 |
| Mean workout-specific active calories (kcal) | 220.70 | 214.23 |
| Median workout-specific active calories (kcal) | 227.14 | 209.59 |
| Mean daily active calories (kcal) | 442.99 | 401.08 |
| Median daily active calories (kcal) | 464.30 | 405.19 |

### 4.2 Key Findings

**Strength-training frequency:** The percentage of recorded strength-training days decreased from 56.67% in the Early Dissertation period to 51.67% in the Intensive Dissertation period, representing a reduction of 5.00 percentage points. The number of recorded training days declined from 34 to 31 across the two equally sized observation periods.

**Strength-training duration:** Mean training duration decreased slightly from 55.88 to 54.28 minutes per training day, a reduction of approximately 2.86%. Median duration remained almost unchanged, decreasing from 60.13 to 60.03 minutes. These results indicate relatively consistent recorded training durations across the two periods.

**Workout-specific active calorie expenditure:** Mean workout-specific active calories decreased from 220.70 to 214.23 kcal per recorded training day, representing a reduction of approximately 2.93%. The median declined more noticeably, from 227.14 to 209.59 kcal, a reduction of approximately 7.72%. Both measures were lower during the Intensive Dissertation period, although the relative decrease was greater for the median.

**Overall daily active calorie expenditure:** Mean daily active calories decreased from 442.99 to 401.08 kcal, representing a reduction of approximately 9.46%. Median daily active calories also decreased, from 464.30 to 405.19 kcal, a reduction of approximately 12.73%. Both measures therefore indicated lower overall daily active calorie expenditure during the Intensive Dissertation period.

### 4.3 Supplementary Analysis: Daily Active Calories by Strength-Training Status

A supplementary analysis examined whether differences in daily active calorie expenditure were also observable when recorded strength-training days and days without recorded strength training were considered separately.

| Metric | Early Dissertation | Intensive Dissertation |
|---|---:|---:|
| Mean daily active calories — Strength-training days (kcal) | 512.77 | 481.22 |
| Median daily active calories — Strength-training days (kcal) | 508.61 | 463.57 |
| Mean daily active calories — Days without recorded strength training (kcal) | 351.74 | 315.42 |

On recorded strength-training days, mean daily active calorie expenditure decreased by approximately 6.15%, while the median decreased by approximately 8.86%. On days without recorded strength training, mean daily active calorie expenditure decreased by approximately 10.33%.

The supplementary results indicate that lower mean daily active calorie expenditure during the Intensive Dissertation period was observed within both training-status categories. Consequently, the overall difference was not attributable solely to the reduced proportion of recorded strength-training days.

Overall, the results show that recorded strength-training frequency and duration changed relatively modestly between the two periods, while overall daily active calorie expenditure exhibited larger relative decreases.

---

## 5. Discussion and Contextual Interpretation

### 5.1 Maintaining Strength-Training Habits

Strength training remained a regular part of my routine during the Intensive Dissertation period. I recorded strength training on 31 out of 60 days (51.67%), while the average time spent training changed very little. This was more consistent than I had expected, given how busy I remember that period being.

Strength training has always been important to me, and I wanted to maintain my existing fitness routine. The university gym was also conveniently located on campus, making it easier to fit workouts around my dissertation work. These factors may help explain why I continued training regularly, although their effects cannot be measured directly.

### 5.2 Changes in Daily Activity

Although my strength-training routine remained relatively consistent, my overall daily active calorie expenditure showed a clearer decline. The mean decreased by 9.46%, while the median decreased by 12.73%. The supplementary analysis also showed lower mean daily active calories on both strength-training days and days without recorded strength training.

Looking back, I remember spending much more time working on my dissertation during July and August. In May and June, I still regularly visited the city centre for shopping, walking, and other activities. However, these outings became less frequent as my dissertation work increased. Bus services were also reduced during the summer break, making trips into the city more time-consuming. As a result, I relied more on grocery deliveries to save time.

These changes in my daily routine may help explain the lower activity levels during the Intensive Dissertation period. However, I did not directly measure how much time I spent walking, studying, or sitting, so I cannot determine how much each activity contributed to the difference.

### 5.3 Training Duration Does Not Tell the Whole Story

Similar workout durations do not necessarily mean that the training sessions had the same intensity. I remember making adjustments to my workouts to manage fatigue, including using slightly lighter weights, avoiding sets taken to muscular failure, and following deload weeks.

However, some of these changes may have started before the dissertation period. Therefore, the Early Dissertation period does not necessarily represent my previous training habits before these adjustments.

Apple Health provides workout duration and estimated active calories, but it does not directly measure the weights lifted, repetitions performed, or how close each set was to muscular failure. For this reason, the results cannot confirm whether my actual training intensity changed between the two periods.

Overall, the findings show that I continued strength training regularly while my daily active calorie expenditure decreased. This highlights why it is useful to look beyond structured workouts when examining changes in physical activity.

---

## 6. Limitations

This analysis is based on my personal Apple Health records across two 60-day periods. As a result, the findings describe changes in my own physical activity and cannot be generalised to other students. Although the periods were defined using documented dissertation milestones, these dates do not directly measure academic workload or stress levels.

Strength-training days were identified using recorded Traditional Strength Training sessions. However, a day without a strength-training record does not necessarily mean that no exercise took place. Unrecorded workouts would also be missing from the analysis. In addition, workout duration and active calories do not provide a complete picture of training intensity. The available data do not include the weights lifted, sets, repetitions, or proximity to muscular failure. Therefore, the analysis cannot confirm whether my actual training load changed between the two periods.

Active calorie expenditure is also an estimate rather than a direct measurement of physical activity or training effort. Multiple strength-training records on the same date were combined, but possible overlaps between workout records were not independently checked.

Finally, changes in daily activity may have been influenced by factors beyond dissertation work, including weather, transport availability, and personal routines. Some of my training adjustments may also have started before the selected analysis period. While my personal recollections provide useful background, they cannot establish what caused the observed differences. The analysis is descriptive and does not establish a causal relationship between dissertation demands and physical activity.

---

## 7. Conclusion

This analysis found that my strength-training routine remained relatively consistent between the Early and Intensive Dissertation periods, despite a small decrease in training frequency. Strength training was still recorded on more than half of the days during the Intensive Dissertation period, while mean and median training durations changed very little. However, workout-specific active calorie expenditure was lower, particularly when comparing median values.

In contrast, overall daily active calorie expenditure showed a more noticeable decline, with the mean decreasing by 9.46% and the median by 12.73%. The supplementary analysis also found lower mean daily active calories on both strength-training days and days without recorded strength training. Looking back, this pattern is consistent with changes in my daily routine, as I spent more time working on my dissertation and reduced other activities, such as shopping and walking around the city.

Although the findings cannot establish whether dissertation demands directly caused these changes, they highlight an important distinction between maintaining a regular workout routine and maintaining overall daily physical activity. For this reason, looking beyond recorded workouts provides a more complete picture of how my activity patterns differed between the two periods.
