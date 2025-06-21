-- Monthly sales trends
SELECT 
    YEAR(o.orderDate) as year,
    MONTH(o.orderDate) as month,
    MONTHNAME(o.orderDate) as month_name,
    COUNT(DISTINCT o.orderNumber) as total_orders,
    COUNT(od.orderLineNumber) as total_items_sold,
    ROUND(SUM(od.quantityOrdered * od.priceEach), 2) as total_revenue,
    ROUND(SUM(od.quantityOrdered * od.priceEach) / COUNT(DISTINCT o.orderNumber), 2) AS avg_order_value
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY YEAR(o.orderDate), MONTH(o.orderDate), MONTHNAME(o.orderDate)
ORDER BY year, month;

-- Seasonal sales patterns
SELECT 
    CASE 
        WHEN MONTH(orderDate) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(orderDate) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(orderDate) IN (6, 7, 8) THEN 'Summer'
        WHEN MONTH(orderDate) IN (9, 10, 11) THEN 'Fall'
    END as season,
    COUNT(DISTINCT o.orderNumber) as total_orders,
    ROUND(SUM(od.quantityOrdered * od.priceEach), 2) as total_revenue,
    ROUND(AVG(od.quantityOrdered * od.priceEach), 2) as avg_order_value,
    SUM(od.quantityOrdered) as total_units_sold
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY season
ORDER BY total_revenue DESC;

-- Sales by country/region
SELECT 
    c.country,
    COUNT(DISTINCT c.customerNumber) as total_customers,
    COUNT(DISTINCT o.orderNumber) as total_orders,
    SUM(od.quantityOrdered) as total_items_sold,
    ROUND(SUM(od.quantityOrdered * od.priceEach), 2) as total_revenue,
    ROUND(AVG(od.quantityOrdered * od.priceEach), 2) as avg_order_value,
    ROUND(SUM(od.quantityOrdered * od.priceEach) / COUNT(DISTINCT c.customerNumber), 2) as revenue_per_customer
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY c.country
ORDER BY total_revenue DESC;