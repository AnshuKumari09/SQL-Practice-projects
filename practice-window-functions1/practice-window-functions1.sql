SELECT * FROM employees;

--Find the row number of each employee ordered by salary.
SELECT *,ROW_NUMBER() OVER(ORDER BY salary) AS row_num
FROM employees;

--Q2 Rank employees based on their salaries
SELECT *,RANK() OVER (ORDER BY salary DESC) AS rank
FROM employees;

--Q3 Dense rank employees within each department based on salary.
SELECT *,DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rank
FROM employees;

--Q4 Rank employees by hire date
SELECT *,RANK() OVER (ORDER BY hire_date) AS rank
FROM employees;

--Q5. Find the row number of each employee within their department based on hire date
SELECT *,ROW_NUMBER() OVER(PARTITION BY department ORDER BY hire_date) AS row_num
FROM employees;

--Q6. Show the employee name and salary of the highest-paid employee in each department
WITH ranked_cte AS
(SELECT *,RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rank_num
FROM employees)

SELECT emp_name,salary,department
FROM ranked_cte
WHERE rank_num=1;

--Q7 . Calculate the rank difference between employees with the same salary across departments
WITH ranked_cte AS(SELECT * ,RANK() OVER (PARTITION BY department ORDER BY salary) AS curr_rank
FROM employees)

SELECT *,LAG(curr_rank) OVER(PARTITION BY department ORDER BY salary) AS last_rank,
curr_rank-LAG(curr_rank) OVER(PARTITION BY department ORDER BY salary)AS rank_diff
FROM ranked_cte;

--8. Get the 2nd highest salary in each department, showing the employee name
WITH ranked AS(SELECT *,RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rank_num
FROM employees)
SELECT emp_name,salary,department
FROM ranked
WHERE rank_num=2;

--Q9. Find the average salary of the top 3 highest-paid employees in each department.
WITH ranked AS (
  SELECT *,
         RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rank_num
  FROM employees
)
SELECT
  department,
  AVG(salary) AS avg_top_3_salary
FROM
  ranked
WHERE
  rank_num <= 3
GROUP BY
  department;

--Q10. Assign a dense rank to employees based on their hire date, resetting at each department change.

SELECT *,DENSE_RANK() OVER (PARTITION BY department ORDER BY hire_date) AS rank_num
FROM employees
