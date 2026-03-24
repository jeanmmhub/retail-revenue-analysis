SELECT --customer revenue
    customerid,
    SUM(quantity * price) AS revenue
FROM fact_event_line_clean
GROUP BY customerid
ORDER BY revenue DESC;

SELECT --repeat customer
    customerid,
    COUNT(DISTINCT invoiceid) AS order_count
FROM fact_event_line_clean
GROUP BY customerid
ORDER BY order_count DESC;

SELECT --active monthly customers
    DATE_TRUNC('month', invoicedate) AS month,
    COUNT(DISTINCT customerid) AS active_customers
FROM fact_event_line_clean
GROUP BY month
ORDER BY month;


WITH merch AS ( --customer pareto
    SELECT
        customerid,
        SUM(quantity * price) AS revenue
    FROM fact_event_line_clean_mat
    GROUP BY customerid
),
ranked AS (
    SELECT
        customerid,
        revenue,
        SUM(revenue) OVER (ORDER BY revenue DESC) AS cumulative_revenue,
        SUM(revenue) OVER () AS total_revenue
    FROM merch
)
SELECT
    customerid,
    revenue,
    cumulative_revenue / total_revenue AS cumulative_pct
FROM ranked
ORDER BY revenue DESC;

WITH merch AS ( --customer pareto order count
    SELECT
        customerid,
        COUNT(DISTINCT(invoiceid)) AS orders
    FROM fact_event_line_clean_mat
    GROUP BY customerid
),
ranked AS (
    SELECT
        customerid,
        orders,
        SUM(orders) OVER (ORDER BY orders DESC) AS cumulative_orders,
        SUM(orders) OVER () AS total_orders
    FROM merch
)
SELECT
    customerid,
    orders,
    cumulative_orders / total_orders AS cumulative_pct
FROM ranked
ORDER BY orders DESC;