-- build product report
/*
=================================================================================
------------------------------- Product Report ----------------------------------
=================================================================================
purpose:
	- This report consolidates key product metrics and behaviors

Highlight:
	1. Gathers essentail fields such product name , category , subcategory , and cost.
	2.segments product by revenue to identify High-performance , Mid-Range , or Low-performane.
	3. Aggregation product-level metrics:
		-total orders
		-total sales
		-total quanitiy sold
		-total customer (unique) 
		-lifespan(in month)
	4. calculate valuable KPIs:
		-recency (months since last sales)
		-average order revenue (AOR)
		-average monthly revenue
=================================================================================
*/
create view report_product as
with base_query as(
/* -----------------------------------------------------------------------------
1) base Query: rerives core coulmn from fact sales and dim product
-------------------------------------------------------------------------------*/
select 
f.order_number,
f.order_date,
f.customer_key,
f.sales_amount,
f.quantity,
p.product_key,
p.product_name,
p.category ,
p.subcategory , 
p.cost
from [gold.fact_sales] f
left join [gold.dim_products] p
on f.product_key = p.product_key
where order_date is not null
),
product_aggregation as(
/* -----------------------------------------------------------------------------
2) product aggregation: summries key metrics at the product level
-------------------------------------------------------------------------------*/
select 
product_key,
product_name,
category,
subcategory,
cost,
Datediff(month , min(order_date) , max(order_date)) as Lifespan,
max(order_date) as last_sale_date,
count(DISTINCT order_number) as total_order,
count(DISTINCT customer_key) as total_customers,
sum(sales_amount) as total_sales,
sum(quantity) as total_quntaty,
round (AVG(cast(sales_amount as float) / nullif(quantity , 0)) ,0) as avg_selling_price
from base_query
group by  product_key,
product_name,
category,
subcategory,
cost)
/* -----------------------------------------------------------------------------
3)  Final Query: comines all product results into one outpot
-------------------------------------------------------------------------------*/
select 
product_key,
product_name,
category,
subcategory,
cost, 
last_sale_date,
DATEDIFF(MONTH , last_sale_date , GETDATE()) as recency_in_months,
case when total_sales > 50000 then 'High-performer'
	 when total_sales >= 10000 then 'Mid-Performer'
	 else 'Low-Performer'
end as product_segment,
Lifespan,
total_order,
total_sales,
total_quntaty,
total_customers,
avg_selling_price,
-- Average Order Revenue (AOR)
case when total_order = 0 then 0
	 else total_sales / total_order
end as avg_order_revenue,
--Average monthly revenue
case when Lifespan = 0 then total_sales
	 else total_sales / Lifespan
end as avg_monthly_revenue
from product_aggregation