/*
=========================================================================================
-------------------------------- performance Analysis ---------------------------------
=========================================================================================
*/


/*analyze the yearly performance of product by comparing thier sales to 
both the average sales performance of product and previous year sales */
WITH yearly_product_name as (
select
year(f.order_date) as order_year,
p.product_name,
sum(f.sales_amount) as current_sales
from [gold.fact_sales] f 
left join [gold.dim_products] p
on f.product_key = p.product_key
where order_date is not null
group by  year(f.order_date) , p.product_name
)
select 
order_year , 
product_name,
current_sales,
avg(current_sales) over(partition by product_name) as avg_sales,
current_sales - avg(current_sales) over(partition by product_name) as diff_avg,
case when current_sales - avg(current_sales) over(partition by product_name) > 0 then 'Above Avg'
	when  current_sales - avg(current_sales) over(partition by product_name) < 0 then 'Below Avg'
	else 'Avg'
end avg_change,
LAG(current_sales) over (partition by product_name  order by order_year ) as py_sales , 
current_sales  - LAG(current_sales) over (partition by product_name  order by order_year ) as diff_py,
case when current_sales  - LAG(current_sales) over (partition by product_name  order by order_year ) > 0 then 'Increase'
	when  current_sales  - LAG(current_sales) over (partition by product_name  order by order_year ) < 0 then 'Decrease'
	else 'No Change'
end py_change
from yearly_product_name
order by 2,1

