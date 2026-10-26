/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/
-- Which categories contribute the most to overall sales?
WITH Category_Sales AS (
SELECT
p.category,
SUM(F.sales_amount) AS Total_Sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
on f.product_key = p.product_key
GROUP BY p.category
)
SELECT 
category,
Total_Sales,
SUM(Total_Sales) OVER() AS Overall_Sales,
ROUND(CAST(Total_Sales AS FLOAT) /SUM(Total_Sales) OVER() * 100,2) AS Percentage_of_Total
FROM Category_Sales
ORDER BY Total_Sales DESC; 
