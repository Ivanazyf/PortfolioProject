Use DataProject;

select * from Sales limit 10;

-- Checking unique values, can be plotted
select distinct status from Sales;
select distinct YEAR_ID from Sales;
select distinct product_line from Sales;
select distinct country from Sales;
select distinct deal_size from Sales;
select distinct territory from Sales;

SELECT distinct MONTH_ID from Sales
where YEAR_ID = 2005;

-- ANALYSIS

-- Group sales by product_line
select product_line, sum(sales) as revenue
from Sales
group by 1
order by 2 asc;

select YEAR_ID, sum(sales) as revenue
from Sales
group by 1
order by 2 asc;

select deal_size, sum(sales) as revenue
from Sales
group by 1
order by 2 asc;

-- What was the best month for sales in a specific year? How much was earned that month?
select MONTH_ID, sum(sales) as revenue, count(order_number) as frequency
from Sales
where YEAR_ID = 2004  -- change year to see the rest
group by 1
order by 2 desc;

-- November seems to be the month with highest sales, so what product do they sell in November?
select MONTH_ID, product_line, sum(sales) as revenue, count(order_number) as frequency
from Sales
where YEAR_ID = 2004 and MONTH_ID = 11 -- change year to see the rest
group by  2
order by 3 desc;

-- Who is our best customer
# FRM Analysis
# Recency - Frequency - Monetary (RFM)
# It is an indexing technique that uses past purchase behavior to segment customers
## Recency - last order date
## Frequency - count of total orders
## Monetary value - total spend

with rfm as ( 
select 
     customer_name,
     sum(sales) as MonetaryValue,
     avg(sales) as AvgMonetaryValue,
     count(order_number) as frequency,
     max(order_date) as last_order_date,
     (select max(order_date) from Sales) as max_order_date,
     DATEDIFF((select max(order_date) from Sales), max(order_date)) as recency
from Sales
group by customer_name),

rfm_cal as (
select *,
    NTILE(4) over (order by MonetaryValue) rfm_monetary,
    NTILE(4) over (order by frequency) rfm_frequency,
    NTILE(4) over (order by recency desc) rfm_recency
from rfm),     # value higher, group number higher, except recency

rfm_table as (
	select *, (rfm_monetary + rfm_frequency + rfm_recency) as rfm_cell,
	concat(cast(rfm_monetary as Nchar), CAST(rfm_frequency as Nchar), cast(rfm_recency as Nchar)) as rfm_cell_string
	from rfm_cal)

select customer_name , rfm_recency, rfm_frequency, rfm_monetary, rfm_cell_string,
	case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  -- lost customers
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_cell_string in (311, 411, 331) then 'new customers'
		when rfm_cell_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432) then 'active' -- (Customers who buy often & recently, but at low price points)
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal'
	end rfm_segment
from rfm_table;

-- What products are most often sold together?
select order_number from
	(select order_number, count(*) rn
	from Sales
	where status = 'Shipped'
	group by order_number) t
where rn = 2;




