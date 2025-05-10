-- SELECT * FROM walmart_sales


---- Q.1 Find the total sales amount for each branch
SELECT SUM(total)
FROM walmart_sales;

SELECT COUNT(total)
FROM walmart_sales;

SELECT AVG(total)
FROM walmart_sales;

SELECT MIN(total)
FROM walmart_sales;

--ROUND() — values ko round karne ke liye
-- SELECT ROUND(AVG(total), 2) FROM walmart_sales;
-- Average ko 2 decimal tak round karta hai

SELECT branch, SUM(total) 
FROM walmart_sales
GROUP BY branch;

SELECT city,SUM(total)
FROM walmart_sales
GROUP BY city;

SELECT gender,SUM(total)
FROM walmart_sales
GROUP BY gender;

SELECT customer_type,SUM(total)
FROM walmart_sales
GROUP BY customer_type;

SELECT date,SUM(total)
FROM walmart_sales
GROUP BY date;

SELECT branch, SUM(total) 
FROM walmart_sales
GROUP BY branch
HAVING SUM(total)>10000;

-- Q.2 Calculate the average customer rating for each city. and also in  Rounded Ratings (2 decimal places):
SELECT city,AVG(rating)
FROM walmart_sales
GROUP BY city;

SELECT city,AVG(rating) AS avg_rating
FROM walmart_sales
GROUP BY city
ORDER BY avg_rating DESC;


-- Q.3 Count the number of sales transactions for each customer type.
SELECT customer_type , COUNT(invoice_id)
FROM walmart_sales
GROUP BY customer_type;

-- MEDIUM DIFFICULTY

-- Q.5 Find the total sales amount and average customer rating for each branch.
SELECT branch, SUM(total) AS total_sales, AVG(rating) AS average_rating
FROM walmart_sales
GROUP BY branch;

-- Q.6 Calculate the total sales amount for each city and gender combination.
SELECT city,gender,SUM(total)
FROM walmart_sales
GROUP BY 1,2
ORDER BY 1;

-- Q.7 Find the average quantity of products sold for each product line to female customers.
SELECT product_line, gender, AVG(quantity) AS avg_quantity
FROM walmart_sales
WHERE gender = 'Female'
GROUP BY product_line, gender;

-- Q.9 Find the total sales amount for each day. (Return day name and their total sales order DESC by amt)
SELECT TO_CHAR(date,'Day') as day_name,SUM(total)
FROM walmart_sales
GROUP BY day_name
ORDER BY SUM(total) DESC;


-- Advanced 
-- Q.10 Calculate the total sales amount for each hour of the day
SELECT 
EXTRACT(HOUR FROM time) as hours,SUM(total) as total_sales
FROM walmart_sales
GROUP BY 1
ORDER BY 2 DESC;


-- Q.11 Find the total sales amount for each month. (return month name and their sales)
SELECT TO_CHAR(date,'Mon') as month_name,SUM(total)
FROM walmart_sales
GROUP BY 1
ORDER BY 2 DESC;

-- Q.12 Calculate the total sales amount for each branch where the average customer rating is greater than 7.
SELECT branch,AVG(rating),SUM(total)
FROM walmart_sales
GROUP BY branch
HAVING AVG(rating)>7;

--Q.13 Find the total VAT collected for each product line where the total sales amount is more than 500.
SELECT product_line,SUM(vat) as vat_sum,SUM(total)
FROM walmart_sales
GROUP BY product_line
HAVING SUM(total)>500;

--Q.14 Calculate the average sales amount for each gender in each branch.
SELECT branch,gender,AVG(total)
FROM walmart_sales
GROUP BY 1,2;

---- Q.15 Count the number of sales transactions for each day of the week.
SELECT TO_CHAR(date, 'Day') AS day_name, COUNT(*) AS total_transactions
FROM walmart_sales
GROUP BY TO_CHAR(date, 'Day');

--Q.16 Find the total sales amount for each city and customer type combination where the number of sales transactions is greater than 50.
SELECT city, customer_type, SUM(total) AS total_sales
FROM walmart_sales
GROUP BY city, customer_type
HAVING COUNT(*) > 50;

--Q.17 Calculate the average unit price for each product line and payment method combination.
SELECT product_line, payment_method, AVG(unit_price) AS avg_unit_price
FROM walmart_sales
GROUP BY product_line, payment_method;

--Q.18 Find the total sales amount for each branch and hour of the day combination.
SELECT EXTRACT(HOUR FROM time) as hours, branch,SUM(total)
FROM walmart_sales
GROUP BY 1,2

--Q.19 Calculate the total sales amount and average customer rating for each product line where the total sales amount is greater than 1000.
SELECT product_line, AVG(rating) AS avg_rating, SUM(total) AS total_sales
FROM walmart_sales
GROUP BY product_line
HAVING SUM(total) > 1000;

-- Q.20 Calculate the total orders amount for morning (6 AM to 12 PM), afternoon (12 PM to 6 PM), and evening (6 PM to 12 AM) periods using the time condition.

WITH new_table
AS
(
SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM time) BETWEEN 6 AND 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM time) > 12 AND  EXTRACT(HOUR FROM time) <= 18 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift    
FROM walmart_sales
)
SELECT 
    shift,
    SUM(total) as total_sales,
    COUNT(invoice_id) as total_orders
FROM new_table
WHERE branch <> 'A'
GROUP BY shift
HAVING COUNT(invoice_id) < 500
