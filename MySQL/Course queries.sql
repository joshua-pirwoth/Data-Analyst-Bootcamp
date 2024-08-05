-- Case statements

SELECT first_name,
last_name,
age,
CASE
	WHEN age < 30 THEN 'Young'
    WHEN age BETWEEN 31 AND 50 THEN 'Old'
    WHEN age >= 50 THEN "On death's door"
END
AS age_bracket
FROM employee_demographics
;

-- Pay Increase and Bonus
-- <50,000: 5%
-- > 50,000: 7%
-- Finace: 10% Bonus

SELECT first_name,
last_name,
salary,
CASE
	WHEN salary < 50000 THEN (salary * 1.05)
    WHEN salary > 50000 THEN (salary * 1.07)
END AS new_salary,
CASE
	WHEN dept_id = 6 THEN (salary * 1.1)
END AS bonus
FROM employee_salary
;

-- Sub-queries

-- All employees whose id is matches a department id of 1
SELECT *
FROM employee_demographics
WHERE employee_id IN (
	SELECT employee_id
    FROM employee_salary
    WHERE dept_id = 1
);

-- Average of the two max ages for each gender
SELECT AVG(max_age) AS avg_max_age
FROM (
	SELECT  gender,
	MAX(age) AS max_age
	FROM employee_demographics
	GROUP BY gender
    ) AS agg_table
;


-- Window Functions

-- View average of salaries based off on the genders, without grouping them into two rows
SELECT dem.first_name, dem.last_name, gender, AVG(salary) OVER(PARTITION BY gender) AS gender_salary_avg
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
;

-- View sum of salaries based off on the genders, without grouping them into two rows
SELECT dem.first_name, dem.last_name, gender, SUM(salary) OVER(PARTITION BY gender) AS gender_salary_avg
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
;

-- Retrieve a cumulative sum for all employees
SELECT dem.first_name, dem.last_name, gender, salary, SUM(salary) OVER(PARTITION BY gender ORDER BY dem.employee_id) AS cumulative_total
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
;

SELECT dem.employee_id, dem.first_name, dem.last_name, gender, salary,
ROW_NUMBER() OVER (PARTITION BY gender ORDER BY salary DESC) AS row_num,
RANK() OVER (PARTITION BY gender ORDER BY salary DESC) AS rank_num,
DENSE_RANK() OVER (PARTITION BY gender ORDER BY salary DESC) AS dense_rank_num
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
    ON dem.employee_id = sal.employee_id;



-- CTE's 

WITH CTE_Example AS
(
	SELECT gender, AVG(salary) AS avg_salary,
	MAX(salary) AS max_salary,
	MIN(salary) AS min_salary
	FROM employee_demographics AS dem
	JOIN employee_salary AS sal
		ON dem.employee_id = sal.employee_id
	GROUP BY gender
)
SELECT *
FROM CTE_Example
;

# Calculating an average of the average salary of both genders
WITH CTE_Example AS
(
	SELECT gender, AVG(salary) AS avg_salary,
	MAX(salary) AS max_salary,
	MIN(salary) AS min_salary
	FROM employee_demographics AS dem
	JOIN employee_salary AS sal
		ON dem.employee_id = sal.employee_id
	GROUP BY gender0
)
SELECT AVG(avg_salary)
FROM CTE_Example
;

# Using more than one CTE

WITH CTE_Example1 AS
(
SELECT employee_id, gender, birth_date
FROM employee_demographics
WHERE birth_date > '1980-01-01'
),
CTE_Example2 AS
(
SELECT employee_id, salary
FROM employee_salary
WHERE salary > 50000
)
SELECT *
FROM CTE_Example1
JOIN CTE_Example2
	ON CTE_Example1.employee_id = CTE_Example2.employee_id
;


-- Temporary Tables

-- Method 1 of creating Temp Tables: Manually creatinga and inserting data
CREATE TEMPORARY TABLE temp_table (
	first_name VARCHAR(50),
	last_name VARCHAR(50),
    favourite_movie VARCHAR(100)
);

SELECT * FROM temp_table;

INSERT INTO temp_table
VALUES ('Joshua', 'Pirwoth', 'Angry Birds 1');

-- Method 2 of creating Temp Tables: Using data from an existing table

CREATE TEMPORARY TABLE salary_of_50k_plus
SELECT *
FROM employee_salary
WHERE salary >= 50000;

SELECT * FROM salary_of_50k_plus;


-- Stored Procedures

SELECT *
FROM employee_salary
WHERE salary >= 50000;

CREATE PROCEDURE large_salaries()
SELECT *
FROM employee_salary
WHERE salary >= 50000;

CALL large_salaries();

-- Using more than 1 query in a stored procedure

DELIMITER $$
CREATE PROCEDURE big_and_small_salaries()
BEGIN
	SELECT *
	FROM employee_salary
	WHERE salary > 50000;
	SELECT *
	FROM employee_salary
	WHERE salary < 30000;
END $$

CALL big_and_small_salaries();

DELIMITER ;


-- Triggers and Events

DELIMITER $$
CREATE TRIGGER employee_insert
	AFTER INSERT ON employee_salary
    FOR EACH ROW
BEGIN
	INSERT INTO employee_demographics (employee_id, first_name, last_name)
    VALUES (NEW.employee_id, NEW.first_name, NEW.last_name);
END $$
DELIMITER ;

-- Testing the Trigger

INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES (13, 'John', 'Doe', 'Data Scientist', 120000, NULL);

SELECT *
FROM employee_demographics;

SELECT *
FROM employee_salary;


-- Events

DELIMITER $$
CREATE EVENT delete_retirees
ON SCHEDULE EVERY 30 SECOND
DO
BEGIN
	DELETE
    FROM employee_demographics
    WHERE age >= 60;
END $$
DELIMITER ;

SELECT *
FROM employee_demographics;

SHOW VARIABLES LIKE 'event%';

SET GLOBAL event_scheduler = 'ON';














