-- ============================================================
-- BLINKIT BUSINESS INTELLIGENCE ANALYSIS
-- Part 7: Combined Mega Insights
-- ============================================================

-- 7.1 Full Business Summary Dashboard
SELECT 
    (SELECT COUNT(*) FROM customers) AS total_customers,
    (SELECT COUNT(*) FROM orders) AS total_orders,
    (SELECT ROUND(SUM(oi.quantity * oi.unit_price), 2) FROM order_item oi) AS total_revenue,
    (SELECT ROUND(AVG(rating), 2) FROM customer_feedbacks) AS avg_customer_rating,
    (SELECT ROUND(SUM(CASE WHEN actual_time <= promised_time THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) FROM delivery) AS on_time_delivery_pct,
    (SELECT ROUND(AVG(roas), 2) FROM marketing) AS avg_marketing_roas;

-- 7.2 High Value Customers with Delivery & Rating Analysis
SELECT 
    c.customer_id,
    c.customer_name,
    c.customer_segment,
    c.area,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS lifetime_value,
    ROUND(AVG(d.delivery_time_minutes), 2) AS avg_delivery_time,
    ROUND(AVG(cf.rating), 2) AS avg_rating
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_item oi ON o.order_id = oi.order_id
JOIN delivery d ON o.order_id = d.order_id
JOIN customer_feedbacks cf ON o.order_id = cf.order_id
GROUP BY c.customer_id, c.customer_name, c.customer_segment, c.area
ORDER BY lifetime_value DESC
LIMIT 20;

-- 7.3 Marketing → Order → Delivery → Feedback Full Funnel
SELECT 
    m.campaign_name,
    m.channel,
    COUNT(DISTINCT o.order_id) AS orders_placed,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue_generated,
    ROUND(AVG(d.delivery_time_minutes), 2) AS avg_delivery_time,
    ROUND(AVG(cf.rating), 2) AS avg_customer_rating
FROM marketing m
JOIN orders o ON m.campaign_id = o.campaign_id
JOIN order_item oi ON o.order_id = oi.order_id
JOIN delivery d ON o.order_id = d.order_id
JOIN customer_feedbacks cf ON o.order_id = cf.order_id
GROUP BY m.campaign_id, m.campaign_name, m.channel
ORDER BY revenue_generated DESC;

-- 7.4 Top Categories by Revenue, Rating and Delivery Performance
SELECT 
    cat.category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue,
    ROUND(AVG(d.delivery_time_minutes), 2) AS avg_delivery_time,
    ROUND(AVG(cf.rating), 2) AS avg_rating
FROM category cat
JOIN products p ON cat.id = p.category_id
JOIN order_item oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
JOIN delivery d ON o.order_id = d.order_id
JOIN customer_feedbacks cf ON o.order_id = cf.order_id
GROUP BY cat.category
ORDER BY total_revenue DESC;

-- 7.5 Customer Churn Risk (No orders in last 90 days)
SELECT 
    c.customer_id,
    c.customer_name,
    c.customer_segment,
    c.area,
    MAX(o.order_date) AS last_order_date,
    DATEDIFF(CURDATE(), MAX(o.order_date)) AS days_since_last_order
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_segment, c.area
HAVING days_since_last_order > 90
ORDER BY days_since_last_order DESC;

-- 7.6 Revenue vs Marketing Spend by Month
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_order_revenue,
    ROUND((SELECT SUM(spend) FROM marketing 
           WHERE DATE_FORMAT(date, '%Y-%m') = DATE_FORMAT(o.order_date, '%Y-%m')), 2) AS marketing_spend,
    ROUND(SUM(oi.quantity * oi.unit_price) / 
          NULLIF((SELECT SUM(spend) FROM marketing 
                  WHERE DATE_FORMAT(date, '%Y-%m') = DATE_FORMAT(o.order_date, '%Y-%m')), 0), 2) AS revenue_to_spend_ratio
FROM orders o
JOIN order_item oi ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;

-- 7.7 Best Area for Business Expansion
SELECT 
    c.area,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue,
    ROUND(AVG(d.delivery_time_minutes), 2) AS avg_delivery_time,
    ROUND(AVG(cf.rating), 2) AS avg_satisfaction
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_item oi ON o.order_id = oi.order_id
JOIN delivery d ON o.order_id = d.order_id
JOIN customer_feedbacks cf ON o.order_id = cf.order_id
GROUP BY c.area
ORDER BY total_revenue DESC
LIMIT 10;

-- 7.8 Low Stock + High Demand Products (Urgent Restock)
SELECT 
    p.product_name,
    p.brand,
    cat.category,
    (i.stock_received - i.damaged_stock) AS available_stock,
    p.min_stock_level,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(AVG(cf.rating), 2) AS avg_customer_rating
FROM products p
JOIN inventory i ON p.product_id = i.product_id
JOIN order_item oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
JOIN customer_feedbacks cf ON o.order_id = cf.order_id
JOIN category cat ON p.category_id = cat.id
WHERE (i.stock_received - i.damaged_stock) < p.min_stock_level
GROUP BY p.product_id, p.product_name, p.brand, cat.category, available_stock, p.min_stock_level
ORDER BY total_units_sold DESC;
