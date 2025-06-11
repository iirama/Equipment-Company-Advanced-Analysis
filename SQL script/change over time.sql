/*=========================================================
-------------------change over time------------------------
===========================================================*/

--1)change over year 
select 
year(order_date) as order_year,
sum(sales_amount)  as total_sales,
count(DISTINCT customer_key) as total_customers,
sum(quantity) as total_quntity
from [gold.fact_sales]
where order_date is not null
group by year(order_date)
order by year(order_date)

--2) change over month 
select 
month(order_date) as order_year,
sum(sales_amount)  as total_sales,
count(DISTINCT customer_key) as total_customers,
sum(quantity) as total_quntity
from [gold.fact_sales]
where order_date is not null
group by month(order_date)
order by month(order_date)

--3) change over months in each year
select 
datetrunc (month , order_date) as order_date ,
sum(sales_amount)  as total_sales,
count(DISTINCT customer_key) as total_customers,
sum(quantity) as total_quntity
from [gold.fact_sales]
where order_date is not null
group by  datetrunc (month , order_date)
order by datetrunc (month , order_date)