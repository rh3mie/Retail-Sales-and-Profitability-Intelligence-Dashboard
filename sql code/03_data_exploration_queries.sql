-- Key KPIs
CREATE OR REPLACE VIEW bi.key_kpis_view AS
SELECT
  SUM(sales) AS total_sales,
  SUM(profit) AS total_profit,
  ROUND(SUM(profit) / NULLIF(SUM(sales),0) * 100, 2) AS profit_margin_pct,
  SUM(quantity) AS total_units
FROM bi.fact_orders;

-- Monthly Sales and Profit over the Years
CREATE OR REPLACE VIEW bi.monthly_salesprofit_yearly_view AS
SELECT
  DATE_TRUNC('month', d.date_value) AS month,
  SUM(f.sales)  AS sales,
  SUM(f.profit) AS profit
FROM bi.fact_orders f
JOIN bi.dim_date d ON d.date_key = f.order_date_key
GROUP BY 1
ORDER BY 1;

-- YoY Sales Growth
CREATE OR REPLACE VIEW bi.yoy_sales_growth_view AS
WITH yearly AS (
  SELECT
    d.year,
    SUM(f.sales) AS sales
  FROM bi.fact_orders f
  JOIN bi.dim_date d ON d.date_key = f.order_date_key
  GROUP BY d.year
)
SELECT
  year,
  sales,
  ROUND((sales - LAG(sales) OVER (ORDER BY year)) / NULLIF(LAG(sales) OVER (ORDER BY year),0) * 100, 2) AS yoy_growth_pct
FROM yearly
ORDER BY year;

-- Category Sales and Profit Margin
CREATE OR REPLACE VIEW bi.category_salesprofit_margin_view AS
SELECT
  p.category,
  p.sub_category,
  SUM(f.sales) AS sales,
  SUM(f.profit) AS profit,
  ROUND(SUM(f.profit) / NULLIF(SUM(f.sales),0) * 100, 2) AS margin_pct
FROM bi.fact_orders f
JOIN bi.dim_product p ON p.product_key = f.product_key
GROUP BY 1,2
ORDER BY sales DESC;

-- Top Products by Profit
CREATE OR REPLACE VIEW bi.top_product_profit_view AS
SELECT
  p.product_name,
  SUM(f.profit) AS total_profit
FROM bi.fact_orders f
JOIN bi.dim_product p ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_profit DESC
LIMIT 10;

-- Bottom Products by Profit
CREATE OR REPLACE VIEW bi.bottom_product_profit_view AS
  p.product_name,
  SUM(f.sales) AS sales,
  SUM(f.profit) AS profit
FROM bi.fact_orders f
JOIN bi.dim_product p ON p.product_key = f.product_key
GROUP BY p.product_name
HAVING SUM(f.profit) < 0
ORDER BY profit ASC
LIMIT 10;

-- Top Customers by Sales
CREATE OR REPLACE VIEW bi.top_customers_by_sales_view AS
  c.customer_name,
  c.segment,
  SUM(f.sales) AS sales,
  SUM(f.profit) AS profit
FROM bi.fact_orders f
JOIN bi.dim_customer c ON c.customer_key = f.customer_key
GROUP BY 1,2
ORDER BY sales DESC
LIMIT 10;

-- Region Performance by Profit
CREATE OR REPLACE VIEW bi.region_profit_view AS
SELECT
  g.region,
  SUM(f.sales) AS sales,
  SUM(f.profit) AS profit,
  ROUND(SUM(f.profit)/NULLIF(SUM(f.sales),0) * 100, 2) AS margin_pct
FROM bi.fact_orders f
JOIN bi.dim_geography g ON g.geography_key = f.geography_key
GROUP BY g.region
ORDER BY sales DESC;

--Best States by Profit
CREATE OR REPLACE VIEW bi.top_state_profit_view AS
SELECT
  g.state,
  SUM(f.profit) AS profit
FROM bi.fact_orders f
JOIN bi.dim_geography g ON g.geography_key = f.geography_key
GROUP BY g.state
ORDER BY profit DESC
LIMIT 10;

-- Worst States by Profit
CREATE OR REPLACE VIEW bi.bottom_state_profit_view AS
SELECT
  g.state,
  SUM(f.profit) AS profit
FROM bi.fact_orders f
JOIN bi.dim_geography g ON g.geography_key = f.geography_key
GROUP BY g.state
ORDER BY profit ASC
LIMIT 10;

-- Average Shipping Days by Ship Mode
CREATE OR REPLACE VIEW bi.avg_shipping_days_view AS
SELECT
  sm.ship_mode,
  ROUND(AVG(d_ship.date_value - d_order.date_value), 2) AS avg_ship_days
FROM bi.fact_orders f
JOIN bi.dim_ship_mode sm ON sm.ship_mode_key = f.ship_mode_key
JOIN bi.dim_date d_order ON d_order.date_key = f.order_date_key
JOIN bi.dim_date d_ship  ON d_ship.date_key  = f.ship_date_key
GROUP BY sm.ship_mode
ORDER BY avg_ship_days;

-- Profit from Discounts
CREATE OR REPLACE VIEW bi.discount_profit_view AS
SELECT
  CASE
    WHEN f.discount = 0 THEN 'No Discount'
    WHEN f.discount <= 0.2 THEN 'Low Discount (0-20%)'
    WHEN f.discount <= 0.5 THEN 'Medium Discount(20-50%)'
    ELSE 'High Discount (50%+)'
  END AS discount,
  SUM(f.sales) AS sales,
  SUM(f.profit) AS profit,
  ROUND(SUM(f.profit)/NULLIF(SUM(f.sales),0) * 100, 2) AS margin_pct
FROM bi.fact_orders f
GROUP BY 1
ORDER BY margin_pct DESC;


