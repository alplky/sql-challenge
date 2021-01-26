# sql-challenge
## Background
Conduct research on employees working in the 1980s and 1990s at the company Pewlett Hackard. The only data that remains from the time period are 6 CSV files. 

## Objectives
This research project consists of designing the tables that will hold the CSV data, import the CSVs into a SQL database, and answer a series of questions about the data. The tasks will consist of:

    1. Data Modeling
    2. Data Engineering
    3. Data Analysis

## Data Modeling
After inspecting the CSVs, create an ERD using Quick Database Diagrams.

![Employees_ERD](EmployeeSQL/employees_erd.png)

## Data Engineering
Create a table schema for each of the 6 CSV files with specific data types, primary keys, foreign keys, and constraints.

```pgsql
-- create titles table
CREATE TABLE titles (
	title_id varchar(5) PRIMARY KEY,
	title varchar(30)
);

-- create employees table
CREATE TABLE employees (
	emp_no varchar(10) PRIMARY KEY,
	emp_title_id varchar(5) references titles(title_id),
	birth_date date,
	first_name varchar(45),
	last_name varchar(45),
	sex varchar(1),
	hire_date date
);

-- create departments table
CREATE TABLE departments (
	dept_no varchar(5) PRIMARY KEY,
	dept_name varchar(30)
);

-- create department managers table
CREATE TABLE dept_manager (
	dept_no varchar(5) references departments(dept_no),
	emp_no varchar(10)
);

-- create department employees table
CREATE TABLE dept_emp (
	emp_no varchar(10) references employees(emp_no),
	dept_no varchar(5) references departments(dept_no)
);

-- create salaries table
CREATE TABLE salaries (
	emp_no varchar(10) references employees(emp_no),
	salary int
);
```

## Data Analysis
1. List the following details of each employee: employee number, last name, first name, sex, and salary.
```pgsql
SELECT e.emp_no, e.last_name, e.first_name, e.sex, s.salary
FROM employees e
JOIN salaries s
ON e.emp_no = s.emp_no;
```
2. List first name, last name, and hire date for employees who were hired in 1986.
```pgsql
SELECT first_name, last_name, hire_date 
FROM employees
WHERE hire_date BETWEEN '1986-1-1' and '1986-12-31'
ORDER BY hire_date ASC;
```
3. List the manager of each department with the following information: department number, department name, the manager's employee number, last name, first name.
```pgsql
SELECT dm.dept_no, d.dept_name, dm.emp_no, e.last_name, e.first_name 
FROM dept_manager dm
JOIN employees e
ON dm.emp_no = e.emp_no
JOIN departments d
ON dm.dept_no = d.dept_no
ORDER BY d.dept_name ASC;
```
4. List the department of each employee with the following information: employee number, last name, first name, and department name.
```pgsql
SELECT e.emp_no, e.last_name, e.first_name, d.dept_name
FROM employees e
JOIN dept_emp de 
ON e.emp_no = de.emp_no
JOIN departments d
ON d.dept_no = de.dept_no
ORDER BY d.dept_name ASC;
```
5. List first name, last name, and sex for employees whose first name is "Hercules" and last names begin with "B."
```pgsql
SELECT first_name, last_name, sex
FROM employees 
WHERE first_name = 'Hercules' AND last_name LIKE 'B%'
ORDER BY last_name ASC;
```
6. List all employees in the Sales department, including their employee number, last name, first name, and department name.
```pgsql
SELECT e.emp_no, e.last_name, e.first_name, d.dept_name
FROM employees e
JOIN dept_emp de 
ON e.emp_no = de.emp_no
JOIN departments d
ON d.dept_no = de.dept_no
WHERE d.dept_name = 'Sales';
```
7. List all employees in the Sales and Development departments, including their employee number, last name, first name, and department name.
```pgsql
SELECT e.emp_no, e.last_name, e.first_name, d.dept_name
FROM employees e
JOIN dept_emp de 
ON e.emp_no = de.emp_no
JOIN departments d
ON d.dept_no = de.dept_no
WHERE d.dept_name = 'Sales' OR d.dept_name = 'Development'
ORDER BY d.dept_name ASC;
```
8. In descending order, list the frequency count of employee last names, i.e., how many employees share each last name.
```pgsql
SELECT last_name, count(emp_no) as num_employees_with_same_last_name
FROM employees
GROUP BY last_name
ORDER BY num_employees_with_same_last_name DESC;
```

## Bonus
In a Jupyter Notebook, import the SQL database into Pandas and create an engine via SQLalchemy to read the tables and create the following graphs:
1. A histogram to visualize the most common salary ranges for employees.
2. A bar chart of average salary by title.

#### Import the SQL database into Pandas
```python
# dependencies and set up
from sqlalchemy import create_engine
import pandas as pd
from matplotlib import pyplot as plt

# establish connection string
connection_str = f"database_type://user:password@host/database"

# create engine
engine = create_engine(connection_str)
```
#### Histogram of Salary Ranges for Employees
```python
# set command to a variable
cmd = "SELECT * FROM salaries"

# read table
df = pd.read_sql(cmd, con=engine)

# histogram of most common salary ranges for employees
df["salary"].hist(color="mediumseagreen")
plt.title("Salary Ranges for Employees")
plt.xlabel("Annual Salary")
plt.ylabel("Number of Employees")
plt.savefig("images/histogram_salaries.png")
plt.show()
```
![Salary_Histogram](EmployeeSQL/images/histogram_salaries.png)

#### Bar Chart of Average Salary by Job Title
First, a view was created in SQL of the average salary for each job title.
```pgsql
CREATE VIEW avg_salaries_by_title AS
SELECT round(avg(s.salary)) as avg_salary, t.title
FROM titles t
JOIN employees e
ON t.title_id = e.emp_title_id
JOIN salaries s
ON e.emp_no = s.emp_no
GROUP BY t.title;
```
```python
# set command to variable
cmd_title_salary = "SELECT * FROM avg_salaries_by_title ORDER BY avg_salary ASC"

# convert view to dataframe
salary_df = pd.read_sql(cmd_title_salary, con=engine)

# create variables for plotting
titles = salary_df["title"]
avg_salary = salary_df["avg_salary"]

# create bar plot
plt.title("Average Salary by Job Title")
plt.bar(titles, avg_salary, color="darkgreen")
plt.xlabel("Job Titles")
plt.ylabel("Average Salary")
plt.xticks(rotation=90)
plt.savefig("images/avg_salary_titles.png")
plt.show()
```
![Bar_Chart](EmployeeSQL/images/avg_salary.png)

