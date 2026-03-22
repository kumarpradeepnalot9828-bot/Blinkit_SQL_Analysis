-- ============================================================
-- BLINKIT BUSINESS INTELLIGENCE ANALYSIS
-- Part 5: Inventory Analysis
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
