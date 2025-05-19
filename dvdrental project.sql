-- DATA TRANSFORMATION FUNCTIONS --

-- Create a function that extracts month from the rental_date column
CREATE OR REPLACE FUNCTION rental_month (rental_date timestamp without time zone)
RETURNS int
LANGUAGE plpgsql
AS $$
DECLARE month_value int;
BEGIN
    SELECT EXTRACT (MONTH FROM rental_date) INTO month_value;
    RETURN month_value;
END; 
$$;

-- Create a function that extracts year from the rental_date column
CREATE OR REPLACE FUNCTION rental_year (rental_date timestamp without time zone)
RETURNS int
LANGUAGE plpgsql
AS $$
DECLARE year_value int;
BEGIN
    SELECT EXTRACT (YEAR FROM rental_date) INTO year_value;
    RETURN year_value;
END;
$$;

-- Test the two functions
SELECT rental_id, rental_year(rental_date), rental_month(rental_date) FROM rental;


-- TABLE CREATION --

-- Create an empty detailed table
DROP TABLE IF EXISTS detailed_table;
CREATE TABLE detailed_table (
	rental_id int,
	rental_year int,
	rental_month int,
	category_name varchar (25)
);

-- Create a summary table that extracts and aggregates data from the detailed table
DROP TABLE IF EXISTS summary_table;
CREATE TABLE summary_table
AS SELECT rental_year, rental_month, category_name, COUNT(*) AS num_rentals
FROM detailed_table
GROUP BY rental_year, rental_month, category_name
ORDER BY rental_year DESC, rental_month DESC, num_rentals DESC;

-- Test the CREATE TABLE statements
SELECT * FROM detailed_table;
SELECT * FROM summary_table;


-- TRIGGER FOR SUMMARY TABLE UPDATE --

-- Create a function that updates the summary table
CREATE OR REPLACE FUNCTION summary_table_update()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	TRUNCATE summary_table;
	INSERT INTO summary_table
		SELECT rental_year, rental_month, category_name, COUNT (*) AS num_rentals
		FROM detailed_table
		GROUP BY rental_year, rental_month, category_name
		ORDER BY rental_year DESC, rental_month DESC, num_rentals DESC;
RETURN NEW;
END; 
$$;

-- Create a trigger that updates the summary table when data is inserted into the detailed table
DROP TRIGGER IF EXISTS update_summary_on_insert ON detailed_table;
CREATE TRIGGER update_summary_on_insert
AFTER INSERT
ON detailed_table
FOR EACH STATEMENT
EXECUTE PROCEDURE summary_table_update(); 


-- DATA EXTRACTION AND POPULATION --

-- Run this block to add raw data to the detailed table
INSERT INTO detailed_table
SELECT r.rental_id, rental_year (r.rental_date), rental_month (r.rental_date), c.name AS category_name
FROM rental r
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film_category fc ON i.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
ORDER BY rental_year DESC, rental_month DESC;

-- Test data extraction in detailed table
SELECT * FROM detailed_table ORDER BY rental_id DESC;   -- The max rental_id is 16049.

-- Test the trigger
SELECT * FROM summary_table;   -- summary_table is now filled with data and the most current month is February 2006.
--- Insert a new row to the detailed table to test the trigger
INSERT INTO detailed_table VALUES (16050, 2007, 10, 'Horror');
--- The most current month in the summary table is Oct 2007
SELECT * FROM summary_table;
--- Run this code after adding a row to the detailed table. The max rental_id is now 16050.
SELECT * FROM detailed_table ORDER BY rental_id DESC;


-- STORED PROCEDURE FOR DATA REFRESH --

-- Create a procedure that refreshes data in both the detailed and summary tables
-- The procedure will not only refresh the data but also remove any test data that was manually inserted (like the row added earlier when testing the trigger)
DROP PROCEDURE IF EXISTS refresh_tables();
CREATE PROCEDURE refresh_tables ()
LANGUAGE plpgsql
AS $$
BEGIN
	TRUNCATE detailed_table;
	TRUNCATE summary_table;
	-- Temporarily disable trigger
    ALTER TABLE detailed_table DISABLE TRIGGER update_summary_on_insert;
	-- Update detailed_table
	INSERT INTO detailed_table
		SELECT r.rental_id, rental_year (ym.rental_date), rental_month (ym.rental_date), c.name AS category_name
		FROM rental r
		INNER JOIN inventory i ON r.inventory_id = i.inventory_id
		INNER JOIN film_category fc ON i.film_id = fc.film_id
		INNER JOIN category c ON fc.category_id = c.category_id
		INNER JOIN rental ym ON r.rental_id = ym.rental_id
		ORDER BY rental_year DESC, rental_month DESC;
	-- Update summary_table
	INSERT INTO summary_table
		SELECT rental_year, rental_month, category_name, COUNT(*) AS num_rentals
		FROM detailed_table
		GROUP BY rental_year, rental_month, category_name
		ORDER BY rental_year DESC, rental_month DESC, num_rentals DESC;
	-- Re-enable trigger
    ALTER TABLE detailed_table ENABLE TRIGGER update_summary_on_insert;
END;
$$;

-- Test the procedure
--- Checking the number of rows in 2 tables before refreshing
SELECT COUNT (*) FROM detailed_table; 
SELECT COUNT (*) FROM summary_table;
--- Call the procedure
CALL refresh_tables(); 
--- Checking the number of rows in 2 tables after refreshing
SELECT COUNT (*) FROM detailed_table;   -- 16044 rows
SELECT COUNT (*) FROM summary_table;   -- 80 rows


-- RESET THE ENVIRONMENT (OPTIONAL) --

-- Undo all the CREATE statements
DROP PROCEDURE IF EXISTS refresh_tables();
DROP TRIGGER IF EXISTS update_summary_on_insert ON detailed_table;
DROP FUNCTION IF EXISTS summary_table_update();
DROP TABLE IF EXISTS summary_table;
DROP TABLE IF EXISTS detailed_table;
DROP FUNCTION IF EXISTS rental_year;
DROP FUNCTION IF EXISTS rental_month;
