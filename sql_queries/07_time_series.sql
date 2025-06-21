-- Time series data for forecasting
SELECT 
    DATE_FORMAT(o.orderDate, '%Y-%m') as month,
    COUNT(DISTINCT o.orderNumber) as orders,
    SUM(od.quantityOrdered) as units_sold,
    ROUND(SUM(od.quantityOrdered * od.priceEach), 2) as revenue,
    COUNT(DISTINCT o.customerNumber) as active_customers,
    ROUND(AVG(od.quantityOrdered * od.priceEach), 2) as avg_order_value,
    LAG(ROUND(SUM(od.quantityOrdered * od.priceEach), 2)) OVER (ORDER BY DATE_FORMAT(o.orderDate, '%Y-%m')) as prev_month_revenue,
    ROUND(
        (SUM(od.quantityOrdered * od.priceEach) - 
         LAG(SUM(od.quantityOrdered * od.priceEach)) OVER (ORDER BY DATE_FORMAT(o.orderDate, '%Y-%m'))) /
        LAG(SUM(od.quantityOrdered * od.priceEach)) OVER (ORDER BY DATE_FORMAT(o.orderDate, '%Y-%m')) * 100, 2
    ) as revenue_growth_rate
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY DATE_FORMAT(o.orderDate, '%Y-%m')
ORDER BY month;