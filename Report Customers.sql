/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/
-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================
IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS

/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/
with base_query as(
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ',c.last_name) customer_name,
DATEDIFF(YEAR,birthdate,GETDATE()) age
FROM gold.fact_sales f
LEFT JOIN GOLD.dim_customers c
ON f.customer_key = c.customer_key 
)

/*---------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------------*/
,customer_aggregation AS (
SELECT 
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) as total_orders,
	SUM(sales_amount) total_sales,
	SUM(quantity) total_quantity,
	COUNT(DISTINCT product_key) Total_Products,
	MAX(order_date) AS last_order_Date,
	datediff(month,min(order_date),MAX(order_date)) AS Lifespan
from base_query
GROUP BY 
	customer_key,
	customer_number,
	customer_name,
	age
)
SELECT 
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE 
	 WHEN age < 20 THEN 'Under 20'
	 WHEN age between 20 and 29 THEN '20-29'
	 WHEN age between 30 and 39 THEN '30-39'
	 WHEN age between 40 and 49 THEN '40-49'
	 ELSE '50 and above'
END AS age_group,
	CASE 
    WHEN LifeSpan >= 12 AND total_sales > 5000 THEN 'VIP'
    WHEN LifeSpan >= 12 AND total_sales<= 5000 THEN 'Regular'
    ELSE 'NEW'
    END  AS Customer_Segment,
	total_orders,
	total_sales,
	total_quantity,
	Total_Products,
	last_order_Date,
	DATEDIFF(MONTH,last_order_Date,GETDATE()) recency,
	Lifespan,
	-- Compuate average order value (AVO)
	CASE
		WHEN total_sales = 0 THEN 0
		ELSE total_sales/Total_orders
	END AS avg_order_value,
	-- Compuate average monthly spend
	CASE
		WHEN Lifespan = 0 THEN total_sales
		ELSE total_sales/Lifespan
	END AS avg_monthly_spending
FROM customer_aggregation

