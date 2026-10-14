# E-Commerce Sales & Customer Analytics Using SQL

## Project Overview

This project analyzes the Brazilian E-Commerce Public Dataset by Olist using MySQL.

The objective is to understand e-commerce sales performance, customer behavior, product and category performance, seller performance, payment patterns, delivery operations, and customer satisfaction.

The analysis uses multiple related tables from the Olist dataset and demonstrates how SQL can be used to answer real-world business questions.

---

## Dataset

**Dataset:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

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
├── Project Questions.sql
│
└── Screenshots
