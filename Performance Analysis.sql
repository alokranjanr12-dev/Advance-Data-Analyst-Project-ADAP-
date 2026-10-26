/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */
WITH Yearly_Product_Sales AS (
SELECT
YEAR(f.order_date) AS Order_Year,
p.product_name,
SUM(f.sales_amount) AS Current_Sale
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date is not null
GROUP BY YEAR(f.order_date) ,p.product_name
)
SELECT
    Order_Year,
    product_name,
    Current_Sale,
    AVG(Current_Sale) OVER(PARTITION BY product_name) AS avg_sale,
    Current_Sale - AVG(Current_Sale) OVER(PARTITION BY product_name) AS diff_avg,
    CASE 
        WHEN Current_Sale - AVG(Current_Sale) OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN Current_Sale - AVG(Current_Sale) OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS Avg_Change,
-- YEAR OVER YEAR ANALYSIS
    LAG(Current_Sale) OVER(PARTITION BY product_name ORDER BY ORDER_YEAR) AS Py_sale,
    Current_Sale -  LAG(Current_Sale) OVER(PARTITION BY product_name ORDER BY ORDER_YEAR) AS diff_Py,
    CASE 
        WHEN Current_Sale -  LAG(Current_Sale) OVER(PARTITION BY product_name ORDER BY ORDER_YEAR) > 0 THEN 'Increase'
        WHEN Current_Sale -  LAG(Current_Sale) OVER(PARTITION BY product_name ORDER BY ORDER_YEAR) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS py_Change
FROM Yearly_Product_Sales
ORDER BY product_name, Order_Year
    
