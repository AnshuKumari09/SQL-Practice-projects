-- INSERT INTO sales (sale_id, product_name, sale_date, amount, store_location)
-- VALUES
-- (1, 'Laptop', '2023-01-15', 1500.00, 'New York'),
-- (2, 'Headphones', '2023-02-03', 200.00, 'Chicago'),
-- (3, 'Laptop', '2023-03-10', 1600.00, 'San Francisco'),
-- (4, 'Phone', '2023-02-21', 800.00, 'New York'),
-- (5, 'Tablet', '2023-05-15', 600.00, 'Chicago'),
-- (6, 'Laptop', '2023-04-12', 1450.00, 'Chicago'),
-- (7, 'Phone', '2023-01-20', 850.00, 'San Francisco'),
-- (8, 'Headphones', '2023-03-18', 220.00, 'New York'),
-- (9, 'Tablet', '2023-04-25', 620.00, 'San Francisco'),
-- (10, 'Laptop', '2023-06-10', 1550.00, 'New York'),
-- (11, 'Phone', '2023-07-02', 790.00, 'Chicago'),
-- (12, 'Tablet', '2023-07-20', 640.00, 'New York'),
-- (13, 'Headphones', '2023-05-30', 210.00, 'San Francisco'),
-- (14, 'Laptop', '2023-08-15', 1620.00, 'Chicago'),
-- (15, 'Phone', '2023-09-01', 800.00, 'San Francisco'),
-- (16, 'Tablet', '2023-08-23', 650.00, 'New York'),
-- (17, 'Headphones', '2023-10-05', 230.00, 'Chicago'),
-- (18, 'Laptop', '2023-11-12', 1580.00, 'New York'),
-- (19, 'Phone', '2023-12-10', 815.00, 'Chicago'),
-- (20, 'Tablet', '2023-12-28', 680.00, 'San Francisco'),
-- (21, 'Laptop', '2023-11-22', 1650.00, 'San Francisco'),
-- (22, 'Headphones', '2023-11-30', 240.00, 'New York'),
-- (23, 'Phone', '2023-12-15', 820.00, 'New York'),
-- (24, 'Tablet', '2023-12-05', 670.00, 'Chicago'),
-- (25, 'Laptop', '2023-12-28', 1700.00, 'Chicago');

SELECT * FROM sales;

-- Q1. Calculate the difference in sales amount between consecutive sales.
WITH cte AS(SELECT *,LAG(amount) OVER(ORDER BY sale_date) AS last_amount
FROM sales)
SELECT *,(amount-last_amount) AS diff
FROM cte;

-- Q2. Find the sale amount for the next product sale.
SELECT *,LEAD(amount) OVER(ORDER BY sale_date) AS next_amount
FROM sales;

-- Q3. For each product, calculate the difference between the current and previous sale amount.
WITH cte AS(SELECT *,LAG(amount) OVER(PARTITION BY product_name ORDER BY sale_date) AS last_amount
FROM sales)
SELECT *,(amount-last_amount) AS diff
FROM cte;

-- Q4. Show the next product sold for each store location.
SELECT *,LEAD(product_name) OVER(PARTITION BY store_location ORDER BY sale_date) AS next_product
FROM sales;

-- Q5. Find the previous sale amount for each store location
SELECT *,LAG(amount) OVER(PARTITION BY store_location ORDER BY sale_date) AS last_amount
FROM sales;

-- Q6. Calculate the rolling difference between sales for each product

SELECT
  product_name,
  sale_date,
  amount,
  LAG(amount) OVER (PARTITION BY product_name ORDER BY sale_date) AS last_amount,
  LEAD(amount) OVER (PARTITION BY product_name ORDER BY sale_date) AS next_amount,
  amount - LAG(amount) OVER (PARTITION BY product_name ORDER BY sale_date) AS diff_from_last,
  LEAD(amount) OVER (PARTITION BY product_name ORDER BY sale_date) - amount AS diff_to_next
FROM
  sales;

-- Q7 . Identify sales where the previous sale amount was higher than the current sale.
WITH cte AS(SELECT *,LAG(amount) OVER(ORDER BY sale_date) AS last_amount
FROM sales)
SELECT *,(amount-last_amount) AS diff
FROM cte
WHERE (amount-last_amount)<0;
-------------------
WITH cte AS (
  SELECT *,
         LAG(amount) OVER (ORDER BY sale_date) AS last_amount
  FROM sales
)
SELECT *
FROM cte
WHERE amount < last_amount;

-- Q8. Show total sales for each month, with the amount sold in the previous month.
SELECT
  EXTRACT(YEAR FROM sale_date) AS year,
  EXTRACT(MONTH FROM sale_date) AS month,
  SUM(amount) AS total_sale
FROM sales
GROUP BY
  EXTRACT(YEAR FROM sale_date),
  EXTRACT(MONTH FROM sale_date)
ORDER BY
  year, month;

--Q9. List all sales where the amount is greater than the average sales amount for that product
WITH cte AS(SELECT product_name,ROUND(AVG(amount),2) AS avg_amount
FROM sales
GROUP BY product_name)

SELECT s.*
FROM sales s
JOIN cte
  ON s.product_name = cte.product_name
WHERE s.amount > cte.avg_amount;
