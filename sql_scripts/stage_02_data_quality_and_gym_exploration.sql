-- Beyond the Gym | SQL Data Quality Checks & Initial Gym Classification
-- SQLite / DBeaver
-- Based on the original analysis script; exploratory versions have been removed.

-- ## 1. Missing Values
-- Check NULL values in both datasets.

SELECT COUNT(*)
FROM workouts_analysis
WHERE active_calories IS NULL;

SELECT
    COUNT(*) - COUNT(startDate) AS null_start_date_observations,
    COUNT(*) - COUNT(workoutActivityType) AS null_workoutactivitytype,
    COUNT(*) - COUNT(duration) AS null_duration,
    COUNT(*) - COUNT(durationUnit) AS null_duration_unit,
    COUNT(*) - COUNT(calorie_unit) AS null_calorie_unit
FROM workouts_analysis;

SELECT
    COUNT(*) - COUNT(dateComponents) AS null_date_observations,
    COUNT(*) - COUNT(activeEnergyBurned) AS null_activeEnergyBurned_observations,
    COUNT(*) - COUNT(activeEnergyBurnedUnit) AS null_activeEnergyBurnedUnit_observations,
    COUNT(*) - COUNT(appleExerciseTime) AS null_appleExerciseTime_observations,
    COUNT(*) - COUNT(appleStandHours) AS null_appleStandHours_observations
FROM daily_activity_analysis;

-- Inspect the imported workout table structure.
PRAGMA table_info('workouts_analysis');

-- Check empty strings and whitespace-only values in text columns.
SELECT
    SUM(CASE WHEN TRIM(startDate) = '' THEN 1 ELSE 0 END) AS startdate_empty_string,
    SUM(CASE WHEN TRIM(workoutActivityType) = '' THEN 1 ELSE 0 END) AS empty_workoutActivityType,
    SUM(CASE WHEN TRIM(durationUnit) = '' THEN 1 ELSE 0 END) AS empty_durationUnit,
    SUM(CASE WHEN TRIM(calorie_unit) = '' THEN 1 ELSE 0 END) AS empty_calorie_unit
FROM workouts_analysis;

SELECT
    SUM(CASE WHEN TRIM(dateComponents) = '' THEN 1 ELSE 0 END) AS empty_date,
    SUM(CASE WHEN TRIM(activeEnergyBurnedUnit) = '' THEN 1 ELSE 0 END) AS empty_energyburned
FROM daily_activity_analysis;


-- ## 2. Potential Duplicate Rows
-- Identify exact duplicate rows, then check repeated daily dates.

SELECT
    COUNT(*) AS observations
FROM workouts_analysis
GROUP BY active_calories, calorie_unit, duration, durationUnit, startDate, workoutActivityType
HAVING COUNT(*) > 1;

SELECT
    COUNT(*) AS observations
FROM daily_activity_analysis
GROUP BY dateComponents, activeEnergyBurned, activeEnergyBurnedUnit, appleExerciseTime, appleStandHours
HAVING COUNT(*) > 1;

SELECT
    dateComponents,
    COUNT(*) AS observations
FROM daily_activity_analysis
GROUP BY dateComponents
HAVING COUNT(*) > 1;


-- ## 3. Date Coverage and Missing Date
-- Confirm the daily dataset's date range and expected number of days.

SELECT
    MIN(dateComponents) AS earliest_record,
    MAX(dateComponents) AS latest_record
FROM daily_activity_analysis;

SELECT
    julianday(MAX(dateComponents)) -
    julianday(MIN(dateComponents)) + 1 AS expected_days,
    COUNT(DISTINCT dateComponents) AS recorded_days
FROM daily_activity_analysis;

-- Identify a missing next day; the final recorded day is excluded.
-- Consecutive missing days would not all be listed by this method.
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

-- Investigate the identified missing date: 2025-04-14.
SELECT *
FROM daily_activity_full
WHERE dateComponents = '2025-04-14';

SELECT *
FROM workouts_analysis
WHERE SUBSTR(startDate, 1, 10) = '2025-04-14';


-- ## 4. Measurement Unit Consistency
-- Count records by recorded unit.

SELECT
    durationUnit,
    COUNT(*) AS observations
FROM workouts_analysis
GROUP BY durationUnit;

SELECT
    calorie_unit,
    COUNT(*) AS observations
FROM workouts_analysis
GROUP BY calorie_unit;

SELECT
    COUNT(*) AS observations,
    activeEnergyBurnedUnit
FROM daily_activity_analysis
GROUP BY activeEnergyBurnedUnit;


-- ## 5. Numerical Consistency Assessment
-- Examine workout duration, calories, and daily activity ranges.

SELECT
    MIN(duration),
    MAX(duration),
    COUNT(*) AS observations
FROM workouts_analysis;

SELECT startDate, workoutActivityType, duration, active_calories
FROM workouts_analysis
ORDER BY duration DESC
LIMIT 5;

SELECT workoutActivityType, COUNT(*) AS observations, MIN(duration), MAX(duration)
FROM workouts_analysis
GROUP BY workoutActivityType
ORDER BY observations DESC;

-- Workout active calories.
SELECT
    MIN(active_calories),
    MAX(active_calories),
    COUNT(*) AS observations,
    SUM(CASE WHEN active_calories > 0 THEN 1 ELSE 0 END) AS valid_number,
    SUM(CASE WHEN active_calories <= 0 THEN 1 ELSE 0 END) AS invalid_number
FROM workouts_analysis;

-- Daily active energy and dates with zero recorded calories.
SELECT
    COUNT(*) AS observations,
    MIN(activeEnergyBurned),
    MAX(activeEnergyBurned)
FROM daily_activity_analysis;

SELECT *
FROM daily_activity_analysis
WHERE activeEnergyBurned = 0;

-- Exercise time and the date(s) with the maximum recorded value.
SELECT
    COUNT(*) AS observations,
    MAX(appleExerciseTime),
    MIN(appleExerciseTime)
FROM daily_activity_analysis;

SELECT *
FROM daily_activity_analysis
WHERE appleExerciseTime = (
    SELECT MAX(appleExerciseTime)
    FROM daily_activity_analysis
);

-- Stand hours (hourly intervals, not total hours spent standing).
SELECT
    COUNT(*) AS observations,
    MAX(appleStandHours),
    MIN(appleStandHours)
FROM daily_activity_analysis;


-- ## 6. Initial Gym Attendance Classification
-- Exploratory: strength-training dates are not yet confirmed gym-attendance days.

SELECT
    COUNT(DISTINCT SUBSTR(startDate, 1, 10)) AS distinct_strength_training_days
FROM workouts_analysis
WHERE workoutActivityType = 'HKWorkoutActivityTypeTraditionalStrengthTraining';

-- Dates with more than one strength-training record.
SELECT
    SUBSTR(startDate, 1, 10) AS date,
    COUNT(*) AS observations
FROM workouts_analysis
WHERE workoutActivityType = 'HKWorkoutActivityTypeTraditionalStrengthTraining'
GROUP BY SUBSTR(startDate, 1, 10)
HAVING COUNT(*) > 1;
