/*
Beyond the Gym | RQ1
Do Gym Days have higher average daily active calorie expenditure
than Non-Gym Days?

Period: 2024-09-28 to 2026-10-27
Database: SQLite
*/


-- 1. Data Exploration: Check strength-training records before gym membership.

SELECT COUNT(*) AS observations
FROM workouts_analysis
WHERE workoutActivityType = 'HKWorkoutActivityTypeTraditionalStrengthTraining'
  AND SUBSTR(startDate, 1, 10) < '2024-09-28';


-- 2. Data Validation: Check for gym workouts without matching daily activity records.

SELECT COUNT(*) AS observations
FROM workouts_analysis AS wa
LEFT JOIN daily_activity_analysis AS daa
    ON SUBSTR(wa.startDate, 1, 10) = daa.dateComponents
WHERE wa.workoutActivityType = 'HKWorkoutActivityTypeTraditionalStrengthTraining'
  AND daa.dateComponents IS NULL
  AND SUBSTR(wa.startDate, 1, 10) >= '2024-09-28';


-- 3. Data Exploration: Count distinct Gym Days to avoid duplicate dates.

SELECT
    COUNT(DISTINCT SUBSTR(wa.startDate, 1, 10)) AS observations
FROM workouts_analysis AS wa
WHERE wa.workoutActivityType = 'HKWorkoutActivityTypeTraditionalStrengthTraining'
  AND SUBSTR(wa.startDate, 1, 10) >= '2024-09-28';


-- 4. Classification: Identify Gym Days (1) and Non-Gym Days (0).

WITH gym_date AS (
    SELECT DISTINCT
        SUBSTR(wa.startDate, 1, 10) AS date
    FROM workouts_analysis AS wa
    WHERE wa.workoutActivityType = 'HKWorkoutActivityTypeTraditionalStrengthTraining'
      AND SUBSTR(wa.startDate, 1, 10) >= '2024-09-28'
)

SELECT
    daa.dateComponents AS date,
    CASE WHEN gd.date IS NOT NULL THEN 1 ELSE 0 END AS gym_day,
    daa.activeEnergyBurned AS daily_active_calories
FROM daily_activity_analysis AS daa
LEFT JOIN gym_date AS gd
    ON daa.dateComponents = gd.date
WHERE daa.dateComponents >= '2024-09-28';


-- 5. Descriptive Analysis: Compare mean daily active calories and group sizes.

WITH gym_date AS (
    SELECT DISTINCT
        SUBSTR(wa.startDate, 1, 10) AS date
    FROM workouts_analysis AS wa
    WHERE wa.workoutActivityType = 'HKWorkoutActivityTypeTraditionalStrengthTraining'
      AND SUBSTR(wa.startDate, 1, 10) >= '2024-09-28'
)

SELECT
    COUNT(*) AS observations,
    CASE WHEN gd.date IS NOT NULL THEN 1 ELSE 0 END AS gym_day,
    AVG(daa.activeEnergyBurned) AS avg_daily_calorie_expenditure
FROM daily_activity_analysis AS daa
LEFT JOIN gym_date AS gd
    ON daa.dateComponents = gd.date
WHERE daa.dateComponents >= '2024-09-28'
GROUP BY gym_day;


-- 6. Descriptive Analysis: Calculate median daily active calories using window functions.

WITH gym_date AS (
    SELECT DISTINCT
        SUBSTR(wa.startDate, 1, 10) AS date
    FROM workouts_analysis AS wa
    WHERE wa.workoutActivityType = 'HKWorkoutActivityTypeTraditionalStrengthTraining'
      AND SUBSTR(wa.startDate, 1, 10) >= '2024-09-28'
),

daily_records AS (
    SELECT
        CASE WHEN gd.date IS NOT NULL THEN 1 ELSE 0 END AS gym_day,
        daa.activeEnergyBurned AS daily_calorie_expenditure
    FROM daily_activity_analysis AS daa
    LEFT JOIN gym_date AS gd
        ON daa.dateComponents = gd.date
    WHERE daa.dateComponents >= '2024-09-28'
),

ranked_daily_records AS (
    SELECT
        gym_day,
        daily_calorie_expenditure,
        ROW_NUMBER() OVER (
            PARTITION BY gym_day
            ORDER BY daily_calorie_expenditure ASC
        ) AS row_num,
        COUNT(*) OVER (
            PARTITION BY gym_day
        ) AS total_days
    FROM daily_records
)

SELECT
    gym_day,
    AVG(daily_calorie_expenditure) AS median_daily_calories
FROM ranked_daily_records
WHERE row_num IN (
    (total_days + 1) / 2,
    (total_days + 2) / 2
)
GROUP BY gym_day;


-- 7. Variability Analysis: Calculate sample variance, standard deviation, and CV.

WITH gym_date AS (
    SELECT DISTINCT
        SUBSTR(wa.startDate, 1, 10) AS date
    FROM workouts_analysis AS wa
    WHERE wa.workoutActivityType = 'HKWorkoutActivityTypeTraditionalStrengthTraining'
      AND SUBSTR(wa.startDate, 1, 10) >= '2024-09-28'
),

daily_records AS (
    SELECT
        CASE WHEN gd.date IS NOT NULL THEN 1 ELSE 0 END AS gym_day,
        daa.activeEnergyBurned AS daily_calorie_expenditure
    FROM daily_activity_analysis AS daa
    LEFT JOIN gym_date AS gd
        ON daa.dateComponents = gd.date
    WHERE daa.dateComponents >= '2024-09-28'
),

daily_records_with_group_mean AS (
    SELECT
        gym_day,
        daily_calorie_expenditure,
        AVG(daily_calorie_expenditure) OVER (
            PARTITION BY gym_day
        ) AS group_mean
    FROM daily_records
),

daily_squared_deviation AS (
    SELECT
        gym_day,
        daily_calorie_expenditure,
        group_mean,
        daily_calorie_expenditure - group_mean AS deviation_from_mean,
        (daily_calorie_expenditure - group_mean)
        * (daily_calorie_expenditure - group_mean) AS squared_deviation
    FROM daily_records_with_group_mean
)

SELECT
    gym_day,
    COUNT(*) AS total_days,
    SUM(squared_deviation) / (COUNT(*) - 1) AS sample_variance,
    SQRT(SUM(squared_deviation) / (COUNT(*) - 1)) AS sample_sd,
    SQRT(SUM(squared_deviation) / (COUNT(*) - 1))
        / AVG(daily_calorie_expenditure) * 100.0 AS cv_percentage
FROM daily_squared_deviation
GROUP BY gym_day;


-- 8. Additional Analysis: Count Non-Gym Days exceeding the Gym Day median (584.234 kcal).

WITH gym_date AS (
    SELECT DISTINCT
        SUBSTR(wa.startDate, 1, 10) AS date
    FROM workouts_analysis AS wa
    WHERE wa.workoutActivityType = 'HKWorkoutActivityTypeTraditionalStrengthTraining'
      AND SUBSTR(wa.startDate, 1, 10) >= '2024-09-28'
),

daily_records AS (
    SELECT
        CASE WHEN gd.date IS NOT NULL THEN 1 ELSE 0 END AS gym_day,
        daa.activeEnergyBurned AS daily_calorie_expenditure
    FROM daily_activity_analysis AS daa
    LEFT JOIN gym_date AS gd
        ON daa.dateComponents = gd.date
    WHERE daa.dateComponents >= '2024-09-28'
)

SELECT COUNT(*) AS observations
FROM daily_records
WHERE gym_day = 0
  AND daily_calorie_expenditure > 584.234;


-- 9. Exploratory Analysis: Identify dates with high Non-Gym Day activity.

WITH gym_date AS (
    SELECT DISTINCT
        SUBSTR(wa.startDate, 1, 10) AS date
    FROM workouts_analysis AS wa
    WHERE wa.workoutActivityType = 'HKWorkoutActivityTypeTraditionalStrengthTraining'
      AND SUBSTR(wa.startDate, 1, 10) >= '2024-09-28'
),

daily_records AS (
    SELECT
        daa.dateComponents AS activity_date,
        CASE WHEN gd.date IS NOT NULL THEN 1 ELSE 0 END AS gym_day,
        daa.activeEnergyBurned AS daily_calorie_expenditure
    FROM daily_activity_analysis AS daa
    LEFT JOIN gym_date AS gd
        ON daa.dateComponents = gd.date
    WHERE daa.dateComponents >= '2024-09-28'
)

SELECT *
FROM daily_records
WHERE gym_day = 0
  AND daily_calorie_expenditure > 584.234
ORDER BY activity_date;
