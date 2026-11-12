/*
Beyond the Gym | RQ4

How did strength-training behaviour and daily physical
activity differ between the early and intensive dissertation periods?

Period: 2026-05-01 to 2026-08-28
Database: SQLite

Dissertation Periods:
- Early Dissertation:     2026-05-01 to 2026-06-29
- Intensive Dissertation: 2026-06-30 to 2026-08-28

Note: Each period contains 60 calendar days.
The periods were defined using documented academic
milestones rather than observed physical activity outcomes.
*/


-- 0. Schema Inspection: Review the relevant table structures.

PRAGMA table_info('daily_activity_analysis');

PRAGMA table_info('workouts_analysis');


-- 1. Period Validation: Check daily observations and missing values.
-- Each dissertation period should contain 60 unique daily observations.

WITH dissertation_period AS (
    SELECT
        dateComponents AS date,
        CASE
            WHEN dateComponents BETWEEN '2026-05-01' AND '2026-06-29'
                THEN 'Early Dissertation'
            WHEN dateComponents BETWEEN '2026-06-30' AND '2026-08-28'
                THEN 'Intensive Dissertation'
        END AS dissertation_period,
        activeEnergyBurned AS daily_calorie_expenditure
    FROM daily_activity_analysis
    WHERE dateComponents BETWEEN '2026-05-01' AND '2026-08-28'
)

SELECT
    dissertation_period,
    COUNT(*) AS observations,
    COUNT(DISTINCT date) AS unique_dates,
    SUM(
        CASE
            WHEN daily_calorie_expenditure IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_calorie_values
FROM dissertation_period
GROUP BY dissertation_period
ORDER BY dissertation_period;


-- 2. Strength-Training Frequency: Compare recorded training-day percentages.
-- LEFT JOIN preserves dates without recorded strength training.
-- Multiple strength-training records on the same date count as one day.

WITH dissertation_period AS (
    SELECT
        dateComponents AS date,
        CASE
            WHEN dateComponents BETWEEN '2026-05-01' AND '2026-06-29'
                THEN 'Early Dissertation'
            WHEN dateComponents BETWEEN '2026-06-30' AND '2026-08-28'
                THEN 'Intensive Dissertation'
        END AS dissertation_period
    FROM daily_activity_analysis
    WHERE dateComponents BETWEEN '2026-05-01' AND '2026-08-28'
),

strength_training_dates AS (
    SELECT DISTINCT
        SUBSTR(startDate, 1, 10) AS date
    FROM workouts_analysis
    WHERE workoutActivityType =
        'HKWorkoutActivityTypeTraditionalStrengthTraining'
),

joined_table AS (
    SELECT
        dp.date,
        dp.dissertation_period,
        CASE
            WHEN std.date IS NOT NULL THEN 1
            ELSE 0
        END AS strength_training_day
    FROM dissertation_period AS dp
    LEFT JOIN strength_training_dates AS std
        ON dp.date = std.date
)

SELECT
    dissertation_period,
    COUNT(*) AS observations,
    SUM(strength_training_day) AS strength_training_days,
    COUNT(*) - SUM(strength_training_day)
        AS days_without_strength_training,
    ROUND(
        SUM(strength_training_day) * 100.0 / COUNT(*), 2
    ) AS strength_training_day_percentage
FROM joined_table
GROUP BY dissertation_period
ORDER BY dissertation_period;


-- 3. Workout Descriptive Analysis: Compare mean duration and active calories.
-- Multiple workouts on the same date are combined before calculating means.
-- Only recorded strength-training days contribute to these calculations.

WITH dissertation_period AS (
    SELECT
        dateComponents AS date,
        CASE
            WHEN dateComponents BETWEEN '2026-05-01' AND '2026-06-29'
                THEN 'Early Dissertation'
            WHEN dateComponents BETWEEN '2026-06-30' AND '2026-08-28'
                THEN 'Intensive Dissertation'
        END AS dissertation_period
    FROM daily_activity_analysis
    WHERE dateComponents BETWEEN '2026-05-01' AND '2026-08-28'
),

daily_strength_training AS (
    SELECT
        SUBSTR(startDate, 1, 10) AS date,
        SUM(duration) AS daily_training_duration,
        SUM(active_calories) AS daily_workout_active_calories
    FROM workouts_analysis
    WHERE workoutActivityType =
        'HKWorkoutActivityTypeTraditionalStrengthTraining'
    GROUP BY SUBSTR(startDate, 1, 10)
),

joined_table AS (
    SELECT
        dp.dissertation_period,
        dst.daily_training_duration,
        dst.daily_workout_active_calories
    FROM dissertation_period AS dp
    INNER JOIN daily_strength_training AS dst
        ON dp.date = dst.date
)

SELECT
    dissertation_period,
    COUNT(*) AS strength_training_days,
    ROUND(
        AVG(daily_training_duration), 2
    ) AS mean_training_duration_min,
    ROUND(
        AVG(daily_workout_active_calories), 2
    ) AS mean_workout_active_calories
FROM joined_table
GROUP BY dissertation_period
ORDER BY dissertation_period;


-- 4. Median Duration Analysis: Compare training duration per recorded training day.
-- INNER JOIN excludes dates without recorded strength training.

WITH dissertation_period AS (
    SELECT
        dateComponents AS date,
        CASE
            WHEN dateComponents BETWEEN '2026-05-01' AND '2026-06-29'
                THEN 'Early Dissertation'
            WHEN dateComponents BETWEEN '2026-06-30' AND '2026-08-28'
                THEN 'Intensive Dissertation'
        END AS dissertation_period
    FROM daily_activity_analysis
    WHERE dateComponents BETWEEN '2026-05-01' AND '2026-08-28'
),

daily_strength_training AS (
    SELECT
        SUBSTR(startDate, 1, 10) AS date,
        SUM(duration) AS daily_training_duration
    FROM workouts_analysis
    WHERE workoutActivityType =
        'HKWorkoutActivityTypeTraditionalStrengthTraining'
    GROUP BY SUBSTR(startDate, 1, 10)
),

ranked_training_days AS (
    SELECT
        dp.dissertation_period,
        dst.daily_training_duration,
        ROW_NUMBER() OVER (
            PARTITION BY dp.dissertation_period
            ORDER BY dst.daily_training_duration ASC
        ) AS row_num,
        COUNT(*) OVER (
            PARTITION BY dp.dissertation_period
        ) AS group_count
    FROM dissertation_period AS dp
    INNER JOIN daily_strength_training AS dst
        ON dp.date = dst.date
)

SELECT
    dissertation_period,
    ROUND(
        AVG(daily_training_duration), 2
    ) AS median_training_duration_min
FROM ranked_training_days
WHERE row_num IN (
    (group_count + 1) / 2,
    (group_count + 2) / 2
)
GROUP BY dissertation_period
ORDER BY dissertation_period;


-- 5. Median Workout Calories: Compare active calories per recorded training day.
-- Workout-specific calories are aggregated by date before ranking.

WITH dissertation_period AS (
    SELECT
        dateComponents AS date,
        CASE
            WHEN dateComponents BETWEEN '2026-05-01' AND '2026-06-29'
                THEN 'Early Dissertation'
            WHEN dateComponents BETWEEN '2026-06-30' AND '2026-08-28'
                THEN 'Intensive Dissertation'
        END AS dissertation_period
    FROM daily_activity_analysis
    WHERE dateComponents BETWEEN '2026-05-01' AND '2026-08-28'
),

daily_strength_training AS (
    SELECT
        SUBSTR(startDate, 1, 10) AS date,
        SUM(active_calories) AS daily_workout_active_calories
    FROM workouts_analysis
    WHERE workoutActivityType =
        'HKWorkoutActivityTypeTraditionalStrengthTraining'
    GROUP BY SUBSTR(startDate, 1, 10)
),

ranked_training_days AS (
    SELECT
        dp.dissertation_period,
        dst.daily_workout_active_calories,
        ROW_NUMBER() OVER (
            PARTITION BY dp.dissertation_period
            ORDER BY dst.daily_workout_active_calories ASC
        ) AS row_num,
        COUNT(*) OVER (
            PARTITION BY dp.dissertation_period
        ) AS group_count
    FROM dissertation_period AS dp
    INNER JOIN daily_strength_training AS dst
        ON dp.date = dst.date
)

SELECT
    dissertation_period,
    ROUND(
        AVG(daily_workout_active_calories), 2
    ) AS median_workout_active_calories
FROM ranked_training_days
WHERE row_num IN (
    (group_count + 1) / 2,
    (group_count + 2) / 2
)
GROUP BY dissertation_period
ORDER BY dissertation_period;


-- 6. Daily Activity Analysis: Compare mean daily active calories.
-- All recorded days are included, regardless of strength-training status.

WITH dissertation_period AS (
    SELECT
        dateComponents AS date,
        CASE
            WHEN dateComponents BETWEEN '2026-05-01' AND '2026-06-29'
                THEN 'Early Dissertation'
            WHEN dateComponents BETWEEN '2026-06-30' AND '2026-08-28'
                THEN 'Intensive Dissertation'
        END AS dissertation_period,
        activeEnergyBurned AS daily_calorie_expenditure
    FROM daily_activity_analysis
    WHERE dateComponents BETWEEN '2026-05-01' AND '2026-08-28'
)

SELECT
    dissertation_period,
    COUNT(*) AS observations,
    ROUND(
        AVG(daily_calorie_expenditure), 2
    ) AS mean_daily_active_calories
FROM dissertation_period
GROUP BY dissertation_period
ORDER BY dissertation_period;


-- 7. Median Daily Activity: Compare daily active calories across all days.
-- No workout JOIN is needed because every daily observation is included.

WITH dissertation_period AS (
    SELECT
        dateComponents AS date,
        CASE
            WHEN dateComponents BETWEEN '2026-05-01' AND '2026-06-29'
                THEN 'Early Dissertation'
            WHEN dateComponents BETWEEN '2026-06-30' AND '2026-08-28'
                THEN 'Intensive Dissertation'
        END AS dissertation_period,
        activeEnergyBurned AS daily_calorie_expenditure
    FROM daily_activity_analysis
    WHERE dateComponents BETWEEN '2026-05-01' AND '2026-08-28'
),

ranked_daily_activity AS (
    SELECT
        dissertation_period,
        daily_calorie_expenditure,
        ROW_NUMBER() OVER (
            PARTITION BY dissertation_period
            ORDER BY daily_calorie_expenditure ASC
        ) AS row_num,
        COUNT(*) OVER (
            PARTITION BY dissertation_period
        ) AS group_count
    FROM dissertation_period
)

SELECT
    dissertation_period,
    ROUND(
        AVG(daily_calorie_expenditure), 2
    ) AS median_daily_active_calories
FROM ranked_daily_activity
WHERE row_num IN (
    (group_count + 1) / 2,
    (group_count + 2) / 2
)
GROUP BY dissertation_period
ORDER BY dissertation_period;


-- 8. Supplementary Analysis: Compare mean daily active calories by training status.
-- Both recorded strength-training days and other days are included.
-- The calorie values represent total daily active calories, not workout calories.

WITH dissertation_period AS (
    SELECT
        dateComponents AS date,
        CASE
            WHEN dateComponents BETWEEN '2026-05-01' AND '2026-06-29'
                THEN 'Early Dissertation'
            WHEN dateComponents BETWEEN '2026-06-30' AND '2026-08-28'
                THEN 'Intensive Dissertation'
        END AS dissertation_period,
        activeEnergyBurned AS daily_calorie_expenditure
    FROM daily_activity_analysis
    WHERE dateComponents BETWEEN '2026-05-01' AND '2026-08-28'
),

strength_training_dates AS (
    SELECT DISTINCT
        SUBSTR(startDate, 1, 10) AS date
    FROM workouts_analysis
    WHERE workoutActivityType =
        'HKWorkoutActivityTypeTraditionalStrengthTraining'
),

joined_table AS (
    SELECT
        dp.date,
        dp.dissertation_period,
        dp.daily_calorie_expenditure,
        CASE
            WHEN std.date IS NOT NULL THEN 1
            ELSE 0
        END AS strength_training_day
    FROM dissertation_period AS dp
    LEFT JOIN strength_training_dates AS std
        ON dp.date = std.date
)

SELECT
    dissertation_period,
    strength_training_day,
    COUNT(*) AS observations,
    ROUND(
        AVG(daily_calorie_expenditure), 2
    ) AS mean_daily_active_calories
FROM joined_table
GROUP BY dissertation_period, strength_training_day
ORDER BY dissertation_period, strength_training_day;


-- 9. Supplementary Median Analysis: Compare daily active calories on training days.
-- Only dates with recorded strength training are included.
-- This measures total daily active calories, not workout-specific calories.

WITH dissertation_period AS (
    SELECT
        dateComponents AS date,
        CASE
            WHEN dateComponents BETWEEN '2026-05-01' AND '2026-06-29'
                THEN 'Early Dissertation'
            WHEN dateComponents BETWEEN '2026-06-30' AND '2026-08-28'
                THEN 'Intensive Dissertation'
        END AS dissertation_period,
        activeEnergyBurned AS daily_calorie_expenditure
    FROM daily_activity_analysis
    WHERE dateComponents BETWEEN '2026-05-01' AND '2026-08-28'
),

strength_training_dates AS (
    SELECT DISTINCT
        SUBSTR(startDate, 1, 10) AS date
    FROM workouts_analysis
    WHERE workoutActivityType =
        'HKWorkoutActivityTypeTraditionalStrengthTraining'
),

ranked_training_days AS (
    SELECT
        dp.dissertation_period,
        dp.daily_calorie_expenditure,
        ROW_NUMBER() OVER (
            PARTITION BY dp.dissertation_period
            ORDER BY dp.daily_calorie_expenditure ASC
        ) AS row_num,
        COUNT(*) OVER (
            PARTITION BY dp.dissertation_period
        ) AS group_count
    FROM dissertation_period AS dp
    INNER JOIN strength_training_dates AS std
        ON dp.date = std.date
)

SELECT
    dissertation_period,
    ROUND(
        AVG(daily_calorie_expenditure), 2
    ) AS median_training_day_daily_calories
FROM ranked_training_days
WHERE row_num IN (
    (group_count + 1) / 2,
    (group_count + 2) / 2
)
GROUP BY dissertation_period
ORDER BY dissertation_period;