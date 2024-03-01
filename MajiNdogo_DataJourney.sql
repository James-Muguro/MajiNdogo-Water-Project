-- BEGINNING OUR DATA-DRIVEN JOURNEY IN MAJI NDOGO

-- Query to retrieve the list of tables in the md_water_services database
SHOW TABLES;

-- Exploring Each Table in the Database

-- 1. The data_dictionary table

/*
   The data_dictionary table contains essential information about the 
   table names, columns, description, datatype, and entity relationship.
   This query fetches the first 5 rows from the data_dictionary table.
*/
SELECT *
FROM data_dictionary
LIMIT 5;


-- 2. The employee table
/*
   The employee table contains detailed information about employees,
   including their personal details such as phone number, email, address,
   province name, town, and their respective job position/type.
   This query retrieves the first 5 rows from the employee table.
*/
SELECT *
FROM employee
LIMIT 5;


-- 3. The global_water_access table
/*
   The global_water_access table provides comprehensive information about countries,
   including country name, region, population size, year, and global access to basic, limited,
   unimproved, and surface water at the national, rural, and urban levels.
   This query retrieves the first 5 rows from the global_water_access table.
*/
SELECT *
FROM global_water_access
LIMIT 5;


-- 4. The location table
/*
   The location table provides details about specific locations, including address,
   province, town, and an indication of whether it's in a city (Urban) or not.
   While the specific location is not apparent, there is some form of identifying number.
   This query retrieves the first 5 rows from the location table.
*/
SELECT *
FROM location
LIMIT 5;


-- 5. The visits table
/*
   The visits table contains details about each employee's visits, including
   information on the source and location, time of record, visit count, and time in queue.
   This query retrieves the first 5 rows from the visits table.
*/
SELECT *
FROM visits
LIMIT 5;


-- 6. The water_quality table
/*
   The water_quality table provides information on the subjective quality score
   and visit count related to water quality assessments.
   This query retrieves the first 5 rows from the water_quality table.
*/
SELECT *
FROM water_quality
LIMIT 5;


-- 7. The water_source table
/*
   The water_source table logs information about each water source, including its location,
   type, and the number of people served by the source.
   This query retrieves the first 5 rows from the water_source table.
*/
SELECT *
FROM water_source
LIMIT 5;


-- 8. The well_pollution table
/*
   The well_pollution table contains details about well pollution, including
   the type of pollution, source ID, date recorded, pollutant concentration, 
   biological contamination, and associated results.
   This query retrieves the first 5 rows from the well_pollution table.
*/
SELECT *
FROM well_pollution
LIMIT 5;


-- Exploring Water Sources
/*
   This query retrieves distinct types of water sources from the water_source table,
   providing insight into the variety of water sources available.
   There are 5 unique types of water sources listed in the results.
*/ 
SELECT DISTINCT type_of_water_source
FROM water_source;


-- Analyzing Visits to Water Sources
/*
   This query retrieves information from the visits table where the estimated time to get water 
   exceeds approximately 8 hours (500 minutes). It offers insights into instances where 
   individuals experience longer waiting times in the queue.
   The query is limited to displaying the first 10 results.
*/
SELECT * 
FROM visits
WHERE time_in_queue > 500
LIMIT 10;


-- Analyzing Water Sources with Extended Wait Times
/*
   This query investigates the type of water sources where people experience approximately
   8 hours or more to get water. It reveals that, in this context, only shared taps fall into
   this category. The selected columns include source ID, type of water source, number of people served,
   and the associated time in the queue.
*/
SELECT 
    ws.source_id,
    type_of_water_source,
    number_of_people_served,
    time_in_queue
FROM water_source AS ws
INNER JOIN visits AS vs
ON ws.source_id = vs.source_id
WHERE vs.time_in_queue > 500;


-- In-depth Analysis of Specific Water Sources
/*
   This query delves further into the types of water sources by selecting specific sources
   based on their IDs. It provides detailed information such as source ID, type of water source,
   and the number of people served for the identified sources.
*/
SELECT 
    source_id,
    type_of_water_source,
    number_of_people_served
FROM water_source 
WHERE source_id IN ('AkKi00881224', 'AkLu01628224', 'AkRu05234224',
                    'HaRu19601224', 'HaZa21742224', 'SoRu36096224',
                    'SoRu37635224', 'SoRu38776224');               


-- Evaluating Water Source Quality
/*
   This query assesses the quality of water sources by retrieving records from the water_quality table
   where the visit count is greater than or equal to 2, and the subjective quality score is 10.
   The criteria aim to identify instances of high-quality water sources with consistent positive assessments.
*/
SELECT *
FROM water_quality
WHERE visit_count >= 2 AND subjective_quality_score = 10;


-- Handling Inconsistencies in Well Pollution Descriptions
/*
   This query addresses inconsistencies in the description column of the well_pollution table.
   It retrieves records where the description begins with 'Clean_' to identify and potentially
   correct or handle any anomalies in the well pollution descriptions.
*/
SELECT description
FROM well_pollution
WHERE description LIKE 'Clean_%';


-- Correcting Well Pollution Description for Bacteria: E. coli
/*
   This SQL update statement addresses inaccuracies in the description column of the well_pollution table.
   It replaces instances where the description is 'Clean Bacteria: E. coli' with the correct label 'Bacteria: E. coli'.
   This ensures accurate and standardized representation of well pollution information.
*/
UPDATE 
    well_pollution
SET 
    description = 'Bacteria: E. coli'
WHERE 
    description = 'Clean Bacteria: E. coli';


-- Correcting Well Pollution Description for Bacteria: Giardia Lamblia
/*
   This SQL update statement addresses inaccuracies in the description column of the well_pollution table.
   It replaces instances where the description is 'Clean Bacteria: Giardia Lamblia' with the correct label 'Bacteria: Giardia Lamblia'.
   This ensures accurate and standardized representation of well pollution information.
*/
UPDATE 
    well_pollution
SET 
    description = 'Bacteria: Giardia Lamblia'
WHERE 
    description = 'Clean Bacteria: Giardia Lamblia';


-- Validating Well Pollution Results for Biological Contamination
/*
   This SQL update statement validates the results column in the well_pollution table.
   It sets the results to 'Contaminated: Biological' for records where the biological contamination exceeds 0.01
   and the current results are labeled as 'Clean'. This ensures accurate representation of biological contamination
   in the results column.
*/
UPDATE 
    well_pollution
SET
    results = 'Contaminated: Biological'   
WHERE 
    biological > 0.01 AND results = 'Clean';
