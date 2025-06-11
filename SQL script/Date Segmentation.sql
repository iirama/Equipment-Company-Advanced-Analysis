/*
=========================================================================================
---------------------------------- Date Segmentation ------------------------------------
=========================================================================================
*/
--1. segment product into cost ranges and count how many products fall into each seqment
with product_segment as (
select 
product_key , product_name , cost,
case when cost < 100 then 'Below 100'
	 when cost between 100 and 500 then '100-500'
	 when cost between 500 and 1000 then '500- 1000'
	 else 'Above 1000'
end cost_range
from [gold.dim_products]
)
select cost_range , 
count(product_key) as total_product 
from product_segment
group by cost_range 
order by total_product DESC
--2. Group customers based into three segments based on thier spending behavor:
-- vip  , regular , new
-- then find total number if customer by each group 

with customer_spending as (
select 
c.customer_key , 
sum(f.sales_amount) as total_spending , 
min (order_date) as first_order , 
max(order_date) as last_order,
datediff(month , min(order_date) , max(order_date)) as lifesapin
from [gold.fact_sales] f 
left join [gold.dim_customers] c 
on f.customer_key = c.customer_key
group by c.customer_key
)
select customer_segment,count(customer_key)as total_customer
from(
select 
customer_key,
case when lifesapin >= 12 and total_spending > 5000 then 'VIP'
	 when  lifesapin >= 12 and total_spending<= 5000 then 'Regular'
	 else 'New'
end customer_segment
from customer_spending
) t 
group by customer_segment
order by total_customer desc