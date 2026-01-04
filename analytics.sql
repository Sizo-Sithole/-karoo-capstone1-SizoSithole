USE DATABASE DB1;
USE SCHEMA PUBLIC;

SELECT
  s.region,
  SUM(o.total_price) AS actual_revenue,
  t.target_amount,
  CASE
    WHEN t.target_amount IS NULL OR t.target_amount = 0 THEN NULL
    ELSE ROUND((SUM(o.total_price) / t.target_amount) * 100, 2)
  END AS pct_of_target
FROM SUPPLIERS s
JOIN ORDERSS o
  ON o.supplier_id = s.supplier_id
LEFT JOIN SALES_TARGETS t
  ON t.region = s.region
 AND t.quarter = '2025-Q4'
WHERE o.order_date >= DATE '2025-10-01'
  AND o.order_date <  DATE '2026-01-01'
GROUP BY s.region, t.target_amount
ORDER BY s.region;

SELECT
  region,
  farm_name,
  total_revenue,
  regional_rank
FROM (
  SELECT
    s.region,
    s.farm_name,
    SUM(o.total_price) AS total_revenue,
    RANK() OVER (
      PARTITION BY s.region
      ORDER BY SUM(o.total_price) DESC
    ) AS regional_rank
  FROM SUPPLIERS s
  JOIN ORDERSS o
    ON o.supplier_id = s.supplier_id
  WHERE o.order_date >= DATE '2025-10-01'
    AND o.order_date <  DATE '2026-01-01'
  GROUP BY s.region, s.supplier_id, s.farm_name
)
WHERE regional_rank <= 3
ORDER BY region, regional_rank, farm_name;
