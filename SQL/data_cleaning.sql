CREATE OR REPLACE VIEW fact_event_line AS
SELECT
	invoiceid,
	invoicedate,
	stockcode,
	customerid,
	quantity,
	price,
	country
FROM archive
WHERE stockcode IS NOT NULL
	AND invoiceid IS NOT NULL;

----Sanity Check: Identifying Duplicates:
SELECT COUNT(*) FROM fact_event_line; -- 1067371 rows
SELECT COUNT(DISTINCT (
    invoiceid,
    invoicedate,
    stockcode,
    customerid,
    quantity,
    price,
    country
)) FROM fact_event_line; -- 1033034

-- This shows a difference of 34,337 rows of exact duplicates across the columns.

SELECT *
FROM archive a
WHERE EXISTS (
    SELECT 1
    FROM archive a2
    WHERE a.invoiceid = a2.invoiceid
      AND a.invoicedate = a2.invoicedate
      AND a.stockcode = a2.stockcode
      AND a.customerid IS NOT DISTINCT FROM a2.customerid
      AND a.quantity = a2.quantity
      AND a.price = a2.price
      AND a.country = a2.country
      AND a.ctid <> a2.ctid
); -- 67426 rows
/*
EXISTS, ctid Clause only showed the actual, physical rows that are duplicated, and by
does not offer any meaningful insights to make sense of the anomaly
*/

-- Clean fact
CREATE VIEW fact_event_line_clean AS
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY invoiceid,
                            invoicedate,
                            stockcode,
                            customerid,
                            quantity,
                            price,
                            country
               ORDER BY invoiceid
           ) AS rn
    FROM archive
) t
WHERE rn = 1; -- 1033034

-- Duplicate audit
CREATE VIEW fact_event_line_duplicates AS
SELECT *
FROM (
	SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY 
				invoiceid,
				invoicedate,
				stockcode,
				customerid,
				quantity,
				price,
				country
			ORDER BY invoiceid
		) AS rn
    FROM archive
) t
WHERE rn > 1; --34,337 dupes

SELECT SUM(quantity * price) AS revenue
FROM fact_event_line; -- Revenue = 19287250.568 √

SELECT SUM(quantity * price) AS dupe_revenue
FROM fact_event_line_duplicates; -- Revenue = 432268.72 √

SELECT SUM(quantity * price) AS clean_revenue
FROM fact_event_line_clean; -- Revenue = 18854981.848 √ 

/* 
fact_event_line_clean have 1033034 of deduplicated transactions which includes sales, returns,
and manual adjustments of financial statement, and product inventory.
This view includes: invoiceid, invoicedate, stockcode, customerid, quantity, price, and country
LOOK FOR DAY 79, section 8 LOGS for SEMANTIC CLARITY
*/

CREATE OR REPLACE VIEW fact_event_line_clean AS -- NORMALIZING stockcode
SELECT *
FROM (
    SELECT 
		invoiceid,
		invoicedate,
		UPPER(TRIM(stockcode)) AS stockcode_norm,
		customerid,
		quantity,
		price,
		country,
		ROW_NUMBER() OVER (
		PARTITION BY 
			invoiceid,
			invoicedate,
			UPPER(TRIM(stockcode)) AS stockcode_norm,
			customerid,
			quantity,
			price,
			country
		ORDER BY invoiceid
	) AS rn
    FROM archive
) t
WHERE rn = 1; -- 1033034
