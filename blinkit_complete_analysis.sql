-- ============================================================
-- BLINKIT BUSINESS INTELLIGENCE ANALYSIS
-- Complete SQL Analysis - All 7 Parts
-- Dataset: 25K Customers | 50K Orders
-- Author: [Your Name]
-- ============================================================


-- ============================================================
-- PART 1: CUSTOMER ANALYSIS
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


-- ============================================================
-- PART 2: SALES & REVENUE ANALYSIS
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


-- ============================================================
-- PART 3: DELIVERY PERFORMANCE ANALYSIS
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
    SUM(CASE WHEN actual_time <= promised_time THEN 1 ELSE 0 END) AS on_time_count,
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


-- ============================================================
-- PART 4: MARKETING & CAMPAIGN ANALYSIS
-- ============================================================

-- 4.1 Overall Campaign Performance
SELECT 
    campaign_name,
    channel,
    impressions,
    clicks,
    conversions,
    spend,
    revenue_generated,
    roas,
    ROUND(clicks * 100.0 / NULLIF(impressions, 0), 2) AS ctr_pct,
    ROUND(conversions * 100.0 / NULLIF(clicks, 0), 2) AS conversion_rate_pct
FROM marketing
ORDER BY revenue_generated DESC;

-- 4.2 Best Performing Marketing Channels
SELECT 
    channel,
    COUNT(*) AS total_campaigns,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(conversions) AS total_conversions,
    ROUND(SUM(spend), 2) AS total_spend,
    ROUND(SUM(revenue_generated), 2) AS total_revenue,
    ROUND(AVG(roas), 2) AS avg_roas
FROM marketing
GROUP BY channel
ORDER BY avg_roas DESC;

-- 4.3 Campaign with Highest ROAS
SELECT 
    campaign_name,
    channel,
    spend,
    revenue_generated,
    roas
FROM marketing
ORDER BY roas DESC
LIMIT 10;

-- 4.4 Target Audience Analysis
SELECT 
    target_audience,
    COUNT(*) AS total_campaigns,
    ROUND(SUM(revenue_generated), 2) AS total_revenue,
    ROUND(AVG(roas), 2) AS avg_roas,
    SUM(conversions) AS total_conversions
FROM marketing
GROUP BY target_audience
ORDER BY total_revenue DESC;

-- 4.5 Monthly Marketing Spend vs Revenue
SELECT 
    DATE_FORMAT(date, '%Y-%m') AS month,
    ROUND(SUM(spend), 2) AS total_spend,
    ROUND(SUM(revenue_generated), 2) AS total_revenue,
    ROUND(SUM(revenue_generated) / NULLIF(SUM(spend), 0), 2) AS overall_roas
FROM marketing
GROUP BY month
ORDER BY month;

-- 4.6 Campaign Conversion Funnel
SELECT 
    campaign_name,
    impressions,
    clicks,
    conversions,
    ROUND(clicks * 100.0 / NULLIF(impressions, 0), 2) AS impression_to_click_pct,
    ROUND(conversions * 100.0 / NULLIF(clicks, 0), 2) AS click_to_conversion_pct
FROM marketing
ORDER BY conversions DESC
LIMIT 10;

-- 4.7 Marketing Campaign Impact on Orders
SELECT 
    m.campaign_name,
    m.channel,
    COUNT(DISTINCT o.order_id) AS orders_generated,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue_from_orders
FROM marketing m
JOIN orders o ON m.campaign_id = o.campaign_id
JOIN order_item oi ON o.order_id = oi.order_id
GROUP BY m.campaign_id, m.campaign_name, m.channel
ORDER BY revenue_from_orders DESC;


-- ============================================================
-- PART 5: INVENTORY ANALYSIS
-- ============================================================

-- 5.1 Current Stock Status
SELECT 
    p.product_name,
    p.brand,
    cat.category,
    i.stock_received,
    i.damaged_stock,
    (i.stock_received - i.damaged_stock) AS available_stock,
    p.min_stock_level,
    p.max_stock_level,
    CASE 
        WHEN (i.stock_received - i.damaged_stock) < p.min_stock_level THEN 'LOW STOCK'
        WHEN (i.stock_received - i.damaged_stock) > p.max_stock_level THEN 'OVERSTOCK'
        ELSE 'NORMAL'
    END AS stock_status
FROM inventory i
JOIN products p ON i.product_id = p.product_id
JOIN category cat ON p.category_id = cat.id
ORDER BY stock_status DESC;

-- 5.2 Products with Low Stock (Critical)
SELECT 
    p.product_name,
    p.brand,
    (i.stock_received - i.damaged_stock) AS available_stock,
    p.min_stock_level,
    (p.min_stock_level - (i.stock_received - i.damaged_stock)) AS stock_deficit
FROM inventory i
JOIN products p ON i.product_id = p.product_id
WHERE (i.stock_received - i.damaged_stock) < p.min_stock_level
ORDER BY stock_deficit DESC;

-- 5.3 Damaged Stock Analysis by Category
SELECT 
    cat.category,
    SUM(i.stock_received) AS total_stock_received,
    SUM(i.damaged_stock) AS total_damaged,
    ROUND(SUM(i.damaged_stock) * 100.0 / NULLIF(SUM(i.stock_received), 0), 2) AS damage_pct
FROM inventory i
JOIN products p ON i.product_id = p.product_id
JOIN category cat ON p.category_id = cat.id
GROUP BY cat.category
ORDER BY damage_pct DESC;

-- 5.4 Fast Moving Products (High Sales Velocity)
SELECT 
    p.product_name,
    p.brand,
    SUM(oi.quantity) AS total_sold,
    AVG(i.stock_received) AS avg_stock_received,
    ROUND(SUM(oi.quantity) / NULLIF(AVG(i.stock_received), 0), 2) AS sell_through_rate
FROM order_item oi
JOIN products p ON oi.product_id = p.product_id
JOIN inventory i ON p.product_id = i.product_id
GROUP BY p.product_id, p.product_name, p.brand
ORDER BY sell_through_rate DESC
LIMIT 10;

-- 5.5 Slow Moving Products (Low Sales)
SELECT 
    p.product_name,
    p.brand,
    SUM(oi.quantity) AS total_sold,
    p.shelf_life_days,
    AVG(i.stock_received) AS avg_stock
FROM order_item oi
JOIN products p ON oi.product_id = p.product_id
JOIN inventory i ON p.product_id = i.product_id
GROUP BY p.product_id, p.product_name, p.brand, p.shelf_life_days
ORDER BY total_sold ASC
LIMIT 10;

-- 5.6 Monthly Stock Received Trend
SELECT 
    DATE_FORMAT(i.date, '%Y-%m') AS month,
    SUM(i.stock_received) AS total_stock_received,
    SUM(i.damaged_stock) AS total_damaged
FROM inventory i
GROUP BY month
ORDER BY month;

-- 5.7 Products Near Shelf Life Expiry Risk
SELECT 
    p.product_name,
    p.shelf_life_days,
    p.min_stock_level,
    (i.stock_received - i.damaged_stock) AS available_stock
FROM products p
JOIN inventory i ON p.product_id = i.product_id
WHERE p.shelf_life_days < 30
ORDER BY p.shelf_life_days ASC;


-- ============================================================
-- PART 6: CUSTOMER FEEDBACK & SENTIMENT ANALYSIS
-- ============================================================

-- 6.1 Overall Average Rating
SELECT 
    ROUND(AVG(rating), 2) AS avg_rating,
    COUNT(*) AS total_feedbacks
FROM customer_feedbacks;

-- 6.2 Sentiment Distribution
SELECT 
    sentiment,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customer_feedbacks), 2) AS percentage
FROM customer_feedbacks
GROUP BY sentiment
ORDER BY total DESC;

-- 6.3 Rating Distribution (1 to 5 Stars)
SELECT 
    rating,
    COUNT(*) AS total_reviews,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customer_feedbacks), 2) AS percentage
FROM customer_feedbacks
GROUP BY rating
ORDER BY rating DESC;

-- 6.4 Average Rating by Category
SELECT 
    cat.category,
    ROUND(AVG(cf.rating), 2) AS avg_rating,
    COUNT(*) AS total_reviews
FROM customer_feedbacks cf
JOIN orders o ON cf.order_id = o.order_id
JOIN order_item oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN category cat ON p.category_id = cat.id
GROUP BY cat.category
ORDER BY avg_rating DESC;

-- 6.5 Worst Rated Products
SELECT 
    p.product_name,
    p.brand,
    ROUND(AVG(cf.rating), 2) AS avg_rating,
    COUNT(*) AS total_reviews
FROM customer_feedbacks cf
JOIN orders o ON cf.order_id = o.order_id
JOIN order_item oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.brand
HAVING COUNT(*) > 5
ORDER BY avg_rating ASC
LIMIT 10;

-- 6.6 Feedback Category Analysis
SELECT 
    feedback_category,
    COUNT(*) AS total,
    ROUND(AVG(rating), 2) AS avg_rating
FROM customer_feedbacks
GROUP BY feedback_category
ORDER BY total DESC;

-- 6.7 Monthly Sentiment Trend
SELECT 
    DATE_FORMAT(feedback_date, '%Y-%m') AS month,
    SUM(CASE WHEN sentiment = 'Positive' THEN 1 ELSE 0 END) AS positive,
    SUM(CASE WHEN sentiment = 'Neutral' THEN 1 ELSE 0 END) AS neutral,
    SUM(CASE WHEN sentiment = 'Negative' THEN 1 ELSE 0 END) AS negative,
    ROUND(AVG(rating), 2) AS avg_rating
FROM customer_feedbacks
GROUP BY month
ORDER BY month;

-- 6.8 Customers Who Always Give Low Ratings
SELECT 
    c.customer_id,
    c.customer_name,
    c.customer_segment,
    ROUND(AVG(cf.rating), 2) AS avg_rating,
    COUNT(*) AS total_feedbacks
FROM customer_feedbacks cf
JOIN customers c ON cf.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_segment
HAVING AVG(cf.rating) < 2.5 AND COUNT(*) > 3
ORDER BY avg_rating ASC;

-- 6.9 Delayed Delivery Impact on Ratings
SELECT 
    CASE 
        WHEN d.actual_time <= d.promised_time THEN 'On Time'
        ELSE 'Delayed'
    END AS delivery_status,
    ROUND(AVG(cf.rating), 2) AS avg_rating,
    COUNT(*) AS total_orders
FROM delivery d
JOIN customer_feedbacks cf ON d.order_id = cf.order_id
GROUP BY delivery_status;


-- ============================================================
-- PART 7: COMBINED MEGA INSIGHTS
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
    ROUND((SELECT SUM(spend) FROM marketing WHERE DATE_FORMAT(date, '%Y-%m') = DATE_FORMAT(o.order_date, '%Y-%m')), 2) AS marketing_spend,
    ROUND(SUM(oi.quantity * oi.unit_price) / NULLIF((SELECT SUM(spend) FROM marketing WHERE DATE_FORMAT(date, '%Y-%m') = DATE_FORMAT(o.order_date, '%Y-%m')), 0), 2) AS revenue_to_spend_ratio
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

-- ============================================================
-- END OF BLINKIT BUSINESS INTELLIGENCE ANALYSIS
-- ============================================================
