# Customer Segmentation & Revenue Intelligence using SQL

A customer intelligence analysis of the Chinook digital music store database. The project uses SQL to identify high-value customers, measure revenue concentration, segment the customer base, and track revenue trends over time.

---

## 1. Business Problem

A digital media company wants to build a customer intelligence system from its sales database. The goal is to identify:

- Valuable customers
- Purchasing patterns
- Customer segments
- Revenue contribution

---

## 2. Dataset

**Chinook Database** (sample digital music store database)
Source: https://github.com/lerocha/chinook-database

The database contains customers, invoices, invoice line items, tracks, albums, artists, genres, and employees. Analysis covers 59 customers and 2,328.60 in total revenue.

*Note: Chinook is a sample dataset, not real company data. Several values repeat across customers and months, so the findings describe this dataset and show the analytical approach, not real business performance.*

---

## 3. Database Schema

The core tables used in this analysis:

| Table | Key Columns | Purpose |
|---|---|---|
| `Customer` | CustomerId, FirstName, LastName, Country, SupportRepId | Customer details |
| `Invoice` | InvoiceId, CustomerId, InvoiceDate, Total | Purchase transactions and revenue |
| `InvoiceLine` | InvoiceId, TrackId, UnitPrice, Quantity | Items within each purchase |
| `Track` | TrackId, AlbumId, GenreId | Music catalogue |
| `Album` | AlbumId, ArtistId | Links tracks to artists |
| `Artist` | ArtistId, Name | Artist names |
| `Genre` | GenreId, Name | Music genres |

**Relationships:** `Customer` → `Invoice` → `InvoiceLine` → `Track` → `Album` → `Artist`, and `Track` → `Genre`.

---

## 4. Business Questions

1. Who are the highest-spending customers?
2. Who are the most frequent purchasers?
3. Which customers have not purchased recently?
4. Which countries have the highest-value customers?
5. What is the average customer lifetime spending?
6. Which genres are most popular?
7. Which artists generate the highest revenue?
8. Which tracks are purchased most frequently?
9. How can customers be segmented into High, Medium and Low Value?
10. How do customers rank by spending within each country?
11. Which customers spend above average?
12. Who are the top 3 customers in each country?
13. Which customers have purchased from multiple genres?
14. What percentage of total revenue does each customer contribute?
15. What is the cumulative revenue over time, and is it growing?
16. Which month generated the highest revenue?

---

## 5. SQL Concepts Used

- SELECT, WHERE, ORDER BY, LIMIT
- GROUP BY with aggregate functions (`SUM`, `COUNT`, `AVG`, `MAX`, `MIN`)
- HAVING (filtering aggregated results)
- INNER JOIN and LEFT JOIN
- Multi-table joins (InvoiceLine → Track → Album → Artist, and Track → Genre)
- CASE WHEN (customer segmentation)
- CTEs (`WITH` clause)
- Subqueries (scalar subquery for the overall average)
- Window functions: `NTILE`, `RANK`, `ROW_NUMBER`, `SUM() OVER`, `LAG`
- Date functions: `DATEDIFF`, `DATE_FORMAT`
- NULL handling: `COALESCE`, `NULLIF`
- String functions: `CONCAT`

---

## 6. SQL Queries

All queries are in `Chinook Customer Segmentation.sql`, in the order of the business questions above. Each query has a comment explaining the business question it answers.

To reproduce the analysis, run the queries in order after the database is set up (see Setup below).

---

## 7. Key Findings

**Revenue and customer value**
- Total revenue is 2,328.60 across 59 customers.
- Average lifetime spending is 39.47 per customer, ranging from 36.64 (lowest) to 49.62 (highest).
- Helena Holý (Czech Republic) is the highest-spending customer at 49.62.

**Revenue concentration**
- No single customer contributes more than 2.13% of total revenue, and the top 10 customers each contribute between about 1.8% and 2.1%. Revenue is spread across the customer base, so the business is not dependent on a few accounts.

**Customer segments (NTILE, 3 groups by customer count)**

| Segment | Customers | Revenue | Share of Revenue | Avg Spend |
|---|---|---|---|---|
| High Value | 20 | 852.40 | 36.61% | 42.62 |
| Medium Value | 20 | 762.40 | 32.74% | 38.12 |
| Low Value | 19 | 713.80 | 30.65% | 37.57 |

The three segments contribute similar shares of revenue. The gap in average spend between High and Low Value is about 5, so the segment labels describe relative rank within this customer base rather than large differences in behaviour.

**Geography**
- The USA is the largest market, with 13 customers and 523.06 in revenue (about 22% of total).
- Germany has 4 customers and 156.48 in revenue, with an average value of 39.12.
- Several countries with one customer show higher average value (for example Chile at 46.62). These averages are based on a single customer and should not be read as market trends.
- Within each country, the top 3 customers are listed in Q12 (strict top 3). Q10 shows the full ranking, including ties.

**Catalogue**
- Rock is the best-selling genre by units (835) and revenue (826.65), about 35% of total revenue. Latin is second with 382.14.
- Iron Maiden is the top-earning artist (138.60), followed by U2 (105.93) and Metallica (90.09).
- Track-level sales are low: the top 10 tracks each sold only 2 units, so no single track stands out.

**Customer behaviour**
- The most frequent purchasers have 7 purchases each, led by Helena Holý and Richard Cunningham.
- Customers with no purchase in the last 180 days are listed in the Q3 output. Recency is measured against the latest invoice date in the data, not today's date.
- Luis Rojas has purchased from 12 genres, the widest spread in the customer base.

**Revenue trend**
- Monthly revenue is flat at about 37.62 across the months shown (January to October 2021), and the month-over-month percentage change is near zero. Cumulative revenue rises steadily to 374.22 by October 2021, which reflects a constant monthly rate, not accelerating growth.
- The highest-revenue month is January 2022 (52.62).

---

## 8. Business Recommendations

- **Protect high-value customers.** The High Value segment generates about 37% of revenue from a third of customers. Loyalty offers and priority support are appropriate here.
- **Re-engage lapsed customers.** Use the Q3 list to target customers with no recent purchases, starting with those who were previously high spenders.
- **Grow the Medium and Low segments.** Their average spend is 38.12 and 37.57. Bundles or genre recommendations, using the multi-genre customers from Q13 as a model, could raise spending.
- **Invest in Rock and Latin.** These genres generate most of the revenue, so catalogue expansion and promotion should focus there.
- **Review the catalogue for weak tracks.** With few tracks selling more than 2 units, promotion may be more effective than catalogue expansion for individual titles.
- **Plan promotions around peak months.** January 2022 was the highest-revenue month, so plan campaigns in the lead-up to it.
- **Find new revenue, since current revenue is flat.** Flat monthly revenue means growth has to come from new customers, higher spend per customer, or new catalogue.

---

## 9. Conclusion

This project uses SQL across 16 business questions to build a customer intelligence view of the Chinook database. It covers customer value, segmentation, geographic performance, catalogue sales, and revenue trends. The analysis shows that revenue is spread evenly across customers, which lowers the risk of losing any single account. Rock and Latin drive the catalogue, the USA is the largest market, and revenue is flat across the months shown.

---

## Setup

1. Download `Chinook_MySql.sql` from https://github.com/lerocha/chinook-database.
2. Open MySQL Workbench (or any MySQL 8.0+ client) and run the full script. It drops and recreates the `Chinook` database.
3. Run `Chinook Customer Segmentation.sql` to execute the analysis.

**Requirements:** MySQL 8.0 or later (window functions and CTEs are required).

---

## Tools

- MySQL 8.0
- MySQL Workbench
- GitHub
