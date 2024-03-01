-- WEAVING THE DATA THREADS OF MAJI NDOGO'S NARRATIVE

-- Creating and Importing Data for Auditor Report

-- Drop the table if it already exists
DROP TABLE IF EXISTS `auditor_report`;

-- Create the `auditor_report` table with necessary columns
CREATE TABLE `auditor_report` (
    `location_id` VARCHAR(32),
    `type_of_water_source` VARCHAR(64),
    `true_water_source_score` INT DEFAULT NULL,
    `statements` VARCHAR(255)
);

-- Load data from the Auditor Report CSV file into the newly created table
LOAD DATA INFILE 'F:/Projects/MajiNdogo/SQL/auditor_report.csv' -- replace with the actual path to your CSV file
INTO TABLE auditor_report
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES; -- Skip the header if it exists in the CSV file


-- Comparing Quality Scores: Auditor vs. Employee

/*
   This query compares the water quality scores from the auditor_report table with the subjective quality scores
   recorded by employees in the water_quality table. It joins the auditor_report, visits, and water_quality tables
   based on common identifiers (location_id and record_id) to provide a comprehensive view of the scores.
*/
SELECT 
    ar.location_id,
    v.record_id,
    ar.true_water_source_score AS auditor_score,
    w.subjective_quality_score AS employee_score
FROM
    auditor_report AS ar
INNER JOIN
    visits AS v
ON 
    ar.location_id = v.location_id
INNER JOIN
    water_quality AS w
ON
    v.record_id = w.record_id;


-- Investigating Auditor and Employee Scores Agreement

/*
   This query investigates whether the auditor's scores match the surveyor's scores for each visit made to a location.
   It joins the auditor_report, visits, and water_quality tables based on common identifiers (location_id and record_id),
   and filters the results to include only cases where the auditor's true_water_source_score equals the employee's subjective_quality_score,
   and the visit count is 1, indicating a single visit to the location.
*/
SELECT 
    ar.location_id,
    v.record_id,
    ar.true_water_source_score AS auditor_score,
    w.subjective_quality_score AS employee_score
FROM
    auditor_report AS ar
INNER JOIN
    visits AS v
ON 
    ar.location_id = v.location_id
INNER JOIN
    water_quality AS w
ON
    v.record_id = w.record_id
WHERE
    ar.true_water_source_score = w.subjective_quality_score
    AND
    v.visit_count = 1;


-- Identifying Incorrect Water Quality Scores

/*
   This query checks for records where the auditor's scores do not match the surveyor's scores
   for each visit made to a location. It joins the auditor_report, visits, water_quality, and water_source tables
   based on common identifiers (location_id, record_id, and source_id), and filters the results to include only cases
   where the auditor's true_water_source_score is not equal to the employee's subjective_quality_score,
   and the visit count is 1, indicating a single visit to the location.
*/
SELECT 
    ar.location_id,
    v.record_id,
    ar.type_of_water_source AS auditor_source,
    ws.type_of_water_source AS survey_source,
    ar.true_water_source_score AS auditor_score,
    w.subjective_quality_score AS employee_score
FROM
    auditor_report AS ar
INNER JOIN
    visits AS v
ON 
    ar.location_id = v.location_id
INNER JOIN
    water_quality AS w
ON
    v.record_id = w.record_id
INNER JOIN
    water_source AS ws
ON
    v.source_id = ws.source_id
WHERE
    ar.true_water_source_score != w.subjective_quality_score
    AND
    v.visit_count = 1;


-- Joining Employee Information for Quality Score Discrepancies

/*
   This query returns the names of employees who made errors in their quality score observations.
   It joins the auditor_report, visits, water_quality, and employee tables based on common identifiers
   (location_id, record_id, and assigned_employee_id). The results include location information, employee names,
   auditor and employee quality scores, focusing on cases where the auditor's true_water_source_score is not equal
   to the employee's subjective_quality_score, and the visit count is 1, indicating a single visit to the location.
*/
SELECT 
    ar.location_id,
    v.record_id,
    e.employee_name,
    ar.true_water_source_score AS auditor_score,
    w.subjective_quality_score AS employee_score
FROM
    auditor_report AS ar
INNER JOIN
    visits AS v
ON 
    ar.location_id = v.location_id
INNER JOIN
    water_quality AS w
ON
    v.record_id = w.record_id
INNER JOIN
    employee AS e
ON
    v.assigned_employee_id = e.assigned_employee_id
WHERE
    ar.true_water_source_score != w.subjective_quality_score
    AND
    v.visit_count = 1;


-- Creating Common Table Expressions (CTEs) for Incorrect Water Quality Records and Error Count

-- CTE for Incorrect Water Quality Records
WITH Incorrect_records AS (
    SELECT 
        ar.location_id,
        v.record_id,
        e.employee_name,
        ar.true_water_source_score AS auditor_score,
        w.subjective_quality_score AS employee_score
    FROM
        auditor_report AS ar
    INNER JOIN
        visits AS v
    ON 
        ar.location_id = v.location_id
    INNER JOIN
        water_quality AS w
    ON
        v.record_id = w.record_id
    INNER JOIN
        employee AS e
    ON
        v.assigned_employee_id = e.assigned_employee_id
    WHERE
        ar.true_water_source_score != w.subjective_quality_score
        AND
        v.visit_count = 1
),

-- CTE for Count of Errors per Employee
Error_Count AS (
    SELECT 
        employee_name,
        COUNT(*) AS number_of_mistakes
    FROM
        Incorrect_records
    GROUP BY
        employee_name
)


-- Investigating Employees with Above-Average Number of Mistakes

/*
   This query identifies employees who made mistakes more than the average number of mistakes.
   It uses the error_count common table expression (CTE) to calculate the average number of mistakes,
   and then filters the results to include only employees with a number of mistakes greater than the overall average.
*/
SELECT
    employee_name,
    ROUND(AVG(number_of_mistakes), 2) AS avg_number_of_mistakes
FROM
    error_count
WHERE
    number_of_mistakes > (SELECT ROUND(AVG(number_of_mistakes), 2) FROM error_count)
GROUP BY
    employee_name;


-- Creating a View for Incorrect Water Quality Records

CREATE VIEW Incorrect_records AS (
    SELECT
        ar.location_id,
        v.record_id,
        e.employee_name,
        ar.true_water_source_score AS auditor_score,
        wq.subjective_quality_score AS employee_score,
        ar.statements AS statements
    FROM
        auditor_report AS ar
    JOIN
        visits AS v
    ON 
        ar.location_id = v.location_id
    JOIN
        water_quality AS wq
    ON 
        v.record_id = wq.record_id
    JOIN
        employee AS e
    ON 
        e.assigned_employee_id = v.assigned_employee_id
    WHERE
        v.visit_count = 1
    AND 
        ar.true_water_source_score != wq.subjective_quality_score
);


-- Creating CTEs for Error Count and Suspect List

-- CTE for Error Count of Each Employee
WITH error_count AS (
    SELECT
        employee_name,
        COUNT(employee_name) AS number_of_mistakes
    FROM
        Incorrect_records
    GROUP BY
        employee_name
/*
   The Incorrect_records view joins the audit report to the database
   for records where the auditor and employee scores are different.
   This CTE calculates the number of mistakes made by each employee.
*/
),

-- CTE for Suspect List of "Corrupt" Employees
Suspect_List AS (
    -- This CTE selects employees with above-average mistakes
    SELECT
        employee_name,
        number_of_mistakes
    FROM
        error_count
    WHERE
        number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count)
)


-- Filtering Records Gathered by "Corrupt" Employees

/*
   This query filters records from the Incorrect_records view where data was gathered by "corrupt" employees.
   It selects employee names, location IDs, and statements from the Incorrect_records view
   and filters the results to include only records where the employee name is in the suspect_list.
*/
SELECT
    employee_name,
    location_id,
    statements
FROM
    Incorrect_records
WHERE
    employee_name IN (SELECT employee_name FROM suspect_list);
