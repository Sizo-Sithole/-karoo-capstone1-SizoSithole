# -karoo-capstone1-SizoSithole

This repo automates Karoo Organics’ quarterly (Q4 2025) regional performance reporting by loading baseline CSV data into PostgreSQL, extending the database schema, and generating a report with analytical SQL queries.

## What’s included
- `schema.sql`  
  Creates/ensures base tables (`suppliers`, `orders`) and adds the required extension tables:
  - `sales_targets` (PK: region + quarter)
  - `certifications` (FK to suppliers, UNIQUE per supplier+cert)
  - `harvest_log` (FK to suppliers, UNIQUE per supplier+date+crop)

- `load_data.py`  
  Loads `suppliers.csv`, `orders.csv`, and `targets.csv`, then inserts:
  - 3 Q4 sales targets (Western Cape, Eastern Cape, Northern Cape)
  - 5+ harvest records
  - 4+ additional Q4 orders and ensures Q4 has at least 10 orders total

- `analytics.sql`  
  1) Regional revenue vs targets (% achieved) using `CASE` + `GROUP BY`  
  2) Top 3 suppliers per region using `RANK() OVER (PARTITION BY ...)`

- `generate_q4_report.py`  
  Runs both analytics queries and writes a single CSV (`q4_performance.csv`) containing:
  - `regional_performance` rows
  - `top_suppliers` rows  
  Also prints a readable summary to the console.

## Assumptions (important)
- Quarter key format is `2025Q4` (6 chars).
- Q4 2025 is filtered as `2025-10-01` to `2026-01-01` (exclusive).
- Baseline CSVs exist in the repo root:
  - `suppliers.csv`
  - `orders.csv`
  - `targets.csv`

If your CSV headers differ significantly, adjust the `*_COLS` lists in `load_data.py`.

## Setup
### 1) Create a PostgreSQL database
Create a DB locally or via a hosted provider.

### 2) Set environment variables
Example:
- `DB_HOST=localhost`
- `DB_PORT=5432`
- `DB_NAME=karoo_db`
- `DB_USER=postgres`
- `DB_PASS=yourpassword`

### 3) Install dependencies
- `pip install psycopg2-binary`

### 4) Load schema + data
- `python load_data.py`

### 5) Generate the Q4 report
- `python generate_q4_report.py`

Output:
- `q4_performance.csv`

## Design choices (brief)
- Targets use a composite primary key (`region`, `quarter`) because a region can have targets each quarter.
- Orders keep `total_price` as a stored numeric for reporting reliability (not dependent on quantity/unit price being present in all CSVs).
- Harvest log uses a uniqueness constraint to avoid duplicate crop logs per supplier and date.

