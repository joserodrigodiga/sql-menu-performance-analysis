--=====================================================
-- Menu Performance Analysis: SQL Questions
-- Windows: 2025-09-01 to 2026-09-30
--=====================================================

-- What are the total sales per category?
SELECT category,
       SUM(total) AS revenue
FROM sales
WHERE date BETWEEN '2025-09-01' AND '2026-09-30'
GROUP BY category
ORDER BY revenue DESC
;

-- Which items sold the most units?
SELECT item,
       SUM(quantity) AS total_units
FROM sales
WHERE date BETWEEN '2025-09-01' AND '2026-09-30'
GROUP BY item
ORDER BY total_units DESC
;

-- What are the total sales per month?
SELECT STRFTIME('%Y-%m',date) AS month,
       SUM(total) AS revenue
FROM sales
WHERE date BETWEEN '2025-09-01' AND '2026-09-30'
GROUP BY month
ORDER BY month ASC
;

-- How many open days are in the window (Sep 1, 2025 to Sep 30, 2026)?
SELECT COUNT(*) AS open_days
FROM calendar
WHERE date BETWEEN '2025-09-01' AND '2026-09-30'
;

-- What is the average daily units per item?
SELECT item,
       ROUND(SUM(quantity) * 1.0 / 
       (SELECT COUNT(*) 
         FROM calendar 
         WHERE is_open = 1
           AND (date BETWEEN '2025-09-01' AND '2026-09-30')), 2) AS avg_units
FROM sales
WHERE date BETWEEN '2025-09-01' AND '2026-09-30'
GROUP BY item
ORDER BY avg_units DESC
;

-- How many days did each item have sales (consistency)?
SELECT item,
       ROUND(COUNT(DISTINCT date) * 1.0 /
       (SELECT COUNT(*)
         FROM calendar
         WHERE is_open = 1
           AND (date BETWEEN '2025-09-01' AND '2026-09-30')), 2) AS consistency_pct
FROM sales
WHERE date BETWEEN '2025-09-01' AND '2026-09-30'
GROUP BY item
ORDER BY consistency_pct DESC
;

-- How many open days had zero sales?
SELECT COUNT(cal.date) AS zero_sale_days
FROM calendar AS cal
LEFT JOIN sales
  ON cal.date = sales.date
WHERE cal.is_open = 1
  AND (cal.date BETWEEN '2025-09-01' AND '2026-09-30')
  And sales.date IS NULL
;

-- Which items are growing or declining (Jul to Sep 2026 vs. Apr to Jun 2026)?
WITH 
  units_per_item AS (
    SELECT item,
           SUM(CASE 
             WHEN date BETWEEN '2026-04-01' AND '2026-06-30'
             THEN quantity
             ELSE 0 
           END) AS prior_units,
           SUM(CASE 
             WHEN date BETWEEN '2026-07-01' AND '2026-09-30'
             THEN quantity
             ELSE 0
           END) AS recent_units
    FROM sales
    WHERE date BETWEEN '2026-04-01' AND '2026-09-30'
    GROUP BY item
),
  open_days AS (
    SELECT 
      SUM(CASE
        WHEN date BETWEEN '2026-04-01' AND '2026-06-30'
        THEN 1
        ELSE 0
      END) AS prior_days,
      SUM(CASE
        WHEN date BETWEEN '2026-07-01' AND '2026-09-30'
        THEN 1
        ELSE 0
      END) AS recent_days
    FROM calendar
    WHERE is_open = 1
      AND (date BETWEEN '2026-04-01' AND '2026-09-30')
)
SELECT item,
       ROUND((((upi.recent_units * 1.0 / op.recent_days) /
       (NULLIF(upi.prior_units, 0) * 1.0 / op.prior_days)) – 1) * 100, 1) AS trend_pct
FROM units_per_item AS upi
CROSS JOIN open_days AS op
ORDER BY trend_pct DESC
;

-- Do customers choose the combo (sandwich w/ fries) over the solo sandwich?
WITH 
  units_qty AS (
    SELECT
      SUM(CASE
        WHEN category = 'Sandwich-Solo'
        THEN quantity
        ELSE 0
      END) AS solo_units,
      SUM(CASE 
        WHEN category = 'Sandwich-Combo'
        THEN quantity
        ELSE 0 
      END) AS combo_units
    FROM sales
    WHERE date BETWEEN '2025-09-01' AND '2026-09-30'
      AND category LIKE 'Sandwich%'
)
SELECT ROUND(((combo_units * 1.0 /
       (solo_units + combo_units)) * 100), 2) AS share_pct
FROM units_qty
;

-- How does RT5(Overload) compare with the average of RT1 to RT4?
WITH 
  units AS (
    SELECT item,
           SUM(quantity) AS total_units
    FROM sales
    WHERE date BETWEEN '2025-09-01' AND '2026-09-30'
      AND category LIKE 'RiceTopper%'
    GROUP BY item
),
  compare AS (
    SELECT 
      SUM(CASE 
        WHEN item = 'RT5'
        THEN total_units
      END) AS rt5_units,
      AVG(CASE 
        WHEN item <> 'RT5'
        THEN total_units 
      END) AS solo_avg
    FROM units
)
SELECT ROUND((rt5_units * 1.0 / solo_avg – 1) * 100, 1) AS pct_share
FROM compare
;
