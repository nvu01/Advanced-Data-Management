-- DATA TRANSFORMATION FUNCTIONS --

-- Run this block to create a function that extracts month from the rental_date column
DROP FUNCTION IF EXISTS month_of_rental ();
CREATE FUNCTION month_of_rental (rental_date timestamp without time zone)
RETURNS int
LANGUAGE plpgsql
AS $$
DECLARE month_value int;
BEGIN
    SELECT EXTRACT (MONTH FROM rental_date) INTO month_value;
    RETURN month_value;
END; $$

-- Run this block to create a function that extracts year from the rental_date column
DROP FUNCTION IF EXISTS year_of_rental ();
CREATE FUNCTION year_of_rental (rental_date timestamp without time zone)
RETURNS int
LANGUAGE plpgsql
AS $$
DECLARE year_value int;
BEGIN
    SELECT EXTRACT (YEAR FROM rental_date) INTO year_value;
    RETURN year_value;
END; $$

-- Test the two functions
SELECT rental_id, year_of_rental(rental_date), month_of_rental(rental_date) FROM rental;

-- TABLE CREATION --

-- Run this block to create an empty detailed table
DROP TABLE IF EXISTS detailed_table;
CREATE TABLE detailed_table (
	rental_id int,
	year_of_rental int,
	month_of_rental int,
	category_name varchar (25)
);

-- Run this block to create a summary table that extracts and aggregates data from the detailed table
DROP TABLE IF EXISTS summary_table;
CREATE TABLE summary_table
AS SELECT year_of_rental, month_of_rental, category_name, COUNT(*) AS num_rentals
FROM detailed_table
GROUP BY year_of_rental, month_of_rental, category_name
ORDER BY year_of_rental DESC, month_of_rental DESC, num_rentals DESC;

-- Test the CREATE TABLE statements
SELECT * FROM detailed_table;
SELECT * FROM summary_table;

-- DATA EXTRACTION AND POPULATION --

-- Run this block to add raw data to the detailed table
INSERT INTO detailed_table
SELECT r.rental_id, year_of_rental (ym.rental_date), month_of_rental (ym.rental_date), c.name AS category_name
FROM rental r
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film_category fc ON i.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
INNER JOIN rental ym ON r.rental_id = ym.rental_id
ORDER BY year_of_rental DESC, month_of_rental DESC;

-- Test data extraction in detailed table
SELECT * FROM detailed_table;
SELECT * FROM summary_table;

-- AUTOMATED SUMMARY TABLE UPDATES --

-- Create a function that updates the summary table
DROP FUNCTION IF EXISTS summary_table_update();
CREATE FUNCTION summary_table_update()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	DELETE FROM summary_table;
	INSERT INTO summary_table
		SELECT year_of_rental, month_of_rental, category_name, COUNT (*) AS num_rentals
		FROM detailed_table
		GROUP BY year_of_rental, month_of_rental, category_name
		ORDER BY year_of_rental DESC, month_of_rental DESC, num_rentals DESC;
RETURN NEW;
END; 
$$;

-- Create a trigger that updates the summary table when data is inserted into the detailed table
DROP TRIGGER IF EXISTS update_trigger ON detailed_table;
CREATE TRIGGER update_trigger
AFTER INSERT
ON detailed_table
FOR EACH STATEMENT
EXECUTE PROCEDURE summary_table_update(); 

-- Test the trigger function

--- Run this code before and after adding a row to the detailed table. Row count should increase by 1 after adding a row.
SELECT COUNT (*) FROM detailed_table;

--- Run this code before and after adding a row to the detailed table. The max rental_id should change.
SELECT * FROM detailed_table ORDER BY rental_id DESC;

--- Insert a new row to the detailed table
INSERT INTO detailed_table VALUES (16050, 2007, 10, 'Horror');

--- The most current month in the summary table is Oct 2007
SELECT * FROM summary_table;

-- STORED PROCEDURE FOR DATA REFRESH --

--Create a procedure that refreshes data in both the detailed and summary tables
DROP PROCEDURE IF EXISTS refresh_tables();
CREATE PROCEDURE refresh_tables ()
LANGUAGE plpgsql
AS
$$
BEGIN
	DELETE FROM detailed_table;
	DELETE FROM summary_table;
	INSERT INTO detailed_table
		SELECT r.rental_id, year_of_rental (ym.rental_date), month_of_rental (ym.rental_date), c.name AS category_name
		FROM rental r
		INNER JOIN inventory i ON r.inventory_id = i.inventory_id
		INNER JOIN film_category fc ON i.film_id = fc.film_id
		INNER JOIN category c ON fc.category_id = c.category_id
		INNER JOIN rental ym ON r.rental_id = ym.rental_id
		ORDER BY year_of_rental DESC, month_of_rental DESC;
	INSERT INTO summary_table
		SELECT year_of_rental, month_of_rental, category_name, COUNT(*) AS num_rentals
		FROM detailed_table
		GROUP BY year_of_rental, month_of_rental, category_name
		ORDER BY year_of_rental DESC, month_of_rental DESC, num_rentals DESC;
RETURN;
END;
$$;

-- Test the procedure

--- Drop the trigger first to avoid conflicts with the procedure
DROP TRIGGER update_trigger ON detailed_table;

--- Call the procedure
--- The procedure will not only refresh the data but also remove any test data that was manually inserted (like the row added when testing the trigger)
CALL refresh_tables(); 

--- Checking the number of rows in 2 tables
SELECT COUNT (*) FROM detailed_table; 
SELECT COUNT (*) FROM summary_table;


-- RESET THE ENVIRONMENT (OPTIONAL) --

-- Undo all the CREATE statements
DROP PROCEDURE IF EXISTS refresh_tables();
DROP TRIGGER IF EXISTS update_trigger ON detailed_table;
DROP FUNCTION IF EXISTS summary_table_update();
DROP TABLE IF EXISTS summary_table;
DROP TABLE IF EXISTS detailed_table;
DROP FUNCTION IF EXISTS year_of_rental;
DROP FUNCTION IF EXISTS month_of_rental;
