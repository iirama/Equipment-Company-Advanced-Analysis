
-- build customer report
/*
=================================================================================
Customer Report
=================================================================================
purpose:
	- This report consolidtion key customer metrics and behavor

Highlight:
	1. Gathers essentail fields such name , ages , and transction details.
	2.segments customer into categories (vip , regular , new) and age group.
	3. Aggregation customer-level metrics:
		-total orders
		-total sales
		-total quantity purchaed
		-total product 
		-lifespan(in month)
	4. calculate valuable KPIs:
		-recency (months since last order)
		-average order value
		-average monthly spend
=================================================================================
*/

CREATE VIEW report_customers AS
with base_query as (
/*-------------------------------------------------------------------------------
1) Base Query: retrieves core columns from tables
--------------------------------------------------------------------------------*/
select 
f.order_number ,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key, 
c.customer_number,
CONCAT(c.first_name ,' ' , c.last_name) as Customer_name,
datediff(year , c.birthdate , GETDATE()) as age
from [gold.fact_sales] f
left join [gold.dim_customers] c
on f.customer_key = c.customer_key
where order_date is not null
)
, customer_Aggergation  as (
/*-------------------------------------------------------------------------------
2) customer Aggergation: Summarizes key metrics at the customer level
--------------------------------------------------------------------------------*/
select  
customer_key, 
customer_number,
Customer_name,
age,
count(Distinct order_number)as Total_Order,
sum(sales_amount) as Total_Sales,
sum(quantity) as Total_Quantity,
COUNT(Distinct product_key) as Total_Product,
max(order_date) as Last_Order,
Datediff(month , min(order_date) , max(order_date)) as Lifespan
from base_query
group by customer_key, 
		 customer_number,
		 Customer_name,
		 age
)
/* -----------------------------------------------------------------------------
3)  Final Query: comines all customer results into one outpot
-------------------------------------------------------------------------------*/
select 
customer_key, 
customer_number,
Customer_name,
age,
case when age < 20 then 'Under 20'
	 when age between 20 and 29 then '20-29'
	 when age between 30 and 39 then '30-39'
	 when age between 40 and 49 then '40-49'
	 else '50 and above'
end  age_group,
case when Lifespan >= 12 and Total_Sales > 5000 then 'VIP'
	 when Lifespan >= 12 and Total_Sales<= 5000 then 'Regular'
	 else 'New'
end as customer_segment ,
Last_Order,
datediff(month , Last_Order , GETDATE()) as  recency,
Total_Order,
Total_Sales,
Total_Quantity,
Total_Product,
Lifespan,
-- compuate average order value(AVO)
case when Total_Order =0 then 0 
	 else Total_Sales / Total_Order 
end  as ave_order_value,
--compuate avaerage monthly spend
case when Lifespan = 0 then Total_Sales
	 else Total_Sales / Lifespan
end as avg_monthly_spend
from customer_Aggergation
