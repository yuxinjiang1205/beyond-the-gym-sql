# Data Quality Assessment

## Objective

This stage aims to assess the quality and reliability of two datasets: `workouts_analysis` and `daily_activity_analysis`.

Using SQLite, a series of data quality checks were conducted to identify missing values, duplicate records, date discrepancies, inconsistent measurement units, and potentially anomalous numerical values.

The purpose of these assessments was to determine whether the datasets were suitable for subsequent analysis and to identify potential limitations that should be considered when interpreting the results.

## 1. Missing Values

Both datasets were examined for missing values using SQL.

Two types of checks were performed:

1. **NULL Value Detection:** The `IS NULL` condition was used to identify NULL values across all columns in both datasets.
2. **Empty String Detection:** The `TRIM()` function was used to identify empty strings or values containing only whitespace in text columns.

**Findings:**

- No NULL values were identified in either dataset.
- No empty strings or whitespace-only values were found in the examined text columns.

These results indicated that the selected columns did not contain NULL or empty-string values. However, the absence of NULL values does not necessarily guarantee that all expected records are present.

## 2. Potential Duplicate Rows

Both datasets were examined for potential duplicate records.

The `GROUP BY` clause was used to group records based on all columns within each dataset. The `HAVING COUNT(*) > 1` condition was then applied to identify groups containing more than one identical record.

**Findings:**

- No exact duplicate records were identified in `workouts_analysis`.
- No exact duplicate records were identified in `daily_activity_analysis`.

Additionally, the `dateComponents` column in `daily_activity_analysis` was examined to verify that each recorded date appeared only once.

No duplicate dates were identified.

These findings confirmed that no exact duplicate rows were detected and that the daily activity dataset contained no more than one record per recorded calendar date.

## 3. Recorded Period Check

This assessment aimed to verify whether the recorded dates were consistent with the study period defined in the project proposal.

The SQL `MIN()` and `MAX()` functions were used to identify the earliest and latest recorded dates.

**Study Period:** 6 September 2024 – 27 October 2026.

**Findings:**

The daily activity dataset covered the following date range:

- **Earliest Date:** `2024-09-06`
- **Latest Date:** `2026-10-27`

The recorded date range was consistent with the proposed study period.

However, confirming the earliest and latest dates does not establish whether every calendar date within the period has a corresponding record. Therefore, an additional date coverage assessment was conducted.

## 4. Date Discrepancy Check

This assessment aimed to determine whether the number of recorded dates matched the expected number of calendar days within the study period.

The SQLite `julianday()` function was used to convert dates into numerical values, allowing date arithmetic to calculate the total number of calendar days between the earliest and latest recorded dates.

The calculation included both the start and end dates.

**Findings:**

| Measurement | Result |
|---|---:|
| Expected Calendar Days | 782 |
| Recorded Daily Activity Dates | 781 |
| Missing Dates | 1 |

The results indicated that one calendar date was missing from `daily_activity_analysis`.

### 4.1 Missing Date Identification

An additional SQL query was used to identify the missing date.

```sql
SELECT
    date(dateComponents, '+1 day') AS missing_date
FROM daily_activity_analysis
WHERE dateComponents < (
    SELECT MAX(dateComponents)
    FROM daily_activity_analysis
)
AND date(dateComponents, '+1 day') NOT IN (
    SELECT dateComponents
    FROM daily_activity_analysis
);
```

**Query Logic:**

The query examines each recorded date and checks whether the following calendar day exists in the dataset.

The `date()` function, combined with the `'+1 day'` modifier, generates the next calendar date for each existing record.

The `NOT IN` condition compares these generated dates against all recorded dates in `daily_activity_analysis`. If the following calendar date is absent from the dataset, it is returned as a potential missing date.

Additionally, the condition:

```sql
WHERE dateComponents < (
    SELECT MAX(dateComponents)
    FROM daily_activity_analysis
)
```

excludes the final recorded date from the assessment. This prevents the query from incorrectly identifying the day after the study period as a missing date.

**Result:**

The query identified one missing date:

`2025-04-14`

**Methodological Limitation:**

This approach identifies the first missing date within a consecutive gap but cannot identify subsequent missing dates in the same gap.

For example, if two consecutive dates were missing, the query would identify the first missing date but not the second.

However, the earlier date coverage assessment established that only one calendar date was missing. Therefore, this approach was sufficient to identify the missing date in the current dataset.

### 4.2 Further Investigation

The missing date, `2025-04-14`, was further investigated across the available datasets.

No corresponding records were found in:

- `daily_activity_analysis`
- `daily_activity_full`
- `workouts_analysis`

The absence of this date from `daily_activity_full` indicated that the missing daily activity record was not introduced by the date filtering process.

However, the absence of a workout record does not necessarily indicate missing workout data, as workouts are not expected to occur every day.

The reason for the missing daily activity record remains unknown.

## 5. Measurement Unit Consistency Check

This assessment aimed to verify whether measurement units were consistent across all records in both datasets.

SQL aggregation using `GROUP BY` and `COUNT(*)` was performed to examine the distinct measurement units and their frequencies.

**Findings:**

| Measurement | Unit | Result |
|---|---|---|
| Workout Duration | min | Consistent |
| Workout Active Calories | kcal | Consistent |
| Daily Active Energy Burned | kcal | Consistent |

All examined measurement units were consistent across their respective datasets.

No inconsistent measurement units were identified.

## 6. Numerical Consistency Assessment

This assessment aimed to examine the validity and plausibility of numerical measurements in both datasets.

The SQL `MIN()` and `MAX()` functions were used to examine numerical ranges and identify potentially anomalous values.

Particular attention was given to negative values, unusually long workout durations, and daily activity measurements recorded as zero.

### 6.1 Workout Duration

Workout duration was examined to identify negative values and potentially unrealistic durations.

**Findings:**

- No negative or zero workout durations were identified.
- An unusually long workout duration of approximately **1,356 minutes (22.6 hours)** was identified on `2024-11-07`.
- The record was classified as a Walking workout.

Although this duration was unusually long, its cause could not be confirmed.

One possible explanation is that the workout recording was not stopped as intended. However, this remains a hypothesis rather than a verified explanation.

The record was therefore identified as a potential anomaly rather than automatically classified as invalid.

### 6.2 Workout Active Calories

The `active_calories` column in `workouts_analysis` was examined for numerical consistency.

**Findings:**

- No negative values were identified.
- All recorded workout active calorie values were greater than zero.

The basic numerical validation did not identify invalid negative values in this column.

### 6.3 Daily Active Energy Burned

The `activeEnergyBurned` column in `daily_activity_analysis` was examined for negative values and potentially unusual observations.

**Findings:**

- No negative values were identified.
- Two dates contained an `activeEnergyBurned` value of zero.

The dates were:

| Date | Active Energy Burned (kcal) | Exercise Time (min) | Stand Hours |
|---|---:|---:|---:|
| 2025-03-21 | 0 | 0 | 0 |
| 2026-01-11 | 0 | 0 | 0 |

Both dates also recorded zero exercise minutes and zero stand hours.

These observations may indicate that the Apple Watch was not worn or that activity measurements were incomplete on those dates.

However, the available data does not provide sufficient evidence to confirm either explanation.

Therefore, these records were identified as potentially incomplete observations rather than definitively invalid values.

### 6.4 Exercise Time and Stand Hours

The `appleExerciseTime` and `appleStandHours` columns in `daily_activity_analysis` were examined to assess their numerical ranges and identify potentially unusual observations.

The SQL `MIN()` and `MAX()` functions were used to identify the minimum and maximum values.

**Findings:**

| Measurement | Minimum | Maximum |
|---|---:|---:|
| Exercise Time | 0 min | 214 min |
| Stand Hours | 0 hours | 17 hours |

The highest recorded exercise time was **214 minutes**, observed on `2024-11-10`. On the same date, the daily active energy expenditure was approximately **1,208.18 kcal**, with 12 stand hours recorded.

The maximum recorded stand hours was 17. However, **this measurement represents the number of hourly intervals in which at least one minute of standing and movement was recorded, rather than the total duration spent standing.** Therefore, this value was not considered inherently anomalous.

Although the exercise duration was relatively high, there was insufficient evidence to classify this observation as invalid.

No negative values were identified in either column.

## 7. Data Quality Decisions

Following the data quality assessment, several observations were identified as potentially incomplete or anomalous.

However, the available information was insufficient to confirm whether these observations resulted from recording errors, missing measurements, or actual physical activity patterns.

Therefore, no records were removed, and no missing values were imputed during this assessment.

The following decisions were made:

| Finding | Decision | Justification |
|---|---|---|
| Missing daily activity record on `2025-04-14` | No replacement value was introduced. | Missing activity measurements do not necessarily indicate zero physical activity. |
| Walking workout lasting approximately 1,356 minutes | The record was retained and documented as a potential anomaly. | The unusually long duration may reflect a recording issue, but its cause could not be confirmed. |
| Two dates with zero daily active calories | Both records were retained and documented as potentially incomplete observations. | The absence of recorded activity may indicate non-wear or incomplete measurement, but this could not be verified. |

These decisions were made to avoid introducing unsupported assumptions or modifications into the datasets.

The identified limitations will be considered during subsequent analyses, particularly when interpreting differences in daily active calorie expenditure.

## 8. Conclusion

The Data Quality Assessment examined both `workouts_analysis` and `daily_activity_analysis` for missing values, duplicate records, date coverage, measurement unit consistency, and numerical plausibility.

Overall, the assessment did not identify any NULL values, empty strings, exact duplicate records, inconsistent measurement units, or negative numerical measurements.

**However, several potential data quality issues were identified,** including one missing daily activity date, an unusually long workout duration, and two dates with zero recorded daily activity measurements.

These observations were documented without modifying the underlying data, as their causes could not be confirmed.

**Based on the completed assessments, the datasets were considered sufficiently suitable for further analysis, provided that the identified limitations are acknowledged and considered when interpreting the results.**

The next stage will focus on data preparation, including the classification of gym and non-gym days and the integration of workout records with daily activity measurements.