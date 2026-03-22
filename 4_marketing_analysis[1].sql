-- ============================================================
-- BLINKIT BUSINESS INTELLIGENCE ANALYSIS
-- Part 4: Marketing & Campaign Analysis
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
