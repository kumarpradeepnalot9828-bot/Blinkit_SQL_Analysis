-- ============================================================
-- BLINKIT BUSINESS INTELLIGENCE ANALYSIS
-- Part 1: Customer Analysis
-- ============================================================

-- 1.1 Total Customers Count
SELECT COUNT(*) AS total_customers 
FROM customers;

-- 1.2 Customer Segment Distribution
SELECT 
    customer_segment,
    COUNT(*) AS total_customers,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers), 2) AS percentage
FROM customers
GROUP BY customer_segment
ORDER BY total_customers DESC;

-- 1.3 Top 10 Areas with Most Customers
SELECT 
    area,
    COUNT(*) AS total_customers
FROM customers
GROUP BY area
ORDER BY total_customers DESC
LIMIT 10;

-- 1.4 Top 10 Pincodes with Most Customers
SELECT 
    pincode,
    COUNT(*) AS total_customers
FROM customers
GROUP BY pincode
ORDER BY total_customers DESC
LIMIT 10;

-- 1.5 Monthly New Customer Registration Trend
SELECT 
    DATE_FORMAT(registration_date, '%Y-%m') AS month,
    COUNT(*) AS new_customers
FROM customers
GROUP BY month
ORDER BY month;

-- 1.6 Returning vs New Customers
SELECT 
    CASE 
        WHEN order_count > 1 THEN 'Returning Customer'
        ELSE 'New Customer'
    END AS customer_type,
    COUNT(*) AS total
FROM (
    SELECT 
        c.customer_id,
        COUNT(o.order_id) AS order_count
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
) AS customer_orders
GROUP BY customer_type;

-- 1.7 Customer Lifetime Value (Top 20)
SELECT 
    c.customer_id,
    c.customer_name,
    c.customer_segment,
    c.area,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS lifetime_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_item oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name, c.customer_segment, c.area
ORDER BY lifetime_value DESC
LIMIT 20;

-- 1.8 Average Orders Per Customer
SELECT 
    ROUND(AVG(order_count), 2) AS avg_orders_per_customer
FROM (
    SELECT customer_id, COUNT(order_id) AS order_count
    FROM orders
    GROUP BY customer_id
) AS sub;

-- 1.9 Top 10 Most Loyal Customers
SELECT 
    c.customer_id,
    c.customer_name,
    c.area,
    c.customer_segment,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.area, c.customer_segment
ORDER BY total_orders DESC
LIMIT 10;

-- 1.10 Customer Segment vs Average Order Value
SELECT 
    c.customer_segment,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(oi.quantity * oi.unit_price), 2) AS avg_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_item oi ON o.order_id = oi.order_id
GROUP BY c.customer_segment
ORDER BY avg_order_value DESC;
