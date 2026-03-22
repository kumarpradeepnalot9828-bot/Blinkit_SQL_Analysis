-- ============================================================
-- BLINKIT BUSINESS INTELLIGENCE ANALYSIS
-- Part 6: Customer Feedback & Sentiment Analysis
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
