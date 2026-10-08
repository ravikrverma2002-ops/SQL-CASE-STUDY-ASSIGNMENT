DROP DATABASE olist_ecommerce;

CREATE DATABASE olist_ecommerce;

USE olist_ecommerce;

CREATE TABLE olist_customers_dataset (
customer_id VARCHAR(32),
customer_unique_id VARCHAR(32),
customer_zip_code_prefix INT,
customer_city VARCHAR(100),
customer_state CHAR (2)
);

CREATE TABLE olist_orders_dataset (
order_id VARCHAR(32),
customer_id VARCHAR(32),
order_status VARCHAR(32),
order_purchase_timestamp DATETIME,
order_approved_at DATETIME,
order_deliverd_carrier_date DATETIME,
order_delivered_customer_date DATETIME,
order_estimated_delivery_date DATETIME
);

CREATE TABLE olist_order_items_dataset (
order_id VARCHAR(32),
order_item_id INT,
product_id VARCHAR(32),
seller_id VARCHAR(32),
shipping_limit_date DATETIME,
price DECIMAL(10,2),
freight_value DECIMAL(10,2)
);

CREATE TABLE olist_order_payments_dataset (
order_id VARCHAR(32),
payment_sequential INT,
payment_type VARCHAR(30),
payment_instalments INT,
payment_value DECIMAL(10,2)
);

CREATE TABLE olist_order_reviews_dataset (
review_id VARCHAR(32),
order_id VARCHAR(32),
review_score INT,
review_comment_title VARCHAR(255),
review_comment_message TEXT,
review_creation_date DATETIME,
review_answer_timestamp DATETIME
);

CREATE TABLE olist_products_dataset (
product_id VARCHAR(32),
product_category_name VARCHAR(100),
product_name_length INT,
product_description_length INT,
products_photos_qty INT,
product_weight_g INT,
product_length_cm INT,
product_height_cm INT,
product_width_cm INT 
);

CREATE TABLE olist_sellers_dataset (
seller_id VARCHAR(32),
seller_zip_code_prefix INT,
seller_city VARCHAR(100),
seller_state CHAR(2)
);

CREATE TABLE product_category_name_translation (
product_category_name VARCHAR(100),
product_category_name_english VARCHAR(100)
);

CREATE TABLE olist_geolocation_dataset (
geolocation_zip_code_prefix INT,
geolocation_lat DECIMAL(10,8),
geolocation_lng DECIMAL(11,8),
geolocation_city VARCHAR(100),
geolocation_state CHAR(2)
);

SHOW TABLES;

SHOW VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE 
'D:/PROJECTS/MY Projects/CSA/archive/product_category_name_translation.csv'
INTO TABLE product_category_name_translation 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 
'D:/PROJECTS/MY Projects/CSA/archive/olist_customers_dataset.csv'
INTO TABLE olist_customers_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 
'D:/PROJECTS/MY Projects/CSA/archive/olist_geolocation_dataset.csv'
INTO TABLE olist_geolocation_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 
'D:/PROJECTS/MY Projects/CSA/archive/olist_order_items_dataset.csv'
INTO TABLE olist_order_items_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 
'D:/PROJECTS/MY Projects/CSA/archive/olist_order_payments_dataset.csv'
INTO TABLE olist_order_payments_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 
'D:/PROJECTS/MY Projects/CSA/archive/olist_order_reviews_dataset.csv'
INTO TABLE olist_order_reviews_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 
'D:/PROJECTS/MY Projects/CSA/archive/olist_orders_dataset.csv'
INTO TABLE olist_orders_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 
'D:/PROJECTS/MY Projects/CSA/archive/olist_products_dataset.csv'
INTO TABLE olist_products_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 
'D:/PROJECTS/MY Projects/CSA/archive/olist_sellers_dataset.csv'
INTO TABLE olist_sellers_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

