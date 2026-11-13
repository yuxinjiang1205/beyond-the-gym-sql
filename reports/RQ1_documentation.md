# RQ1: Gym Days vs Non-Gym Days — Daily Active Calorie Expenditure

**Version:** 3   
**Author:** Peter Jiang (Yuxin Jiang)  
**Analysis Status:** Completed  
**Last Updated:** 13/11/2026  

---

## 1. Research Question

**Do gym days have higher average daily active calorie expenditure than non-gym days?**

This analysis investigates the relationship between gym attendance and daily active calorie expenditure using personal Apple Health data. As strength training has been a consistent part of my lifestyle, I wanted to examine how much recorded gym activity contributes to my overall daily activity levels and whether days without gym attendance necessarily involve lower active calorie expenditure. The primary hypothesis is that Gym Days are associated with higher average daily active calorie expenditure than Non-Gym Days.

The analysis addresses three aspects:

1. Differences in **mean** and **median** daily active calorie expenditure between Gym Days and Non-Gym Days.
2. Differences in the **variability** of daily active calorie expenditure between the two groups.
3. The proportion of Non-Gym Days that exceed the median active calorie expenditure recorded on Gym Days.

---

## 2. Data Preparation and Classification

### 2.1 Analysis Period

The analysis covers: **28 September 2024 – 27 October 2026 (inclusive)**

The starting date was selected because gym membership began approximately on 28 September 2024. Earlier workout records were excluded to maintain consistency with the study's gym-attendance classification.

Within the analysis period:

| Measurement | Value |
|---|---:|
| Expected Calendar Days | 760 |
| Recorded Daily Activity Observations | 759 |
| Missing Daily Activity Observations | 1 |

The missing observation occurred on **14 April 2025**. This missing record was identified during the Data Quality Assessment and was not imputed.

### 2.2 Gym Day Classification

Gym Days were identified using Apple Health workout records classified as: `HKWorkoutActivityTypeTraditionalStrengthTraining`

A **Gym Day** was defined as a recorded calendar date containing at least one Traditional Strength Training workout. Dates without a corresponding strength-training record were classified as **Non-Gym Days**.

The classification was implemented in SQL using:

- `SUBSTR()` to extract calendar dates from workout timestamps.
- `DISTINCT` to prevent multiple strength-training records on the same date from being counted as separate Gym Days.
- `LEFT JOIN` to connect distinct gym dates with the daily activity dataset.
- `CASE WHEN` to assign the Gym Day indicator.

The resulting classification was:

| gym_day | Classification |
|---|---|
| 0 | Non-Gym Day |
| 1 | Gym Day |

The `LEFT JOIN` preserved the available daily activity observations while allowing each recorded date to be classified according to the presence or absence of a Traditional Strength Training record.

### 2.3 Measurement

The primary variable was: `daily_activity_analysis.activeEnergyBurned`

This variable represents daily active energy expenditure recorded by Apple Health, measured in kilocalories (kcal). The analysis used daily active calories rather than summing individual workout calories, avoiding double-counting energy expenditure already included in the daily activity summary.

---

## 3. Descriptive Statistical Analysis

The analysis compared Gym Days and Non-Gym Days using the following descriptive statistics:

| Statistic | Purpose |
|---|---|
| Mean | Measure average daily active calorie expenditure |
| Median | Identify the middle value of each group's daily active calorie observations |
| Sample Variance | Measure squared deviations from the group mean |
| Sample Standard Deviation (SD) | Measure absolute dispersion around the mean in kcal |
| Coefficient of Variation (CV) | Compare dispersion relative to each group's mean |

All calculations were performed using SQLite.

### 3.1 Mean and Median

Mean daily active calorie expenditure was calculated using `AVG()`. Median values were calculated using Common Table Expressions (CTEs) and window functions. The analysis used `ROW_NUMBER()` to rank observations within each group and `COUNT() OVER (PARTITION BY gym_day)` to determine the number of observations. The middle observation or observations were identified according to group size, allowing the median calculation to accommodate both odd and even numbers of observations.

### 3.2 Variance and Standard Deviation

Sample variance was calculated from the squared deviations between individual observations and their respective group means. The calculation used **n − 1** as the denominator, consistent with the sample variance convention and the standard deviation calculated by R's `sd()` function. Sample standard deviation was then obtained by applying `SQRT()` to the calculated variance.

### 3.3 Coefficient of Variation

The coefficient of variation was calculated by dividing the sample standard deviation by the group mean and expressing the result as a percentage. This measure was included to compare relative variability between groups with different average daily active calorie expenditure.

### 3.4 High-Activity Non-Gym Days

An additional analysis examined how frequently Non-Gym Days exceeded the median daily active calorie expenditure recorded on Gym Days. The Gym Day median was used as the reference threshold. The analysis calculated the number and percentage of Non-Gym Days exceeding that threshold and reviewed the qualifying dates for potential temporal patterns.

---

## 4. Results

### 4.1 Descriptive Statistics

The analysis included **759 daily activity observations**, consisting of 479 Gym Days and 280 Non-Gym Days.

| Measurement | Non-Gym Days | Gym Days |
|---|---:|---:|
| Number of Days | 280 | 479 |
| Mean Daily Active Calories | 455.36 kcal | **642.06 kcal** |
| Median Daily Active Calories | 415.73 kcal | **584.23 kcal** |
| Sample Variance | 46,987.18 kcal² | 57,356.45 kcal² |
| Sample Standard Deviation | 216.77 kcal | 239.49 kcal |
| Coefficient of Variation | **47.60%** | 37.30% |

Gym Days recorded higher mean and median daily active calorie expenditure, while the variability measures revealed differences in absolute and relative dispersion.

### 4.2 Mean and Median Comparison

Gym Days recorded higher daily active calorie expenditure than Non-Gym Days. The mean daily active calorie expenditure was:

- **642.06 kcal** on Gym Days.
- **455.36 kcal** on Non-Gym Days.

This represents a difference of approximately **186.71 kcal per day**. Relative to Non-Gym Days, Gym Days recorded approximately **41.0% higher mean daily active calorie expenditure**.

The median comparison showed a similar pattern:

- **584.23 kcal** on Gym Days.
- **415.73 kcal** on Non-Gym Days.

The median difference was approximately **168.51 kcal**. Both measures of central tendency indicate that daily active calorie expenditure was generally higher on days containing recorded Traditional Strength Training activity. These findings support the primary research hypothesis.

### 4.3 Variation in Daily Active Calorie Expenditure

Sample standard deviation was used to compare the absolute dispersion of daily active calories within each group. The results were:

- **Gym Days: 239.49 kcal**
- **Non-Gym Days: 216.77 kcal**

Gym Days exhibited slightly greater absolute dispersion, with a standard deviation approximately **22.73 kcal higher** than that of Non-Gym Days. However, the coefficient of variation revealed a different pattern. The calculated CV values were:

- **Gym Days: 37.30%**
- **Non-Gym Days: 47.60%**

Although Gym Days had a higher absolute standard deviation, Non-Gym Days demonstrated greater dispersion relative to their lower mean daily active calorie expenditure. The difference between the two groups was approximately **10.30 percentage points**. This distinction suggests that Non-Gym Days were less consistent in relative terms, even though Gym Days exhibited slightly greater absolute variation.

### 4.4 Distribution Considerations

In both groups, the mean exceeded the median.

| Group | Mean | Median |
|---|---:|---:|
| Non-Gym Days | 455.36 kcal | 415.73 kcal |
| Gym Days | 642.06 kcal | 584.23 kcal |

The difference between the mean and median suggests that relatively high daily active calorie observations may have contributed to the arithmetic means. A detailed assessment of distribution shape and skewness was not included in the primary analysis.

### 4.5 High-Activity Non-Gym Days

To investigate whether substantial daily physical activity occurred without recorded strength training, Non-Gym Days were compared against the Gym Day median of: **584.234 kcal**

The analysis identified:

| Measurement | Result |
|---|---:|
| Total Non-Gym Days | 280 |
| Non-Gym Days Exceeding the Gym Day Median | 60 |
| Percentage of Non-Gym Days Exceeding the Threshold | **21.43%** |

Approximately **one in five Non-Gym Days** recorded higher daily active calorie expenditure than the median Gym Day. This finding highlights that substantial daily physical activity can occur without a recorded strength-training session.

#### Temporal Patterns

An exploratory review of the 60 qualifying dates identified differences across the analysis period. Several high-activity Non-Gym Days occurred during late 2024 and early 2025. Between **May and August 2025**, no Non-Gym Days exceeded the Gym Day median threshold. Further qualifying dates appeared during September and October 2026.

These observations indicate that high-activity Non-Gym Days were not evenly distributed across the study period. The temporal findings provide a starting point for subsequent analyses examining how travel, geographical location, and changes in daily routines relate to recorded physical activity.

---

## 5. Discussion

The findings support the primary hypothesis that Gym Days are associated with higher daily active calorie expenditure. Gym Days recorded approximately **41.0% higher mean daily active calories** than Non-Gym Days, and the median comparison demonstrated a similar difference. These findings are consistent with the expectation that days containing structured strength training generally involve higher recorded daily active energy expenditure.

However, the analysis also revealed important differences within the two groups. Gym Days exhibited slightly greater absolute variability, while Non-Gym Days showed greater relative variability. This suggests that daily active calorie expenditure on Non-Gym Days may depend more heavily on other activities and daily circumstances, although the present analysis does not identify the specific contributors to that variation.

The high-activity Non-Gym Day analysis provides further context. **60 of the 280 Non-Gym Days (21.43%) exceeded the Gym Day median**, demonstrating that the absence of a recorded strength-training session does not necessarily correspond to low daily active calorie expenditure. Daily activities such as walking, travel, commuting, and other forms of movement may contribute to recorded active calories outside structured exercise sessions.

This finding is particularly relevant to the motivation behind *Beyond the Gym*. Although gym attendance is an important part of my lifestyle, the results suggest that overall daily activity is influenced by a broader range of experiences.

RQ1 therefore establishes two complementary findings:

- **First, Gym Days generally recorded higher daily active calorie expenditure.**
- **Second, a meaningful proportion of Non-Gym Days still achieved activity levels exceeding those of a typical Gym Day.**

Together, these findings provide the foundation for RQ2, which examines whether extended travel periods are associated with higher daily active calorie expenditure on days without recorded strength training.

---

## 6. Limitations

### 6.1 Gym Day Classification Scope

Gym Days were classified using Apple Health records labelled `HKWorkoutActivityTypeTraditionalStrengthTraining`. The classification therefore focuses specifically on recorded strength-training activity rather than every possible form of physical exercise. Other activities, including walking or alternative workout types, may occur on days classified as Non-Gym Days. This distinction is relevant when interpreting the differences between the two groups.

### 6.2 Unequal Group Sizes

The analysis included **479 Gym Days** and **280 Non-Gym Days**. These differences reflect the observed frequency of strength-training activity throughout the study period. Unequal group sizes do not invalidate the descriptive comparison, and no observations were removed to balance the groups. However, group sizes should be considered when interpreting estimates or conducting future inferential analysis.

### 6.3 Data Quality

The analysis period contained one missing daily activity observation, dated **14 April 2025**. Two Non-Gym Days also contained zero recorded daily active calories. The original recorded values were retained without modification, and the missing observation was not imputed. These recording characteristics may influence the calculated descriptive statistics. The data quality findings and treatment decisions are documented separately in the Data Quality Assessment.

### 6.4 Observational Study Design

The analysis uses observational Apple Health data collected from a single individual. Daily active calorie expenditure reflects a combination of structured exercise and other activities throughout the day. The comparison does not isolate the energy expenditure attributable specifically to strength-training sessions or control for all differences in daily routines. Accordingly, the findings describe observed associations between recorded gym activity and daily active calorie expenditure rather than establishing a direct causal effect.

No statistical significance test was conducted on the full RQ1 dataset. The results are therefore presented as descriptive findings specific to the available personal data.

---

## 7. Conclusion

RQ1 investigated whether Gym Days recorded higher daily active calorie expenditure than Non-Gym Days. The analysis found that Gym Days recorded approximately **186.71 kcal higher mean daily active calorie expenditure**, representing an increase of **41.0%** compared with Non-Gym Days. The median comparison supported the same pattern, with Gym Days recording a median of **584.23 kcal**, compared with **415.73 kcal** for Non-Gym Days.

Variability analysis revealed that Gym Days exhibited slightly greater absolute dispersion, while Non-Gym Days demonstrated greater relative dispersion. An additional analysis identified **60 Non-Gym Days (21.43%)** with daily active calorie expenditure exceeding the Gym Day median. These findings suggest that although recorded strength-training activity is associated with higher daily active calorie expenditure, substantial physical activity can also occur on days without gym attendance.

Overall, RQ1 supports the primary research hypothesis while highlighting the importance of considering physical activity beyond structured exercise. The findings establish a foundation for subsequent research questions exploring how travel, daily routines, and different life circumstances relate to recorded active calorie expenditure.
