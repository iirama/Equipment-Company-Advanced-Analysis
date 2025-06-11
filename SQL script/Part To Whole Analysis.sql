/*
=========================================================================================
-------------------------------- Part To Whole Analysis ---------------------------------
=========================================================================================
*/
--1. which categories contribute the most to overall sales
with category_sales as (
select 
category ,
sum (sales_amount) as total_sales
from [gold.fact_sales] f
left join [gold.dim_products] p
on f.product_key = p.product_key
group by category
) 
select category , total_sales,
sum (total_sales) over ()overall_sales,
concat (round ((cast(total_sales as float) / sum (total_sales) over ()) * 100 , 2) , '%')  as percentage_of_total
from category_sales
order by total_sales DESC