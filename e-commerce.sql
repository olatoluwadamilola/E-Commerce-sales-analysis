USE tireni_store;
 #1.List the top selling products
SELECT products.product_id,products.product_name,SUM(orders.quantity) AS total_sales
FROM products
JOIN orders ON products.product_id = orders.product_id
GROUP BY products.product_id,products.product_name 
order by total_sales desc
limit 10;	
#2.find the total revenue generated;
SELECT SUM(orders.quantity*products.product_price) AS total_revenue
FROM orders
JOIN products ON orders.product_id = products.product_id;
#3.identify the most valuable customers;
SELECT customers.customer_id,customers.first_name,customers.last_name,
sum(orders.quantity*products.product_price) AS total_spent
FROM customers
JOIN orders ON customers.customer_id=orders.customer_id
JOIN products ON orders.product_id=products.product_id
GROUP BY customers.customer_id,customers.first_name,customers.last_name
ORDER BY total_spent DESC 
LIMIT 10;
#4.Calculate the average order value;
SELECT avg(orders.quantity*products.product_price) AS average_order_value
FROM orders
JOIN products ON orders.product_id=products.product_id;
#5.Break down the total revenue by month
select year(order_date) AS year,
MONTH(order_date) AS month ,
SUM(quantity*total_price) AS revenue
FROM orders
GROUP BY YEAR(order_date),
MONTH(order_date)
ORDER BY 
  year,month;
#6.Retrieve the purchase history for a specific customers.
SELECT orders.order_id,products.product_name,orders.quantity,orders.order_date
FROM orders
JOIN products ON orders.product_id=products.product_id
WHERE orders.customer_id=3;
#7.identify the top product categories by total revenue
SELECT products.product_category,
SUM(orders.total_price) AS total_revenue
FROM orders
JOIN products ON orders.product_id = products.product_id
GROUP BY products.product_category
ORDER BY total_revenue DESC;
#8.count the number of repeat customers 
SELECT COUNT(DISTINCT customer_id) AS repeated_customers_count
FROM ( 
SELECT customer_id
FROM orders
GROUP BY customer_id
HAVING 
COUNT(order_id)> 1)
AS repeated_customers;
#9. calculate the customer churn rate
SELECT (COUNT(DISTINCT customer_id)/
(SELECT count(distinct customer_id) 
FROM customers))*100 AS churn_rate
 FROM orders 
WHERE order_date <= 
DATE_SUB(CURRENT_DATE(),INTERVAL 1 YEAR);
 #10. find the most popular products in a specific category 
 SELECT products.product_name,
 SUM(orders.quantity) AS total_quantity 
 FROM orders 
 JOIN products ON orders.product_id=products.product_id
 WHERE products.product_category = 'clothing'
 GROUP BY products.product_name
 ORDER BY total_quantity DESC
 limit 10;
#11.identify products that haven't been sold in the last three months 
SELECT products.product_id,products.product_name
FROM products
WHERE products.product_id NOT IN(
SELECT transaction.product_id
FROM transaction
WHERE transaction.transaction_date >= DATE_SUB(CURRENT_DATE,INTERVAL 3 MONTH))
ORDER BY products.product_name;
#12. calculate the average transaction value for each customers 
SELECT customers.customer_id,customers.first_name,customers.last_name,
AVG(transaction.price*transaction.quantity) AS average_transaction 
FROM customers 
LEFT JOIN transaction ON customers.customer_id= transaction.customer_id
GROUP BY customers.customer_id,customers.first_name,customers.last_name
ORDER BY average_transaction desc;
#13. determine the percentage of total revenue contributed by the top 10 customers
SELECT (SUM(total_price)/(SELECT SUM(total_price) FROM orders))*100 AS percentage_of_total_revenue
FROM ( SELECT total_price 
FROM orders
ORDER BY total_price DESC 
LIMIT 10)
AS top_customers;
#14.identify the days with the highest number of sales 
SELECT transaction_date,
COUNT(*) AS num_sales
FROM transaction
GROUP BY transaction_date
ORDER BY num_sales DESC 
LIMIT 10;
#15. calculate the average number of products included in each order
SELECT AVG(orders.quantity) AS avg_products_per_order
FROM orders;
#16. how to find new customers that made purchase
SELECT customers.*
FROM customers
JOIN orders ON customers.customer_id = orders.customer_id
WHERE orders.order_date>=(CURRENT_DATE-INTERVAL 30 DAY)
 AND customers.customer_id NOT IN (
 SELECT customer_id
 FROM orders
 GROUP BY customer_id
 HAVING COUNT(order_id)>1);
# comment there is no new customers that made their first purchase recently within the interval of 30 days
#17. How to find repeated customers that made purchase
SELECT customers.*
FROM customers
JOIN (
SELECT customer_id
FROM orders
WHERE order_date >=(CURRENT_DATE-INTERVAL 30 DAY)
GROUP BY customer_id
HAVING COUNT(order_id) > 1)
AS repeat_customers ON customers.customer_id =
repeat_customers.customer_id;
# no customers made a repeated purchase within the last 30 days
#18.how to find high-value customers
SELECT customers.*
FROM customers 
JOIN (
SELECT customer_id,SUM(total_price) AS total_spent
FROM orders
GROUP BY customer_id
ORDER BY total_spent DESC 
LIMIT 10 
) AS top_customers ON customers.customer_id = top_customers.customer_id;
#19.calculate the monthly revenue 
SELECT 
EXTRACT(YEAR FROM orders.order_date) AS year, 
EXTRACT(MONTH FROM orders.order_date) AS month, 
SUM(orders.total_price) AS monthly_revenue 
FROM orders
GROUP BY 
EXTRACT(YEAR FROM orders.order_date),
EXTRACT(MONTH FROM orders.order_date)
ORDER BY
year,month;
#20.calculate the quarterly revenue 
SELECT 
EXTRACT(YEAR FROM orders.order_date) AS year,
EXTRACT(QUARTER FROM orders.order_date) AS quater,
SUM(orders.total_price) AS quaterly_revenue
FROM orders
GROUP BY 
EXTRACT(YEAR FROM orders.order_date),
EXTRACT(QUARTER FROM orders.order_date)
ORDER BY 
year,quater;
#21. identify the peak sales period 
SELECT 
EXTRACT(YEAR FROM orders.order_date) AS year,
EXTRACT(MONTH FROM orders.order_date) AS month,
SUM(orders.total_price) AS monthly_sales 
FROM orders
GROUP BY 
EXTRACT(YEAR FROM orders.order_date),
EXTRACT(MONTH FROM orders.order_date)
ORDER BY
monthly_sales DESC; 
#22.identify best selling products by category 
SELECT products.product_category,products.product_name,products.product_id,
SUM(orders.quantity) AS total_quantity_sold 
FROM  orders
JOIN products ON orders.product_id = 
products.product_id
GROUP BY products.product_category,products.product_name,products.product_id
ORDER BY products.product_category, total_quantity_sold DESC;
#23.determine the average order size
SELECT
AVG(orders.quantity) AS average_order_size
FROM orders;
#24.how to observe any seasonality 
    SELECT 
    order_date,
    SUM(total_price) AS total_sales
FROM 
    orders
GROUP BY 
    order_date
ORDER BY 
    order_date;
#25. Products with declining sales 
# first find aggregate sales data by product and time
SELECT
    products.product_id,
    products.product_name,
    QUARTER(orders.order_date) AS order_quarter,
    SUM(orders.quantity) AS total_quantity_sold
FROM
    orders 
JOIN
    products  ON orders.product_id = products.product_id
WHERE
    YEAR(orders.order_date) = 2023
    AND QUARTER(orders.order_date) IN (1, 2)
GROUP BY
    products.product_id, products.product_name, QUARTER(orders.order_date)
ORDER BY
    products.product_id, QUARTER(orders.order_date);
# then we compare sales between two quaters
SELECT
    q1.product_id,
    q1.product_name,
    q1.total_quantity_sold AS Q1_sales,
    q2.total_quantity_sold AS Q2_sales
FROM
    (SELECT
        products.product_id,
        products.product_name,
        SUM(orders.quantity) AS total_quantity_sold
    FROM
        orders 
    JOIN
        products  ON orders.product_id = products.product_id
    WHERE
        YEAR(orders.order_date) = 2023
        AND QUARTER(orders.order_date) = 1
    GROUP BY
        products.product_id, products.product_name) q1
JOIN
    (SELECT
        products.product_id,
        products.product_name,
        SUM(orders.quantity) AS total_quantity_sold
    FROM
        orders 
    JOIN
        products ON orders.product_id = products.product_id
    WHERE
        YEAR(orders.order_date) = 2023
        AND QUARTER(orders.order_date) = 2
    GROUP BY
        products.product_id, products.product_name) q2
ON q1.product_id = q2.product_id
WHERE
    q2.total_quantity_sold < q1.total_quantity_sold
ORDER BY
    q1.product_id;
    #number 11 redo
SELECT products.product_id,products.product_name
FROM products 
LEFT JOIN transaction 
ON products.product_id = transaction.product_id
AND transaction.transaction_date >= DATEADD(MONTH, -3, GETDATE())
WHERE transaction.transaction_id IS NULL;
#Total number of customers
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM customers;