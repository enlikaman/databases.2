-- Laboratory Work 4: SQL Queries, Functions, and Operators
-- Author: (fill your name)
-- Note: Written for PostgreSQL (uses format(), COALESCE, window functions)

-- (Optional) Schema for reference:
-- CREATE TABLE employees (
--   employee_id SERIAL PRIMARY KEY,
--   first_name VARCHAR(50),
--   last_name VARCHAR(50),
--   department VARCHAR(50),
--   salary NUMERIC(10,2),
--   hire_date DATE,
--   manager_id INTEGER,
--   email VARCHAR(100)
-- );
-- CREATE TABLE projects (
--   project_id SERIAL PRIMARY KEY,
--   project_name VARCHAR(100),
--   budget NUMERIC(12,2),
--   start_date DATE,
--   end_date DATE,
--   status VARCHAR(20)
-- );
-- CREATE TABLE assignments (
--   assignment_id SERIAL PRIMARY KEY,
--   employee_id INTEGER REFERENCES employees(employee_id),
--   project_id INTEGER REFERENCES projects(project_id),
--   hours_worked NUMERIC(5,1),
--   assignment_date DATE
-- );

-- Task 1.1
-- Select all employees, full name, department, and salary
-- Task 1.1
SELECT
  employee_id,
  first_name || ' ' || last_name AS full_name,
  department,
  salary
FROM employees;

-- Task 1.2
-- Unique departments
SELECT DISTINCT department
FROM employees
WHERE department IS NOT NULL;

-- Task 1.3
-- Projects with budget_category
SELECT
  project_id,
  project_name,
  budget,
  CASE
    WHEN budget > 150000 THEN 'Large'
    WHEN budget BETWEEN 100000 AND 150000 THEN 'Medium'
    ELSE 'Small'
  END AS budget_category
FROM projects;

-- Task 1.4
-- Employee names and emails with COALESCE
SELECT
  employee_id,
  first_name || ' ' || last_name AS full_name,
  COALESCE(email, 'No email provided') AS email
FROM employees;

-- Task 2.1
-- Employees hired after 2020-01-01
SELECT
  employee_id,
  first_name || ' ' || last_name AS full_name,
  hire_date
FROM employees
WHERE hire_date > DATE '2020-01-01';

-- Task 2.2
-- Employees with salary between 60000 and 70000
SELECT
  employee_id,
  first_name || ' ' || last_name AS full_name,
  salary
FROM employees
WHERE salary BETWEEN 60000 AND 70000;

-- Task 2.3
-- Employees whose last name starts with 'S' or 'J'
SELECT
  employee_id,
  first_name || ' ' || last_name AS full_name,
  last_name
FROM employees
WHERE last_name LIKE 'S%' OR last_name LIKE 'J%';

-- Task 2.4
-- Employees who have a manager and work in IT department
SELECT
  employee_id,
  first_name || ' ' || last_name AS full_name,
  manager_id,
  department
FROM employees
WHERE manager_id IS NOT NULL
  AND department = 'IT';

-- Task 3.1
-- Employee names in uppercase, length of last name, first 3 chars of email
SELECT
  employee_id,
  UPPER(first_name || ' ' || last_name) AS full_name_upper,
  LENGTH(last_name) AS last_name_length,
  SUBSTRING(COALESCE(email, '') FROM 1 FOR 3) AS email_first3
FROM employees;

-- Task 3.2
-- Annual salary, monthly salary (rounded), 10% raise amount
SELECT
  employee_id,
  first_name || ' ' || last_name AS full_name,
  salary AS monthly_salary_current,
  (salary * 12) AS annual_salary,
  ROUND((salary * 12) / 12, 2) AS monthly_salary_rounded, -- equivalent to salary, shown for clarity
  ROUND(salary * 0.10, 2) AS ten_percent_raise -- raise on monthly salary; if raise on annual use (salary*12)*0.10
FROM employees;

-- Task 3.3
-- Formatted project string using format()
SELECT
  project_id,
  format('Project: %s - Budget: $%s - Status: %s', project_name, budget::text, status) AS project_summary
FROM projects;

-- Task 3.4
-- Years with the company (using current_date)
SELECT
  employee_id,
  first_name || ' ' || last_name AS full_name,
  hire_date,
  EXTRACT(YEAR FROM AGE(current_date, hire_date))::INT AS years_with_company
FROM employees;

-- Task 4.1
-- Average salary per department
SELECT
  department,
  ROUND(AVG(salary),2) AS avg_salary
FROM employees
GROUP BY department;

-- Task 4.2
-- Total hours worked on each project including project name
SELECT
  p.project_id,
  p.project_name,
  COALESCE(SUM(a.hours_worked),0) AS total_hours_worked
FROM projects p
LEFT JOIN assignments a ON p.project_id = a.project_id
GROUP BY p.project_id, p.project_name;

-- Task 4.3
-- Count employees in each department; only departments with more than 1 employee
SELECT
  department,
  COUNT(*) AS employee_count
FROM employees
GROUP BY department
HAVING COUNT(*) > 1;

-- Task 4.4
-- Max and min salary and total payroll
SELECT
  MAX(salary) AS max_salary,
  MIN(salary) AS min_salary,
  SUM(salary) AS total_payroll
FROM employees;

-- Task 5.1
-- UNION: Query1 employees with salary > 65000; Query2 employees hired after 2020-01-01
SELECT
  employee_id,
  first_name || ' ' || last_name AS full_name,
  salary
FROM employees
WHERE salary > 65000

UNION

SELECT
  employee_id,
  first_name || ' ' || last_name AS full_name,
  salary
FROM employees
WHERE hire_date > DATE '2020-01-01';

-- Task 5.2
-- INTERSECT: employees who work in IT AND have salary > 65000
SELECT
  employee_id,
  first_name || ' ' || last_name AS full_name,
  department,
  salary
FROM employees
WHERE department = 'IT'
INTERSECT
SELECT
  employee_id,
  first_name || ' ' || last_name AS full_name,
  department,
  salary
FROM employees
WHERE salary > 65000;

-- Task 5.3
-- EXCEPT: employees NOT assigned to any projects
-- We'll list employee_id, full_name, salary for consistency
SELECT
  employee_id,
  first_name || ' ' || last_name AS full_name,
  salary
FROM employees

EXCEPT

SELECT
  e.employee_id,
  e.first_name || ' ' || e.last_name AS full_name,
  e.salary
FROM employees e
JOIN assignments a ON e.employee_id = a.employee_id;

-- Task 6.1
-- EXISTS: employees who have at least one project assignment
SELECT
  employee_id,
  first_name || ' ' || last_name AS full_name
FROM employees e
WHERE EXISTS (
  SELECT 1 FROM assignments a WHERE a.employee_id = e.employee_id
);

-- Task 6.2
-- IN with subquery: employees working on projects with status 'Active'
SELECT
  DISTINCT e.employee_id,
  e.first_name || ' ' || e.last_name AS full_name
FROM employees e
WHERE e.employee_id IN (
  SELECT a.employee_id
  FROM assignments a
  WHERE a.project_id IN (
    SELECT project_id FROM projects WHERE status = 'Active'
  )
);

-- Task 6.3
-- ANY: employees whose salary is greater than ANY employee in Sales department
SELECT
  employee_id,
  first_name || ' ' || last_name AS full_name,
  salary
FROM employees
WHERE salary > ANY (
  SELECT salary FROM employees WHERE department = 'Sales'
);

-- Task 7.1
-- Employee name, department, avg hours across assignments, and rank within department by salary
SELECT
  e.employee_id,
  e.first_name || ' ' || e.last_name AS full_name,
  e.department,
  COALESCE(ROUND(AVG(a.hours_worked),1),0) AS avg_hours_worked,
  RANK() OVER (PARTITION BY e.department ORDER BY e.salary DESC) AS dept_salary_rank
FROM employees e
LEFT JOIN assignments a ON e.employee_id = a.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.department, e.salary
ORDER BY e.department, dept_salary_rank;

-- Task 7.2
-- Projects where total hours worked exceeds 150 hours
SELECT
  p.project_id,
  p.project_name,
  SUM(a.hours_worked) AS total_hours,
  COUNT(DISTINCT a.employee_id) AS num_employees_assigned
FROM projects p
JOIN assignments a ON p.project_id = a.project_id
GROUP BY p.project_id, p.project_name
HAVING SUM(a.hours_worked) > 150;

-- Task 7.3
-- Departments report: total employees, average salary, highest paid employee name
-- Use GREATEST and LEAST to show examples (e.g., compare avg and max salaries)
WITH dept_stats AS (
  SELECT
    department,
    COUNT(*) AS total_employees,
    ROUND(AVG(salary),2) AS avg_salary,
    MAX(salary) AS max_salary
  FROM employees
  GROUP BY department
),
highest_per_dept AS (
  SELECT
    d.department,
    e.employee_id,
    e.first_name || ' ' || e.last_name AS highest_paid_employee,
    e.salary
  FROM dept_stats d
  JOIN employees e ON e.department = d.department AND e.salary = d.max_salary
)
SELECT
  d.department,
  d.total_employees,
  d.avg_salary,
  h.highest_paid_employee,
  d.max_salary,
  -- Examples using GREATEST and LEAST (numeric comparison between average and max salary)
  GREATEST(d.avg_salary, d.max_salary) AS greatest_of_avg_and_max,
  LEAST(d.avg_salary, d.max_salary) AS least_of_avg_and_max
FROM dept_stats d
LEFT JOIN highest_per_dept h ON d.department = h.department
ORDER BY d.department;

-- End of file
