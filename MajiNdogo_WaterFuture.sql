-- CHARTING THE COURSE FOR MAJI NDOGO'S WATER FUTURE

-- Joining Visits and Location Tables for Province and Town Information

/*
   This query returns information about the province, town, visit count, and location ID
   by joining the visits table with the location table based on the common identifier (location_id).
*/
SELECT 
    l.province_name,
    l.town_name,
    v.visit_count,
    l.location_id
FROM
    visits AS v
JOIN
    location AS l 
ON
    v.location_id = l.location_id;


-- Joining Visits, Location, and Water Source Tables for Location Information

/*
   This query returns information about the province, town, location type, type of water source, number of people served,
   and time spent in the queue (in minutes) for locations visited once.
   It joins the visits table with the location and water_source tables based on the common identifiers (location_id and source_id),
   and filters the results to include only records with a visit count of 1.
*/
SELECT 
    l.province_name,
    l.town_name,
    l.location_type,
    ws.type_of_water_source,
    ws.number_of_people_served,
    v.time_in_queue
FROM
    visits AS v
JOIN
    location AS l 
ON
    v.location_id = l.location_id
JOIN
    water_source AS ws
ON
    ws.source_id = v.source_id
WHERE v.visit_count = 1;


-- Joining Visits, Well Pollution, Location, and Water Source Tables for Pollution Results

/*
   This query returns information about the province, town, location type, type of water source, number of people served,
   time spent in the queue (in minutes), and pollution results status for each type of water source for locations visited once.
   It joins the visits table with the well_pollution (using a left join for well-specific information), location, and water_source tables
   based on the common identifiers (location_id and source_id), and filters the results to include only records with a visit count of 1.
*/
SELECT 
    l.province_name,
    l.town_name,
    l.location_type,
    ws.type_of_water_source,
    ws.number_of_people_served,
    v.time_in_queue,
    wp.results
FROM
    visits AS v
-- The well_pollution table contains information about well sources only, so we use a left join to retrieve
-- information about wells and return null for the remaining water sources
LEFT JOIN
    well_pollution AS wp
ON 
    wp.source_id = v.source_id
JOIN
    location AS l 
ON
    v.location_id = l.location_id
JOIN
    water_source AS ws
ON
    ws.source_id = v.source_id
WHERE v.visit_count = 1;


-- Creating a View for Combined Analysis Table

/*
   This view named 'combined_analysis_table' assembles data from different tables into one
   to simplify analysis and provide a comprehensive view of relevant information.
   It includes details such as province, town, location type, type of water source, number of people served,
   time spent in the queue (in minutes), and pollution results for each type of water source at locations visited once.
*/
CREATE VIEW combined_analysis_table AS (
    SELECT 
        l.province_name,
        l.town_name,
        l.location_type,
        ws.type_of_water_source AS source_type,
        ws.number_of_people_served AS people_served,
        v.time_in_queue,
        wp.results
    FROM
        visits AS v
    LEFT JOIN
        well_pollution AS wp
    ON 
        wp.source_id = v.source_id
    JOIN
        location AS l 
    ON
        v.location_id = l.location_id
    JOIN
        water_source AS ws
    ON
        ws.source_id = v.source_id
    WHERE v.visit_count = 1
);


-- Building a Pivot Table for Province and Their Types of Water Sources

/*
   This query builds a pivot table breaking down data into provinces or towns and source types.
   It utilizes Common Table Expressions (CTEs) for intermediate calculations.
*/

-- CTE to Calculate the Population of Each Province
WITH province_totals AS (
    SELECT
        province_name,
        SUM(people_served) AS total_ppl_serv
    FROM
        combined_analysis_table
    GROUP BY
        province_name
)

-- Main Query to Pivot Data
SELECT
    ct.province_name,
    -- These CASE statements create columns for each type of source.
    -- The results are aggregated, and percentages are calculated.
    ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
    ROUND((SUM(CASE WHEN source_type = 'shared_tap' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
    ROUND((SUM(CASE WHEN source_type = 'well' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM
    combined_analysis_table ct
JOIN
    province_totals pt
ON 
    ct.province_name = pt.province_name
GROUP BY
    ct.province_name
ORDER BY
    ct.province_name;


-- Aggregating Data per Town

/*
   This query aggregates data per town, calculating the percentage of people served by each type of water source.
   It uses a Common Table Expression (CTE) to calculate the population of each town.
   Since there are two Harare towns in two provinces (Akatsi and Kilimani), the grouping is done by province_name and town_name
   to ensure retrieval of distinct town names in each province.
*/

-- CTE to Calculate the Population of Each Town
WITH town_totals AS (
    SELECT 
        province_name, 
        town_name, 
        SUM(people_served) AS total_ppl_serv
    FROM 
        combined_analysis_table
    GROUP BY 
        province_name,
        town_name
)

-- Main Query to Aggregate Data per Town
SELECT
    ct.province_name,
    ct.town_name,
    ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
    ROUND((SUM(CASE WHEN source_type = 'shared_tap' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
    ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
    ROUND((SUM(CASE WHEN source_type = 'well' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
    combined_analysis_table ct
-- Joining on a composite key as town names are not unique
JOIN
    town_totals tt 
ON 
    ct.province_name = tt.province_name 
    AND 
    ct.town_name = tt.town_name
-- Group by province first, then by town
GROUP BY
    ct.province_name,
    ct.town_name
ORDER BY
    ct.town_name;


-- Identifying the Town with the Highest Ratio of Non-Functional Taps

/*
   This query identifies the town with the highest ratio of people who have taps but have no running water.
   It calculates the percentage of broken taps relative to the total number of taps in each town.
*/

SELECT
    province_name,
    town_name,
    ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) * 100, 0) AS Pct_broken_taps
FROM
    town_aggregated_water_access;


-- Creating the Progress Report Table for Water Source Projects

/*
   This query creates the 'Project_progress' table, which will serve as a progress report for water source projects.
   The table includes attributes such as Project_id, source_id, Address, Town, Province, Source_type, Improvement,
   Source_status, Date_of_completion, and Comments to capture relevant information for managing and tracking project progress.
   Descriptions for each attribute are provided below.
*/

CREATE TABLE Project_progress (
    Project_id SERIAL PRIMARY KEY,
    source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
    Address VARCHAR(50),
    Town VARCHAR(30),
    Province VARCHAR(30),
    Source_type VARCHAR(50),
    Improvement VARCHAR(50),
    Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
    Date_of_completion DATE,
    Comments TEXT
);


-- Inserting Values into the Progress Report Table

/*
   This query inserts values into the 'Project_progress' table based on conditions derived from the water source and visits data.
   It assigns values to attributes such as Source_id, Address, Town, Province, Source_type, and Improvement based on specified criteria.
   The CASE statement is used to determine the appropriate improvement action based on contamination results, water source type, and queue time.
   The resulting data provides insights into necessary improvements for different water sources.
*/

INSERT INTO Project_progress (`Source_id`, `Address`, `Town`, `Province`, `Source_type`, `Improvement`)
SELECT
    ws.source_id,
    l.address,
    l.town_name,
    l.province_name,
    ws.type_of_water_source,
    CASE 
        WHEN wp.results = 'Contaminated: Chemical' THEN 'Install RO filter'
        WHEN wp.results = 'Contaminated: Biological' THEN 'Install UV and RO filter'
        WHEN ws.type_of_water_source = 'river' THEN 'Drill wells'
        WHEN ws.type_of_water_source = 'shared_tap' AND v.time_in_queue >= 30 THEN CONCAT("Install ", FLOOR(v.time_in_queue/30), " taps nearby")
        WHEN ws.type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose local infrastructure'
        ELSE NULL
    END AS Improvements
FROM
    water_source AS ws
LEFT JOIN
    well_pollution AS wp
ON 
    ws.source_id = wp.source_id
INNER JOIN
    visits AS v
ON 
    ws.source_id = v.source_id
INNER JOIN
    location AS l
ON 
    l.location_id = v.location_id
WHERE 
    v.visit_count = 1
    AND (
        wp.results != 'Clean'
        OR ws.type_of_water_source IN ('tap_in_home_broken', 'river')
        OR (ws.type_of_water_source = 'shared_tap' AND v.time_in_queue >= 30)
    );

-- Verify the data in the 'Project_progress' table
SELECT
    *
FROM
    project_progress;
