SELECT
    stockcode_norm,
    COUNT(*) AS freq,
    SUM(quantity * price) AS revenue
FROM fact_event_line_clean
GROUP BY stockcode_norm
ORDER BY revenue DESC; -- view Day 81, section 1 for logs

SELECT DISTINCT stockcode, description, SUM(quantity * price)
FROM archive
WHERE stockcode ~ '^[A-Za-z]+[0-9]*$'
GROUP BY stockcode, description
ORDER BY stockcode; -- 70 rows

SELECT DISTINCT stockcode, description
FROM archive
WHERE stockcode ~ '^[A-Za-z]*$'; -- 24 rows

SELECT DISTINCT stockcode, description, SUM(quantity * price)
FROM archive
WHERE stockcode !~ '^[0-9]+[A-Za-z]*$'
	AND stockcode !~ '^[A-Za-z]*$'
GROUP BY stockcode, description
ORDER BY stockcode; -- 69 rows, 

/* 
40 rows of DCGS(4 digit number) - merchandise, null, ebay
17 rows of gift_0001_(2 digit number) - gift shop  voucher
SP1002 = Kid's chalkboard/easel, [null]
TEST001, TEST002 - test product
47503J  = floral garden tools (trailing space)
ADJUST, ADJUST2 = Adjustment
AMAZONFEE = Amazon Fee
B = Adjust bad debt
C2 = CARRIAGE, [null]
C3 = [null]
CRUK = CRUK Commission
D = Discount
DCGSBOY, DSGSGIRL = party bag, [null]
DOT = DOTCOM POSTAGE, [null]
GIFT = [null]
m, M = Manual 
PADS = Pads for cushions
POST = Postage, [null]
S = Samples
*/

CREATE OR REPLACE VIEW dim_product_ranked AS 
SELECT
	UPPER(TRIM(stockcode)) AS stockcode_norm,
	description,
	COUNT(*),
	ROW_NUMBER() OVER (
		PARTITION BY UPPER(TRIM(stockcode))
		ORDER BY COUNT(*) DESC
	) AS rn
FROM archive
WHERE stockcode IS NOT NULL
GROUP BY UPPER(TRIM(stockcode)), description; -- first layer: normalizing stockcode structure

CREATE OR REPLACE VIEW dim_product AS
SELECT
	stockcode_norm,
	description AS rep_description,
	CASE
		WHEN stockcode_norm ~ '^[0-9]+[A-Za-z]*$' THEN 'merchandise'
		WHEN stockcode_norm ~ '^[A-Za-z]+$' THEN 'operational'
		ELSE 'other'
	END AS structural_category
FROM dim_product_ranked
WHERE rn = 1; -- second layer, stockcode classification

SELECT stockcode_norm, COUNT(*)
FROM dim_product
GROUP BY stockcode_norm
HAVING COUNT(*) > 1; -- SANITY CHECK: 0 returns √ 

SELECT
    structural_category,
    SUM(quantity * price) AS revenue
FROM fact_event_line_clean f
LEFT JOIN dim_product d
ON UPPER(TRIM(f.stockcode)) = d.stockcode_norm
GROUP BY structural_category;
/*
SANITY CHECK: clean_revenue = 18854981.848 
merchandise = 18925714.33
operational = -51629.883
others = -19102.599
total = 18854981.848 √ 
*/


SELECT UPPER(TRIM(stockcode)), description, SUM(quantity * price)
FROM fact_event_line_clean
WHERE UPPER(TRIM(stockcode)) !~ '^[0-9]+[A-Za-z]*$'
	AND UPPER(TRIM(stockcode)) !~ '^[A-Za-z]+$'
GROUP BY stockcode, description; -- 68 rows "other" strutural_category

SELECT SUM(quantity * price)
FROM fact_event_line_clean
WHERE UPPER(TRIM(stockcode)) !~ '^[0-9]+[A-Za-z]*$'
	AND UPPER(TRIM(stockcode)) !~ '^[A-Za-z]+$'; -- returns -19086.469 sum

SELECT UPPER(TRIM(stockcode)), SUM(quantity * price) AS rev
FROM fact_event_line_clean
WHERE UPPER(TRIM(stockcode)) !~ '^[0-9]+[A-Za-z]*$'
GROUP BY UPPER(TRIM(stockcode))
ORDER BY rev; -- Weight of Operational Codes

SELECT SUM(quantity * price)
FROM fact_event_line_clean
WHERE UPPER(TRIM(stockcode)) !~ '^[0-9]+[A-Za-z]*$'; -- SUM of Operational Codes


SELECT
    UPPER(TRIM(stockcode)) AS stockcode_norm,
    SUM(quantity * price) AS revenue
FROM fact_event_line_clean
GROUP BY UPPER(TRIM(stockcode))
ORDER BY ABS(SUM(quantity * price)) DESC
LIMIT 30; -- refers to top 30 high-impact stockcodes

SELECT COUNT(*)
FROM dim_product
WHERE stockcode_norm ~ '^[0-9]+[A-Z]*$'; -- 5070 rows of unique merchandise stockcode

CREATE OR REPLACE VIEW dim_product AS -- redefined
SELECT
    stockcode_norm,
    description AS rep_description,

    -- structural (keep it simple)
    CASE
        WHEN stockcode_norm ~ '^[0-9]+[A-Z]*$' THEN 'merchandise'
        WHEN stockcode_norm ~ '^[A-Z]+$' THEN 'operational'
        ELSE 'other'
    END AS structural_category,

    -- economic (accounting logic)
    CASE
        WHEN stockcode_norm IN ('AMAZONFEE') THEN 'platform_fee'
        WHEN stockcode_norm IN ('BANK CHARGES') THEN 'bank_fee'
        WHEN stockcode_norm IN ('B') THEN 'bad_debt'
        WHEN stockcode_norm IN ('M','ADJUST','ADJUST2') THEN 'manual_adjustment'
        WHEN stockcode_norm IN ('D') THEN 'discount'
        WHEN stockcode_norm IN ('POST','C2', 'DOT') THEN 'shipping_income'
        WHEN stockcode_norm LIKE 'GIFT%' THEN 'gift_voucher'
        WHEN stockcode_norm LIKE 'TEST%' THEN 'internal_test'
        WHEN stockcode_norm ~ '^[0-9]+[A-Z]*$' THEN 'core_merchandise'
        ELSE 'other'
    END AS economic_category

FROM dim_product_ranked
WHERE rn = 1;

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