# RQ1: Gym Days vs Non-Gym Days — Daily Active Calorie Expenditure

## 1. Research Question

**Do gym days have higher average daily active calorie expenditure than non-gym days?**

This analysis investigates the relationship between recorded gym activity and daily active calorie expenditure using personal Apple Health data.

The primary hypothesis is that days with recorded gym activity are associated with higher average daily active calorie expenditure than days without recorded gym activity.

The analysis focuses on three aspects:

1. Differences in mean and median daily active calories.
2. Variation in daily active calorie expenditure between the two groups.
3. Whether non-gym days can exceed typical gym-day activity levels.

---

## 2. Data Preparation and Classification

### 2.1 Analysis Period

The analysis covers:

**28 September 2024 – 27 October 2026 (inclusive)**

The starting date was selected because gym membership began approximately on 28 September 2024.

Earlier workout records were excluded from RQ1 to maintain consistency with the intended gym-attendance classification.

Within this period:

- Expected calendar days: **760**
- Recorded daily activity observations: **759**
- Missing daily activity date: **14 April 2025**

The missing date was previously identified during the Data Quality Assessment and was not imputed.

### 2.2 Defining Gym Days

Gym attendance was approximated using Apple Health workout records classified as:

`HKWorkoutActivityTypeTraditionalStrengthTraining`

A **Gym Day** was defined as a recorded calendar date containing at least one Traditional Strength Training workout.

A **Non-Gym Day** was defined as a recorded calendar date without a corresponding Traditional Strength Training workout.

The classification was performed using SQL.

The `SUBSTR()` function extracted the recorded date from each workout's `startDate` field.

The `DISTINCT` keyword ensured that dates containing multiple strength-training records were counted only once.

A `LEFT JOIN` connected the resulting gym dates to the daily activity dataset.

Finally, a `CASE WHEN` expression assigned the following indicators:

| gym_day | Classification |
|---|---|
| 0 | Non-Gym Day |
| 1 | Gym Day |

This approach preserved daily activity observations regardless of whether a corresponding strength-training record existed.

**Methodological consideration:** Traditional Strength Training records serve as a proxy for gym attendance. They do not independently verify physical attendance at a gym, nor do they identify every possible form of exercise.

### 2.3 Measurement

The primary variable was:

`daily_activity_analysis.activeEnergyBurned`

This variable represents recorded daily active energy expenditure, measured in kilocalories (kcal).

Daily active calories were used instead of summing individual workout calories to avoid double-counting workout energy expenditure already reflected in the daily activity summary.

---

## 3. Descriptive Statistical Analysis

The analysis compared Gym Days and Non-Gym Days using:

- **Mean:** Average daily active calorie expenditure.
- **Median:** The middle value of daily active calorie expenditure.
- **Sample Variance:** The dispersion of squared deviations from the group mean.
- **Sample Standard Deviation (SD):** The dispersion of daily active calories around the group mean, expressed in kcal.
- **Coefficient of Variation (CV):** Standard deviation relative to the group mean, expressed as a percentage.

SQLite was used to perform the calculations.

Because the SQLite environment did not provide built-in median and standard deviation aggregate functions, these statistics were calculated using SQL operations, Common Table Expressions (CTEs), and window functions.

For the median, `ROW_NUMBER()` and `COUNT() OVER (PARTITION BY ...)` were used to identify the middle observation or observations within each group.

For sample standard deviation, the analysis calculated group means, individual deviations, squared deviations, and sample variance before applying `SQRT()`.

Sample variance used a denominator of `n - 1`, consistent with the sample standard deviation returned by R's `sd()` function.

---

## 4. Results

### 4.1 Descriptive Statistics

| Measurement | Non-Gym Days | Gym Days |
|---|---:|---:|
| Number of Days | 280 | 479 |
| Mean Daily Active Calories | 455.36 kcal | 642.06 kcal |
| Median Daily Active Calories | 415.73 kcal | 584.23 kcal |
| Sample Variance | 46,987.18 kcal² | 57,356.45 kcal² |
| Sample Standard Deviation | 216.77 kcal | 239.49 kcal |
| Coefficient of Variation | 47.60% | 37.30% |

### 4.2 Mean and Median Comparison

Gym Days recorded higher daily active calorie expenditure than Non-Gym Days.

The mean daily active calorie expenditure was:

- **642.06 kcal** on Gym Days.
- **455.36 kcal** on Non-Gym Days.

This represents a difference of approximately **186.71 kcal**, with Gym Days recording approximately **41.0% higher average daily active calorie expenditure**.

The median comparison showed a similar pattern:

- **584.23 kcal** on Gym Days.
- **415.73 kcal** on Non-Gym Days.

The median difference was approximately **168.51 kcal**.

Both measures of central tendency indicate that daily active calorie expenditure was generally higher on days containing recorded strength-training activity.

### 4.3 Variation in Daily Active Calories

Sample standard deviation was calculated to examine how widely daily active calorie expenditure varied around each group's mean.

The results showed:

- Non-Gym Days: **SD = 216.77 kcal**
- Gym Days: **SD = 239.49 kcal**

Gym Days had a higher absolute standard deviation, indicating greater dispersion in daily active calorie expenditure.

However, the difference between the two standard deviations was approximately **22.73 kcal**.

This suggests that the difference in absolute variation was less pronounced than the difference in average daily calorie expenditure.

To account for the different group means, the coefficient of variation was also considered.

The results showed:

- Non-Gym Days: **CV = 47.60%**
- Gym Days: **CV = 37.30%**

Although Gym Days exhibited greater absolute dispersion, Non-Gym Days demonstrated greater dispersion relative to their lower average daily active calorie expenditure.

These findings highlight the distinction between absolute and relative variability.

### 4.4 Distribution Considerations

In both groups, the mean exceeded the median.

This pattern may suggest that some relatively high daily active calorie observations influenced the group means.

However, the difference between the mean and median alone is insufficient to establish the direction or magnitude of skewness.

A more detailed distributional assessment would be needed to evaluate skewness.

## 4.5 High-Activity Non-Gym Days

To investigate whether substantial physical activity could occur without recorded strength training, Non-Gym Days were compared against the Gym Day median daily active calorie expenditure of **584.234 kcal**.

The SQL analysis identified:

- Total Non-Gym Days: **280**
- Non-Gym Days exceeding the Gym Day median: **60**
- Percentage of Non-Gym Days exceeding the threshold: **21.43%**

This indicates that approximately one in five Non-Gym Days recorded higher daily active calorie expenditure than the median Gym Day.

The findings demonstrate that substantial physical activity can occur without recorded strength-training activity.

### Temporal Patterns

An exploratory review of the 60 qualifying dates revealed that high-activity Non-Gym Days were not evenly distributed throughout the analysis period.

Several qualifying dates occurred during late 2024 and early 2025, while no Non-Gym Days exceeded the Gym Day median between May and August 2025.

Additional qualifying dates appeared during September and October 2026.

These patterns suggest that daily activity levels may vary across different periods and living circumstances.

However, the current analysis does not establish whether these differences were associated with travel, employment, geographical location, or other lifestyle factors.

Importantly, the absence of qualifying dates during a particular period does not necessarily indicate low overall physical activity, since this analysis only considered Non-Gym Days exceeding a specific threshold.

A more comprehensive comparison of activity levels across locations and travel periods would be required to investigate these possible explanations.

---

## 5. Discussion

The descriptive findings support the proposed hypothesis that Gym Days are associated with higher average daily active calorie expenditure.

Both mean and median comparisons consistently showed higher activity levels on Gym Days.

However, the variation analysis revealed an additional distinction.

Gym Days exhibited greater absolute variation in daily active calories, whereas Non-Gym Days exhibited greater relative variation.

One possible explanation is that daily physical activity reflects a combination of structured exercise and other activities throughout the day.

For instance, days without gym attendance may still involve substantial walking, travel, or other physically demanding activities.

Similarly, Gym Days may differ in workout duration, intensity, and additional daily movement.

These explanations are plausible but have not been independently verified within RQ1.

The results therefore describe observed differences rather than identifying the specific factors responsible for them.

---

## 6. Limitations

### 6.1 Gym Attendance Classification

Gym attendance was inferred from Traditional Strength Training records rather than directly verified.

Consequently, some days classified as Non-Gym Days may have involved other forms of exercise or unrecorded gym activity.

This classification should be interpreted as a practical proxy rather than a definitive measure of gym attendance.

### 6.2 Unequal Group Sizes

The analysis included:

- **479 Gym Days**
- **280 Non-Gym Days**

The difference reflects the observed frequency of strength-training activity during the study period.

Unequal group sizes do not invalidate the descriptive comparison, and no observations were removed merely to balance the groups.

However, differences in sample size should be considered when interpreting estimates and conducting any future inferential analysis.

### 6.3 Data Quality

One daily activity record was missing within the analysis period.

Additionally, two Non-Gym Days contained zero recorded daily active calories.

These zero values may reflect incomplete activity tracking or other recording circumstances, but their causes have not been confirmed.

The original observations were retained without modification.

Potentially unusual observations may influence statistics such as the mean, variance, and standard deviation.

### 6.4 Unmeasured Factors

Daily active calorie expenditure may be influenced by factors other than recorded gym activity, including:

- Daily walking and non-exercise movement.
- Workout duration and intensity.
- Travel and changes in daily routines.
- Differences in occupation, study schedules, and living environments.

These factors were not controlled for in the current comparison.

### 6.5 Observational Nature of the Data

This project uses observational data from a single individual.

The analysis does not establish a causal relationship between gym attendance and increased daily active calorie expenditure.

Furthermore, the present findings are descriptive. No statistical significance test was conducted on the full RQ1 dataset.

The results should therefore not be interpreted as evidence of a statistically significant difference or as proof that gym attendance caused the observed increase.

---

## 7. Conclusion

The analysis found that days containing recorded Traditional Strength Training activity were associated with higher daily active calorie expenditure than days without such records.

Gym Days recorded approximately **186.71 kcal more daily active energy expenditure on average**, representing an increase of approximately **41.0%** compared with Non-Gym Days.

The median comparison supported the same overall pattern.

Variation analysis revealed that Gym Days exhibited greater absolute dispersion, whereas Non-Gym Days demonstrated greater relative dispersion.

Furthermore, **60 out of 280 Non-Gym Days (21.43%)** exceeded the Gym Day median daily active calorie expenditure of 584.234 kcal.

This additional finding highlights that substantial daily physical activity is not exclusively associated with recorded strength-training sessions.

Overall, the descriptive results support the research hypothesis that Gym Days are associated with higher average daily active calorie expenditure.

However, the analysis does not establish a causal relationship between gym attendance and increased energy expenditure. Other daily activities and lifestyle factors may contribute to the observed differences.

---

## 8. RQ1 Completion Status

**Status: Completed**

The following analyses were successfully conducted using SQLite:

- Gym and Non-Gym Day classification.
- Mean and median daily active calorie comparisons.
- Sample variance and standard deviation calculations.
- Coefficient of variation comparison.
- Identification of high-activity Non-Gym Days.
- Calculation of the proportion of Non-Gym Days exceeding the Gym Day median.
- Exploratory examination of qualifying dates.

The analysis provides a descriptive answer to RQ1 and establishes a foundation for subsequent investigations into physical activity beyond structured exercise.

### Potential Extensions

Further analysis could examine:

- Distribution shapes and skewness.
- Differences in activity patterns across geographical locations.
- The relationship between travel and daily active calorie expenditure.

These investigations are outside the scope of the completed RQ1 analysis and may be explored in subsequent research questions.