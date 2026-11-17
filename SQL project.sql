-- ==========================================
-- 1. Create Departments Table
-- ==========================================

CREATE TABLE departments (
    department_id   SMALLINT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL
);


-- ==========================================
-- 2. Create Employees Table
-- ==========================================

CREATE TABLE employees (
    employee_id    INTEGER PRIMARY KEY,
    first_name     VARCHAR(50) NOT NULL,
    last_name      VARCHAR(50) NOT NULL,
    department_id  SMALLINT REFERENCES departments(department_id),
    salary         NUMERIC(10,2) NOT NULL CHECK (salary >= 0),
    joining_date   DATE NOT NULL
);


-- ==========================================
-- 3. Create Projects Table
-- ==========================================

CREATE TABLE projects (
    project_id    INTEGER PRIMARY KEY,
    project_name  VARCHAR(100) NOT NULL,
    employee_id   INTEGER REFERENCES employees(employee_id),
    start_date    DATE NOT NULL,
    end_date      DATE,
    CHECK (end_date IS NULL OR end_date >= start_date)
);
 
-- View departments
SELECT *
FROM departments;

-- View employees
SELECT *
FROM employees;

-- View projects
SELECT *
FROM projects;

SELECT
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;

-- 1. List all employees along with the department they belong to.

SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id;


-- 2. Retrieve the first and last names of employees
      who earn more than 70,000.

SELECT
    first_name,
    last_name
FROM employees
WHERE salary > 70000;


-- 3. Find all employees who joined after "2020-01-01".

SELECT *
FROM employees
WHERE joining_date > '2020-01-01';


-- 4. List all department names and the number of employees in each department.

SELECT
    d.department_name,
    COUNT(e.employee_id) AS employee_count
FROM departments d
LEFT JOIN employees e
    ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY employee_count DESC;


-- 5. Get the names of employees who belong to the "Sales" department.

SELECT
    e.first_name,
    e.last_name
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
WHERE d.department_name = 'Sales';


-- 6. Show the names of employees and their departments,
--    ordered by their salary in descending order.

SELECT
    e.first_name,
    e.last_name,
    d.department_name,
    e.salary
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
ORDER BY e.salary DESC;


-- 7. List employees who have been with the company for more than 2 years.

SELECT
    employee_id,
    first_name,
    last_name,
    joining_date
FROM employees
WHERE joining_date < CURRENT_DATE - INTERVAL '2 years';


-- 8. Find the employee with the highest salary in each department.

SELECT
    d.department_name,
    e.first_name,
    e.last_name,
    e.salary
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
WHERE e.salary = (
    SELECT MAX(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
)
ORDER BY d.department_name;


-- 9. Retrieve all employees who belong to the "HR" department
--    and have been with the company for more than 3 years.

SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.joining_date
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
WHERE d.department_name = 'HR'
  AND e.joining_date < CURRENT_DATE - INTERVAL '3 years';


-- 10. Show the total salary expense for each department.

SELECT
    d.department_name,
    SUM(e.salary) AS total_salary_expense
FROM departments d
LEFT JOIN employees e
    ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY total_salary_expense DESC;


-- 11. List all employees along with the projects they are working on.

SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    p.project_name
FROM employees e
LEFT JOIN projects p
    ON e.employee_id = p.employee_id
ORDER BY e.employee_id;


-- 12. Show the names of employees who are working on
--     the project "Customer Satisfaction Analysis".

SELECT
    e.first_name,
    e.last_name
FROM employees e
JOIN projects p
    ON e.employee_id = p.employee_id
WHERE p.project_name = 'Customer Satisfaction Analysis';


-- 13. Retrieve all employees who are not assigned to any project.

SELECT
    e.employee_id,
    e.first_name,
    e.last_name
FROM employees e
LEFT JOIN projects p
    ON e.employee_id = p.employee_id
WHERE p.project_id IS NULL;


-- 14. Show the department name and the number of employees
--     working on a project in each department.

SELECT
    d.department_name,
    COUNT(DISTINCT e.employee_id) AS employees_working_on_projects
FROM departments d
LEFT JOIN employees e
    ON d.department_id = e.department_id
LEFT JOIN projects p
    ON e.employee_id = p.employee_id
GROUP BY d.department_id, d.department_name
ORDER BY employees_working_on_projects DESC;


-- 15. Find the names of employees who work on a project
--     that ends after "2021-12-31".

SELECT DISTINCT
    e.first_name,
    e.last_name,
    p.project_name,
    p.end_date
FROM employees e
JOIN projects p
    ON e.employee_id = p.employee_id
WHERE p.end_date > '2021-12-31';


-- 16. List the employees who work on more than one project.

SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    COUNT(p.project_id) AS project_count
FROM employees e
JOIN projects p
    ON e.employee_id = p.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
HAVING COUNT(p.project_id) > 1
ORDER BY project_count DESC;


-- 17. Find employees who are assigned to projects that started
--     after "2021-01-01" and are still ongoing.

SELECT DISTINCT
    e.employee_id,
    e.first_name,
    e.last_name,
    p.project_name,
    p.start_date,
    p.end_date
FROM employees e
JOIN projects p
    ON e.employee_id = p.employee_id
WHERE p.start_date > '2021-01-01'
  AND p.end_date IS NULL;


-- 18. Get the total number of projects for each employee.

SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    COUNT(p.project_id) AS total_projects
FROM employees e
LEFT JOIN projects p
    ON e.employee_id = p.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY total_projects DESC;


-- 19. Retrieve the names and project details of employees
--     who work on the project "Employee Performance Analytics".

SELECT
    e.first_name,
    e.last_name,
    p.project_id,
    p.project_name,
    p.start_date,
    p.end_date
FROM employees e
JOIN projects p
    ON e.employee_id = p.employee_id
WHERE p.project_name = 'Employee Performance Analytics';


-- 20. Find the average salary of employees in each department.

SELECT
    d.department_name,
    ROUND(AVG(e.salary), 2) AS average_salary
FROM departments d
LEFT JOIN employees e
    ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY average_salary DESC;


-- 21. List all departments and the total salary expense
--     for employees in each department.

SELECT
    d.department_name,
    COALESCE(SUM(e.salary), 0) AS total_salary_expense
FROM departments d
LEFT JOIN employees e
    ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY total_salary_expense DESC;


-- 22. Get the department with the highest average salary.

SELECT
    d.department_name,
    ROUND(AVG(e.salary), 2) AS average_salary
FROM departments d
JOIN employees e
    ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY average_salary DESC
LIMIT 1;


-- 23. Count the number of employees who joined each year.

SELECT
    EXTRACT(YEAR FROM joining_date) AS joining_year,
    COUNT(*) AS employee_count
FROM employees
GROUP BY EXTRACT(YEAR FROM joining_date)
ORDER BY joining_year;


-- 24. Show the number of projects each department is handling.

SELECT
    d.department_name,
    COUNT(p.project_id) AS total_projects
FROM departments d
LEFT JOIN employees e
    ON d.department_id = e.department_id
LEFT JOIN projects p
    ON e.employee_id = p.employee_id
GROUP BY d.department_id, d.department_name
ORDER BY total_projects DESC;


-- 25. Find the department with the maximum number
--     of employees working on multiple projects.

SELECT
    d.department_name,
    COUNT(*) AS employees_with_multiple_projects
FROM departments d
JOIN employees e
    ON d.department_id = e.department_id
JOIN projects p
    ON e.employee_id = p.employee_id
GROUP BY d.department_id, d.department_name, e.employee_id
HAVING COUNT(p.project_id) > 1
ORDER BY employees_with_multiple_projects DESC
LIMIT 1;