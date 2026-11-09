# Data Understanding

## 1. Objective

This was the first stage of the project. The purpose of this stage was to understand the structure and contents of the original Apple Health dataset before selecting variables and preparing the data for SQL analysis.

The primary data source was `export.xml`, containing various health and physical activity records exported from Apple Health.

The investigation focused on understanding how the data was organised, identifying relevant measurements, and determining which variables could support the research questions.

## 2. Understanding XML Structure

Before inspecting the dataset, I reviewed several fundamental XML concepts:

* **XML (Extensible Markup Language):** A format used to store and organise structured information.
* **Element:** A component of an XML document, identified by a tag such as `<Workout>`.
* **Attribute:** Information stored within an element, such as `duration` or `startDate`.
* **Parent Element:** An element containing other elements.
* **Child Element:** An element nested within another element.
* **Hierarchical Structure:** The organisation of XML elements into parent-child relationships.

Unlike CSV files, XML documents can contain different types of records with distinct attributes and nested structures. Understanding these concepts was necessary before extracting data into a tabular format.

## 3. Initial Data Structure Inspection

I used Python's `xml.etree.ElementTree` library to inspect the complete `export.xml` file. Since the original XML file was large, I used `ET.iterparse()` to process it incrementally rather than loading the entire document into memory.

I also used `Counter` and `defaultdict` from Python's `collections` module to identify:

* The available XML elements.
* The attributes associated with each element.
* The hierarchical relationships between elements.
* The number of occurrences of each element.
* The different measurement types stored within `Record`.

### Inspection Results

| XML Element         |     Count | Description                                       |
| ------------------- | --------: | ------------------------------------------------- |
| `Record`            | 1,946,284 | Individual health measurements                    |
| `Workout`           |       546 | Individual workout sessions                       |
| `WorkoutStatistics` |     1,666 | Statistical measurements associated with workouts |
| `ActivitySummary`   |     1,364 | Daily activity summaries                          |

The inspection confirmed that different elements represented different levels of data granularity. For example, a single `Workout` could contain multiple `WorkoutStatistics` elements, while `ActivitySummary` represented daily activity information. Therefore, the differences in record counts did not necessarily indicate missing or inconsistent data.

## 4. Examining Actual Records

After understanding the overall XML structure, I inspected representative records to determine how measurements were stored.

### 4.1 Workout and WorkoutStatistics

I examined an individual `Workout` element and its associated `WorkoutStatistics` child elements.The inspection showed that `Workout` contained information such as:

* Workout activity type.
* Start and end times.
* Workout duration and its measurement unit.
* Recording device and data source.

The associated `WorkoutStatistics` contained measurements for the individual workout session. I then examined the statistical types available across the dataset.

| Workout Statistic        | Count |
| ------------------------ | ----: |
| Active Energy Burned     |   546 |
| Heart Rate               |   546 |
| Basal Energy Burned      |   546 |
| Walking/Running Distance |    27 |
| Cycling Distance         |     1 |

The inspection demonstrated that statistical attributes had different meanings depending on their measurement types. For example, `sum` represented accumulated energy expenditure, whereas `average`, `minimum`, and `maximum` described heart-rate measurements.

**Key Finding:** Workout statistics relate to **individual** workout sessions, rather than representing averages or totals across the entire study period.

### 4.2 ActivitySummary

I inspected individual `ActivitySummary` elements from different dates to understand how daily activity measurements were represented. The available attributes included:

* `dateComponents`
* `activeEnergyBurned`
* `activeEnergyBurnedUnit`
* `appleExerciseTime`
* `appleStandHours`
* Activity goal-related attributes. Such as `appleMoveTimeGoal`, `appleExerciseTimeGoal`, and `appleStandHoursGoal`

The inspection confirmed that `ActivitySummary` provided daily-level measurements, including active calorie expenditure, exercise minutes, and stand hours.

I also identified records dating back to 2022, before I began using an Apple Watch in September 2024. Some early activity records contained low values, suggesting that their completeness and suitability for analysis would require further investigation.

**Key Finding:** `ActivitySummary` is the most direct source for examining daily active calorie expenditure, which is the primary outcome of this project.

### 4.3 Record

I examined two measurement types stored within the `Record` element:

1. `HKQuantityTypeIdentifierStepCount`
2. `HKQuantityTypeIdentifierActiveEnergyBurned`

The inspection showed that individual records contained:

* Measurement type.
* Data source and device.
* Start and end times.
* Measurement value and unit.

Unlike `ActivitySummary`, these records represented measurements collected over specific time intervals. For example, an individual step-count record represented the number of steps recorded during a particular period, rather than the total number of steps taken during an entire day. I also found that Apple Health contained measurements recorded by an iPhone before I began using an Apple Watch.

**Key Finding:** Calculating daily step counts would require aggregating interval-level records while considering potentially overlapping measurements from different devices. For this reason, step-count analysis was postponed rather than introducing additional complexity into the initial project.

## 5. Variable Selection

Based on the research questions and the findings from Data Inspection, I selected the following variables for extraction. Two tables were generated:

### 5.1 Workout Dataset

| Selected Column       | XML Source        | Purpose                                                   |
| --------------------- | ----------------- | --------------------------------------------------------- |
| `startDate`           | Workout           | Identify workout dates and times                          |
| `workoutActivityType` | Workout           | Identify workout categories                               |
| `duration`            | Workout           | Measure workout duration                                  |
| `durationUnit`        | Workout           | Identify duration units                                   |
| `active_calories`     | WorkoutStatistics | Measure active calories burned during individual workouts |
| `calorie_unit`        | WorkoutStatistics | Identify energy units                                     |

The `active_calories` value was extracted from the `sum` attribute of the `WorkoutStatistics` element with the type `HKQuantityTypeIdentifierActiveEnergyBurned`. Heart-rate and basal-energy statistics were excluded because they were not required to answer the current research questions.

### 5.2 Daily Activity Dataset

| Selected Column          | XML Source      | Purpose                                  |
| ------------------------ | --------------- | ---------------------------------------- |
| `dateComponents`         | ActivitySummary | Identify observation dates               |
| `activeEnergyBurned`     | ActivitySummary | Measure daily active calorie expenditure |
| `activeEnergyBurnedUnit` | ActivitySummary | Identify energy units                    |
| `appleExerciseTime`      | ActivitySummary | Examine daily exercise minutes           |
| `appleStandHours`        | ActivitySummary | Examine daily stand-hour patterns        |

Exercise minutes and stand hours were retained to support comparisons across different lifestyle periods. Activity goal-related attributes were excluded because the study focused on actual activity measurements rather than goal achievement.

## 6. Data Extraction

Following variable selection, I used Python to extract the selected attributes from `export.xml`.

The extraction process used:

* `xml.etree.ElementTree` to parse the XML file.
* `csv.DictWriter` to write the selected attributes into CSV files.
* Incremental XML parsing to manage memory usage.

Two CSV files were generated:

| Output File               | Records | Columns |
| ------------------------- | ------: | ------: |
| `workouts_full.csv`       |     546 |       6 |
| `daily_activity_full.csv` |   1,364 |       5 |

The extraction preserved the selected values as provided in the original XML. No date filtering, numerical aggregation, rounding, or missing-value replacement was performed. The original XML file remained unchanged.

### 6.1 Date Filtering for Analysis

Following the initial extraction and validation, I applied date filtering to align the datasets with the study period defined in the project proposal.

**Study Period:** 6 September 2024 – 27 October 2026 (inclusive).

Two additional CSV files were generated:

| Output File                   | Description                                    |
| ----------------------------- | ---------------------------------------------- |
| `workouts_analysis.csv`       | Workout records within the study period        |
| `daily_activity_analysis.csv` | Daily activity records within the study period |

The filtering process retained records within the selected date range without modifying their original measurements. The original XML file and both unfiltered CSV files were preserved for reference and reproducibility.

## 7. Initial Extraction Validation

After generating the CSV files, I used Python's `csv.DictReader` to inspect their contents.

The validation included:

1. Counting the number of rows in each CSV.
2. Confirming the extracted column names.
3. Comparing selected values against previously inspected XML records.

### Validation Results

| Validation Check               | Result       |
| ------------------------------ | ------------ |
| Workout record count           | PASS — 546   |
| Daily activity record count    | PASS — 1,364 |
| Extracted column names         | PASS         |
| Sample workout date            | PASS         |
| Sample workout duration        | PASS         |
| Sample workout active calories | PASS         |
| Sample daily activity date     | PASS         |
| Sample daily active calories   | PASS         |

The CSV record counts matched the corresponding element counts in the original XML file. All sampled values also matched their expected values.

**Limitation:** These checks confirmed the initial extraction results but did not constitute a complete record-by-record validation.

### 7.1 Date Filtering for Analysis

Following the initial extraction and validation, I used Python to filter the datasets according to the study period defined in the project proposal.

**Study Period:** 6 September 2024 – 27 October 2026 (inclusive).

The filtering was performed using `csv.DictReader()` to read the original extracted CSV files. Records were retained if their dates fell within the specified range.

Two additional CSV files were generated:

| Output File                   | Records | Columns |
| ----------------------------- | ------: | ------: |
| `workouts_analysis.csv`       |     545 |       6 |
| `daily_activity_analysis.csv` |     781 |       5 |

The filtering process did not modify the original measurements, perform numerical aggregation, or replace missing values.

Both unfiltered CSV files and the original XML file were preserved.

The resulting datasets will undergo further data quality assessment before being used for analysis.

## 8. SQLite Import and Structure Inspection

The two CSV files were imported into SQLite using DBeaver. The resulting database contained:

* `workouts_full`
* `daily_activity_full`

I inspected the table structures to verify that the selected columns were present and that numerical variables had been assigned appropriate data types.

For example:

* Workout duration and active calories were stored as `REAL`.
* Daily active calories were stored as `REAL`.
* Exercise minutes and stand hours were stored as `INTEGER`.
* Date and time values were retained as text.

The initial database structure inspection did not identify any obvious schema-related issues.

However, a comprehensive assessment of imported values, missing data, duplicate records, and date coverage has not yet been completed.

## 9. Conclusion and Next Stage

The initial Data Understanding and Data Extraction stages have been completed.

Through this process, I:

* Examined the structure of the original Apple Health XML dataset.
* Identified the different levels of measurement within the data.
* Investigated actual workout, daily activity, and interval-level records.
* Selected variables based on the research objectives.
* Extracted the relevant data into two CSV files.
* Performed initial extraction validation.
* Imported the datasets into SQLite and inspected their table structures.
* Applied date filtering to create separate analysis datasets while preserving the full extracted datasets.

The next stage will focus on **Data Quality Assessment**, including missing values, duplicates, date coverage, measurement consistency, and the reliability of observations for the proposed research.
