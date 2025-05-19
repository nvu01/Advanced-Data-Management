# Advanced Data Management - DVD Rental Store Analysis

## Overview
In this project, I developed an automated reporting solution for a DVD rental business using a PostgreSQL database. The database includes key information about rentals, films, categories, and inventory.
This automated reporting solution enables the DVD rental store to track rental trends over time, identify popular film categories, and make data-driven decisions for inventory and marketing. 
By having up-to-date rental data available, the business can better forecast demand, optimize inventory levels, and tailor promotions to high-performing film categories.

## Project Files:
1. Sample database: __dvdrental.zip__ file containing __dvdrental.tar__ file which is used to set up PostgreSQL database.
2. SQL script: __dvdrental_project.sql__ contains:
   - User-defined functions for data transformation (`rental_month()`, `rental_year()`).
   - SQL queries with multiple joins and aggregation to create tables (`detailed_table`, `summary_table`).
   - SQL queries to extract raw data and populate the `detailed_table`.
   - User-defined function to update table (`summary_table_update()`) and function trigger (`update_summary_on_insert`).
   - Stored procedure (`refresh_tables()`).
   - Optional code to reset the environment.
3. Result tables:
   - __detailed_table.csv__: Contains the detailed rental data with the year, month, and category of each rental.
   - __summary_table.csv__: Contains the summary data showing the total number of rentals for each film category, organized by year and month.
4. Project Description: __Project description.pdf__ — This document provides a detailed outline of the project scope, objectives, and methodology.

## Prerequisites

### Install PostgreSQL on your local machine.
[Instructions on how to install PostgreSQL](https://neon.tech/postgresql/postgresql-getting-started/install-postgresql)

### Install a PostgreSQL database tool (such as pgAdmin or the psql command-line tool).
[Install pgAdmin](https://www.pgadmin.org/download/)

### Connect to a PostgreSQL database server
[Instructions on how to connect to a PostgreSQL database server](https://neon.tech/postgresql/postgresql-getting-started/connect-to-postgresql-database)

### Download sample database:  
Download dvdrental.zip from [root directory of GitHub repository](https://github.com/nvu01/Advanced-Data-Management)
or from [neon.tech](https://neon.tech/postgresql/postgresql-getting-started/postgresql-sample-database)

### Load PostgreSQL sample database
[Instructions on how to load PostgreSQL sample database](https://neon.tech/postgresql/postgresql-getting-started/load-postgresql-sample-database)

## SQL Script Usage
The __dvdrental_project.sql__ file is divided into logical sections, each performing a specific task related to data transformation, aggregation, and automation. 
Follow the instructions below to execute each section as needed.

1. Data Transformation Functions
   - Purpose: This section creates two user-defined functions:
     - `rental_month()`: Extracts the month from rental date. 
     - `rental_year()`: Extracts the year from rental date.
   - How to use: Run the first 2 `CREATE OR REPLACE FUNCTION` blocks to create the functions.   
2. Tables Creation
   - Purpose: Create two tables:
     - `detailed_table`: Stores detailed rental data including the rental_id, year_of_rental, month_of_rental, and category_name.
     - `summary_table`: Aggregates rental data by year, month, and category to track rental counts.
   - How to use: Execute the `CREATE TABLE` blocks to create the tables. You can later populate them with data and use them for reporting.
3. Automatic `summary_table` update with trigger
   - Purpose: Create a trigger (`update_summary_on_insert`) that updates the `summary_table` automatically when new data is inserted into the `detailed_table`.
   - How to use: Run the 2 blocks: `CREATE OR REPLACE FUNCTION summary_table_update()` and `CREATE TRIGGER update_summary_on_insert` to create the trigger. 
4. Data Extraction and Table Population
   - Purpose: This section extracts raw data from the database and populates the `detailed_table` with the appropriate information.
   - How to use: Run the `INSERT INTO` query to load data into the `detailed_table`. This is a one-time operation to extract and store rental data for analysis.
5. Stored Procedure for Data Refresh
   - Purpose: The `refresh_tables()` stored procedure deletes all existing data in both detailed_table and summary_table, then reloads the data from the source tables, ensuring both tables have the most up-to-date information.
   - How to use: Run the `CREATE PROCEDURE` block to create the stored procedure. Run `CALL refresh_tables();` to call the procedure whenever you want to refresh the data in both tables.
6. Reset the Environment (Optional)
   - Purpose: Includes code to drop all the created functions, triggers, and tables, which is useful for resetting the environment.
   - How to use: Run the `DROP...IF EXISTS` queries to remove all custom objects (functions, triggers, and tables) from the database, effectively resetting the setup.

Notes:
   You can execute each section independently based on your needs (e.g., if you need to refresh data or just create the tables).
   Always test your tables (detailed_table and summary_table) using SELECT queries after running the script to ensure the data is loaded correctly.
