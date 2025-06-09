-- Create example tables for employees and departments
CREATE TABLE dep (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100)
);
CREATE TABLE emp (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    id_d INT,
    salary NUMERIC(10,2)
);

-- Insert sample data
INSERT INTO dep (name) VALUES ('IT'), ('Sales'), ('HR');
INSERT INTO emp (name, id_d, salary) VALUES
    ('Alice', 1, 70000),
    ('Bob', 1, 65000),
    ('Charlie', 2, 80000),
    ('David', 3, 55000),
    ('Eve', 2, 75000);

-- Basic JOIN example with subquery for average salary
SELECT e.name, e.salary, d.name AS department
FROM emp e
JOIN dep d ON e.id_d = d.id
JOIN (
    SELECT id_d, AVG(salary) AS avg_salary
    FROM emp
    GROUP BY id_d
) AS avg_data ON e.id_d = avg_data.id_d
WHERE e.salary > avg_data.avg_salary;

-- CTE example: select employees in IT department
WITH it_emp AS (
    SELECT id, name, id_d, salary
    FROM emp
    WHERE id_d = (SELECT id FROM dep WHERE name = 'IT')
)
SELECT e.name, e.salary, d.name AS department
FROM it_emp e
JOIN dep d ON e.id_d = d.id;

-- Another CTE example: filter by average salary
WITH avg_cte AS (
    SELECT id_d, AVG(salary) AS avg_salary
    FROM emp
    GROUP BY id_d
)
SELECT e.name, e.salary, d.name AS department
FROM emp e
JOIN dep d ON e.id_d = d.id
JOIN avg_cte a ON e.id_d = a.id_d
WHERE e.salary >= a.avg_salary;

-- Recursive CTE: generate sequence from 1 to 5
WITH RECURSIVE seq (n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 5
)
SELECT n FROM seq;

-- Create table for staff hierarchy (self-referential foreign key)
CREATE TABLE staff (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    manager_id INT REFERENCES staff(emp_id)
);

-- Insert sample staff hierarchy
INSERT INTO staff (emp_id, emp_name, manager_id) VALUES
    (1, 'CEO', NULL),
    (2, 'VP of Engineering', 1),
    (3, 'VP of Sales', 1),
    (4, 'Lead Engineer', 2),
    (5, 'Software Engineer 1', 4),
    (6, 'Software Engineer 2', 4),
    (7, 'Sales Manager', 3),
    (8, 'Sales Rep 1', 7),
    (9, 'Sales Rep 2', 7);

-- Recursive CTE to display organizational hierarchy
WITH RECURSIVE emp_hierarchy (emp_id, emp_name, manager_id, level) AS (
    SELECT emp_id, emp_name, manager_id, 0 AS level
    FROM staff
    WHERE manager_id IS NULL
    UNION ALL
    SELECT s.emp_id, s.emp_name, s.manager_id, eh.level + 1
    FROM staff s
    JOIN emp_hierarchy eh ON s.manager_id = eh.emp_id
)
SELECT emp_id, emp_name, manager_id, level, LPAD('', level * 4, ' ') || emp_name AS indented_name
FROM emp_hierarchy
ORDER BY level, manager_id, emp_id;
