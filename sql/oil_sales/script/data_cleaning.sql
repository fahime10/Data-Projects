-- Data cleaning

SELECT * FROM oil_sales LIMIT 10;

-- ALTER table oil_sales
-- CHANGE COLUMN `ï»¿city` `city` VARCHAR(255)

SELECT *
FROM oil_sales
WHERE CONCAT(city, store_name, manufacturer, brand, class, size, sku, price_bracket, year, month, value_sales, volume_sales, average_price) IS NULL;

SELECT 
	city, 
    store_name, 
    manufacturer, 
    brand, 
    class, 
    size, 
    sku, 
    price_bracket, 
    year, 
    month, 
    value_sales, 
    volume_sales, 
    average_price
FROM oil_sales
GROUP BY city, store_name, manufacturer, brand, class, size, sku, price_bracket, year, month, value_sales, volume_sales, average_price
HAVING COUNT(*) > 1;

WITH RankedSales AS (
	SELECT
		value_sales,
        PERCENT_RANK() OVER(ORDER BY value_sales) AS pct
	FROM oil_sales
),
Quartiles AS (
	SELECT 
		MIN(CASE WHEN pct >= 0.25 THEN value_sales END) AS q1,
        MIN(CASE WHEN pct >= 0.75 THEN value_sales END) AS q3
	FROM RankedSales
),
Boundaries AS (
	SELECT 
		q1,
        q3, 
        (q3 - q1) AS iqr,
        q1 - 1.5 * (q3 - q1) AS lower_bound,
        q3 + 1.5 * (q3 - q1) AS upper_bound
	FROM Quartiles
)
SELECT 
	o.*,
    b.lower_bound,
    b.upper_bound,
    CASE
		WHEN o.value_sales < b.lower_bound THEN 'Low outlier'
        WHEN o.value_sales > b.upper_bound THEN 'High outlier'
        ELSE "Normal"	
    END AS outlier_status
FROM oil_sales o
CROSS JOIN Boundaries b
WHERE o.value_sales < lower_bound 
 	OR o.value_sales > upper_bound;
-- No records are in the lower bound
-- There are 147 records out of 2000 where the value sales exceed the upper bound

-- To delete records
-- WITH RankedSales AS (
-- 	SELECT
-- 		value_sales,
--         PERCENT_RANK() OVER(ORDER BY value_sales) AS pct
-- 	FROM oil_sales
-- ),
-- Quartiles AS (
-- 	SELECT 
-- 		MIN(CASE WHEN pct >= 0.25 THEN value_sales END) AS q1,
--         MIN(CASE WHEN pct >= 0.75 THEN value_sales END) AS q3
-- 	FROM RankedSales
-- ),
-- Boundaries AS (
-- 	SELECT 
-- 		q1,
--         q3, 
--         (q3 - q1) AS iqr,
--         q1 - 1.5 * (q3 - q1) AS lower_bound,
--         q3 + 1.5 * (q3 - q1) AS upper_bound
-- 	FROM Quartiles
-- )
-- DELETE 
-- 	o
-- FROM oil_sales o
-- CROSS JOIN Boundaries b
-- WHERE o.value_sales < lower_bound 
--  	OR o.value_sales > upper_bound;

SELECT DISTINCT city
FROM oil_sales;

SELECT DISTINCT store_name
FROM oil_sales;

SELECT DISTINCT manufacturer
FROM oil_sales;

SELECT DISTINCT brand
FROM oil_sales;

SELECT DISTINCT class
FROM oil_sales;

SELECT DISTINCT size
FROM oil_sales
ORDER BY CAST(REPLACE(size, 'L', '') AS FLOAT);

SELECT DISTINCT year
FROM oil_sales
ORDER BY year;

SELECT month
FROM oil_sales
WHERE month < 1 
	OR month > 12;

WITH RankedAveragePrice AS (
	SELECT
		average_price,
        PERCENT_RANK() OVER(ORDER BY average_price) AS pct
	FROM oil_sales
),
Quartiles AS (
	SELECT 
		MIN(CASE WHEN pct >= 0.25 THEN average_price END) AS q1,
        MIN(CASE WHEN pct >= 0.75 THEN average_price END) AS q3
	FROM RankedAveragePrice
),
Boundaries AS (
	SELECT 
		q1,
        q3, 
        (q3 - q1) AS iqr,
        q1 - 1.5 * (q3 - q1) AS lower_bound,
        q3 + 1.5 * (q3 - q1) AS upper_bound
	FROM Quartiles
)
SELECT 
	o.*,
    b.lower_bound,
    b.upper_bound,
    CASE
		WHEN o.average_price < b.lower_bound THEN 'Low outlier'
        WHEN o.average_price > b.upper_bound THEN 'High outlier'
        ELSE 'Normal'	
    END AS outlier_status
FROM oil_sales o
CROSS JOIN Boundaries b
WHERE o.average_price < lower_bound 
 	OR o.average_price > upper_bound;