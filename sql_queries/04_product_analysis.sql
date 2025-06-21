-- Top 10 products by revenue
SELECT 
    p.productCode,
    p.productName,
    p.productLine,
    SUM(od.quantityOrdered) as total_quantity_sold,
    ROUND(SUM(od.quantityOrdered * od.priceEach), 2) as total_revenue,
    ROUND(AVG(od.priceEach), 2) as avg_selling_price,
    ROUND(AVG(p.buyPrice), 2) as avg_cost_price,
    ROUND(AVG(od.priceEach - p.buyPrice), 2) as avg_profit_per_unit
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName, p.productLine
ORDER BY total_revenue DESC
LIMIT 10;

-- Product line performance
SELECT 
    pl.productLine,
    pl.textDescription,
    COUNT(DISTINCT p.productCode) as number_of_products,
    SUM(od.quantityOrdered) as total_units_sold,
    ROUND(SUM(od.quantityOrdered * od.priceEach), 2) as total_revenue,
    ROUND(AVG(od.priceEach), 2) as avg_price_per_unit,
    ROUND(SUM(od.quantityOrdered * od.priceEach) / COUNT(DISTINCT p.productCode), 2) as revenue_per_product
FROM productlines pl
JOIN products p ON pl.productLine = p.productLine
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY pl.productLine, pl.textDescription
ORDER BY total_revenue DESC;

-- Product profitability
SELECT 
    p.productCode,
    p.productName,
    (SUM(od.quantityOrdered * od.priceEach) - SUM(od.quantityOrdered * p.buyPrice)) AS profit_margin
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName;

-- Frequently co-purchased products
SELECT 
    od1.productCode AS product1,
    p1.productName AS productName1, 
    od2.productCode AS product2,
    p2.productName AS productName2,
    COUNT(*) AS co_purchase_count
FROM orderdetails od1
JOIN orderdetails od2 ON od1.orderNumber = od2.orderNumber AND od1.productCode <> od2.productCode
JOIN products p1 ON od1.productCode = p1.productCode
JOIN products p2 ON od2.productCode = p2.productCode
GROUP BY product1, productName1, product2, productName2
ORDER BY co_purchase_count DESC;