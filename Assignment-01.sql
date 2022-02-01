-- Name of the Database
use property;

-- Creating a table with below attributes
create table airbnb_calendar(
	listing_id int,
    curr_date date,
    available varchar(1),
    price text
);

-- Loading data from the CSV file
load data local infile '/Users/shashankdey/Downloads/airbnb_calendar.csv'
into table airbnb_calendar
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(listing_id,curr_date,available,price);

-- Removing commas from the column price
update airbnb_calendar set price = replace(price,',','');

-- Creating a column to store the price in float
alter table airbnb_calendar add column float_price float; 

-- Converting text to float
update airbnb_calendar set float_price = right(price, length(price)-1)
where length(price)>1;

/*=====================================Q1======================================*/ 
select min(curr_date) as "Start Date", max(curr_date) as "End Date", datediff(max(curr_date) + 1, min(curr_date)) as "Duration (in Days)"
from airbnb_calendar;

/*=====================================Q2======================================*/ 
With airbnbCTE as
(
	select *, row_number() over(partition by listing_id, curr_date, available order by listing_id) as RowNumber
    from airbnb_calendar
)
delete from airbnbCTE where RowNumber > 1;

/*=====================================Q3======================================*/ 
select listing_id, count(case when available = 't' then 1 end) as "Available Days",
count(case when available = 'f' then 1 end) as "Unavailable Days", 
count(case when available = 't' then 1 end)/count(*) as "Available fraction of Total Days"
from airbnb_calendar group by listing_id;

/*=====================================Q4======================================*/ 
select count(*) as "Above 50 percent" from
(select listing_id, (count(case when available ='t' then 1 end)/count(*)) as fraction
from airbnb_calendar group by listing_id) as new where fraction > 0.5;

select count(*) as "Above 75 percent" from
(select listing_id, (count(case when available ='t' then 1 end)/count(*)) as fraction
from airbnb_calendar group by listing_id) as new where fraction > 0.75;

/*=====================================Q5======================================*/ 
select listing_id, max(float_price) as "Max Price", min(float_price) as "Min Price", 
avg(float_price) as "Average Price" from airbnb_calendar group by listing_id;

/*=====================================Q6======================================*/ 
select listing_id, new_price from
(select listing_id, avg(float_price) as "new_price" from airbnb_calendar group by listing_id) 
as new where new_price > 500;


