# DBeaver: Universal Database Manager for Data Engineers

This repository is part of the **YZV 322E — Applied Data Engineering** Individual Tool Presentation.

---

## 1. What is DBeaver?

DBeaver is a free, open-source, multi-platform universal database management tool. It provides a powerful graphical interface for connecting to, querying, and visualizing data from dozens of different database engines including PostgreSQL, MySQL, SQLite, MongoDB, and Oracle — all from a single application. It is widely adopted by data engineers and DBAs as a replacement for engine-specific tools like pgAdmin or MySQL Workbench.

---

## 2. Prerequisites

| Requirement | Version Used | Notes |
|---|---|---|
| **OS** | macOS 13+ (also works on Windows/Linux) | |
| **Docker Desktop** | 4.x or later | [Download](https://www.docker.com/products/docker-desktop/) |
| **Docker Engine** | 24.x or later | Bundled with Docker Desktop |
| **DBeaver Community** | 24.x or later | [Download](https://dbeaver.io/download/) |
| **Homebrew** (optional) | Any | macOS only, for CLI install |

> **Note:** `docker compose` (V2, no hyphen) is used in this project. `docker-compose` (V1) is deprecated.

---

## 3. Installation

### Step 1: Clone the Repository
```bash
git clone https://github.com/<your-username>/dbeaver-tool-presentation.git
cd dbeaver-tool-presentation
```

### Step 2: Install DBeaver
**Option A — Homebrew (macOS recommended):**
```bash
brew install --cask dbeaver-community
```

**Option B — Direct download:**
Download the installer from [https://dbeaver.io/download/](https://dbeaver.io/download/) and run it.

### Step 3: Start the Demo PostgreSQL Database
```bash
docker compose up -d
```

This command will:
1. Pull the official `postgres:15` Docker image.
2. Start a container named `dbeaver_demo_db`.
3. Automatically execute `scripts/seed_data.sql` to create tables, views, indexes, and insert sample data.

### Step 4: Verify the Database is Running
```bash
docker compose ps
```

Expected output:
```
NAME                STATUS          PORTS
dbeaver_demo_db     Up (healthy)    0.0.0.0:5432->5432/tcp
```

---

## 4. Running the Example

### Connect DBeaver to the Database
1. Open the **DBeaver** application.
2. Click the **"New Database Connection"** icon (plug icon, top-left).
3. Select **PostgreSQL**, click **Next**.
4. Enter the following credentials:
   - **Host**: `localhost`
   - **Port**: `5432`
   - **Database**: `dbeaver_demo`
   - **Username**: `user`
   - **Password**: `password`
5. Click **"Test Connection"** (download drivers if prompted), then **"Finish"**.

### Run Sample Queries
Open `sample_queries.sql` in DBeaver's SQL Editor (`File > Open File`) and execute any of the following:

```sql
-- View all products
SELECT * FROM products;

-- Join query: products with their categories (price > 50)
SELECT p.name AS product, c.name AS category, p.price
FROM products p
JOIN categories c ON p.category_id = c.category_id
WHERE p.price > 50;

-- View pre-built order summary (uses the SQL View)
SELECT * FROM v_order_summaries;

-- Execution Plan: analyze query performance
EXPLAIN ANALYZE
SELECT c.first_name, SUM(o.total_amount)
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.first_name;
```

Press **`Ctrl+Enter`** (or **`Cmd+Enter`** on macOS) to execute the selected query.

### Stop the Database (when done)
```bash
docker compose down
```

---

## 5. Expected Output

After connecting and running the queries, you should see:

**ER Diagram** (`public` schema → "Diagram" tab):
- 5 tables (`categories`, `products`, `customers`, `orders`, `order_items`) connected by foreign key lines.
- 1 view (`v_order_summaries`) visible in the diagram.

**SQL Query Result** (`SELECT * FROM products`):
```
 product_id | name              | category_id | price   | stock_quantity
------------+-------------------+-------------+---------+---------------
 1          | Smartphone Alpha  | 1           | 699.99  | 50
 2          | Laptop Pro        | 1           | 1299.50 | 20
 3          | Cotton T-Shirt    | 2           | 19.99   | 100
 4          | Chef Knife        | 3           | 45.00   | 30
```

**Terminal — `docker compose ps`:**
```
NAME                STATUS    PORTS
dbeaver_demo_db     Up        0.0.0.0:5432->5432/tcp
```

---

## 6. AI Usage Disclosure

I used **Gemini (Google AI)** as a helper for this project. I mainly used it to check my grammar, get some ideas for the sample data, and help me understand some error messages I got from Docker. All the actual work and logic are mine.

You can see the full list of what I used it for in [ai_usage.md](./ai_usage.md).

---

**Course**: YZV 322E — Applied Data Engineering
**Student**: Sude Dilay Tunç
**Date**: April 29, 2026
