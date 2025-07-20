CREATE DATABASE pizza_analysis;
USE pizza_analysis;

########### Calling the tables ###########

SELECT * FROM order_details;
SELECT * FROM orders;
SELECT * FROM pizza_types;
SELECT * FROM pizzas;

######### Data Modelling ##############
-- at first we are settling up the primary key in the table 
-- here we have 

ALTER TABLE orders ADD PRIMARY KEY (order_id);
ALTER TABLE order_details ADD PRIMARY KEY (order_details_id);

-- For settling the primary key in pizzas we have to settle down the length of pizza_id in boht the table pizzas and order_details:

ALTER TABLE order_details MODIFY pizza_id VARCHAR(20);
ALTER TABLE pizzas MODIFY pizza_id VARCHAR(20);

ALTER TABLE pizzas ADD PRIMARY KEY (pizza_id);

-- For settling the primary key in pizza_types we have to settle down the length of pizza_type_id in boht the table pizza_type and pizzas:

ALTER TABLE pizza_types MODIFY pizza_type_id VARCHAR(20);
ALTER TABLE pizzas MODIFY pizza_type_id VARCHAR(20);

ALTER TABLE pizza_types ADD PRIMARY KEY (pizza_type_id);

-- ADDING THE FOREIGN KEY IN THE DATABASE:

SET SQL_SAFE_UPDATES = 0;
DELETE FROM order_details
WHERE order_id NOT IN (SELECT order_id FROM orders);


ALTER TABLE order_details
ADD FOREIGN KEY (order_id)
REFERENCES orders(order_id);


DELETE FROM order_details
WHERE pizza_id NOT IN (SELECT pizza_id FROM pizzas);

ALTER TABLE order_details
ADD FOREIGN KEY (pizza_id) 
REFERENCES pizzas (pizza_id);


INSERT INTO pizza_types (pizza_type_id)
SELECT DISTINCT pizza_type_id
FROM pizzas
WHERE pizza_type_id NOT IN (SELECT pizza_type_id FROM pizza_types);

ALTER TABLE pizzas
ADD FOREIGN KEY (pizza_type_id)
REFERENCES pizza_types (pizza_type_id);


############ Question bank : Data Analysis #############

-- 1. Retrieve the total number of orders placed?


SELECT COUNT(*) FROM orders;

-- 2. Calculate the total revenue generated from pizza sales?

SELECT pizza_type_id, SUM(price) AS total_revenue -- For each pizza type
FROM pizzas AS p
JOIN order_details AS o_d ON p.pizza_id = o_d.pizza_id
GROUP BY 1
ORDER BY 2 DESC;

-- 3. Identify the highest-priced pizza.

SELECT MAX(price)
FROM pizzas;

-- 4. Identify the most common pizza size ordered.

SELECT pizza_type_id, COUNT(o_d.pizza_id) AS comman_pizza -- For each pizza type
FROM pizzas AS p
JOIN order_details AS o_d ON p.pizza_id = o_d.pizza_id
GROUP BY 1
ORDER BY 2 DESC;

-- 5. List the top 5 most ordered pizza types along with their quantities.
 
SELECT pizza_type_id, COUNT(o_d.pizza_id) AS comman_pizza, SUM(price) AS total_revenue -- For each pizza type
FROM pizzas AS p
JOIN order_details AS o_d ON p.pizza_id = o_d.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT COUNT(quantity), category, name
FROM order_details AS o_d
JOIN pizzas AS p ON o_d.pizza_id = p.pizza_id
JOIN pizza_types AS p_T ON p.pizza_type_id = p_t.pizza_type_id
GROUP BY 2,3
ORDER BY 2;


-- 7. Determine the distribution of orders by hour of the day?

WITH cte AS 
(SELECT o.order_id AS order_id,
	    p_t.name AS pizza_name,
       EXTRACT(DAY FROM o.date) AS day,
       EXTRACT(MONTH FROM o.date) AS month,
	   EXTRACT(HOUR FROM o.time) AS hour
FROM orders AS o
JOIN order_details AS o_d ON o.order_id = o_d.order_id
JOIN pizzas AS p ON p.pizza_id = o_d.pizza_id
JOIN pizza_types AS p_t ON p.pizza_type_id = p_t.pizza_type_id
ORDER BY 1)

SELECT 
	   pizza_name,
       
        hour, month, COUNT(hour) 
FROM cte
GROUP BY 1,2,3
ORDER BY 3;

Join relevant tables to find the category-wise distribution of pizzas.
Group the orders by date and calculate the average number of pizzas ordered per day.
Determine the top 3 most ordered pizza types based on revenue.

Advanced:
Calculate the percentage contribution of each pizza type to total revenue.
Analyze the cumulative revenue generated over time.
Determine the top 3 most ordered pizza types based on revenue for each pizza category.


