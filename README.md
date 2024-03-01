# Maji Ndogo Water Project

## Project Overview

The Maji Ndogo Water Project is a data-driven initiative aimed at analyzing and improving water sources in various towns and provinces. The project involves the exploration of multiple database tables, including information on water sources, visits, water quality, and pollution, to assess the current state of water infrastructure and identify areas for improvement.

## Table Structure

The project utilizes several database tables to store relevant data:

- **Location Table (`location`):** Contains information about specific locations, including address, province, town, and urban status.

- **Visits Table (`visits`):** Holds details about each employee's visits, including source and location, time of record, visit count, and time in the queue.

- **Water Quality Table (`water_quality`):** Contains information about subjective quality scores and visit counts.

- **Water Source Table (`water_source`):** Logs details about each water source, such as location, source type, and the number of people served.

- **Well Pollution Table (`well_pollution`):** Provides information about well pollution, including type, source ID, date recorded, pollutant concentration, biological contamination, and results.

- **Auditor Report Table (`auditor_report`):** Stores information obtained from an auditor's report, including location ID, water source type, true water source score, and statements.

- **Project Progress Table (`project_progress`):** Created for tracking improvement projects, this table includes project ID, source ID, address, town, province, source type, improvement action, source status, date of completion, and comments.

## Queries and Analysis

### Data Exploration and Analysis

Queries have been written to explore and analyze different aspects of the data:

- **Water Sources Analysis:** Investigates unique water sources based on source types.

- **Visits to Water Sources:** Identifies visits where the estimated time to get water takes approximately 8 hours.

- **Water Source Quality Assessment:** Assesses the quality of water sources based on visit count and subjective quality scores.

- **Handling Data Inconsistencies:** Addresses inconsistencies in the description column of the well_pollution table.

### Data Transformation and Enrichment

Several queries focus on updating and refining data for better accuracy and clarity:

- **Updating Description Columns:** Corrects and updates description columns for specific types of pollution.

- **Employee Information Enrichment:** Updates the employee table with email addresses and removes trailing whitespaces from phone numbers.

### Performance Metrics and Employee Recognition

Queries have been designed to assess performance metrics and recognize top-performing employees:

- **Employee Count per Town:** Lists the number of employees in each town.

- **Top Employees Based on Visit Count:** Identifies the top 3 employees based on the number of visits.

### Location Analysis

Queries provide insights into the distribution of records across different locations:

- **Records per Town and Province:** Counts the number of records per town and province.

- **Location Type Analysis:** Expresses the number of records per location type in percentages.

### Water Source Population and Prioritization

Queries are written to analyze the population served by each water source and prioritize sources:

- **Population Served by Water Source Type:** Calculates the average number of people per water source and ranks sources based on population served.

- **Ranking Water Sources:** Ranks water sources based on different criteria using RANK(), DENSE_RANK(), and ROW_NUMBER().

### Queue Time Analysis

Queries focus on analyzing queue times for water sources:

- **Average Queue Time:** Calculates the average total queue time for water.

- **Average Queue Time on Different Days:** Breaks down the average queue time based on different days of the week.

- **Hourly Queue Time Analysis:** Analyzes queue time for each hour of the day.

### Auditor and Employee Scores Comparison

Queries compare auditor and employee scores for water sources:

- **Comparison of Quality Scores:** Compares quality scores in the water_quality table to the auditor's scores.

- **Investigating Auditor and Employees' Scores:** Checks for matching scores in the auditor's and employee's observations.

- **Identifying Incorrect Records:** Lists records where auditor and employee scores do not match.

- **Employee Recognition Based on Mistakes:** Identifies employees with above-average mistakes in their quality score observations.

### Data Visualization and Reporting

The project includes queries for creating views and generating reports:

- **Creating Views:** Creates views for incorrect records and the aggregated analysis table.

- **Generating Town and Province Reports:** Generates reports for provinces and towns, breaking down the data based on source types.

- **Creating a Pivot Table:** Builds a pivot table to represent the distribution of water sources across provinces and source types.

### Project Progress and Improvement Actions

Queries and actions related to improving water sources are implemented:

- **Creating Project Progress Table:** Establishes a table to track the progress of improvement projects.

- **Inserting Values into Project Progress Table:** Populates the project progress table with data based

 on water source conditions.

## Datasets Availability and Database Information

The datasets used for this project are contained in two sets:

1. **md_water_services.sql**: This SQL file comprises eight tables, providing comprehensive information about water sources, visits, water quality, and related data.

2. **Auditor_report.csv**: A CSV file containing auditor reports, specifically focusing on water source scores and related statements.

To request access to these datasets or if you have any inquiries, please reach out.

Additionally, the SQL queries in this project were executed on a MySQL database. If you encounter any issues or have specific requirements related to the database schema or setup, feel free to reach out for assistance.

## Usage

To utilize and understand the Maji Ndogo Water Project, follow these steps:

1. Execute the provided queries in a compatible SQL database system.
2. Review the project tables to gain insights into water source data, visits, quality scores, pollution, and employee performance.
3. Explore the project progress table to track ongoing improvement projects and plan for future upgrades.

Feel free to contribute to the project by refining queries, improving data accuracy, and suggesting additional analyses for continuous enhancement.
