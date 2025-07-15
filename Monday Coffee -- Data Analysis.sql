-- Key Questions

--------------------------------------------------------------------------------------------------------------------------------
-- 1 . Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

-- SELECT * FROM city;
-- SELECT * FROM customers;
-- SELECT * FROM products;
-- SELECT * FROM sales;

-- -- SELECT (ROUND(SUM(population)/4),2) AS coffeConsumers
-- -- FROM city

-- SELECT (ROUND(SUM(population)/4),2) AS coffeConsumers
-- FROM city;

-- SELECT city_name AS city,(population/4) AS population
-- FROM city;

-- SELECT city_name AS city,population AS population
-- FROM city;


SELECT 
	city_name,
	ROUND(
	(population * 0.25)/1000000, 
	2) as coffee_consumers_in_millions,
	city_rank
FROM city
ORDER BY 2 DESC;

-- -----------------------------------------------

-- -- -- Q.2
-- -- Total Revenue from Coffee Sales
-- -- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

-- SELECT sale_id,EXTRACT(YEAR FROM sale_date) AS sale_year,product_id
-- FROM sales
-- WHERE EXTRACT(YEAR FROM sale_date) = '2023';

-- -- joining city,customers,sales
-- SELECT *
-- FROM city
-- LEFT JOIN customers cust
-- ON city.city_id=cust.city_id
-- LEFT JOIN sales s
-- ON cust.customer_id=s.customer_id
-- WHERE EXTRACT(YEAR FROM s.sale_date) = '2023';

SELECT *
FROM city
LEFT JOIN customers cust
ON city.city_id=cust.city_id
LEFT JOIN sales s
ON cust.customer_id=s.customer_id
LEFT JOIN products p
ON s.product_id=p.product_id
WHERE EXTRACT(YEAR FROM s.sale_date) = '2023';
 
SELECT c.city_name,SUM(s.total)AS total
FROM city c
LEFT JOIN customers cust
ON c.city_id=cust.city_id
LEFT JOIN sales s
ON cust.customer_id=s.customer_id
WHERE EXTRACT(YEAR FROM s.sale_date) = '2023' AND EXTRACT(quarter FROM s.sale_date) = 4
GROUP BY 1
ORDER BY 2 desc;

-- -- Q.3
-- -- Sales Count for Each Product
-- -- How many units of each coffee product have been sold?
SELECT product_name,COUNT(prouct_name)
FROM sales sd
JOIN products p
ON s.product_id=p.product_id
GROUP BY product_name
ORDER BY 2 DESC;

-- -- Q.4
-- -- Average Sales Amount per City
-- -- What is the average sales amount per customer in each city?

-- -- city abd total sale
-- -- no cx in each these city

SELECT 
	ci.city_name,
	SUM(s.total) as total_revenue,
	COUNT(DISTINCT s.customer_id) as total_cx,
	ROUND(
			SUM(s.total)::numeric/
				COUNT(DISTINCT s.customer_id)::numeric
			,2) as avg_sale_pr_cx
	
FROM sales as s
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
GROUP BY 1
ORDER BY 2 DESC;

SELECT * FROM sales;
SELECT cust.customer_name,ci.city_name,SUM(s.total)/COUNT(DISTINCT s.customer_id)
FROM sales as s
JOIN customers as cust
ON s.customer_id = cust.customer_id
JOIN city as ci
ON cust.city_id=ci.city_id
GROUP BY cust.customer_name,ci.city_name
ORDER BY 1,3 DESC;

-- City Population and Coffee Consumers
-- Provide a list of cities along with their populations and estimated coffee consumers.
SELECT ci.city_name,COUNT(DISTINCT cust.customer_id),SUM(ci.population)
FROM city as ci
JOIN customers as cust
ON ci.city_id=cust.city_id
GROUP BY ci.city_name;

WITH city_table as 
(
	SELECT 
		city_name,
		ROUND((population * 0.25)/1000000, 2) as coffee_consumers
	FROM city
),
customers_table
AS
(
	SELECT 
		ci.city_name,
		COUNT(DISTINCT c.customer_id) as unique_cx
	FROM sales as s
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1
)
SELECT 
	customers_table.city_name,
	city_table.coffee_consumers as coffee_consumer_in_millions,
	customers_table.unique_cx
FROM city_table
JOIN 
customers_table
ON city_table.city_name = customers_table.city_name;

-- -- Q6
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

SELECT *
FROM sales as s
JOIN products as p
ON s.product_id=p.product_id
JOIN customers as cust
ON s.customer_id=cust.customer_id
JOIN city as c
ON cust.city_id=c.city_id;

SELECT p.product_name,COUNT(*),c.city_name
FROM sales as s
JOIN products as p
ON s.product_id=p.product_id
JOIN customers as cust
ON s.customer_id=cust.customer_id
JOIN city as c
ON cust.city_id=c.city_id
GROUP BY product_name,c.city_name
ORDER BY COUNT(*) DESC;



SELECT * 
FROM -- table
(
	SELECT 
		ci.city_name,
		p.product_name,
		COUNT(s.sale_id) as total_orders,
		DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) as rank
	FROM sales as s
	JOIN products as p
	ON s.product_id = p.product_id
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1, 2
	-- ORDER BY 1, 3 DESC
) as t1
WHERE rank <= 3;

-- Q.7
-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

SELECT c.customer_name,COUNT(*),ci.city_name
	FROM sales as s
	JOIN products as p
	ON s.product_id = p.product_id
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY c.customer_name,ci.city_name;


SELECT 
	ci.city_name,
	COUNT(DISTINCT c.customer_id) as unique_cx
FROM city as ci
LEFT JOIN customers as c
ON c.city_id = ci.city_id
JOIN sales as s
ON s.customer_id = c.customer_id
WHERE 
	s.product_id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)
GROUP BY 1;


-- -- Q.8
-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer
WITH city_table
AS
(
	SELECT 
		ci.city_name,
		SUM(s.total) as total_revenue,
		COUNT(DISTINCT s.customer_id) as total_cx,
		ROUND(
				SUM(s.total)::numeric/
					COUNT(DISTINCT s.customer_id)::numeric
				,2) as avg_sale_pr_cx
		
	FROM sales as s
	JOIN customers as c
	ON s.customer_id = c.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1
	ORDER BY 2 DESC
),
city_rent
AS
(SELECT 
	city_name, 
	estimated_rent
FROM city
)
SELECT 
	cr.city_name,
	cr.estimated_rent,
	ct.total_cx,
	ct.avg_sale_pr_cx,
	ROUND(
		cr.estimated_rent::numeric/
									ct.total_cx::numeric
		, 2) as avg_rent_per_cx
FROM city_rent as cr
JOIN city_table as ct
ON cr.city_name = ct.city_name
ORDER BY 4 DESC

-- Q.9
-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
-- by each city
-- GROUP BY city_name,MONTH

-- SELECT cust.customer_id,cte.year,cte.month,ci.city_name,cte.total_sale FROM 
-- (
-- SELECT customer_id,EXTRACT(YEAR FROM sale_date) AS year,EXTRACT(MONTH FROM sale_date) AS month,total AS total_sale
-- FROM sales
-- ORDER BY EXTRACT(MONTH FROM sale_date),EXTRACT(YEAR FROM sale_date)
-- )AS cte
-- JOIN customers cust
-- ON cte.customer_id=cust.customer_id
-- JOIN city ci
-- ON cust.city_id=ci.city_id


-- LAG() ek window function hai jo pichla row ka value lane ke liye hota hai.
SELECT 
  sale_id,
  total,
  LAG(total) OVER (ORDER BY sale_id) AS last_sales
FROM sales;

------------------------------

WITH cte AS (
  SELECT 
    customer_id,
    EXTRACT(YEAR FROM sale_date) AS year,
    EXTRACT(MONTH FROM sale_date) AS month,
    total AS total_sale
  FROM sales
),

monthly_sales AS (
  SELECT 
    ci.city_name,
    cte.year,
    cte.month,
    SUM(cte.total_sale) AS total_sale
  FROM cte
  JOIN customers cust ON cte.customer_id = cust.customer_id
  JOIN city ci ON cust.city_id = ci.city_id
  GROUP BY ci.city_name, cte.year, cte.month
),

growth_ratio AS (
  SELECT 
    city_name,
    year,
    month,
    total_sale AS cr_month_sale,
    LAG(total_sale) OVER(PARTITION BY city_name ORDER BY year, month) AS last_month_sale
  FROM monthly_sales
)

SELECT 
  city_name,
  year,
  month,
  cr_month_sale,
  last_month_sale,
  ROUND( ((cr_month_sale - last_month_sale)::NUMERIC / last_month_sale::NUMERIC) * 100, 2 )

FROM growth_ratio
WHERE last_month_sale IS NOT NULL;

-- Q.10
-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer


--::NUMERIC ka istemaal kab? Agar tum decimal places specify karna chahati ho (ROUND(value, 2)), toh tumhara value NUMERIC type hona chahiye.

SELECT ci.city_name,SUM(s.total) AS total_sale,SUM(ci.estimated_rent) AS rent
FROM sales s
JOIN customers cust
ON s.customer_id=cust.customer_id
JOIN city ci
ON cust.city_id=ci.city_id
GROUP BY ci.city_name
ORDER BY SUM(s.total) DESC;

-----------------------------------------------------------

WITH city_table AS (
  SELECT 
    ci.city_name,
    SUM(s.total) AS total_revenue,
    COUNT(DISTINCT s.customer_id) AS total_cx,
    ROUND(SUM(s.total)::numeric / COUNT(DISTINCT s.customer_id)::numeric, 2) AS avg_sale_pr_cx
  FROM sales s
  JOIN customers c ON s.customer_id = c.customer_id
  JOIN city ci ON ci.city_id = c.city_id
  GROUP BY 1
  ORDER BY 2 DESC
),
city_rent AS (
  SELECT 
    city_name, 
    estimated_rent,
    ROUND((population * 0.25) / 1000000, 3) AS estimated_coffee_consumer_in_millions
  FROM city
)
SELECT 
  cr.city_name,
  total_revenue,
  cr.estimated_rent AS total_rent,
  ct.total_cx,
  estimated_coffee_consumer_in_millions,
  ct.avg_sale_pr_cx,
  ROUND(cr.estimated_rent::numeric / ct.total_cx::numeric, 2) AS avg_rent_per_cx
FROM city_rent cr
JOIN city_table ct ON cr.city_name = ct.city_name
ORDER BY 2 DESC;


