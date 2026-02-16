-- Create raw table for importing data
DROP TABLE IF EXISTS public.superstore_raw;

CREATE TABLE public.superstore_raw (
  row_id         text,
  order_id       text,
  order_date     text,
  ship_date      text,
  ship_mode      text,
  customer_id    text,
  customer_name  text,
  segment        text,
  country        text,
  city           text,
  state          text,
  postal_code    text,
  region         text,
  product_id     text,
  category       text,
  sub_category   text,
  product_name   text,
  sales          text,
  quantity       text,
  discount       text,
  profit         text
);

-- Create Table with Types
CREATE TABLE superstore (
  row_id        int,
  order_id      text,
  order_date    date,
  ship_date     date,
  ship_mode     text,
  customer_id   text,
  customer_name text,
  segment       text,
  country       text,
  city          text,
  state         text,
  postal_code   text,
  region        text,
  product_id    text,
  category      text,
  sub_category  text,
  product_name  text,
  sales         numeric(12,2),
  quantity      int,
  discount      numeric(6,3),
  profit        numeric(12,2)
);


-- Insert Raw Data into Typed Table
INSERT INTO superstore
SELECT
  NULLIF(row_id,'')::int,
  order_id,
  TO_DATE(order_date, 'MM/DD/YYYY'),
  TO_DATE(ship_date, 'MM/DD/YYYY'),
  ship_mode,
  customer_id,
  customer_name,
  segment,
  country,
  city,
  state,
  postal_code,
  region,
  product_id,
  category,
  sub_category,
  product_name,
  NULLIF(sales,'')::numeric,
  NULLIF(quantity,'')::int,
  NULLIF(discount,'')::numeric,
  NULLIF(profit,'')::numeric
FROM superstore_raw;

-- Add indexes for Power BI
CREATE INDEX idx_superstore_order_date ON superstore(order_date);
CREATE INDEX idx_superstore_region ON superstore(region);
CREATE INDEX idx_superstore_category ON superstore(category);
CREATE INDEX idx_superstore_customer ON superstore(customer_id);
CREATE INDEX idx_superstore_product ON superstore(product_id);
