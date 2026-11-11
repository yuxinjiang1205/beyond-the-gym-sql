/*
Beyond the Gym | RQ3

How did physical activity patterns differ across periods
of living in Canada, Taiwan, and Scotland?

Period: 2024-09-06 to 2026-10-27
Database: SQLite

Life stages:
- Canada:   2024-09-06 to 2025-04-22
- Taiwan:   2025-04-23 to 2025-09-14
- Scotland: 2025-09-15 to 2026-10-27

Note: Life stages represent broader periods of life rather
than exact geographical locations.
*/


-- 0. Schema Inspection: Review the relevant table structures.

PRAGMA table_info('daily_activity_analysis');

PRAGMA table_info('workouts_analysis');


-- 1. Life Stage Classification: Count daily observations in each stage.

WITH life_stage_classes AS (
    SELECT
        dateComponents AS date,
        CASE
            WHEN dateComponents <= '2025-04-22' THEN 'Canada'
            WHEN dateComponents <= '2025-09-14' THEN 'Taiwan'
            WHEN dateComponents <= '2026-10-27' THEN 'Scotland'
            ELSE 'Unclassified'
        END AS life_stage_classification
    FROM daily_activity_analysis
),

number_of_observations AS (
    SELECT
        life_stage_classification,
        COUNT(*) AS observations
    FROM life_stage_classes
    GROUP BY life_stage_classification
)

SELECT *
FROM number_of_observations
ORDER BY life_stage_classification;


-- 2. Descriptive Analysis: Calculate mean daily active calories by life stage.

WITH life_stage_classes AS (
    SELECT
        dateComponents AS date,
        CASE
            WHEN dateComponents <= '2025-04-22' THEN 'Canada'
            WHEN dateComponents <= '2025-09-14' THEN 'Taiwan'
            WHEN dateComponents <= '2026-10-27' THEN 'Scotland'
            ELSE 'Unclassified'
        END AS life_stage_classification,
        activeEnergyBurned AS daily_calorie_expenditure
    FROM daily_activity_analysis
),

observation_and_mean AS (
    SELECT
        life_stage_classification,
        COUNT(*) AS observations,
        ROUND(AVG(daily_calorie_expenditure), 2)
            AS mean_calorie_expenditure
    FROM life_stage_classes
    GROUP BY life_stage_classification
)

SELECT *
FROM observation_and_mean
ORDER BY life_stage_classification;


-- 3. Descriptive Analysis: Calculate median daily active calories by life stage.

WITH life_stage_classes AS (
    SELECT
        dateComponents AS date,
        CASE
            WHEN dateComponents <= '2025-04-22' THEN 'Canada'
            WHEN dateComponents <= '2025-09-14' THEN 'Taiwan'
            WHEN dateComponents <= '2026-10-27' THEN 'Scotland'
            ELSE 'Unclassified'
        END AS life_stage_classification,
        activeEnergyBurned AS daily_calorie_expenditure
    FROM daily_activity_analysis
),

numbered_table AS (
    SELECT
        date,
        life_stage_classification,
        daily_calorie_expenditure,
        ROW_NUMBER() OVER (
            PARTITION BY life_stage_classification
            ORDER BY daily_calorie_expenditure ASC
        ) AS row_num,
        COUNT(*) OVER (
            PARTITION BY life_stage_classification
        ) AS group_count
    FROM life_stage_classes
),

median_table AS (
    SELECT
        life_stage_classification,
        ROUND(AVG(daily_calorie_expenditure), 2)
            AS median_daily_active_calories
    FROM numbered_table
    WHERE row_num IN (
        (group_count + 1) / 2,
        (group_count + 2) / 2
    )
    GROUP BY life_stage_classification
)

SELECT *
FROM median_table
ORDER BY life_stage_classification;


-- 4. Strength-Training Frequency: Calculate recorded training-day percentages.

WITH life_stage_classes AS (
    SELECT
        dateComponents AS date,
        CASE
            WHEN dateComponents <= '2025-04-22' THEN 'Canada'
            WHEN dateComponents <= '2025-09-14' THEN 'Taiwan'
            WHEN dateComponents <= '2026-10-27' THEN 'Scotland'
            ELSE 'Unclassified'
        END AS life_stage_classification
    FROM daily_activity_analysis
),

workout_observations AS (
    SELECT DISTINCT
        SUBSTR(startDate, 1, 10) AS date
    FROM workouts_analysis
    WHERE workoutActivityType =
        'HKWorkoutActivityTypeTraditionalStrengthTraining'
),

joined_table AS (
    SELECT
        lsc.life_stage_classification,
        COUNT(*) AS observations,
        COUNT(wo.date) AS strength_training_days,
        ROUND(
            COUNT(wo.date) * 100.0 / COUNT(*), 2
        ) AS strength_training_day_percentage
    FROM life_stage_classes AS lsc
    LEFT JOIN workout_observations AS wo
        ON lsc.date = wo.date
    GROUP BY lsc.life_stage_classification
)

SELECT *
FROM joined_table
ORDER BY life_stage_classification;


-- 5. Monthly Analysis: Compare training frequency and daily active calories.

WITH life_stage_classes AS (
    SELECT
        dateComponents AS date,
        CASE
            WHEN dateComponents <= '2025-04-22' THEN 'Canada'
            WHEN dateComponents <= '2025-09-14' THEN 'Taiwan'
            WHEN dateComponents <= '2026-10-27' THEN 'Scotland'
            ELSE 'Unclassified'
        END AS life_stage_classification,
        activeEnergyBurned AS daily_calorie_expenditure
    FROM daily_activity_analysis
),

workout_observations AS (
    SELECT DISTINCT
        SUBSTR(startDate, 1, 10) AS date
    FROM workouts_analysis
    WHERE workoutActivityType =
        'HKWorkoutActivityTypeTraditionalStrengthTraining'
),

joined_table AS (
    SELECT
        lsc.life_stage_classification,
        SUBSTR(lsc.date, 1, 7) AS month,
        COUNT(*) AS observations,
        COUNT(wo.date) AS strength_training_days,
        ROUND(
            COUNT(wo.date) * 100.0 / COUNT(*), 2
        ) AS strength_training_day_percentage,
        ROUND(AVG(lsc.daily_calorie_expenditure), 2)
            AS monthly_mean_calorie_expenditure
    FROM life_stage_classes AS lsc
    LEFT JOIN workout_observations AS wo
        ON lsc.date = wo.date
    GROUP BY lsc.life_stage_classification, month
)

SELECT *
FROM joined_table
ORDER BY month, life_stage_classification;


-- 6. Monthly Duration Analysis: Calculate mean duration per training day.
-- Multiple strength-training records on the same date are combined.

WITH workout_records AS (
    SELECT
        SUBSTR(startDate, 1, 10) AS date,
        SUM(duration) AS daily_strength_training_duration
    FROM workouts_analysis
    WHERE workoutActivityType =
        'HKWorkoutActivityTypeTraditionalStrengthTraining'
    GROUP BY SUBSTR(startDate, 1, 10)
),

life_stage_classes AS (
    SELECT
        dateComponents AS date,
        CASE
            WHEN dateComponents <= '2025-04-22' THEN 'Canada'
            WHEN dateComponents <= '2025-09-14' THEN 'Taiwan'
            WHEN dateComponents <= '2026-10-27' THEN 'Scotland'
            ELSE 'Unclassified'
        END AS life_stage_classification
    FROM daily_activity_analysis
)

SELECT
    SUBSTR(lsc.date, 1, 7) AS month,
    lsc.life_stage_classification,
    COUNT(*) AS total_observations,
    COUNT(wr.date) AS strength_training_days,
    ROUND(
        AVG(wr.daily_strength_training_duration), 2
    ) AS mean_training_duration_min
FROM life_stage_classes AS lsc
LEFT JOIN workout_records AS wr
    ON lsc.date = wr.date
GROUP BY lsc.life_stage_classification, month
ORDER BY month, life_stage_classification;


-- 7. Overall Duration Analysis: Compare mean duration across life stages.
-- Only dates with recorded strength training contribute to the mean.

WITH workout_records AS (
    SELECT
        SUBSTR(startDate, 1, 10) AS date,
        SUM(duration) AS daily_strength_training_duration
    FROM workouts_analysis
    WHERE workoutActivityType =
        'HKWorkoutActivityTypeTraditionalStrengthTraining'
    GROUP BY SUBSTR(startDate, 1, 10)
),

life_stage_classes AS (
    SELECT
        dateComponents AS date,
        CASE
            WHEN dateComponents <= '2025-04-22' THEN 'Canada'
            WHEN dateComponents <= '2025-09-14' THEN 'Taiwan'
            WHEN dateComponents <= '2026-10-27' THEN 'Scotland'
            ELSE 'Unclassified'
        END AS life_stage_classification
    FROM daily_activity_analysis
)

SELECT
    lsc.life_stage_classification,
    COUNT(*) AS total_observations,
    COUNT(wr.date) AS strength_training_days,
    ROUND(
        AVG(wr.daily_strength_training_duration), 2
    ) AS mean_training_duration_min
FROM life_stage_classes AS lsc
LEFT JOIN workout_records AS wr
    ON lsc.date = wr.date
GROUP BY lsc.life_stage_classification
ORDER BY lsc.life_stage_classification;


-- 8. Median Duration Analysis: Compare median duration per training day.
-- INNER JOIN excludes dates without recorded strength-training activity.

WITH workout_records AS (
    SELECT
        SUBSTR(startDate, 1, 10) AS date,
        SUM(duration) AS daily_strength_training_duration
    FROM workouts_analysis
    WHERE workoutActivityType =
        'HKWorkoutActivityTypeTraditionalStrengthTraining'
    GROUP BY SUBSTR(startDate, 1, 10)
),

life_stage_classes AS (
    SELECT
        dateComponents AS date,
        CASE
            WHEN dateComponents <= '2025-04-22' THEN 'Canada'
            WHEN dateComponents <= '2025-09-14' THEN 'Taiwan'
            WHEN dateComponents <= '2026-10-27' THEN 'Scotland'
            ELSE 'Unclassified'
        END AS life_stage_classification
    FROM daily_activity_analysis
),

numbered_table AS (
    SELECT
        lsc.date,
        lsc.life_stage_classification,
        wr.daily_strength_training_duration,
        ROW_NUMBER() OVER (
            PARTITION BY lsc.life_stage_classification
            ORDER BY wr.daily_strength_training_duration ASC
        ) AS row_num,
        COUNT(*) OVER (
            PARTITION BY lsc.life_stage_classification
        ) AS group_count
    FROM life_stage_classes AS lsc
    INNER JOIN workout_records AS wr
        ON lsc.date = wr.date
)

SELECT
    life_stage_classification,
    ROUND(
        AVG(daily_strength_training_duration), 2
    ) AS median_training_duration_min
FROM numbered_table
WHERE row_num IN (
    (group_count + 1) / 2,
    (group_count + 2) / 2
)
GROUP BY life_stage_classification
ORDER BY life_stage_classification;


-- 9. Data Validation: Identify missing daily active calorie values.
-- Expected result: No records.

SELECT
    dateComponents AS date,
    activeEnergyBurned AS daily_calorie_expenditure
FROM daily_activity_analysis
WHERE activeEnergyBurned IS NULL;