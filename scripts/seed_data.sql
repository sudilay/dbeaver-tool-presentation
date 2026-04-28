-- ============================================================
-- Database Prep Script for DBeaver Presentation
-- All tables and sample data needed for  assignment
-- ============================================================

-- 1. CREATING TABLES -----------------------------------------

-- Categories for  products
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT
);

-- Products table (linked to categories)
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category_id INT REFERENCES categories(category_id),
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Our customer database
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(50),
    country VARCHAR(50),
    registration_date DATE DEFAULT CURRENT_DATE
);

-- Order tracking
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2),
    status VARCHAR(20) DEFAULT 'Pending'
);

-- Details for each order (mapping products to orders)
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INT REFERENCES products(product_id),
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL
);

-- Reviews table - Using JSONB here to show off DBeaver's JSON capabilities
CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(product_id),
    customer_id INT REFERENCES customers(customer_id),
    rating INT CHECK (rating BETWEEN 1 AND 5),
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB  -- Stores extra data like device info. DBeaver grid renders this perfectly.
);

-- 2. INDEXES (Useful for demoing performance analysis in DBeaver) -----------
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
-- GIN index for JSON queries - can be shown in DBeaver's 'Indexes' tab
CREATE INDEX idx_reviews_metadata ON reviews USING GIN (metadata);

-- 3. VIEWS -----------------------------------------------------------------
-- Quick summary of orders
CREATE VIEW v_order_summaries AS
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.city,
    o.order_date,
    o.total_amount,
    o.status,
    COUNT(oi.order_item_id) AS items_count
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, customer_name, c.city, o.order_date, o.total_amount, o.status;

-- Monthly sales summary
CREATE VIEW v_monthly_revenue AS
SELECT
    DATE_TRUNC('month', order_date) AS month,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS avg_order_value
FROM orders
WHERE status != 'Cancelled'
GROUP BY 1
ORDER BY 1;

-- 4. LOADING SAMPLE DATA ----------------------------------------------------

-- Categories first
INSERT INTO categories (name, description) VALUES
('Electronics', 'Gadgets, devices, and accessories'),
('Clothing', 'Apparel and fashion items'),
('Home & Kitchen', 'Furniture and kitchenware'),
('Books', 'Technical and fiction books'),
('Sports', 'Sporting goods and equipment');

-- Products list
INSERT INTO products (name, category_id, price, stock_quantity) VALUES
('Smartphone Alpha', 1, 699.99, 50),
('Laptop Pro',       1, 1299.50, 20),
('Wireless Earbuds', 1, 89.99, 80),
('Smart Watch',      1, 249.00, 35),
('Cotton T-Shirt',   2, 19.99, 100),
('Winter Jacket',    2, 129.00, 40),
('Running Shoes',    5, 95.00, 60),
('Chef Knife',       3, 45.00, 30),
('Coffee Maker',     3, 79.99, 25),
('Python Cookbook',  4, 39.99, 45);

-- Some customers
INSERT INTO customers (first_name, last_name, email, city, country) VALUES
('Sude',    'Tunc',    'sude@example.com',    'Istanbul',  'Turkey'),
('John',    'Doe',     'john@example.com',    'New York',  'USA'),
('Jane',    'Smith',   'jane@example.com',    'London',    'UK'),
('Carlos',  'Garcia',  'carlos@example.com',  'Madrid',    'Spain'),
('Yuki',    'Tanaka',  'yuki@example.com',    'Tokyo',     'Japan'),
('Fatima',  'Al-Said', 'fatima@example.com',  'Dubai',     'UAE'),
('Anna',    'Mueller', 'anna@example.com',    'Berlin',    'Germany'),
('Lucas',   'Petit',   'lucas@example.com',   'Paris',     'France');

-- Generating 200 random orders to show how DBeaver handles scrolling/pagination
INSERT INTO orders (customer_id, order_date, total_amount, status)
SELECT
    (RANDOM() * 7 + 1)::INT,
    TIMESTAMP '2024-01-01' + (RANDOM() * 850) * INTERVAL '1 day',
    ROUND((RANDOM() * 1500 + 20)::NUMERIC, 2),
    (ARRAY['Pending','Processing','Shipped','Delivered','Cancelled'])[FLOOR(RANDOM()*5+1)::INT]
FROM generate_series(1, 200);

-- Adding items to those 200 orders
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT
    o.order_id,
    (RANDOM() * 9 + 1)::INT,
    (RANDOM() * 4 + 1)::INT,
    p.price
FROM orders o
JOIN products p ON p.product_id = (RANDOM() * 9 + 1)::INT
WHERE o.order_id > 3;

-- Some manual orders for easier demoing
INSERT INTO orders (customer_id, total_amount, status) VALUES
(1, 719.98, 'Shipped'),
(2, 1299.50, 'Processing'),
(1, 45.00, 'Pending');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(201, 1, 1, 699.99),
(201, 5, 1, 19.99),
(202, 2, 1, 1299.50),
(203, 8, 1, 45.00);

-- Reviews with JSON metadata
INSERT INTO reviews (product_id, customer_id, rating, metadata) VALUES
(1, 1, 5, '{"tags": ["fast","reliable"], "device": "macOS", "verified_purchase": true, "helpful_votes": 42}'),
(1, 2, 4, '{"tags": ["good value"], "device": "Windows", "verified_purchase": true, "helpful_votes": 15}'),
(2, 3, 5, '{"tags": ["excellent","fast delivery"], "device": "macOS", "verified_purchase": true, "helpful_votes": 88}'),
(3, 4, 3, '{"tags": ["average sound"], "device": "Android", "verified_purchase": false, "helpful_votes": 5}'),
(5, 5, 5, '{"tags": ["comfortable","great fit"], "device": "iOS", "verified_purchase": true, "helpful_votes": 31}'),
(9, 6, 4, '{"tags": ["easy to use","quiet"], "device": "Windows", "verified_purchase": true, "helpful_votes": 20}'),
(10, 7, 5, '{"tags": ["must read","practical"], "device": "macOS", "verified_purchase": true, "helpful_votes": 67}'),
(2, 8, 4, '{"tags": ["powerful","worth it"], "device": "Linux", "verified_purchase": true, "helpful_votes": 50}');
