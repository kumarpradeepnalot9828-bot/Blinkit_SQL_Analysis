-- ============================================================
-- BLINKIT BUSINESS INTELLIGENCE ANALYSIS
-- Part 2: Sales & Revenue Analysis
-- ============================================================

-- 2.1 Total Revenue
SELECT 
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM order_item oi;

-- 2.2 Monthly Revenue Trend
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS monthly_revenue
FROM orders o
JOIN order_item oi ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;

-- 2.3 Average Order Value (AOV)
SELECT 
    ROUND(AVG(order_total), 2) AS average_order_value
FROM (
    SELECT 
        o.order_id,
        SUM(oi.quantity * oi.unit_price) AS order_total
    FROM orders o
    JOIN order_item oi ON o.order_id = oi.order_id
    GROUP BY o.order_id
) AS order_totals;

-- 2.4 Revenue by Day of Week
SELECT 
    DAYNAME(o.order_date) AS day_of_week,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM orders o
JOIN order_item oi ON o.order_id = oi.order_id
GROUP BY day_of_week
ORDER BY DAYOFWEEK(o.order_date);

-- 2.5 Top 10 Best Selling Products
SELECT 
    p.product_name,
    p.brand,
    SUM(oi.quantity) AS total_quantity_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM order_item oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.brand
ORDER BY total_quantity_sold DESC
LIMIT 10;

-- 2.6 Revenue by Category
SELECT 
    cat.category AS category_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS total_items_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM order_item oi
JOIN products p ON oi.product_id = p.product_id
JOIN category cat ON p.category_id = cat.id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY cat.category
ORDER BY total_revenue DESC;

-- 2.7 Payment Method Distribution
SELECT 
    payment_method,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage
FROM orders
GROUP BY payment_method
ORDER BY total_orders DESC;

-- 2.8 Hourly Order Distribution (Peak Hours)
SELECT 
    HOUR(order_date) AS hour_of_day,
    COUNT(*) AS total_orders
FROM orders
GROUP BY hour_of_day
ORDER BY total_orders DESC;

-- 2.9 Top 10 Revenue Generating Products
SELECT 
    p.product_name,
    p.brand,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue,
    ROUND(AVG(p.margin_percentage), 2) AS avg_margin_pct
FROM order_item oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.brand
ORDER BY total_revenue DESC
LIMIT 10;

-- 2.10 MRP vs Selling Price Analysis (Discount Insight)
SELECT 
    p.product_name,
    ROUND(AVG(p.mrp), 2) AS avg_mrp,
    ROUND(AVG(oi.unit_price), 2) AS avg_selling_price,
    ROUND(AVG(p.mrp - oi.unit_price), 2) AS avg_discount,
    ROUND(AVG((p.mrp - oi.unit_price) / p.mrp * 100), 2) AS avg_discount_pct
FROM order_item oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY avg_discount_pct DESC
LIMIT 10;
