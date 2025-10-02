-- Laboratory Work #3 - Advanced DML operations (PostgreSQL)
-- PART A: DATABASE AND TABLE SETUP

DROP DATABASE IF EXISTS advanced_lab;
CREATE DATABASE advanced_lab;
\c advanced_lab



-- Create tables with constraints and sensible types
CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100) UNIQUE NOT NULL,
    budget INTEGER DEFAULT 0 CHECK (budget >= 0),
    manager_id INTEGER -- will reference employees.emp_id after employees created
);

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    -- department stored as dept_name (string) per task spec; nullable allowed
    department VARCHAR(100),
    salary INTEGER DEFAULT 30000 CHECK (salary >= 0),
    hire_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

-- Now we can add manager_id FK referencing employees
ALTER TABLE departments
    ADD CONSTRAINT fk_manager_emp FOREIGN KEY (manager_id) REFERENCES employees(emp_id) ON DELETE SET NULL;

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(150) NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id) ON DELETE SET NULL,
    start_date DATE,
    end_date DATE,
    budget INTEGER DEFAULT 0 CHECK (budget >= 0)
);

-- PART B: ADVANCED INSERT OPERATIONS
-- Insert sample employees (full columns)
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES
('Alice','Ivanova','IT',55000,'2019-06-15','Active'),
('Bob','Sidorov','Sales',45000,'2021-03-10','Active'),
('Carla','Petrova',NULL,38000,'2024-02-01','Active'),
('Dmitry','Kuznetsov','IT',82000,'2015-11-20','Active'),
('Elena','Smirnova','HR',60000,'2018-07-05','Active');

-- 2. INSERT with column specification (only certain columns)
INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (999, 'Test','User','QA'); -- specifying emp_id explicitly (note: may collide; for testing)

-- 3. INSERT with DEFAULT values (salary & status use defaults)
INSERT INTO employees (first_name, last_name, department, hire_date)
VALUES ('Default','Salary','Support', CURRENT_DATE);

-- 4. INSERT multiple rows in single statement (departments)
INSERT INTO departments (dept_name, budget, manager_id)
VALUES
('IT', 200000, NULL),
('Sales', 150000, NULL),
('HR', 80000, NULL);

-- 5. INSERT with expressions (salary = 50000 * 1.1, hire_date = CURRENT_DATE)
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Express','Insert','IT', (50000 * 1.1)::INTEGER, CURRENT_DATE);

-- 6. INSERT from SELECT (subquery) -> create temp table and populate with employees from 'IT'
CREATE TEMP TABLE temp_employees AS
SELECT * FROM employees WHERE department = 'IT';

-- Verify temp_employees
-- SELECT * FROM temp_employees;

-- PART C: COMPLEX UPDATE OPERATIONS

-- 7. UPDATE with arithmetic expressions: increase all salaries by 10%
-- Comment: use integer arithmetic rounding down; cast to integer after multiplication.
UPDATE employees
SET salary = (salary * 1.10)::INTEGER
WHERE salary IS NOT NULL;

-- 8. UPDATE with WHERE clause and multiple conditions
UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
  AND hire_date < '2020-01-01';

-- 9. UPDATE using CASE expression to set department by salary bands
UPDATE employees
SET department = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END;

-- 10. UPDATE with DEFAULT: set department to DEFAULT (here department column has no declared DEFAULT,
-- so to "reset" we will set to NULL unless a DEFAULT is defined. To demonstrate, alter column to have DEFAULT 'Unassigned'
ALTER TABLE employees ALTER COLUMN department SET DEFAULT 'Unassigned';

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

-- 11. UPDATE with subquery: Update department budget to be 20% higher than avg salary of employees in that department.
-- Note: employees.department stores dept_name; use join on dept_name.
UPDATE departments d
SET budget = GREATEST(0, (sub.avg_salary * 1.20)::INTEGER)
FROM (
    SELECT department AS dept_name, AVG(salary)::NUMERIC AS avg_salary
    FROM employees
    WHERE department IS NOT NULL
    GROUP BY department
) AS sub
WHERE d.dept_name = sub.dept_name;

-- 12. UPDATE multiple columns in single statement
UPDATE employees
SET salary = (salary * 1.15)::INTEGER,
    status = 'Promoted'
WHERE department = 'Sales';

-- PART D: ADVANCED DELETE OPERATIONS

-- Insert sample rows for delete testing
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES
('Term','Inated','Ops',30000,'2022-01-01','Terminated'),
('Low','Paid',NULL,35000,'2024-06-01','Active'),
('Old','Timer','Finance',70000,'2010-05-20','Active');

-- 13. DELETE with simple WHERE condition
DELETE FROM employees
WHERE status = 'Terminated';

-- 14. DELETE with complex WHERE clause
DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;

-- 15. DELETE with subquery: delete departments not referenced by any employee (by dept_name)
DELETE FROM departments
WHERE dept_id NOT IN (
    SELECT DISTINCT d.dept_id
    FROM departments d
    JOIN employees e ON e.department = d.dept_name
);

-- 16. DELETE with RETURNING clause: delete old projects and return deleted rows
-- Insert sample projects
INSERT INTO projects (project_name, dept_id, start_date, end_date, budget)
VALUES
('Legacy','1','2018-01-01','2022-12-31',40000),
('ActiveProject','1','2024-01-01','2025-12-31',120000),
('SmallOld','2','2021-05-01','2022-06-01',10000);

-- Delete projects ended before 2023-01-01 and return deleted rows
DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

-- PART E: OPERATIONS WITH NULL VALUES

-- 17. INSERT with NULL values
INSERT INTO employees (first_name, last_name, salary, department)
VALUES ('Nully','Value', NULL, NULL);

-- 18. UPDATE NULL handling: set department to 'Unassigned' where NULL
UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

-- 19. DELETE with NULL conditions: delete employees with NULL salary OR NULL department
DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;

-- PART F: RETURNING CLAUSE OPERATIONS

-- 20. INSERT with RETURNING: return auto-generated emp_id and full name
INSERT INTO employees (first_name, last_name, department, salary)
VALUES ('Returned','Insert','Marketing',48000)
RETURNING emp_id, (first_name || ' ' || last_name) AS full_name;

-- 21. UPDATE with RETURNING: increase salary for IT dept by 5000, return emp_id, old salary, new salary
-- To capture old salary we use a CTE
WITH updated AS (
    SELECT emp_id, salary AS old_salary
    FROM employees
    WHERE department = 'IT'
)
UPDATE employees e
SET salary = e.salary + 5000
FROM updated u
WHERE e.emp_id = u.emp_id
RETURNING e.emp_id, u.old_salary, e.salary AS new_salary;

-- 22. DELETE with RETURNING all columns: delete employees hired before 2020-01-01
DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

-- PART G: ADVANCED DML PATTERNS

-- 23. Conditional INSERT: only add employee if same name doesn't exist
INSERT INTO employees (first_name, last_name, department, salary)
SELECT 'Unique','Person','QA',42000
WHERE NOT EXISTS (
    SELECT 1 FROM employees WHERE first_name = 'Unique' AND last_name = 'Person'
);

-- 24. UPDATE with JOIN logic using subqueries:
-- If department budget > 100000 => increase salary by 10%, else by 5%
UPDATE employees e
SET salary = CASE
    WHEN d.budget > 100000 THEN (e.salary * 1.10)::INTEGER
    ELSE (e.salary * 1.05)::INTEGER
END
FROM departments d
WHERE e.department = d.dept_name;

-- 25. Bulk operations: insert 5 employees in single statement, then update their salaries to +10%
INSERT INTO employees (first_name, last_name, department, salary)
VALUES
('Bulk1','A','Dev',35000),
('Bulk2','B','Dev',36000),
('Bulk3','C','Dev',37000),
('Bulk4','D','Dev',38000),
('Bulk5','E','Dev',39000);

-- Update all just-inserted Dev employees by 10%
UPDATE employees
SET salary = (salary * 1.10)::INTEGER
WHERE department = 'Dev';

-- 26. Data migration simulation: create archive table, move 'Inactive' employees there, then delete from original
CREATE TABLE IF NOT EXISTS employee_archive AS TABLE employees WITH NO DATA;

-- Add a migration timestamp column to archive for audit
ALTER TABLE employee_archive
ADD COLUMN archived_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Insert inactive employees into archive
INSERT INTO employee_archive
SELECT e.*, CURRENT_TIMESTAMP AS archived_at
FROM employees e
WHERE e.status = 'Inactive';

-- Delete them from original table
DELETE FROM employees
WHERE status = 'Inactive';

-- 27. Complex business logic:
-- Update project end_date to be 30 days later for projects where budget > 50000
-- AND associated department has more than 3 employees.
UPDATE projects p
SET end_date = (p.end_date + INTERVAL '30 days')::DATE
FROM (
    SELECT d.dept_id
    FROM departments d
    JOIN employees e ON e.department = d.dept_name
    GROUP BY d.dept_id
    HAVING COUNT(e.emp_id) > 3
) AS big_depts
WHERE p.dept_id = big_depts.dept_id
  AND p.budget > 50000
  AND p.end_date IS NOT NULL;


