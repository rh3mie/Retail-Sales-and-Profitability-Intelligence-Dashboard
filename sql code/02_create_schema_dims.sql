CREATE SCHEMA IF NOT EXISTS bi;

-- Create Dimension tables
CREATE TABLE IF NOT EXISTS bi.dim_customer (
  customer_key   BIGSERIAL PRIMARY KEY,
  customer_id    TEXT UNIQUE NOT NULL,
  customer_name  TEXT,
  segment        TEXT
);

CREATE TABLE IF NOT EXISTS bi.dim_product (
  product_key    BIGSERIAL PRIMARY KEY,
  product_id     TEXT UNIQUE NOT NULL,
  product_name   TEXT,
  category       TEXT,
  sub_category   TEXT
);

CREATE TABLE IF NOT EXISTS bi.dim_ship_mode (
  ship_mode_key  BIGSERIAL PRIMARY KEY,
  ship_mode      TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS bi.dim_geography (
  geography_key  BIGSERIAL PRIMARY KEY,
  country        TEXT,
  region         TEXT,
  state          TEXT,
  city           TEXT,
  postal_code    TEXT,
  UNIQUE (country, region, state, city, postal_code)
);

CREATE TABLE IF NOT EXISTS bi.dim_date (
  date_key     INTEGER PRIMARY KEY,  -- YYYYMMDD
  date_value   DATE UNIQUE NOT NULL,
  year         SMALLINT NOT NULL,
  quarter      SMALLINT NOT NULL,
  month        SMALLINT NOT NULL,
  month_name   TEXT NOT NULL,
  day          SMALLINT NOT NULL,
  day_of_week  SMALLINT NOT NULL,     -- 1=Mon ... 7=Sun
  week_of_year SMALLINT NOT NULL
);

-- Insert data into dims
INSERT INTO bi.dim_customer (customer_id, customer_name, segment)
SELECT DISTINCT customer_id, customer_name, segment
FROM public.superstore
WHERE customer_id IS NOT NULL
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO bi.dim_product (product_id, product_name, category, sub_category)
SELECT DISTINCT product_id, product_name, category, sub_category
FROM public.superstore
WHERE product_id IS NOT NULL
ON CONFLICT (product_id) DO NOTHING;

INSERT INTO bi.dim_ship_mode (ship_mode)
SELECT DISTINCT ship_mode
FROM public.superstore
WHERE ship_mode IS NOT NULL
ON CONFLICT (ship_mode) DO NOTHING;

INSERT INTO bi.dim_geography (country, region, state, city, postal_code)
SELECT DISTINCT country, region, state, city, postal_code
FROM public.superstore
ON CONFLICT (country, region, state, city, postal_code) DO NOTHING;

WITH bounds AS (
  SELECT
    LEAST(MIN(order_date), MIN(ship_date)) AS min_d,
    GREATEST(MAX(order_date), MAX(ship_date)) AS max_d
  FROM public.superstore
),
dates AS (
  SELECT generate_series((SELECT min_d FROM bounds),
                         (SELECT max_d FROM bounds),
                         interval '1 day')::date AS d
)
INSERT INTO bi.dim_date (
  date_key, date_value, year, quarter, month, month_name, day, day_of_week, week_of_year
)
SELECT
  (EXTRACT(YEAR FROM d)::int * 10000
   + EXTRACT(MONTH FROM d)::int * 100
   + EXTRACT(DAY FROM d)::int) AS date_key,
  d AS date_value,
  EXTRACT(YEAR FROM d)::smallint AS year,
  EXTRACT(QUARTER FROM d)::smallint AS quarter,
  EXTRACT(MONTH FROM d)::smallint AS month,
  TO_CHAR(d, 'Mon') AS month_name,
  EXTRACT(DAY FROM d)::smallint AS day,
  EXTRACT(ISODOW FROM d)::smallint AS day_of_week,
  EXTRACT(WEEK FROM d)::smallint AS week_of_year
FROM dates
ON CONFLICT (date_key) DO NOTHING;

-- Create Fact Table
CREATE TABLE IF NOT EXISTS bi.fact_orders (
  fact_key          BIGSERIAL PRIMARY KEY,
  order_id          TEXT NOT NULL,
  row_id            INTEGER,
  order_date_key    INTEGER NOT NULL REFERENCES bi.dim_date(date_key),
  ship_date_key     INTEGER NOT NULL REFERENCES bi.dim_date(date_key),
  customer_key      BIGINT NOT NULL REFERENCES bi.dim_customer(customer_key),
  product_key       BIGINT NOT NULL REFERENCES bi.dim_product(product_key),
  ship_mode_key     BIGINT NOT NULL REFERENCES bi.dim_ship_mode(ship_mode_key),
  geography_key     BIGINT NOT NULL REFERENCES bi.dim_geography(geography_key),
  sales             NUMERIC(12,2),
  quantity          INTEGER,
  discount          NUMERIC(6,3),
  profit            NUMERIC(12,2)
);

INSERT INTO bi.fact_orders (
  order_id, row_id,
  order_date_key, ship_date_key,
  customer_key, product_key, ship_mode_key, geography_key,
  sales, quantity, discount, profit
)
SELECT
  s.order_id,
  s.row_id,

  (EXTRACT(YEAR FROM s.order_date)::int * 10000
   + EXTRACT(MONTH FROM s.order_date)::int * 100
   + EXTRACT(DAY FROM s.order_date)::int) AS order_date_key,
  (EXTRACT(YEAR FROM s.ship_date)::int * 10000
   + EXTRACT(MONTH FROM s.ship_date)::int * 100
   + EXTRACT(DAY FROM s.ship_date)::int) AS ship_date_key,

  c.customer_key,
  p.product_key,
  sm.ship_mode_key,
  g.geography_key,
  s.sales,
  s.quantity,
  s.discount,
  s.profit
FROM public.superstore s
JOIN bi.dim_customer c ON c.customer_id = s.customer_id
JOIN bi.dim_product  p ON p.product_id  = s.product_id
JOIN bi.dim_ship_mode sm ON sm.ship_mode = s.ship_mode
JOIN bi.dim_geography g
  ON g.country = s.country
 AND g.region = s.region
 AND g.state = s.state
 AND g.city = s.city
 AND COALESCE(g.postal_code,'') = COALESCE(s.postal_code,'');

-- Indexes for PBI
CREATE INDEX IF NOT EXISTS ix_fact_order_date ON bi.fact_orders(order_date_key);
CREATE INDEX IF NOT EXISTS ix_fact_customer   ON bi.fact_orders(customer_key);
CREATE INDEX IF NOT EXISTS ix_fact_product    ON bi.fact_orders(product_key);
CREATE INDEX IF NOT EXISTS ix_fact_geo        ON bi.fact_orders(geography_key);
CREATE INDEX IF NOT EXISTS ix_fact_order_id   ON bi.fact_orders(order_id);
