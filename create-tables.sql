DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS items;
DROP TABLE IF EXISTS calendar;

CREATE TABLE sales (
  date       TEXT,
  item       TEXT,
  category   TEXT,
  quantity   INTEGER,
  unit_price REAL,
  total      REAL
);

CREATE TABLE items (
  item        TEXT PRIMARY KEY,
  category    TEXT,
  launch_date TEXT
);

CREATE TABLE calendar (
  date    TEXT PRIMARY KEY,
  is_open INTEGER
);

INSERT INTO items (item, category, launch_date) VALUES
('S1',  'Sandwich-Solo',   '2025-04-03'),
('S2',  'Sandwich-Solo',   '2025-04-03'),
('S3',  'Sandwich-Combo',  '2025-04-03'),
('S4',  'Sandwich-Combo',  '2025-04-03'),
('RT1', 'RiceTopper-Solo', '2025-09-01'),
('RT2', 'RiceTopper-Solo', '2025-09-01'),
('RT3', 'RiceTopper-Solo', '2025-09-01'),
('RT4', 'RiceTopper-Solo', '2025-09-01'),
('RT5', 'RiceTopper-Mix',  '2025-09-01');
