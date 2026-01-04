import os
import csv
from pathlib import Path
import snowflake.connector

BASE_DIR = Path(__file__).resolve().parent
SUPPLIERS_CSV = BASE_DIR / "suppliers.csv"
ORDERSS_CSV = BASE_DIR / "orderss.csv"
TARGETS_CSV = BASE_DIR / "targets.csv"

def connect():
    return snowflake.connector.connect(
        account=os.getenv("SNOWFLAKE_ACCOUNT"),
        user=os.getenv("SNOWFLAKE_USER"),
        password=os.getenv("SNOWFLAKE_PASSWORD"),
        warehouse=os.getenv("SNOWFLAKE_WAREHOUSE"),
        role=os.getenv("SNOWFLAKE_ROLE"),
        database=os.getenv("SNOWFLAKE_DATABASE", "DB1"),
        schema=os.getenv("SNOWFLAKE_SCHEMA", "PUBLIC"),
    )

def read_rows(path, expected_cols):
    with path.open("r", newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        headers = [h.strip().lower() for h in (reader.fieldnames or [])]
        missing = [c for c in expected_cols if c not in headers]
        if missing:
            raise ValueError(f"{path.name} missing columns: {missing}. Found: {reader.fieldnames}")
        out = []
        for r in reader:
            out.append(tuple((r[c] if r[c] != "" else None) for c in expected_cols))
        return out

def main():
    conn = None
    cur = None
    try:
        conn = connect()
        cur = conn.cursor()

        cur.execute("USE DATABASE DB1")
        cur.execute("USE SCHEMA PUBLIC")

        suppliers = read_rows(SUPPLIERS_CSV, ["supplier_id","farm_name","region"])
        orders = read_rows(ORDERSS_CSV, ["order_id","supplier_id","order_date","total_price"])
        targets = read_rows(TARGETS_CSV, ["region","quarter","target_amount"])

        cur.executemany(
            "INSERT INTO SUPPLIERS (supplier_id, farm_name, region) VALUES (%s, %s, %s)",
            suppliers
        )

        cur.executemany(
            "INSERT INTO ORDERSS (order_id, supplier_id, order_date, total_price) VALUES (%s, %s, %s, %s)",
            orders
        )

        cur.executemany(
            "INSERT INTO SALES_TARGETS (region, quarter, target_amount) VALUES (%s, %s, %s)",
            targets
        )

        print("Loaded suppliers.csv, orderss.csv, targets.csv into DB1.PUBLIC")

    except Exception as e:
        print(f"Load failed: {e}")
        raise
    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()

if __name__ == "__main__":
    main()
