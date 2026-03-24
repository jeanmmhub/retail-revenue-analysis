SELECT
    economic_category,
    SUM(quantity * price) AS revenue
FROM fact_event_line_clean f
JOIN dim_product d
  ON UPPER(TRIM(f.stockcode)) = d.stockcode_norm
GROUP BY economic_category
ORDER BY revenue DESC;

/*
"core_merchandise"	18925714.33
"shipping_income"	433410.51
"gift_voucher"	1686.61
"internal_test"	203.5
"other"	-12791.653
"discount"	-12879.63
"bank_fee"	-35482.249
"manual_adjustment"	-75744.99
"bad_debt"	-147614.08
"platform_fee"	-221520.50
*/

SELECT
	DATE_TRUNC('month', invoicedate) AS month,
	SUM(quantity * price) AS revenue
FROM fact_event_line_clean
GROUP BY DATE_TRUNC('month', invoicedate)
ORDER BY month; -- high seasonal from Sept-Nov

SELECT
	DATE_TRUNC('month', invoicedate) AS month,
	d.economic_category,
	SUM(f.quantity * f.price) AS revenue
FROM fact_event_line_clean f
LEFT JOIN dim_product d
ON UPPER(TRIM(f.stockcode)) = d.stockcode_norm
GROUP BY DATE_TRUNC('month',invoicedate), d.economic_category
ORDER BY revenue; -- few anomalies, patterns, and verification found

SELECT -- anomaly picking
	price,
	quantity,
	d.rep_description,
	stockcode_norm,
	invoicedate,
	invoiceid
FROM fact_event_line_clean f
LEFT JOIN dim_product d
ON UPPER(TRIM(f.stockcode)) = d.stockcode_norm
WHERE invoicedate BETWEEN '2010-08-01' AND '2010-09-01'
	AND economic_category = 'bank_fee'
GROUP BY price, quantity, d.rep_description, stockcode_norm, invoicedate, invoiceid;

SELECT *
FROM fact_event_line_clean
WHERE invoiceid = 'C520667';

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


CREATE TABLE dim_product_mat AS
SELECT *
FROM dim_product;

CREATE INDEX idx_dim_product_mat_stockcode
ON dim_product_mat(stockcode_norm);

CREATE TABLE fact_event_line_clean_mat AS
SELECT * FROM fact_event_line_clean;

CREATE INDEX idx_fact_stockcode
ON fact_event_line_clean_mat(stockcode_norm);


WITH merch AS ( --product pareto principle check
    SELECT
        f.stockcode_norm,
        SUM(f.quantity * f.price) AS revenue
    FROM fact_event_line_clean f
    JOIN dim_product_mat d
      ON f.stockcode_norm = d.stockcode_norm
    WHERE d.economic_category = 'core_merchandise'
    GROUP BY f.stockcode_norm
),
ranked AS (
    SELECT
        stockcode_norm,
        revenue,
        SUM(revenue) OVER (ORDER BY revenue DESC) AS cumulative_revenue,
        SUM(revenue) OVER () AS total_revenue
    FROM merch
)
SELECT
    stockcode_norm,
    revenue,
    cumulative_revenue / total_revenue AS cumulative_pct
FROM ranked
ORDER BY revenue DESC;


WITH monthly AS (
    SELECT
        DATE_TRUNC('month', f.invoicedate) AS month,
        d.economic_category,
        SUM(f.quantity * f.price) AS revenue
    FROM fact_event_line_clean_mat f
    JOIN dim_product_mat d
      ON f.stockcode_norm = d.stockcode_norm
    GROUP BY 1,2
)
SELECT
    month,
    economic_category,
    revenue,
    revenue / SUM(revenue) OVER (PARTITION BY month) AS pct_share
FROM monthly
ORDER BY month, economic_category;

SELECT
	economic_category,
	SUM(price * quantity) AS revenue
FROM fact_event_line_clean_mat f
LEFT JOIN dim_product d
ON f.stockcode_norm = d.stockcode_norm
GROUP BY economic_category
ORDER BY revenue;