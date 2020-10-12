-- list employee number, last name, first name, sex, and salary
SELECT e.emp_no, e.last_name, e.first_name, e.sex, s.salary
FROM employees e
JOIN salaries s
ON e.emp_no = s.emp_no;

-- list first name, last name, and hire date for employees hired in 1986
SELECT first_name, last_name, hire_date 
FROM employees
WHERE hire_date BETWEEN '1986-1-1' and '1986-12-31' ;
