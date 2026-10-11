SELECT TABLE_NAME, 
COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() 
ORDER BY TABLE_NAME, ORDINAL_POSITION;


-- Q1. Total Order & Total Revenue

SELECT COUNT(DISTINCT o.order_id) AS total_orders,
ROUND(SUM(p.payment_value),2) AS total_revenue
FROM olist_orders_dataset o 
JOIN olist_order_payments_dataset p ON o.order_id = p.order_id;


-- Q2. MONTHLY SALES TREND

SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month, 
COUNT(DISTINCT o.order_id) AS total_orders,
ROUND(SUM(p.payment_value),2) AS revenue
FROM olist_orders_dataset o 
JOIN olist_order_payments_dataset p 
ON o.order_id = p.order_id 
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY month;


-- Q3. Yearly Sales Trend

SELECT YEAR(o.order_purchase_timestamp) AS year, 
COUNT(DISTINCT o.order_id) AS total_orders,
ROUND(SUM(p.payment_value),2) AS revenue
FROM olist_orders_dataset o 
JOIN olist_order_payments_dataset p 
ON o.order_id = p.order_id 
GROUP BY YEAR(o.order_purchase_timestamp)
ORDER BY year;


-- Q4. Highest-revenue Product Categories

SELECT COALESCE(t.product_category_name_english,
p.product_category_name) AS category,
ROUND(SUM(oi.price), 2) AS revenue
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t
ON p.product_category_name = t.product_category_name
GROUP BY category
ORDER BY revenue DESC
LIMIT 10;


-- Q5. Productswith Highest Sales Volume

SELECT oi.product_id,
COUNT(*) AS units_sold
FROM olist_order_items_dataset oi
GROUP BY oi.product_id
ORDER BY units_sold DESC
LIMIT 10;


-- Q6 — Top Sellers by Revenue

SELECT seller_id,
ROUND(SUM(price), 2) AS revenue
FROM olist_order_items_dataset
GROUP BY seller_id
ORDER BY revenue DESC
LIMIT 10;


-- Q7 — States Contributing The Most Sales

SELECT c.customer_state,
COUNT(DISTINCT o.order_id) AS orders,
ROUND(SUM(p.payment_value), 2) AS revenue
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
ON o.customer_id = c.customer_id
JOIN olist_order_payments_dataset p
ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;


-- Q8 — Average Order Value

SELECT ROUND(SUM(p.payment_value) / 
COUNT(DISTINCT p.order_id), 2) 
AS average_order_value
FROM olist_order_payments_dataset p;


-- Q9 — Most-used Payment Methods

SELECT payment_type,
COUNT(*) AS usage_count,
ROUND(SUM(payment_value), 2) AS total_value
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY usage_count DESC;


-- Q10 — Average Delivery Time

SELECT ROUND(AVG(DATEDIFF(
order_delivered_customer_date, 
order_purchase_timestamp)), 2) 
AS average_delivery_days
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NOT NULL;


-- Q11 — Categories With Highest Customer Ratings

SELECT COALESCE(t.product_category_name_english,
p.product_category_name) AS category,
ROUND(AVG(r.review_score), 2) AS average_rating,
COUNT(*) AS reviews
FROM olist_order_reviews_dataset r
JOIN olist_order_items_dataset oi
ON r.order_id = oi.order_id
JOIN olist_products_dataset p
ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t
ON p.product_category_name = t.product_category_name
GROUP BY category
HAVING COUNT(*) >= 50
ORDER BY average_rating DESC;


-- Q12 — Are late deliveries associated with lower ratings?

SELECT CASE
WHEN o.order_delivered_customer_date >
o.order_estimated_delivery_date
THEN 'Late' ELSE 'On Time'
END AS delivery_status,
ROUND(AVG(r.review_score), 2) AS average_review_score,
COUNT(*) AS orders
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r
ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;


-- Q13 — Top Customers by Spending

SELECT o.customer_id,
ROUND(SUM(p.payment_value), 2) AS total_spending
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
ON o.order_id = p.order_id
GROUP BY o.customer_id
ORDER BY total_spending DESC
LIMIT 10;


-- Q14 — Cancellation Percentage

SELECT ROUND(100.0 * SUM(
CASE WHEN order_status = 'canceled' THEN 1
ELSE 0 END) / COUNT(*),2) AS cancellation_percentage
FROM olist_orders_dataset;


-- Q15. High Sales + Poor Customer Ratings

WITH category_sales AS (SELECT
p.product_category_name,
COUNT(*) AS units_sold,
SUM(oi.price) AS revenue
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
ON oi.product_id = p.product_id
GROUP BY p.product_category_name),

category_ratings AS (SELECT
p.product_category_name,
AVG(r.review_score) AS avg_rating,
COUNT(DISTINCT r.review_id) AS review_count
FROM olist_order_reviews_dataset r
JOIN olist_order_items_dataset oi
ON r.order_id = oi.order_id
JOIN olist_products_dataset p
ON oi.product_id = p.product_id
GROUP BY p.product_category_name),

category_metrics AS (
SELECT cs.product_category_name,
cs.units_sold, cs.revenue,
cr.avg_rating, cr.review_count
FROM category_sales cs
JOIN category_ratings cr
ON cs.product_category_name = cr.product_category_name
WHERE cr.review_count >= 50)

SELECT COALESCE(t.product_category_name_english,
cm.product_category_name) AS category,
cm.units_sold,
ROUND(cm.revenue, 2) AS revenue,
ROUND(cm.avg_rating, 2) AS avg_rating,
cm.review_count
FROM category_metrics cm
LEFT JOIN product_category_name_translation t
ON cm.product_category_name = t.product_category_name
WHERE cm.avg_rating < 3.5
ORDER BY cm.revenue DESC;


-- Extra 1 — Top 10% Customers by Spending

WITH customer_spend AS (
SELECT o.customer_id,
SUM(p.payment_value) AS total_spending
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
ON o.order_id = p.order_id
GROUP BY o.customer_id),

ranked_customers AS (SELECT
customer_id, total_spending,
NTILE(10) OVER (
ORDER BY total_spending DESC) AS spending_decile
FROM customer_spend)

SELECT customer_id,
ROUND(total_spending, 2) AS total_spending,
spending_decile
FROM ranked_customers
WHERE spending_decile = 1
ORDER BY total_spending DESC;


-- Extra 2 — Top Sellers by Revenue + Ranking

WITH seller_revenue AS (
SELECT seller_id,
SUM(price) AS revenue
FROM olist_order_items_dataset
GROUP BY seller_id),

ranked_sellers AS (SELECT
seller_id, revenue, RANK() OVER (ORDER BY revenue DESC)
AS seller_rank
FROM seller_revenue)

SELECT seller_id,
ROUND(revenue, 2) AS revenue,
seller_rank
FROM ranked_sellers
WHERE seller_rank <= 10
ORDER BY seller_rank;