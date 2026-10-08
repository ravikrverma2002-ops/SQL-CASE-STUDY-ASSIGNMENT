/*
============================================================
PROJECT: E-Commerce Sales & Customer Analytics Using SQL
DATABASE: Olist Brazilian E-Commerce Dataset
DBMS: MySQL
============================================================

Business Objective:
Analyze sales performance, customer behavior, product/category
performance, seller performance, delivery operations, payments,
and customer satisfaction.

Database:
olist_ecommerce

Main tables:
- olist_orders_dataset
- olist_order_items_dataset
- olist_order_payments_dataset
- olist_order_reviews_dataset
- olist_customers_dataset
- olist_products_dataset
- olist_sellers_dataset
- product_category_name_translation
- olist_geolocation_dataset

NOTE:
Run this file after importing the Olist CSV files into MySQL.
This file contains analysis queries only; it does not modify data.
============================================================
*/

USE olist_ecommerce;


/* ============================================================
   SECTION 1 — BUSINESS OVERVIEW
   ============================================================ */


/* Q1. Total number of orders and total revenue */
SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value), 2) AS total_revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id;


/* Q2. Monthly sales trends */
SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value), 2) AS revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY month;


/* Q3. Yearly sales trends */
SELECT
    YEAR(o.order_purchase_timestamp) AS year,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value), 2) AS revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY YEAR(o.order_purchase_timestamp)
ORDER BY year;


/* ============================================================
   SECTION 2 — PRODUCT & CATEGORY PERFORMANCE
   ============================================================ */


/* Q4. Product categories with the highest revenue */
SELECT
    COALESCE(
        t.product_category_name_english,
        p.product_category_name
    ) AS category,
    ROUND(SUM(oi.price), 2) AS revenue
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY category
ORDER BY revenue DESC
LIMIT 10;


/* Q5. Products with the highest sales volume */
SELECT
    oi.product_id,
    COUNT(*) AS units_sold
FROM olist_order_items_dataset oi
GROUP BY oi.product_id
ORDER BY units_sold DESC
LIMIT 10;


/* Q6. Sellers with the highest revenue */
SELECT
    seller_id,
    ROUND(SUM(price), 2) AS revenue
FROM olist_order_items_dataset
GROUP BY seller_id
ORDER BY revenue DESC
LIMIT 10;


/* ============================================================
   SECTION 3 — CUSTOMER & LOCATION ANALYSIS
   ============================================================ */


/* Q7. States with the highest sales */
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(p.payment_value), 2) AS revenue
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;


/* Q8. Average order value (AOV) */
SELECT
    ROUND(
        SUM(p.payment_value) / COUNT(DISTINCT p.order_id),
        2
    ) AS average_order_value
FROM olist_order_payments_dataset p;


/* Q13. Top customers by total spending */
SELECT
    o.customer_id,
    ROUND(SUM(p.payment_value), 2) AS total_spending
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY o.customer_id
ORDER BY total_spending DESC
LIMIT 10;


/* ============================================================
   SECTION 4 — PAYMENT & DELIVERY OPERATIONS
   ============================================================ */


/* Q9. Most common payment methods */
SELECT
    payment_type,
    COUNT(*) AS usage_count,
    ROUND(SUM(payment_value), 2) AS total_value
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY usage_count DESC;


/* Q10. Average delivery time */
SELECT
    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_purchase_timestamp
            )
        ),
        2
    ) AS average_delivery_days
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NOT NULL;


/* Q12. Late deliveries and customer review scores */
SELECT
    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
            THEN 'Late'
        ELSE 'On Time'
    END AS delivery_status,
    ROUND(AVG(r.review_score), 2) AS average_review_score,
    COUNT(DISTINCT r.review_id) AS reviews
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r
    ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;


/* Q14. Percentage of orders cancelled */
SELECT
    ROUND(
        100.0 * SUM(
            CASE
                WHEN order_status = 'canceled' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS cancellation_percentage
FROM olist_orders_dataset;


/* ============================================================
   SECTION 5 — CUSTOMER SATISFACTION
   ============================================================ */


/* Q11. Categories with the highest customer ratings
   A minimum of 50 reviews is used to avoid very small samples. */
WITH category_reviews AS (
    SELECT DISTINCT
        r.review_id,
        r.order_id,
        p.product_category_name,
        r.review_score
    FROM olist_order_reviews_dataset r
    JOIN olist_order_items_dataset oi
        ON r.order_id = oi.order_id
    JOIN olist_products_dataset p
        ON oi.product_id = p.product_id
)
SELECT
    COALESCE(
        t.product_category_name_english,
        cr.product_category_name
    ) AS category,
    ROUND(AVG(cr.review_score), 2) AS average_rating,
    COUNT(DISTINCT cr.review_id) AS reviews
FROM category_reviews cr
LEFT JOIN product_category_name_translation t
    ON cr.product_category_name = t.product_category_name
GROUP BY category
HAVING COUNT(DISTINCT cr.review_id) >= 50
ORDER BY average_rating DESC;


/* Q15. Categories with high sales but poor customer ratings
   High sales = above the average category revenue.
   Poor rating = below the average category rating.
   Minimum 50 reviews per category. */
WITH category_sales AS (
    SELECT
        p.product_category_name,
        COUNT(*) AS units_sold,
        SUM(oi.price) AS revenue
    FROM olist_order_items_dataset oi
    JOIN olist_products_dataset p
        ON oi.product_id = p.product_id
    GROUP BY p.product_category_name
),
category_ratings AS (
    SELECT DISTINCT
        r.review_id,
        r.order_id,
        p.product_category_name,
        r.review_score
    FROM olist_order_reviews_dataset r
    JOIN olist_order_items_dataset oi
        ON r.order_id = oi.order_id
    JOIN olist_products_dataset p
        ON oi.product_id = p.product_id
),
category_metrics AS (
    SELECT
        cs.product_category_name,
        cs.units_sold,
        cs.revenue,
        AVG(cr.review_score) AS avg_rating,
        COUNT(DISTINCT cr.review_id) AS review_count
    FROM category_sales cs
    JOIN category_ratings cr
        ON cs.product_category_name = cr.product_category_name
    GROUP BY
        cs.product_category_name,
        cs.units_sold,
        cs.revenue
    HAVING COUNT(DISTINCT cr.review_id) >= 50
),
benchmarks AS (
    SELECT
        AVG(revenue) AS avg_category_revenue,
        AVG(avg_rating) AS avg_category_rating
    FROM category_metrics
)
SELECT
    COALESCE(
        t.product_category_name_english,
        cm.product_category_name
    ) AS category,
    cm.units_sold,
    ROUND(cm.revenue, 2) AS revenue,
    ROUND(cm.avg_rating, 2) AS avg_rating,
    cm.review_count
FROM category_metrics cm
CROSS JOIN benchmarks b
LEFT JOIN product_category_name_translation t
    ON cm.product_category_name = t.product_category_name
WHERE cm.revenue > b.avg_category_revenue
  AND cm.avg_rating < b.avg_category_rating
ORDER BY cm.revenue DESC;


/* ============================================================
   SECTION 6 — ADDITIONAL PORTFOLIO ANALYSIS
   ============================================================ */


/* Extra 1. Top 10% of customers by spending
   NTILE(10) divides customers into ten spending groups. */
WITH customer_spend AS (
    SELECT
        o.customer_id,
        SUM(p.payment_value) AS total_spending
    FROM olist_orders_dataset o
    JOIN olist_order_payments_dataset p
        ON o.order_id = p.order_id
    GROUP BY o.customer_id
),
ranked_customers AS (
    SELECT
        customer_id,
        total_spending,
        NTILE(10) OVER (
            ORDER BY total_spending DESC
        ) AS spending_decile
    FROM customer_spend
)
SELECT
    customer_id,
    ROUND(total_spending, 2) AS total_spending,
    spending_decile
FROM ranked_customers
WHERE spending_decile = 1
ORDER BY total_spending DESC;


/* Extra 2. Ranked top sellers by revenue */
WITH seller_revenue AS (
    SELECT
        seller_id,
        SUM(price) AS revenue
    FROM olist_order_items_dataset
    GROUP BY seller_id
),
ranked_sellers AS (
    SELECT
        seller_id,
        revenue,
        RANK() OVER (
            ORDER BY revenue DESC
        ) AS seller_rank
    FROM seller_revenue
)
SELECT
    seller_id,
    ROUND(revenue, 2) AS revenue,
    seller_rank
FROM ranked_sellers
WHERE seller_rank <= 10
ORDER BY seller_rank;


/* ============================================================
   END OF PROJECT ANALYSIS
   ============================================================ */
