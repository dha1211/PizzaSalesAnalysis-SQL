-- Retrieve the total number of orders placed. 
USE desipizza;
SELECT COUNT(order_id) FROM orders;

-- Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(quantity*price),2) FROM order_details 
JOIN pizzas 
ON order_details.pizza_id=pizzas.pizza_id; 

-- Identify the highest-priced pizza.
SELECT pizza_type_id FROM pizzas WHERE price= (SELECT MAX(price) FROM pizzas);

-- Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1;


-- List the top 5 most ordered pizza types along with their quantities.  
SELECT 
    pizza_types.name,
    COUNT(order_details.quantity) AS order_count
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY order_count DESC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category, COUNT(order_details.quantity) AS order_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY order_quantity DESC;



-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(time), COUNT(order_id) AS ord_quantity
FROM
    orders
GROUP BY HOUR(time)
ORDER BY ord_quantity DESC;


-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;


-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue. 
SELECT pizza_types.category, 
CONCAT(ROUND(SUM(order_details.quantity*pizzas.price) / 
(SELECT ROUND(SUM(quantity*price),2) 
FROM order_details JOIN pizzas 
ON order_details.pizza_id=pizzas.pizza_id)*100,2),'%')as revenue 
FROM pizza_types 
JOIN pizzas 
ON pizza_types.pizza_type_id=pizzas.pizza_type_id  
JOIN order_details 
ON order_details.pizza_id=pizzas.pizza_id
GROUP BY pizza_types.category ORDER BY revenue DESC;

-- Analyze the cumulative revenue generated over time.
SELECT date ,
ROUND(SUM(revenue) OVER(ORDER BY date),2) AS cum_revenue 
FROM
(SELECT  orders.date, SUM(order_details.quantity*pizzas.price) as revenue
FROM order_details JOIN pizzas 
ON order_details.pizza_id=pizzas.pizza_id
JOIN orders
ON orders.order_id=order_details.order_id
GROUP BY orders.date) AS sales;


-- Determine the top 3 most ordered pizza types based on 
-- revenue for each pizza category. 
SELECT category, name, revenue FROM 
(SELECT category, name, revenue, 
RANK() OVER(PARTITION BY category 
ORDER BY revenue DESC) AS rn 
FROM
(SELECT pizza_types.category, pizza_types.name, 
ROUND(SUM(order_details.quantity*pizzas.price),2) as revenue
FROM order_details
JOIN pizzas ON
order_details.pizza_id=pizzas.pizza_id
JOIN pizza_types ON
pizza_types.pizza_type_id=pizzas.pizza_type_id
GROUP BY pizza_types.category, pizza_types.name) AS A) b
WHERE rn<=3;