CREATE DATABASE Retail_Analysis;
USE Retail_Analysis;

######Calling the table########

SELECT * FROM retail_analysis;

#################### Questions ##########################

-- Data Analysis & Business Key Problems & Answers

-- My Analysis & Findings

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'?

SELECT 
    *
FROM
    retail_analysis
WHERE
    sale_date = '2022-11-05';

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022

SELECT 
    *
FROM
    retail_analysis
WHERE
    category = 'Clothing' AND quantiy > 10
        AND (sale_date BETWEEN '2022-11-01' AND '2022-11-30');

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

SELECT 
    category, SUM(total_sale) AS total_sale
FROM
    retail_analysis
GROUP BY 1
ORDER BY 2;

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT 
    gender, AVG(age) AS average_age
FROM
    retail_analysis
WHERE
    category = 'Beauty'
GROUP BY 1
ORDER BY 1;

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.?

SELECT 
    *
FROM
    retail_analysis
WHERE
    total_sale > 1000;

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

SELECT 
    COUNT(DISTINCT Ã¯Â»Â¿transactions_id) AS total_number_of_account,
    gender,
    category
FROM
    retail_analysis
GROUP BY 2 , 3;

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

SELECT 
    EXTRACT(MONTH FROM sale_date) AS MONTH,
    EXTRACT(YEAR FROM sale_date) AS YEAR,
    AVG(total_sale) AS average_sale
FROM
    retail_analysis
GROUP BY 
	1,2
ORDER BY 
	1,2;

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales?

SELECT 
    customer_id, total_sale
FROM
    retail_analysis
ORDER BY 2 DESC
LIMIT 5;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

SELECT 
    COUNT(DISTINCT customer_id), category
FROM
    retail_analysis
GROUP BY 2;

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

SELECT 
	CASE
		WHEN sale_time <= '12:00:00' THEN 'Morning'
        WHEN sale_time BETWEEN '12:00:00 =' AND '17:00:00' THEN 'Afternoon'
        ELSE 'Evening'
        END AS shift,
	COUNT(customer_id)
FROM retail_analysis
GROUP BY 1;