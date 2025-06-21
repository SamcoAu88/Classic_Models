-- Sales representative performance
SELECT 
    e.employeeNumber,
    CONCAT(e.firstName, ' ', e.lastName) as sales_rep_name,
    e.jobTitle,
    o.city as office_city,
    COUNT(DISTINCT c.customerNumber) as customers_managed,
    COUNT(DISTINCT ord.orderNumber) as total_orders,
    COUNT(DISTINCT CASE WHEN ord.status = 'Cancelled' THEN ord.orderNumber END) AS cancelled_orders,
    ROUND(SUM(od.quantityOrdered * od.priceEach), 2) as total_sales,
    ROUND(AVG(od.quantityOrdered * od.priceEach), 2) as avg_order_value,
    ROUND(SUM(od.quantityOrdered * od.priceEach) / COUNT(DISTINCT c.customerNumber), 2) as sales_per_customer
FROM employees e
JOIN offices o ON e.officeCode = o.officeCode
LEFT JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
LEFT JOIN orders ord ON c.customerNumber = ord.customerNumber
LEFT JOIN orderdetails od ON ord.orderNumber = od.orderNumber
WHERE e.jobTitle LIKE '%Sales%' OR e.jobTitle LIKE '%Rep%'
GROUP BY e.employeeNumber, sales_rep_name, e.jobTitle, o.city
HAVING total_sales IS NOT NULL
ORDER BY total_sales DESC;

-- Office performance metrics
SELECT 
    o.officeCode,
    o.city,
    o.country,
    COUNT(DISTINCT e.employeeNumber) as total_employees,
    COUNT(DISTINCT c.customerNumber) as customers_served,
    COUNT(DISTINCT ord.orderNumber) as total_orders,
    ROUND(SUM(od.quantityOrdered * od.priceEach), 2) as total_revenue,
    ROUND(SUM(od.quantityOrdered * od.priceEach) / COUNT(DISTINCT e.employeeNumber), 2) as revenue_per_employee,
    ROUND(AVG(od.quantityOrdered * od.priceEach), 2) as avg_order_value
FROM offices o
JOIN employees e ON o.officeCode = e.officeCode
LEFT JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
LEFT JOIN orders ord ON c.customerNumber = ord.customerNumber
LEFT JOIN orderdetails od ON ord.orderNumber = od.orderNumber
GROUP BY o.officeCode, o.city, o.country
ORDER BY total_revenue DESC;