/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

/*Segment products into cost ranges and 
count how many products fall into each segment*/
    WITH Product_Segement AS (
SELECT
product_key,
product_name,
cost,
CASE 
    WHEN COST < 100 THEN 'Below 100'
    WHEN COST BETWEEN 100 AND 500 THEN '100-500'
    WHEN COST BETWEEN 500 AND 1000 THEN '500-1000'
    ELSE 'ABOVE 1000'
    END AS Cost_Range
FROM GOLD.dim_products
)
SELECT 
Cost_range,
count(product_key) AS TOTAL_PRODUCT
FROM Product_Segement
GROUP BY Cost_Range
ORDER BY TOTAL_PRODUCT DESC;

/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/
with Customer_Spending AS(
SELECT
    c.Customer_key,
    sum(f.sales_amount) AS Total_Spending,
    min(order_date) as first_order,
    max(order_date) as last_order,
    DATEDIFF(MONTH,min(order_date),max(order_date)) AS LifeSpan
from gold.fact_sales f
left join gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)

SELECT 
    Customer_Segment,
    COUNT(Customer_key) AS Total_Customer
from(
SELECT
customer_key,
CASE 
    WHEN LifeSpan >= 12 AND Total_Spending > 5000 THEN 'VIP'
    WHEN LifeSpan >= 12 AND Total_Spending <= 5000 THEN 'Regular'
    ELSE 'NEW'
    END  AS Customer_Segment
FROM Customer_Spending)t
GROUP BY Customer_Segment
ORDER BY Total_Customer desc;