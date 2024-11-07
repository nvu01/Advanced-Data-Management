# Advanced Data Management - DVD Rental Store Analysis
## Overview
This project demonstrates the use of PostgreSQL and PL/pgSQL to perform data analysis, transformation, and automation tasks within a DVD rental store business database.
## Key Features:
1. Data Transformation: User-defined functions to extract the month and year from rental dates. 
2. Data Aggregation: Creation of detailed_table and summary_table to track rentals by category, month, and year. 
3. Automation:
   - A trigger function to automatically update the summary table when new rental data is inserted in the detailed_table.
   - A stored procedure to refresh data in both tables on demand.
## Project Files:
1. Sample database: __dvdrental.zip__ file containing __dvdrental.tar__ file which is used to set up PostgreSQL database.
2. SQL script: __dvdrental_project.sql__ contains:
   - User-defined functions for data transformation (month_of_rental(), year_of_rental()).
   - SQL queries to create tables (detailed_table, summary_table).
   - SQL queries to extract raw data and populate the detailed_table.
   - User-defined function to update table (summary_table_update()) and function trigger (update_trigger()).
   - Stored procedure (refresh_tables()).
   - Optional code to reset the environment.
3. Result tables:
   - __detailed_table.csv__: Contains the detailed rental data with the year, month, and category of each rental.
   - __summary_table.csv__: Contains the summary data showing the total number of rentals for each film category, organized by year and month.
4. Project Description: __Project description.pdf__ — This document provides a detailed outline of the project scope, objectives, and methodology.
## Prerequisites
### Install PostgreSQL on your local machine.
[Instructions on how to install PostgreSQL](https://neon.tech/postgresql/postgresql-getting-started/install-postgresql)
### Install a PostgreSQL client (such as pgAdmin or the psql command-line tool).
[Install pgAdmin](https://www.pgadmin.org/download/)
### Connect to a PostgreSQL database server
[Instructions on how to connect to a PostgreSQL database server](https://neon.tech/postgresql/postgresql-getting-started/connect-to-postgresql-database)
### Download sample database:  
Download dvdrental.zip from [root directory of GitHub repository](https://github.com/nvu01/Advanced-Data-Management)
or from [neon.tech](https://neon.tech/postgresql/postgresql-getting-started/postgresql-sample-database)
### Load PostgreSQL sample database
[Instructions on how to load PostgreSQL sample database](https://neon.tech/postgresql/postgresql-getting-started/load-postgresql-sample-database)

## SQL Script Usage
The dvdrental_project.sql file is divided into logical sections, each performing a specific task related to data transformation, aggregation, and automation. 
Follow the instructions below to execute each section as needed.

1. Data Transformation Functions
   - Purpose: This section creates two user-defined functions:
     - month_of_rental(rental_date): Extracts the month from a rental date. 
     - year_of_rental(rental_date): Extracts the year from a rental date.
   - How to use: Run this block to create the functions. You can then use them for extracting time-based information from rental dates when inserting or querying data.  
2. Table Creation
   - Purpose: Creates two tables:
     - detailed_table: Stores detailed rental data including the rental_id, year_of_rental, month_of_rental, and category_name.
     - summary_table: Aggregates rental data by year, month, and category to track rental counts.
   - How to use: Execute this block to create the tables. You can later populate them with data and use them for reporting.
3. Data Extraction and Population
   - Purpose: This section extracts raw rental and category data from the database and populates the detailed_table with the appropriate information (rental_id, year, month, category).
   - How to use: Run this block to load data into the detailed_table. This is a one-time operation to extract and store rental data for analysis.
4. Automated Summary Table Updates (Trigger and Function)
   - Purpose: Creates a trigger function (summary_table_update) that updates the summary_table automatically when new data is inserted into the detailed_table. This ensures that the summary table remains up-to-date with the latest rental data.
   - How to use: Run this block to create the trigger function and the trigger itself. The summary table will automatically update with each insert into the detailed table.
5. Stored Procedure for Data Refresh
   - Purpose: The refresh_tables() stored procedure deletes all existing data in both detailed_table and summary_table, then reloads the data from the source tables, ensuring both tables have the most up-to-date information.
   - How to use: Run this block to create the stored procedure. You can call the procedure whenever you want to refresh the data in both tables (e.g., after new rentals have been added to the system).
6. Reset the Environment (Optional)
   - Purpose: Includes code to drop all the created functions, triggers, and tables, which is useful for resetting the environment.
   - How to use: Run this block to remove all custom objects (functions, triggers, and tables) from the database, effectively resetting the setup.

### Execution Flow
- Step 1: Begin by running the data transformation functions (month_of_rental() and year_of_rental()) to handle rental date analysis.
- Step 2: Create the necessary tables (detailed_table and summary_table) to store and aggregate the data.
- Step 3: Load raw data into the detailed_table using the provided SQL query.
- Step 4: Implement the trigger to ensure automatic updates to the summary data when new records are inserted.
- Step 5: Use the refresh_tables() procedure for refreshing the data in both tables when needed.
- Step 6: Optionally, run the reset code to clear the created objects and start over.

Notes:
   You can execute each section independently based on your needs (e.g., if you need to refresh data or just create the tables).
   Always test your tables (detailed_table and summary_table) using SELECT queries after running the script to ensure the data is loaded correctly.
