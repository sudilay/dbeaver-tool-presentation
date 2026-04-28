-- ============================================================
-- DBeaver Demo Queries
-- Use these in the SQL Editor to show off DBeaver's features
-- (Select a row and press Cmd+Enter to run)
-- ============================================================


-- ── SECTION 1: BASICS ──────────────────────────────────────

-- 1a. Simple select - Great for showing DBeaver's sorting and filtering in the grid UI
SELECT * FROM products ORDER BY price DESC;

-- 1b. Multi-table JOIN - Shows how clean DBeaver renders results from multiple tables
SELECT
    p.name        AS product,
    c.name        AS category,
    p.price,
    p.stock_quantity
FROM products p
JOIN categories c ON p.category_id = c.category_id
WHERE p.price > 50
ORDER BY p.price DESC;

-- 1c. Working with Views - Notice how DBeaver lists these separately in the Navigator on the left
SELECT * FROM v_order_summaries LIMIT 20;
SELECT * FROM v_monthly_revenue;


-- ── SECTION 2: ADVANCED ANALYTICAL QUERIES ─────────────────

-- 2a. Window Function: Ranking products by price within each category
--     (The RANK column looks very clear in DBeaver's data grid)
SELECT
    c.name          AS category,
    p.name          AS product,
    p.price,
    RANK() OVER (
        PARTITION BY c.name
        ORDER BY p.price DESC
    )               AS price_rank
FROM products p
JOIN categories c ON p.category_id = c.category_id;

-- 2b. Window Function: Running total of revenue
--     (We can turn this into a graph using DBeaver's "Charts" feature - right click > View as Chart)
SELECT
    order_date::DATE                              AS day,
    SUM(total_amount)                             AS daily_revenue,
    SUM(SUM(total_amount)) OVER (
        ORDER BY order_date::DATE
    )                                             AS running_total
FROM orders
WHERE status != 'Cancelled'
GROUP BY order_date::DATE
ORDER BY day;

-- 2c. Using CTEs: Finding our top 3 biggest spenders
WITH customer_spend AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        c.country,
        SUM(o.total_amount)                 AS total_spent,
        COUNT(o.order_id)                   AS order_count
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.status != 'Cancelled'
    GROUP BY c.customer_id, customer_name, c.country
),
ranked AS (
    SELECT *, RANK() OVER (ORDER BY total_spent DESC) AS spend_rank
    FROM customer_spend
)
SELECT * FROM ranked WHERE spend_rank <= 3;

-- 2d. LAG: Comparing current month revenue to the previous month
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(total_amount)               AS revenue
    FROM orders
    WHERE status != 'Cancelled'
    GROUP BY 1
)
SELECT
    TO_CHAR(month, 'YYYY-MM')             AS month,
    revenue,
    LAG(revenue) OVER (ORDER BY month)    AS prev_month_revenue,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
              / NULLIF(LAG(revenue) OVER (ORDER BY month), 0),
        2
    )                                     AS growth_pct
FROM monthly
ORDER BY month;


-- ── SECTION 3: WORKING WITH JSON DATA ─────────────────────

-- 3a. Browsing raw JSONB - DBeaver formats JSON in cells beautifully
SELECT
    r.review_id,
    p.name          AS product,
    r.rating,
    r.metadata
FROM reviews r
JOIN products p ON r.product_id = p.product_id;

-- 3b. Querying inside JSONB - Filtering for verified purchases only
SELECT
    p.name                              AS product,
    r.rating,
    r.metadata ->> 'device'            AS device,
    r.metadata -> 'helpful_votes'      AS helpful_votes,
    r.metadata -> 'tags'               AS tags
FROM reviews r
JOIN products p ON r.product_id = p.product_id
WHERE (r.metadata ->> 'verified_purchase')::BOOLEAN = TRUE
ORDER BY rating DESC;

-- 3c. Checking index usage - We can demo the "Execution Plan" here
--     (Select the query and click the "Explain Execution Plan" button)
EXPLAIN ANALYZE
SELECT * FROM reviews
WHERE metadata @> '{"verified_purchase": true}';


-- ── SECTION 4: PERFORMANCE (Execution Plan) ───────────────

-- 4a. A complex join query to test index efficiency
--     DBeaver shows exactly which indexes are used in the visual plan
EXPLAIN ANALYZE
SELECT
    c.first_name,
    COUNT(o.order_id)   AS order_count,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_date >= '2024-06-01'
  AND o.status = 'Delivered'
GROUP BY c.first_name
ORDER BY total_spent DESC;


-- ── SECTION 5: DATA UPDATES & TRANSACTIONS ─────────────────
-- Tip: Before running these, switch DBeaver to "Manual Commit" mode
-- (Click the "Auto" dropdown in the top toolbar and select "Manual")
-- This allows us to ROLLBACK mistakes - a great safety feature to demo!

-- 5a. Updating data (Use DBeaver toolbar to ROLLBACK or COMMIT after)
UPDATE products
SET stock_quantity = stock_quantity - 1
WHERE product_id = 1
RETURNING product_id, name, stock_quantity;

-- 5b. Inserting a new row and seeing it instantly in the grid
INSERT INTO products (name, category_id, price, stock_quantity)
VALUES ('Mechanical Keyboard', 1, 159.99, 15)
RETURNING *;

-- 5c. Cleaning up the test insert
DELETE FROM products
WHERE name = 'Mechanical Keyboard'
RETURNING *;
