# Sales & Profitability Intelligence Dashboard

*By Rhey Mar De Vera*

## Business Problem
Retail businesses generate large volumes of transactional data across products, customers, and regions, without a structured data model and analytical tooling, and that data sits unused. This leads to a lack of visibility into which products are actually profitable, which customer segments drive the most value, and where discounting strategies might help increase margins, and also where they might be hurting them. This makes it difficult to prioritize different decisions between pricing, inventory, and marketing.

## Solution/ Overview
This project was created to analyze retail sales data and provide business intelligence solutions by building a structured **PostgreSQL** star schema and a fully interactive multi-page **Power BI** dashboard. Stakeholders can then use this dashboard to receive insights to inform data-driven decisions towards pricing, inventory, and retention strategy. This includes insights such as:

- Business Performance
- Product Profitability
- Customer Segmentation
- Geographic Trends

## Files

- ```dashboard + images```: This folder contains the Power BI dashboard file, along with screenshots of its pages.
- ```sql code```: This folder holds all the SQL code used in this project (schema, views, etc.)
- ```Sample - Superstore.csv```: CSV file containing superstore sales data (Original data from [Kaggle](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)).

## The Database

<img width="980" height="628" alt="image" src="https://github.com/user-attachments/assets/34a40277-e996-48f1-966d-d2a788161986" />

Using PostgreSQL, I structured the data into a star schema to optimize queries and for better dashboard use. In total, there are 6 tables, all centered around the facts table:
- ```dim_date```: Contains all data with dates for product sales, orders, etc.
- ```dim_product```: Holds all product information (name, sales, etc.).
- ```dim_customer```: Stores all customer information (name, segment, etc.).
- ```dim_geography```: Has cities, countries, states, and postal code data.
- ```dim_ship_mode```: Stores information about an order's shipment mode.
- ```fact_orders```: Contains all sales, profit, quantity, and discount data.

By creating a structured schema in PostgreSQL, it allows for the data relationships to be understood more clearly, as each table is connected with primary and foreign keys. This also improves model clarity and query efficiency, especially across dimensions such as time, product, customer, and geography. As a result, the data model becomes more scalable, easier to maintain, and optimized. With this, it is ready to be loaded and used in Power BI.

## Dashboard Structure

Using the PostgreSQL database, I loaded it into Power BI and created a dashboard with three analytical pages.

**1. General Overview Page**
<img width="2045" height="1148" alt="image" src="https://github.com/user-attachments/assets/ae622ab3-a3bc-4acf-ab65-e6108609c2b6" />

The goal of this page is to provide an overall assessment of the superstore's health and sales trends. Here we can see a KPI summary, monthly sales and margin trends, quarterly profit breakdowns, category contribution analysis, and state-level performance. We can also use the filters on the left view this data for different years/months, regions, and product categories.

**2. Product Performance Page**
<img width="2045" height="1149" alt="image" src="https://github.com/user-attachments/assets/6d4ec1f7-1bef-4dca-a395-22600721a273" />

This page analyzes product-level sales, profitability, shipping selection, and more. It contains visualizations on sales and profit by product and subcategory, profit margin by category, orders by shipping mode, and a product performance table. This helps with pricing and product strategy decisions as it evaluates product performance at multiple levels.

**3. Customer Insights Page**
<img width="2047" height="1150" alt="image" src="https://github.com/user-attachments/assets/ebca5783-dbd7-4ebf-bf4a-66f775d9cdc0" />

With this page, we can evaluate customer behavior based on segmentation, geography, and growth trends. It contains information on customer count per state, sales, and profit by customer segment, and profit distribution by state. This can be used to view which customer segments drive the most value, how different regions perform, and how customer counts change over time. This can be used for segmentation strategy and retention efforts.

## Key Insights
In this project, I used PostgreSQL and Power BI to explore and analyze retail sales performance, product profitability, and customer behavior. I used SQL queries with CTEs, subqueries, and window functions, as well as Power BI's DAX queries and visualizations to find these insights.

- **Revenue and Profit**: From KPI tracking and visualizations, the superstore shows strong year-to-year growth in revenue and profit. Profit margins also remained stable, showing a strong pricing structure.
- **Product Performance**: Despite some products having high sales, it doesn't always translate to high profit. For example, there are high-cost furniture products that produce a loss in revenue. This gives opportunities to optimize pricing and product inventory based on performance.
- **Customer Insights**: Across regions, performance varies significantly by state. We can also see sales and profit based on customer segmentation. These findings would enable deeper support for targeted customer retention and marketing.
- **Shipping Efficiency**: Standard shipping was chosen more often over first and second class shipping, but had longer delivery periods. This insight could be used for marketing to encourage customers to buy more products, in return for better shipping.
- **Discounts Effect on Profit**: Lower discounts (0-20%) kept a healthy profit margin; discounts above that group (20-50%+) would lower it, despite them seeming to contribute a lot to sales volume. Focusing on balancing these discounts can keep these products having high contributions to sales volume, while keeping the profit margin positive.

## Recommendations

Based on the sales, profitability, customer, and shipping analysis, several actions could improve business performance:

- **Review underperforming high-sales products**: Especially items that generate strong revenue but weak or negative profit. These products should be evaluated for pricing changes, cost reduction opportunities, or inventory adjustments.

- **Limit aggressive discounting above 20%**: Higher discount ranges appear to reduce profit margin despite contributing to sales volume. Discount strategies should prioritize profitability instead of revenue growth alone.

- **Use customer segmentation to target high-value groups**: Focusing marketing and retention efforts on segments and regions that consistently drive stronger sales and profit.

- **Investigate low-profit states or regions**: Regional pricing, product mix, or marketing strategies could be adjusted based on state-level profitability trends.

- **Improve shipping strategy around Standard Class**: The business could test incentives that encourage larger orders in exchange for standard shipping or promote faster shipping for high-value customers.

- **Monitor category and subcategory profit margins regularly**: Especially in categories where sales volume masks weaker profitability. This would help prioritize which product lines to promote, adjust, or reduce.

## How to use this Project
1. Import the dataset into PostgreSQL
2. Run the scripts in ```sql code``` to create the schema and dimensions
3. Open the Power BI file (```superstore_sales_dashboard.pbix```) and connect the database
4. Refresh the data model

