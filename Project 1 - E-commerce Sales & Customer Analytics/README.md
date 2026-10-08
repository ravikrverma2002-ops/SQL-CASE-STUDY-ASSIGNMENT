# E-Commerce Sales & Customer Analytics Using SQL

## Project Overview

This project analyzes the Brazilian E-Commerce Public Dataset by Olist using MySQL.

The objective is to understand e-commerce sales performance, customer behavior, product and category performance, seller performance, payment patterns, delivery operations, and customer satisfaction.

The analysis uses multiple related tables from the Olist dataset and demonstrates how SQL can be used to answer real-world business questions.

---

## Business Problem

An e-commerce business generates large amounts of transactional, customer, product, seller, payment, delivery, and review data.

The goal of this project is to analyze that data and answer key business questions such as:

- How much revenue is being generated?
- How are sales changing over time?
- Which product categories and products perform best?
- Which sellers generate the most revenue?
- Which customer locations generate the most sales?
- What is the average order value?
- Which payment methods are most commonly used?
- How long does delivery take?
- Which categories receive the best customer ratings?
- Do late deliveries affect customer satisfaction?
- Who are the highest-value customers?
- What percentage of orders are cancelled?
- Which categories generate strong sales but have poor customer ratings?

---

## Dataset

**Dataset:** Brazilian E-Commerce Public Dataset by Olist

The dataset contains information about orders, customers, products, sellers, payments, reviews, product categories, and geolocation.

### Main Tables

| Table | Description |
|---|---|
| `olist_orders_dataset` | Order information and order status/timestamps |
| `olist_order_items_dataset` | Products included in each order |
| `olist_order_payments_dataset` | Payment information for orders |
| `olist_order_reviews_dataset` | Customer review scores and review information |
| `olist_customers_dataset` | Customer information and location |
| `olist_products_dataset` | Product information and categories |
| `olist_sellers_dataset` | Seller information |
| `product_category_name_translation` | Portuguese-to-English product category translation |
| `olist_geolocation_dataset` | Brazilian geolocation information |

---

## Database

**Database:** `olist_ecommerce`

**SQL Tool:** MySQL

The project uses relational tables connected through keys such as:

- `order_id`
- `customer_id`
- `product_id`
- `seller_id`
- `product_category_name`

These relationships allow information from different parts of the e-commerce system to be combined for analysis.

---

## Business Questions

The project answers the following questions:

1. What is the total number of orders and total revenue?
2. What are the monthly sales trends?
3. What are the yearly sales trends?
4. Which product categories generate the highest revenue?
5. Which products have the highest sales volume?
6. Which sellers generate the highest revenue?
7. Which customer states generate the most sales?
8. What is the average order value?
9. What are the most commonly used payment methods?
10. What is the average delivery time?
11. Which product categories have the highest customer ratings?
12. Are late deliveries associated with lower customer review scores?
13. Who are the top customers by spending?
14. What percentage of orders are cancelled?
15. Which categories have high sales but poor customer ratings?

### Additional Portfolio Analyses

To demonstrate advanced SQL techniques, the project also includes:

16. Who belongs to the top 10% of customers by spending?
17. Which sellers rank highest by revenue?

---

## SQL Concepts Demonstrated

This project demonstrates practical use of:

- `SELECT`
- `WHERE`
- `ORDER BY`
- `GROUP BY`
- `HAVING`
- Aggregate functions such as `SUM()`, `COUNT()`, and `AVG()`
- `CASE WHEN`
- `INNER JOIN`
- `LEFT JOIN`
- Multiple-table joins
- `COALESCE()`
- `DISTINCT`
- Date functions such as `YEAR()`, `DATE_FORMAT()`, and `DATEDIFF()`
- Common Table Expressions (CTEs)
- Window functions
- `NTILE()`
- `LAG()`
- `RANK()`
- `NULLIF()`

---

## Key Analysis Areas

### 1. Sales Performance

Sales data is analyzed at monthly and yearly levels to understand revenue and order trends over time.

### 2. Product & Category Performance

Product and category analysis identifies the products and categories generating the highest sales volume and revenue.

### 3. Seller Performance

Seller-level analysis identifies the highest-revenue sellers and ranks them based on sales performance.

### 4. Customer Analysis

Customer spending and geographic information are analyzed to identify high-value customers and locations generating the most sales.

### 5. Payment Analysis

Payment data is used to understand the most frequently used payment methods and their transaction values.

### 6. Delivery Performance

Order timestamps are used to calculate average delivery time and classify deliveries as on-time or late.

### 7. Customer Satisfaction

Review scores are analyzed by product category and compared with delivery performance to understand potential relationships between operational performance and customer satisfaction.

### 8. High-Sales / Low-Rating Categories

Categories with strong revenue performance but weaker customer ratings are identified for further investigation.

---

## Advanced SQL Analysis

### Top 10% Customers

`NTILE(10)` is used to divide customers into ten spending groups and identify the highest-spending decile.

This helps identify the business's highest-value customer segment.

### Seller Ranking

`RANK()` is used to rank sellers based on total revenue.

These analyses demonstrate the use of SQL window functions for business analysis.

---

## Business Insights

The analysis is designed to identify:

- Overall sales and revenue performance
- Changes in sales over time
- High-performing product categories
- High-volume products
- Top-performing sellers
- High-value customers
- Important customer markets by state
- Customer payment preferences
- Delivery performance
- Relationship between delivery delays and customer satisfaction
- Categories requiring attention because of strong sales but weaker ratings
- Revenue growth and changes between months

---

## Business Recommendations

Based on the analysis, businesses can use the findings to:

1. **Focus on high-performing categories**  
   Continue supporting categories that generate strong revenue and sales volume.

2. **Investigate high-sales but low-rated categories**  
   Categories with strong sales but weaker ratings should be investigated for possible product quality, customer expectation, packaging, or service issues.

3. **Improve delivery performance**  
   If late deliveries are associated with lower review scores, improving logistics and delivery reliability can help improve customer satisfaction.

4. **Focus on high-value customers**  
   The top-spending customer segment can be targeted through loyalty initiatives, personalized offers, and retention strategies.

5. **Monitor seller performance**  
   High-performing sellers can be studied to identify practices that contribute to stronger revenue performance.

6. **Track revenue trends regularly**  
   Month-over-month revenue analysis can help identify periods of growth or decline and support better planning.

---

## Project Structure

```text
01. E-Commerce-Sales-Customers-Analytics
│
├── README.md
│
├── ecommerce_sales_customer_analytics.sql
│
├── E-Commerce.sql
│
├── Project Questions.sql
│
└── Screenshots
