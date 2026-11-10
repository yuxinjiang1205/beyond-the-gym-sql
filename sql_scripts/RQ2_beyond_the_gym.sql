/*
Beyond the Gym | RQ2

Do Non-Gym Days during extended travel periods have higher
daily activity levels than ordinary Non-Gym Days?

Period: 2024-09-28 to 2026-10-27
Database: SQLite

Travel Periods:
1. France and London: 2024-12-04 to 2024-12-17
2. Italy: 2025-04-06 to 2025-04-22
3. UK Family Trip: 2026-09-25 to 2026-10-08
*/


-- 1. Travel Day Classification: Identify recorded days within the three travel periods.

WITH travel_days AS (
    SELECT
        dateComponents AS date,
        CASE
            WHEN dateComponents BETWEEN '2024-12-04' AND '2024-12-17'
              OR dateComponents BETWEEN '2025-04-06' AND '2025-04-22'
              OR dateComponents BETWEEN '2026-09-25' AND '2026-10-08'
            THEN 1
            ELSE 0
        END AS travel_day
    FROM daily_activity_analysis
    WHERE dateComponents >= '2024-09-28'
)

SELECT
    COUNT(*) AS observations
FROM travel_days
WHERE travel_day = 1;


-- 2. Data Validation: Reproduce Gym Day and Non-Gym Day counts from RQ1.

WITH travel_days AS (
    SELECT
        dateComponents AS date,
        CASE
            WHEN dateComponents BETWEEN '2024-12-04' AND '2024-12-17'
              OR dateComponents BETWEEN '2025-04-06' AND '2025-04-22'
              OR dateComponents BETWEEN '2026-09-25' AND '2026-10-08'
            THEN 1
            ELSE 0
        END AS travel_day
    FROM daily_activity_analysis
    WHERE dateComponents >= '2024-09-28'
),

gym_date AS (
    SELECT DISTINCT
        SUBSTR(startDate, 1, 10) AS date
    FROM workouts_analysis
    WHERE workoutActivityType = 'HKWorkoutActivityTypeTraditionalStrengthTraining'
),

joined_table AS (
    SELECT
        td.date,
        td.travel_day,
        CASE
            WHEN gd.date IS NOT NULL THEN 1
            ELSE 0
        END AS gym_day
    FROM travel_days AS td
    LEFT JOIN gym_date AS gd
        ON td.date = gd.date
)

SELECT
    gym_day,
    COUNT(*) AS observations
FROM joined_table
GROUP BY gym_day
ORDER BY gym_day;


-- 3. Comparison Group Validation: Count Travel and Non-Travel observations among Non-Gym Days.

WITH travel_days AS (
    SELECT
        dateComponents AS date,
        CASE
            WHEN dateComponents BETWEEN '2024-12-04' AND '2024-12-17'
              OR dateComponents BETWEEN '2025-04-06' AND '2025-04-22'
              OR dateComponents BETWEEN '2026-09-25' AND '2026-10-08'
            THEN 1
            ELSE 0
        END AS travel_day
    FROM daily_activity_analysis
    WHERE dateComponents >= '2024-09-28'
),

gym_date AS (
    SELECT DISTINCT
        SUBSTR(startDate, 1, 10) AS date
    FROM workouts_analysis
    WHERE workoutActivityType = 'HKWorkoutActivityTypeTraditionalStrengthTraining'
),

joined_table AS (
    SELECT
        td.date,
        td.travel_day,
        CASE
            WHEN gd.date IS NOT NULL THEN 1
            ELSE 0
        END AS gym_day
    FROM travel_days AS td
    LEFT JOIN gym_date AS gd
        ON td.date = gd.date
)

SELECT
    travel_day,
    COUNT(*) AS observations
FROM joined_table
WHERE gym_day = 0
GROUP BY travel_day
ORDER BY travel_day;


-- 4. Descriptive Analysis: Compare mean daily active calories between the two Non-Gym groups.

WITH travel_days AS (
    SELECT
        dateComponents AS date,
        CASE
            WHEN dateComponents BETWEEN '2024-12-04' AND '2024-12-17'
              OR dateComponents BETWEEN '2025-04-06' AND '2025-04-22'
              OR dateComponents BETWEEN '2026-09-25' AND '2026-10-08'
            THEN 1
            ELSE 0
        END AS travel_day,
        activeEnergyBurned AS daily_active_calories
    FROM daily_activity_analysis
    WHERE dateComponents >= '2024-09-28'
),

gym_date AS (
    SELECT DISTINCT
        SUBSTR(startDate, 1, 10) AS date
    FROM workouts_analysis
    WHERE workoutActivityType = 'HKWorkoutActivityTypeTraditionalStrengthTraining'
),

joined_table AS (
    SELECT
        td.date,
        td.travel_day,
        CASE
            WHEN gd.date IS NOT NULL THEN 1
            ELSE 0
        END AS gym_day,
        td.daily_active_calories
    FROM travel_days AS td
    LEFT JOIN gym_date AS gd
        ON td.date = gd.date
)

SELECT
    travel_day,
    COUNT(*) AS observations,
    AVG(daily_active_calories) AS mean_daily_active_calories
FROM joined_table
WHERE gym_day = 0
GROUP BY travel_day
ORDER BY travel_day;


-- 5. Descriptive Analysis: Calculate median daily active calories using window functions.

WITH travel_days AS (
    SELECT
        dateComponents AS date,
        CASE
            WHEN dateComponents BETWEEN '2024-12-04' AND '2024-12-17'
              OR dateComponents BETWEEN '2025-04-06' AND '2025-04-22'
              OR dateComponents BETWEEN '2026-09-25' AND '2026-10-08'
            THEN 1
            ELSE 0
        END AS travel_day,
        activeEnergyBurned AS daily_active_calories
    FROM daily_activity_analysis
    WHERE dateComponents >= '2024-09-28'
),

gym_date AS (
    SELECT DISTINCT
        SUBSTR(startDate, 1, 10) AS date
    FROM workouts_analysis
    WHERE workoutActivityType = 'HKWorkoutActivityTypeTraditionalStrengthTraining'
),

joined_table AS (
    SELECT
        td.date,
        td.travel_day,
        CASE
            WHEN gd.date IS NOT NULL THEN 1
            ELSE 0
        END AS gym_day,
        td.daily_active_calories
    FROM travel_days AS td
    LEFT JOIN gym_date AS gd
        ON td.date = gd.date
),

table_for_median AS (
    SELECT
        travel_day,
        daily_active_calories,
        ROW_NUMBER() OVER (
            PARTITION BY travel_day
            ORDER BY daily_active_calories ASC
        ) AS row_num,
        COUNT(*) OVER (
            PARTITION BY travel_day
        ) AS group_count
    FROM joined_table
    WHERE gym_day = 0
)

SELECT
    travel_day,
    AVG(daily_active_calories) AS median_daily_active_calories
FROM table_for_median
WHERE row_num IN (
    (group_count + 1) / 2,
    (group_count + 2) / 2
)
GROUP BY travel_day
ORDER BY travel_day;


-- 6. Final Summary: Combine observation counts, mean, and median daily active calories.

WITH travel_days AS (
    SELECT
        dateComponents AS date,
        CASE
            WHEN dateComponents BETWEEN '2024-12-04' AND '2024-12-17'
              OR dateComponents BETWEEN '2025-04-06' AND '2025-04-22'
              OR dateComponents BETWEEN '2026-09-25' AND '2026-10-08'
            THEN 1
            ELSE 0
        END AS travel_day,
        activeEnergyBurned AS daily_active_calories
    FROM daily_activity_analysis
    WHERE dateComponents >= '2024-09-28'
),

gym_date AS (
    SELECT DISTINCT
        SUBSTR(startDate, 1, 10) AS date
    FROM workouts_analysis
    WHERE workoutActivityType = 'HKWorkoutActivityTypeTraditionalStrengthTraining'
),

joined_table AS (
    SELECT
        td.date,
        td.travel_day,
        CASE
            WHEN gd.date IS NOT NULL THEN 1
            ELSE 0
        END AS gym_day,
        td.daily_active_calories
    FROM travel_days AS td
    LEFT JOIN gym_date AS gd
        ON td.date = gd.date
),

table_for_median AS (
    SELECT
        travel_day,
        daily_active_calories,
        ROW_NUMBER() OVER (
            PARTITION BY travel_day
            ORDER BY daily_active_calories ASC
        ) AS row_num,
        COUNT(*) OVER (
            PARTITION BY travel_day
        ) AS group_count
    FROM joined_table
    WHERE gym_day = 0
),

mean_summary AS (
    SELECT
        travel_day,
        COUNT(*) AS observations,
        AVG(daily_active_calories) AS mean_daily_active_calories
    FROM joined_table
    WHERE gym_day = 0
    GROUP BY travel_day
),

median_summary AS (
    SELECT
        travel_day,
        AVG(daily_active_calories) AS median_daily_active_calories
    FROM table_for_median
    WHERE row_num IN (
        (group_count + 1) / 2,
        (group_count + 2) / 2
    )
    GROUP BY travel_day
)

SELECT
    ms.travel_day,
    ms.observations,
    ROUND(ms.mean_daily_active_calories, 2)
        AS rounded_mean_daily_active_calories,
    ROUND(md.median_daily_active_calories, 2)
        AS rounded_median_daily_active_calories
FROM mean_summary AS ms
INNER JOIN median_summary AS md
    ON ms.travel_day = md.travel_day
ORDER BY ms.travel_day;