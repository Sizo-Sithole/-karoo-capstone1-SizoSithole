USE DATABASE DB1;
USE SCHEMA PUBLIC;

MERGE INTO SALES_TARGETS t
USING (
  SELECT column1 AS region, column2 AS quarter, column3::NUMBER(12,2) AS target_amount
  FROM VALUES
    ('Western Cape','2025-Q4',50000.00),
    ('Eastern Cape','2025-Q4',20000.00),
    ('Northern Cape','2025-Q4',30000.00)
) s
ON t.region = s.region AND t.quarter = s.quarter
WHEN MATCHED THEN UPDATE SET target_amount = s.target_amount
WHEN NOT MATCHED THEN INSERT (region, quarter, target_amount) VALUES (s.region, s.quarter, s.target_amount);

INSERT INTO HARVEST_LOG (supplier_id, harvest_date, crop, quantity_kg, grade, notes)
VALUES
  (1, '2025-10-03', 'Rooibos', 1200.00, 'A', 'Q4 harvest sample'),
  (2, '2025-10-18', 'Dates', 850.00, 'A', 'Q4 harvest sample'),
  (3, '2025-11-02', 'Wool', 640.00, 'B', 'Q4 harvest sample'),
  (4, '2025-11-20', 'Olives', 1500.00, 'A', 'Q4 harvest sample'),
  (5, '2025-12-09', 'Grapes', 2000.00, 'A', 'Q4 harvest sample');

INSERT INTO ORDERSS (order_id, supplier_id, order_date, total_price)
VALUES
  (12, 1, '2025-12-05', 9100.00),
  (13, 2, '2025-12-08', 4300.00),
  (14, 4, '2025-12-15', 12500.00),
  (15, 6, '2025-12-19', 7700.00);
