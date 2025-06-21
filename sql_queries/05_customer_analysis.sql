-- RFM Customer Segmentation
WITH customer_metrics AS (
    SELECT 
        c.customerNumber,
        c.customerName,
        c.country,
        c.city,
        COUNT(DISTINCT o.orderNumber) as order_frequency,
        SUM(od.quantityOrdered) as total_items_purchased,
        ROUND(SUM(od.quantityOrdered * od.priceEach), 2) as monetary_value,
        ROUND(AVG(od.quantityOrdered * od.priceEach), 2) as avg_order_value,
        MAX(o.orderDate) as last_order_date,
        DATEDIFF((SELECT MAX(orderDate) FROM orders), MAX(o.orderDate)) as recency_days
    FROM customers c
    JOIN orders o ON c.customerNumber = o.customerNumber
    JOIN orderdetails od ON o.orderNumber = od.orderNumber
    GROUP BY c.customerNumber, c.customerName, c.country, c.city
),
customer_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY monetary_value) as monetary_score,
        NTILE(5) OVER (ORDER BY order_frequency) as frequency_score,
        NTILE(5) OVER (ORDER BY recency_days DESC) as recency_score,
        (NTILE(5) OVER (ORDER BY monetary_value) + 
         NTILE(5) OVER (ORDER BY order_frequency) + 
         NTILE(5) OVER (ORDER BY recency_days DESC)) as rfm_score
    FROM customer_metrics
)
SELECT 
    customerNumber,
    customerName,
    country,
    city,
    order_frequency,
    total_items_purchased,
    monetary_value,
    avg_order_value,
    last_order_date,
    recency_days,
    monetary_score,
    frequency_score,
    recency_score,
    rfm_score,
    CASE 
        WHEN rfm_score >= 13 THEN 'VIP Customers'
        WHEN rfm_score >= 11 THEN 'Loyal Customers'
        WHEN monetary_score >= 4 AND frequency_score >= 4 THEN 'High Potential'
        WHEN recency_score <= 2 THEN 'At Risk'
        WHEN frequency_score >= 4 THEN 'Frequent Buyers'
        WHEN monetary_score >= 4 THEN 'Big Spenders'
        WHEN recency_score >= 4 AND frequency_score = 1 THEN 'New Customers'
        ELSE 'Regular Customers'
    END as customer_segment
FROM customer_scores
ORDER BY rfm_score DESC, monetary_value DESC;

-- Customer purchase behavior
SELECT 
    COUNT(o.orderNumber) / COUNT(DISTINCT c.customerNumber) AS avg_orders_per_customer
FROM customers c
LEFT JOIN orders o ON c.customerNumber = o.customerNumber;

-- Monthly cohort retention analysis
WITH customer_first_purchase AS (
    SELECT 
        customerNumber,
        DATE_FORMAT(MIN(orderDate), '%Y-%m') as first_purchase_month
    FROM orders
    GROUP BY customerNumber
),
monthly_activity AS (
    SELECT DISTINCT
        o.customerNumber,
        DATE_FORMAT(o.orderDate, '%Y-%m') as order_month
    FROM orders o
),
cohort_data AS (
    SELECT 
        cfp.first_purchase_month as cohort_month,
        ma.order_month,
        PERIOD_DIFF(
            CAST(REPLACE(ma.order_month, '-', '') AS UNSIGNED),
            CAST(REPLACE(cfp.first_purchase_month, '-', '') AS UNSIGNED)
        ) as period_number,
        COUNT(DISTINCT ma.customerNumber) as customers
    FROM customer_first_purchase cfp
    JOIN monthly_activity ma ON cfp.customerNumber = ma.customerNumber
    GROUP BY cfp.first_purchase_month, ma.order_month
)
SELECT 
    cohort_month,
    period_number,
    customers,
    FIRST_VALUE(customers) OVER (
        PARTITION BY cohort_month 
        ORDER BY period_number
    ) as cohort_size,
    ROUND(
        100.0 * customers / FIRST_VALUE(customers) OVER (
            PARTITION BY cohort_month 
            ORDER BY period_number
        ), 2
    ) as retention_rate
FROM cohort_data
ORDER BY cohort_month, period_number;