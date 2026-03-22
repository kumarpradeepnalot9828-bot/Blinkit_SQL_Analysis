-- ============================================================
-- BLINKIT BUSINESS INTELLIGENCE ANALYSIS
-- Part 3: Delivery Performance Analysis
-- ============================================================

-- 3.1 Overall Delivery Status Distribution
SELECT 
    delivery_status,
    COUNT(*) AS total_deliveries,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM delivery), 2) AS percentage
FROM delivery
GROUP BY delivery_status
ORDER BY total_deliveries DESC;

-- 3.2 On-Time vs Delayed Deliveries
SELECT 
    CASE 
        WHEN actual_time <= promised_time THEN 'On Time'
        ELSE 'Delayed'
    END AS delivery_type,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM delivery), 2) AS percentage
FROM delivery
GROUP BY delivery_type;

-- 3.3 Average Delivery Time (Minutes)
SELECT 
    ROUND(AVG(delivery_time_minutes), 2) AS avg_delivery_time_minutes
FROM delivery;

-- 3.4 Average Delivery Time by Area
SELECT 
    c.area,
    ROUND(AVG(d.delivery_time_minutes), 2) AS avg_delivery_time,
    COUNT(*) AS total_deliveries
FROM delivery d
JOIN orders o ON d.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.area
ORDER BY avg_delivery_time DESC
LIMIT 10;

-- 3.5 Top Reasons for Delayed Deliveries
SELECT 
    reasons_if_delayed,
    COUNT(*) AS total_delays
FROM delivery
WHERE reasons_if_delayed IS NOT NULL 
  AND reasons_if_delayed != ''
  AND actual_time > promised_time
GROUP BY reasons_if_delayed
ORDER BY total_delays DESC;

-- 3.6 Distance vs Delivery Time Correlation
SELECT 
    CASE 
        WHEN distance_km < 2 THEN 'Under 2 km'
        WHEN distance_km BETWEEN 2 AND 5 THEN '2-5 km'
        WHEN distance_km BETWEEN 5 AND 10 THEN '5-10 km'
        ELSE 'Above 10 km'
    END AS distance_range,
    COUNT(*) AS total_deliveries,
    ROUND(AVG(delivery_time_minutes), 2) AS avg_delivery_time
FROM delivery
GROUP BY distance_range
ORDER BY avg_delivery_time;

-- 3.7 Best Performing Delivery Partners
SELECT 
    delivery_partner_id,
    COUNT(*) AS total_deliveries,
    ROUND(AVG(delivery_time_minutes), 2) AS avg_delivery_time,
    ROUND(SUM(CASE WHEN actual_time <= promised_time THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS on_time_pct
FROM delivery
GROUP BY delivery_partner_id
ORDER BY on_time_pct DESC
LIMIT 10;

-- 3.8 Worst Performing Delivery Partners
SELECT 
    delivery_partner_id,
    COUNT(*) AS total_deliveries,
    ROUND(AVG(delivery_time_minutes), 2) AS avg_delivery_time,
    ROUND(SUM(CASE WHEN actual_time > promised_time THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS delay_pct
FROM delivery
GROUP BY delivery_partner_id
ORDER BY delay_pct DESC
LIMIT 10;

-- 3.9 Monthly Delivery Performance Trend
SELECT 
    DATE_FORMAT(promised_time, '%Y-%m') AS month,
    COUNT(*) AS total_deliveries,
    ROUND(AVG(delivery_time_minutes), 2) AS avg_delivery_time,
    ROUND(SUM(CASE WHEN actual_time <= promised_time THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS on_time_pct
FROM delivery
GROUP BY month
ORDER BY month;

-- 3.10 Delay Impact on Customer Ratings
SELECT 
    CASE 
        WHEN d.actual_time <= d.promised_time THEN 'On Time'
        ELSE 'Delayed'
    END AS delivery_type,
    ROUND(AVG(cf.rating), 2) AS avg_customer_rating,
    COUNT(*) AS total_orders
FROM delivery d
JOIN customer_feedbacks cf ON d.order_id = cf.order_id
GROUP BY delivery_type;
