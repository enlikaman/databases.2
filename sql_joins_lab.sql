
-- SQL Joins Lab: All queries collected into a single .sql file
-- Author: ChatGPT assistant
-- Encoding: UTF-8
-- Note: Run this file in PostgreSQL / MySQL (some FULL JOINs may vary by DB).

/* =============================
   Part 1: Database Setup
   ============================= */

-- Create table: employees
CREATE TABLE employees (
  emp_id INT PRIMARY KEY,
  emp_name VARCHAR(50),
  dept_id INT,
  salary DECIMAL(10,2)
);

-- Create table: departments
CREATE TABLE departments (
  dept_id INT PRIMARY KEY,
  dept_name VARCHAR(50),
  location VARCHAR(50)
);

-- Create table: projects
CREATE TABLE projects (
  project_id INT PRIMARY KEY,
  project_name VARCHAR(50),
  dept_id INT,
  budget DECIMAL(10,2)
);

-- Insert data into employees
INSERT INTO employees (emp_id, emp_name, dept_id, salary) VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);

-- Insert data into departments
INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');

-- Insert data into projects
INSERT INTO projects (project_id, project_name, dept_id, budget) VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);


/* =============================
   Part 2: CROSS JOIN Exercises
   ============================= */

-- Exercise 2.1: Basic CROSS JOIN
SELECT e.emp_name, d.dept_name
FROM employees e CROSS JOIN departments d;

-- Expected number of rows = N_employees * M_departments
-- Here N = 5, M = 4 => 5 * 4 = 20 rows

-- Exercise 2.2: Alternative CROSS JOIN Syntax
-- a) Comma notation
SELECT e.emp_name, d.dept_name
FROM employees e, departments d;

-- b) INNER JOIN with TRUE condition
SELECT e.emp_name, d.dept_name
FROM employees e INNER JOIN departments d ON TRUE;

-- Exercise 2.3: Practical CROSS JOIN (employee × project schedule)
SELECT e.emp_name, p.project_name
FROM employees e CROSS JOIN projects p;


/* =============================
   Part 3: INNER JOIN Exercises
   ============================= */

-- Exercise 3.1: Basic INNER JOIN with ON
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

-- Expected rows: only employees with a dept_id matching departments (Tom Brown excluded because dept_id IS NULL)

-- Exercise 3.2: INNER JOIN with USING
SELECT emp_name, dept_name, location
FROM employees
INNER JOIN departments USING (dept_id);

-- Note: USING removes duplicate dept_id column in output (one shared column)

-- Exercise 3.3: NATURAL INNER JOIN
-- NATURAL JOIN will join on columns with the same name (dept_id)
SELECT emp_name, dept_name, location
FROM employees
NATURAL INNER JOIN departments;

-- Exercise 3.4: Multi-table INNER JOIN (employees → departments → projects)
SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN projects p ON d.dept_id = p.dept_id;


/* =============================
   Part 4: LEFT JOIN Exercises
   ============================= */

-- Exercise 4.1: Basic LEFT JOIN (include employees without department)
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;

-- Tom Brown will appear with emp_dept = NULL and dept_dept / dept_name = NULL

-- Exercise 4.2: LEFT JOIN with USING
SELECT emp_name, dept_id, dept_name
FROM employees
LEFT JOIN departments USING (dept_id);

-- Exercise 4.3: Find Unmatched Records (employees without department)
SELECT e.emp_name, e.dept_id
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;

-- Exercise 4.4: LEFT JOIN with Aggregation (departments with employee counts)
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;


/* =============================
   Part 5: RIGHT JOIN Exercises
   ============================= */

-- Exercise 5.1: Basic RIGHT JOIN (all departments with their employees)
SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- Exercise 5.2: Convert to LEFT JOIN (reverse table order)
SELECT e.emp_name, d.dept_name
FROM departments d
LEFT JOIN employees e ON e.dept_id = d.dept_id;

-- Exercise 5.3: Find Departments Without Employees
SELECT d.dept_name, d.location
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;


/* =============================
   Part 6: FULL JOIN Exercises
   ============================= */

-- Exercise 6.1: Basic FULL JOIN (all employees and all departments)
-- Note: FULL JOIN may not be supported in some MySQL versions (prior to 8.0); PostgreSQL supports it.
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id;

-- Records with NULL on the left side: departments that have no matching employee (e.emp_id IS NULL)
-- Records with NULL on the right side: employees with no matching department (e.g., Tom Brown: d.dept_id IS NULL)

-- Exercise 6.2: FULL JOIN with Projects (departments and projects)
SELECT d.dept_name, p.project_name, p.budget
FROM departments d
FULL JOIN projects p ON d.dept_id = p.dept_id;

-- Exercise 6.3: Find Orphaned Records using FULL JOIN
SELECT
  CASE
    WHEN e.emp_id IS NULL THEN 'Department without employees'
    WHEN d.dept_id IS NULL THEN 'Employee without department'
    ELSE 'Matched'
  END AS record_status,
  e.emp_name,
  d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;


/* =============================
   Part 7: ON vs WHERE Clause
   ============================= */

-- Exercise 7.1: Filtering in ON Clause (Outer Join)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

-- Exercise 7.2: Filtering in WHERE Clause (Outer Join)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

-- Explanation (comment):
-- Query 1 keeps all employees but only matches departments located in 'Building A' (non-matching departments become NULL).
-- Query 2 filters the joined rows after the join: rows where d.location IS NOT 'Building A' (including NULL) are excluded, so employees without a Building A department are removed.

-- Exercise 7.3: ON vs WHERE with INNER JOIN
-- Using INNER JOIN these two produce the same result because INNER JOIN requires a match; the filter in ON or WHERE effectively both restrict rows to matched rows.
-- Example:
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';


/* =============================
   Part 8: Complex JOIN Scenarios
   ============================= */

-- Exercise 8.1: Multiple Joins with Different Types
SELECT
  d.dept_name,
  e.emp_name,
  e.salary,
  p.project_name,
  p.budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;

-- Exercise 8.2: Self Join (add manager_id column and sample updates)
ALTER TABLE employees ADD COLUMN manager_id INT;

UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;

-- Self join query to show employees with their managers
SELECT
  e.emp_name AS employee,
  m.emp_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;

-- Exercise 8.3: Join with Subquery (departments with avg salary > 50000)
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM departments d
INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;


/* =============================
   Lab Questions (answers as comments)
   ============================= */

-- 1) Difference between INNER JOIN and LEFT JOIN:
-- INNER JOIN returns only matching rows from both tables.
-- LEFT JOIN returns all rows from the left table and matched rows from the right (NULLs for no match).

-- 2) When to use CROSS JOIN:
-- Useful for generating combinations (price lists, schedules, test matrices) where every pairing is needed.

-- 3) ON vs WHERE for outer joins:
-- For outer joins, placing conditions in ON affects which rows are considered matched; WHERE filters after join and can turn an outer join into an effective inner join by removing NULL-rows.

-- 4) SELECT COUNT(*) FROM table1 CROSS JOIN table2 when 5 and 10 rows:
-- Result = 5 * 10 = 50.

-- 5) How NATURAL JOIN chooses columns:
-- NATURAL JOIN automatically joins on all columns with the same name in both tables.

-- 6) Risks of NATURAL JOIN:
-- Accidental joins on unintended columns if schema changes; less explicit and therefore fragile and less readable.

-- 7) Convert LEFT JOIN to RIGHT JOIN:
-- Given: SELECT * FROM A LEFT JOIN B ON A.id = B.id
-- Equivalent with RIGHT JOIN: SELECT * FROM B RIGHT JOIN A ON A.id = B.id
-- (Or swap table order and use LEFT JOIN: SELECT * FROM B RIGHT JOIN A ...)

-- 8) When use FULL OUTER JOIN:
-- Use when you need all rows from both sides and want to see unmatched rows from both tables (e.g., reconciliation tasks).

/* =============================
   Additional Challenges (Optional)
   ============================= */

-- 1) Simulate FULL OUTER JOIN using UNION (for DBs without FULL JOIN)
SELECT e.emp_id, e.emp_name, d.dept_id, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
UNION
SELECT e.emp_id, e.emp_name, d.dept_id, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- 2) Employees who work in departments that have more than one project
SELECT DISTINCT e.emp_name
FROM employees e
JOIN projects p ON e.dept_id = p.dept_id
JOIN (
  SELECT dept_id FROM projects GROUP BY dept_id HAVING COUNT(*) > 1
) multi ON p.dept_id = multi.dept_id;

-- 3) Hierarchical query (employee → manager → manager's manager)
-- Note: the depth shown here is 2 levels; for arbitrary depth use recursive CTE (Postgres / MySQL 8+)
WITH RECURSIVE org AS (
  SELECT emp_id, emp_name, manager_id, emp_name AS full_path, 1 AS level FROM employees WHERE manager_id IS NOT NULL
  UNION ALL
  SELECT e.emp_id, e.emp_name, e.manager_id, o.full_path || ' -> ' || e.emp_name, o.level + 1
  FROM employees e
  JOIN org o ON e.manager_id = o.emp_id
)
SELECT * FROM org;

-- 4) Find all pairs of employees who work in the same department
SELECT a.emp_name AS emp1, b.emp_name AS emp2, a.dept_id
FROM employees a
JOIN employees b ON a.dept_id = b.dept_id AND a.emp_id < b.emp_id
WHERE a.dept_id IS NOT NULL;


-- End of file
