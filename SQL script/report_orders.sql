CREATE VIEW report_orders AS
SELECT
  f.order_number,
  f.order_date,
  f.customer_key,
  CONCAT(c.first_name , ' ' , c.last_name ) as customer_name ,
  f.product_key,
  p.product_name,
  f.sales_amount,
  f.quantity
FROM [gold.fact_sales] f
LEFT JOIN [gold.dim_customers] c ON f.customer_key = c.customer_key
LEFT JOIN [gold.dim_products] p ON f.product_key = p.product_key