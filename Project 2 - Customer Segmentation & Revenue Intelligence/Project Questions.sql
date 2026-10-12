-- Customer Segmentation & Revenue Analytics using SQL
-- Exploring the schema


USE Chinook;

SHOW TABLES;

-- Core tables for analytics
DESCRIBE Customer;
DESCRIBE Invoice;
DESCRIBE InvoiceLine;
DESCRIBE Track;

-- Row counts to confirm the import
SELECT COUNT(*) AS customers FROM Customer;
SELECT COUNT(*) AS invoices FROM Invoice;
SELECT COUNT(*) AS tracks FROM Track;

-- Q1. Highest Spending Customer
-- These Customers are the core revenue base, protect them 
-- with loyalty offers and priority support.

SELECT c.CustomerId, 
       CONCAT(c.FirstName, ' ' , c.LastName) AS customer_name, c.country,
       ROUND(SUM(i.Total), 2) AS total_spent
FROM Customer c 
INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName, c.LastName
ORDER BY total_spent DESC
LIMIT 10;


-- Q2. Most Frequent Purchasers
-- Frequency shows engagement

SELECT c.CustomerId,
       CONCAT(c.FirstName, ' ' , c.LastName) AS customer_name,
       COUNT(i.InvoiceId) AS number_of_purchases,
       ROUND(SUM(i.Total), 2) AS total_spent
FROM Customer c
INNER JOIN Invoice i ON c.CustomerId = i.CustomerId 
GROUP BY c.CustomerId, c.FirstName, c.LastName
ORDER BY number_of_purchases DESC, total_spent DESC
LIMIT 10;


-- Q3. Customers who haven't purchased recently
-- Helps to find customers who haven't purchased for a long time
-- so the company can try to bring them back

WITH last_purchase AS (
	SELECT c.CustomerId,
		   CONCAT(c.FirstName, ' ' , LastName) AS customer_name,
           c.Country,
           MAX(i.InvoiceDate) AS last_purchase_date
    FROM Customer c 
    LEFT JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId, c.FirstName, c.LastName, c.Country
),
recency AS (
    SELECT customer_name, 
           Country, 
           last_purchase_date,
		   COALESCE(DATEDIFF((SELECT MAX(InvoiceDate) FROM Invoice), last_purchase_date), 9999)
               AS days_since_last_purchase
	FROM last_purchase
)
SELECT customer_name, Country, last_purchase_date, days_since_last_purchase 
FROM recency
WHERE days_since_last_purchase > 180
ORDER BY days_since_last_purchase;


-- Q4. Countries with Highest Value Customer
-- average value per customer shows where each acquired
-- customer is worth most.

WITH customer_totals As ( 
	SELECT c.CustomerId, c.Country, SUM(i.Total) AS total_spent 
    FROM Customer c 
    INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId, c.Country
)
SELECT Country,
       COUNT(*) AS num_customers,
       ROUND(SUM(total_spent), 2) AS country_revenue,
       ROUND(AVG(total_spent), 2) AS avg_customer_value
FROM customer_totals
GROUP BY Country
ORDER BY avg_customer_value DESC;


-- Q5. Average Customer Lifetime Spending
-- This will help to makle budget decision 

WITH customer_totals As (
	SELECT CustomerId, SUM(Total) AS total_spent
    FROM Invoice 
    GROUP BY CustomerId
)
SELECT ROUND(AVG(total_spent), 2) AS avg_lifetime_spending,
	   ROUND(MAX(total_spent), 2) AS max_lifetime_spending,
       ROUND(MIN(total_spent), 2) AS min_lifetime_spending
FROM customer_totals;


-- Q6. Most Popular Genres
-- Tells the team which genre needs to be expanded

SELECT g.Name AS genre,
       SUM(il.Quantity) AS units_sold,
       ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS revenue
FROM InvoiceLine il
INNER JOIN Track t ON t.TrackId = il.TrackId
INNER JOIN Genre g ON g.GenreId = t.GenreId
GROUP BY g.GenreId, g.Name
ORDER BY units_sold DESC;


-- Q7. Top Revenue Generating Artist
-- Identifies Artists who are most popular among the listeners

SELECT ar.Name As artist,
       SUM(il.Quantity) AS units_sold,
       ROUND(SUM(il.UnitPrice * il.Quantity), 2) As revenue 
FROM InvoiceLine il
INNER JOIN Track t ON il.TrackId = t.TrackId
INNER JOIN Album al ON t.AlbumId = al.AlbumId
INNER JOIN Artist ar ON al.ArtistId = ar.ArtistId
GROUP BY ar.ArtistId, ar.Name 
ORDER BY revenue DESC 
LIMIT 10;


-- Q8. Most Frequently Purchased Tracks
-- This will help the company to know and promote the track

SELECT t.Name AS track,
       ar.Name As artist,
       SUM(il.Quantity) AS units_sold,
       ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS revenue
FROM InvoiceLine il
INNER JOIN Track t ON il.TrackId = t.TrackId
INNER JOIN Album al ON t.AlbumId = al.AlbumId
INNER JOIN Artist ar On al.ArtistId = ar.ArtistId
GROUP BY t.TrackId, t.Name, ar.Name
ORDER BY units_sold DESC, revenue DESC, track
LIMIT 10;


-- Q9. Customer Segments: High, Medium and Low Value
-- NTILE(3) splits customers into three equal groups by total spend.
-- Each segment can then be targeted with a different retention or growth plan.

WITH customer_totals AS (
	SELECT c.CustomerId,
           CONCAT(c.FirstName, ' ' , LastName) AS customer_name,
           c.Country,
           SUM(i.Total) AS total_spent 
	FROM Customer c 
    INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId, c.FirstName, c.LastName, c.Country
),
bucketed AS ( 
	SELECT *, NTILE(3) OVER (ORDER BY total_spent DESC) AS spend_bucket
    FROM customer_totals
)
 SELECT CustomerId, customer_name, Country,
        ROUND(total_spent, 2) AS total_spent,
        CASE spend_bucket 
             WHEN 1 THEN 'High Value'
             WHEN 2 THEN 'Medium Value'
             ELSE 'Low Value'
		END AS customer_segment
FROM bucketed
ORDER BY total_spent DESC;

-- 9.1 Segment summary (revenue share of each segment)

WITH customer_totals AS (
    SELECT CustomerId, SUM(Total) AS total_spent
    FROM Invoice
    GROUP BY CustomerId
),
bucketed AS (
    SELECT *, NTILE(3) OVER (ORDER BY total_spent DESC) AS spend_bucket
    FROM customer_totals
)
SELECT CASE spend_bucket 
            WHEN 1 THEN 'High Value'
			WHEN 2 THEN 'Medium Value'
			ELSE 'Low Value' END AS customer_segment,
       COUNT(*) AS num_customers,
       ROUND(SUM(total_spent), 2) AS segment_revenue,
       ROUND(SUM(total_spent) * 100 / SUM(SUM(total_spent)) OVER (), 2) AS pct_of_revenue,
       ROUND(AVG(total_spent), 2) AS avg_spend
FROM bucketed
GROUP BY spend_bucket
ORDER BY spend_bucket;

-- Q10. Customers Rank by Spending Within Each Country
-- Best customer per market for regional teams

WITH customer_totals AS (
	SELECT c.CustomerId, 
           CONCAT(c.FirstName, ' ' , LastName) AS customer_name,
           c.Country,
           SUM(i.Total) AS total_spent
	FROM Customer c
    INNER JOIN Invoice i On c.CustomerId = i.CustomerId
    GROUP BY c.CustomerID, c.FIrstName, c.LastName, c.Country
)
SELECT Country,
       customer_name,
       ROUND(total_spent, 2) AS total_spent,
       RANK() OVER (PARTITION BY Country ORDER BY total_spent DESC) AS rank_in_country
FROM customer_totals
ORDER BY Country, rank_in_country;


-- Q11. Customers whose spending is above avg
-- This group is the target for premium offers and loyalty programmes

WITH customer_totals AS (
    SELECT c.CustomerId,
           CONCAT(c.FirstName, ' ', c.LastName) AS customer_name,
           c.Country,
           SUM(i.Total) AS total_spent
    FROM Customer c
    INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId, c.FirstName, c.LastName, c.Country
)
SELECT customer_name, Country,
       ROUND(total_spent, 2) AS total_spent,
       (SELECT ROUND(AVG(total_spent), 2) FROM customer_totals) AS overall_avg
FROM customer_totals
WHERE total_spent > (SELECT AVG(total_spent) FROM customer_totals)
ORDER BY total_spent DESC;


-- Q12. Top 3 Customers in Each Country
-- ROW_NUMBER with CustomerId as a tie-breaker returns exactly 3 per country.
-- Customers tied with the 3rd place are excluded; see Q10 for the full ranking.

WITH customer_totals AS (
    SELECT c.CustomerId,
           CONCAT(c.FirstName, ' ', c.LastName) AS customer_name,
           c.Country,
           SUM(i.Total) AS total_spent
    FROM Customer c
    INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId, c.FirstName, c.LastName, c.Country
),
ranked AS (
    SELECT Country, customer_name, total_spent,
           ROW_NUMBER() OVER (PARTITION BY Country
                              ORDER BY total_spent DESC, CustomerId) AS rnk
    FROM customer_totals
)
SELECT Country, customer_name, ROUND(total_spent, 2) AS total_spent, rnk
FROM ranked
WHERE rnk <= 3
ORDER BY Country, rnk;


-- Q13. Customers who have purchased from multiple genres
-- genre-diverse customers are open to recommendations,
-- single-genre customers can be nudged to explore.

SELECT c.CustomerId,
       CONCAT(c.FirstName, ' ', c.LastName) AS customer_name,
       COUNT(DISTINCT t.GenreId) AS genres_purchased
FROM Customer c
INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
INNER JOIN InvoiceLine il ON i.InvoiceId  = il.InvoiceId
INNER JOIN Track t ON il.TrackId   = t.TrackId
GROUP BY c.CustomerId, c.FirstName, c.LastName
HAVING COUNT(DISTINCT t.GenreId) > 1
ORDER BY genres_purchased DESC, customer_name;


-- Q14. Each Customer's Percentage Contribution to Total Revenue
-- Shows revenue concentration. If a handful of customers drive a large share,
-- losing them is a major risk.

WITH customer_totals AS (
    SELECT c.CustomerId,
           CONCAT(c.FirstName, ' ', c.LastName) AS customer_name,
           SUM(i.Total) AS total_spent
    FROM Customer c
    INNER JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId, c.FirstName, c.LastName
)
SELECT customer_name,
       ROUND(total_spent, 2) AS total_spent,
       ROUND(total_spent * 100 / SUM(total_spent) OVER (), 2) AS pct_of_total_revenue
FROM customer_totals
ORDER BY total_spent DESC;


-- Q15. Cumulative Revenue Using Window Function
-- Shows the running total and month-over-month change, so growth
-- or flattening is visible.

WITH monthly_revenue AS (
    SELECT DATE_FORMAT(InvoiceDate, '%Y-%m') AS revenue_month,
           SUM(Total) AS monthly_revenue
    FROM Invoice
    GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
)
SELECT revenue_month,
       ROUND(monthly_revenue, 2) AS monthly_revenue,
       ROUND(SUM(monthly_revenue) OVER (ORDER BY revenue_month), 2) AS cumulative_revenue,
       ROUND(monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY revenue_month), 2)
           AS change_vs_prev_month,
       ROUND((monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY revenue_month)) * 100
             / NULLIF(LAG(monthly_revenue) OVER (ORDER BY revenue_month), 0), 2)
           AS pct_change
FROM monthly_revenue
ORDER BY revenue_month;


-- Q16. Highest Revenue Month
-- peak month to plan promotions and server/catalogue
-- readiness around.

WITH monthly_revenue AS (
    SELECT DATE_FORMAT(InvoiceDate, '%Y-%m') AS revenue_month,
           SUM(Total) AS monthly_revenue
    FROM Invoice
    GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
)
SELECT revenue_month, ROUND(monthly_revenue, 2) AS monthly_revenue
FROM monthly_revenue
ORDER BY monthly_revenue DESC
LIMIT 1;