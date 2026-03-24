-- Repeat Purchase Segmentation
WITH customer_orders AS (
    SELECT
        customerid,
        COUNT(DISTINCT invoiceid) AS order_count
    FROM fact_event_line_clean
    WHERE customerid IS NOT NULL
    GROUP BY customerid
),
segmented AS (
    SELECT
        CASE
            WHEN order_count = 1 THEN '1 order'
            WHEN order_count BETWEEN 2 AND 3 THEN '2–3 orders'
            WHEN order_count BETWEEN 4 AND 6 THEN '4–6 orders'
            WHEN order_count BETWEEN 7 AND 10 THEN '7–10 orders'
            ELSE '10+ orders'
        END AS customer_segment,
        order_count
    FROM customer_orders
)
SELECT
customer_segment,
COUNT(*) AS customers,
SUM(order_count) AS total_orders,
SUM(order_count) * 1.0 / SUM(SUM(order_count)) OVER () AS pct_orders
FROM segmented
GROUP BY customer_segment
ORDER BY total_orders DESC; -- total orders = 44876

-- COUNT Sanity Check
SELECT COUNT(DISTINCT invoiceid)
FROM fact_event_line_clean
WHERE customerid IS NOT NULL; --44876 rows

-- Monthly Active Customers
SELECT
    DATE_TRUNC('month', invoicedate) AS month,
    COUNT(DISTINCT customerid) AS active_customers,
    COUNT(DISTINCT invoiceid) AS orders,
    SUM(quantity * price) AS revenue,
    COUNT(DISTINCT invoiceid)::numeric /
        COUNT(DISTINCT customerid) AS orders_per_customer,
    SUM(quantity * price) /
        COUNT(DISTINCT customerid) AS revenue_per_customer
FROM fact_event_line_clean
WHERE customerid IS NOT NULL
GROUP BY month
ORDER BY month; -- Total Revenue:  16,289,439.44 

-- Anonymous Total Revenue Sanity Check
SELECT SUM(price * quantity) AS total_revenue
FROM fact_event_line_clean_mat
WHERE customerid IS NULL; 
-- total_revenue (anonymous) = 2565542.41
-- 2565542.41 + 16,289,439.44 =  18,854,981.85 √
