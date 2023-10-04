use DataProject;

create table Sales 
(
order_number varchar(255),
quantity_ordered int,
price_each double,
order_line_number int,
sales double,
order_date date,
status varchar(255),
QTR_ID varchar(255),
MONTH_ID varchar(255),
YEAR_ID varchar(255),
product_line varchar(255),
MSRP int,
product_code varchar(255),
customer_name varchar(255),
phone varchar(255),
address_line1 varchar(255),
address_line2 varchar(255),
city varchar(255),
state varchar(255),
postal_code varchar(255),
country varchar(255),
territory varchar(255),
contact_last_name varchar(255),
contact_first_name varchar(255),
deal_size varchar(255));

select * from Sales;

SHOW VARIABLES LIKE "local_infile";

set global local_infile = 1;

load data local infile '/Users/ivanazhao/Desktop/Sales Data Analysis/sales_data_sample.csv'
into table Sales
fields terminated by ','
ignore 1 rows;

select count(*) from Sales;

select * from Sales limit 20;

truncate Sales;
# If find field matching, probably because there are ',' in csv cell text, try to replace ',' with '.'
# If date shows '00000', change date format in csv into 'custom - yyyy/mm/dd hh:mm:ss'


