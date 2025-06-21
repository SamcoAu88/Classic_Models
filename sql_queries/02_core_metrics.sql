-- Executive dashboard metrics
SELECT 
    'Total Revenue' as metric,
    CONCAT('$', FORMAT(SUM(od.quantityOrdered * od.priceEach), 2)) as value
FROM orderdetails od
UNION ALL
SELECT 
    'Total Orders',
    FORMAT(COUNT(DISTINCT orderNumber), 0)
FROM orders
UNION ALL
SELECT 
    'Active Customers',
    FORMAT(COUNT(DISTINCT customerNumber), 0)
FROM customers
UNION ALL
SELECT 
    'Average Order Value',
    CONCAT('$', FORMAT(AVG(order_total), 2))
FROM (
    SELECT SUM(quantityOrdered * priceEach) as order_total
    FROM orderdetails
    GROUP BY orderNumber
) as order_totals
UNION ALL
SELECT 
    'Products in Catalog',
    FORMAT(COUNT(*), 0)
FROM products;

-- On-time shipping performance
SELECT 
    SUM(CASE WHEN o.shippedDate <= o.requiredDate THEN 1 ELSE 0 END) / COUNT(*) * 100 AS percentage_on_time
FROM orders o;