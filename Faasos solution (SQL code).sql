use faasos;

-- Data Cleaning
-- Cleaning driver_order

update driver_order
set distance = replace(distance, 'km', '');

alter table driver_order
change column distance distance_km decimal(6,2);

update driver_order
set duration = replace(trim(lower(duration)), 'minutes', '');

update driver_order
set duration = replace(trim(lower(duration)), 'minute', '');

update driver_order
set duration = replace(trim(lower(duration)), 'mins', '');

alter table driver_order
change column duration duration_mins int;

/* # Question segment

A. Roll Metrics
B. Driver and Customer Experience */

-- A. Roll Metrics

-- Qus 1: How many orders were made?
select count(roll_id) as 'Total Orders'
from customer_orders;

-- Qus 2: How many unique customer orders were made?
select count(distinct(customer_id)) as 'Unique orders'
from customer_orders;

-- Qus 3: How many successful orders were made by each driver?
select driver_id, count(order_id) as Orders
from driver_order
WHERE cancellation NOT IN ('Cancellation', 'Customer Cancellation')
GROUP BY driver_id;

-- Qus 4: How many of each roll type were delivered?
select a.roll_id, count(a.roll_id) as Orders
from customer_orders a
inner join driver_order b on a.order_id = b.order_id
where b.cancellation IS NULL OR b.cancellation = 'Nan' OR cancellation = ''
group by a.roll_id;

-- Another way of solving this question:

select roll_id, count(roll_id) as Orders
from customer_orders
where order_id in(
					select c.order_id from (select order_id, case when cancellation is null or cancellation ='NaN' or cancellation = '' then 'nc' else 'c' end as order_status
											from driver_order) c
					where c.order_status = 'nc')
group by roll_id;

-- Qus 5: How many Veg and Non-Veg rolls were ordered by each customer?
select a.*, b.roll_name from
(select customer_id, roll_id, count(roll_id) as Orders
from customer_orders
group by customer_id, roll_id) a
inner join rolls b on a.roll_id = b.roll_id;

-- Qus 6: What's the maximum number of rolls were delivered in a single order?
select d.order_id, max(d.rolls) as max_rolls from
(select order_id, count(roll_id) as rolls
from customer_orders
where order_id in (select c.order_id from 
					(select order_id, case when cancellation is null or cancellation ='NaN' or cancellation = '' then 'nc' else 'c' end as order_status
						from driver_order) c where c.order_status = 'nc')
group by order_id) d
group by d.order_id
order by max_rolls desc
limit 1;

-- Another way of solving the question:
select c.order_id, max(c.rolls) as max_rolls from 
(select a.order_id, count(a.roll_id) as rolls
from customer_orders a
inner join driver_order b on a.order_id = b.order_id
where b.cancellation is null or b.cancellation = 'NaN' or b.cancellation = ''
group by a.order_id) c
group by c.order_id
order by max_rolls desc
limit 1;


-- Qus 7: For each customer, how many rolls had atleast 1 change and how many had no changes?

with temp_customer_orders(order_id, customer_id, roll_id, new_not_include_items, new_extra_items_included, order_date) as
(select order_id, customer_id, roll_id, case when not_include_items is null or not_include_items = '' then 0 else not_include_items end as new_not_include_items,
case when extra_items_included is null or extra_items_included = 'NaN' or extra_items_included = '' then 0 else extra_items_included end as new_not_include_items, order_date
from customer_orders),
temp_driver_order(order_id, driver_id, pickup_time, distance_km, duration_mins, new_cancellation) as
(select order_id, driver_id, pickup_time, distance_km, duration_mins, case when cancellation is null or cancellation = 'NaN' or cancellation='' then 'nc' else 'c' end as new_cancellation
from driver_order)

select a.customer_id, change_or_nochange, count(a.roll_id) as Orders from 
(select a.*, case when a.new_not_include_items = 0 and a.new_extra_items_included = 0 then 'no change' else 'change' end as change_or_nochange
from temp_customer_orders a
inner join temp_driver_order b on a.order_id = b.order_id
where b.new_cancellation = 'nc') a
group by a.customer_id, change_or_nochange
order by change_or_nochange;

-- Qus 8: How many rolls were delivered that had both exclusions and extras?

with temp_customer_orders(order_id, customer_id, roll_id, new_not_include_items, new_extra_items_included, order_date) as
(select order_id, customer_id, roll_id, case when not_include_items is null or not_include_items = '' then 0 else not_include_items end as new_not_include_items,
case when extra_items_included is null or extra_items_included = 'NaN' or extra_items_included = '' then 0 else extra_items_included end as new_not_include_items, order_date
from customer_orders),
temp_driver_order(order_id, driver_id, pickup_time, distance_km, duration_mins, new_cancellation) as
(select order_id, driver_id, pickup_time, distance_km, duration_mins, case when cancellation is null or cancellation = 'NaN' or cancellation='' then 'nc' else 'c' end as new_cancellation
from driver_order)

select a.included_excluded, count(a.included_excluded) as Rolls from 
(select a.*, case when a.new_not_include_items != 0 and a.new_extra_items_included != 0 then 'both included excluded' else 'either included or excluded' end as included_excluded
from temp_customer_orders a
inner join temp_driver_order b on a.order_id = b.order_id
where b.new_cancellation = 'nc') a
group by included_excluded
order by Rolls;

-- Qus 9: How many rolls were ordered for each hour of the day?
select concat(hour(order_date) , '-', hour(order_date) +1) as Hour, count(order_id) as Orders
from customer_orders
group by Hour
order by Hour;

-- Qus 10: How many orders were made for each day of the week?

select case when a.Day_of_week = 1 then 'Monday'
			when a.Day_of_week = 2 then 'Tuesday'
            when a.Day_of_week = 3 then 'Wednesday'
            when a.Day_of_week = 4 then 'Thursday'
            when a.Day_of_week = 5 then 'Friday'
            when a.Day_of_week = 6 then 'Saturday'
            when a.Day_of_week = 7 then 'Sunday'
            end as Day_of_week,
            Orders from 
(select dayofweek(order_date) as Day_of_week, count(distinct(order_id)) as Orders
from customer_orders
group by Day_of_week) a
order by Orders desc;


-- B. Driver and Customer Experience

-- Qus 1: What was the average time in minutes it took for each driver to arrive at the HQ to pickup the order?

select e.driver_id, avg(time_diff_minute) as Avg_time_diff_minute from 
(select d.* from
(select c.*, row_number() over(partition by c.order_id order by c.time_diff_minute) as rnk from
(select a.*, b.driver_id, b.pickup_time, b.distance_km, b.duration_mins, b.cancellation, timestampdiff(minute, a.order_date, b.pickup_time) as time_diff_minute
from customer_orders a 
inner join driver_order b on a.order_id = b.order_id
where b.pickup_time is not null) c) d
where d.rnk = 1) e
group by e.driver_id;


-- Qus 2: Is there a relationship between the number of rolls and how long the order takes to prepare?

select c.order_id, count(c.roll_id) as Rolls, avg(c.time_diff_minute) as Avg_time_diff_minute from
(select a.*, b.driver_id, b.pickup_time, b.distance_km, b.duration_mins, b.cancellation, timestampdiff(minute, a.order_date, b.pickup_time) as time_diff_minute
from customer_orders a 
inner join driver_order b on a.order_id = b.order_id
where b.pickup_time is not null) c
group by c.order_id; 

-- Qus 3: What is the average distance travelled for each custoemer?

select c.customer_id, avg(distance_km) as Avg_distance from 
(select a.*, b.distance_km
from customer_orders a
inner join driver_order b on a.order_id = b.order_id
where b.cancellation is null or b.cancellation = 'NaN' or b.cancellation = '')c
group by c.customer_id;

-- Qus 4: What is the difference between longest and shortest delivery time of all orders?
select max(duration_mins) as max_duration, min(duration_mins) as min_duration, (max(duration_mins) - min(duration_mins)) as time_diff
from driver_order
where duration_mins is not null;

-- Qus 5: What is the average speed of each driver for each delivery and do you notice any trend for these values?
-- Formula to calculate Speed: Distance/Time -------- equation (1)

select a.order_id, b.driver_id, (b.distance_km/b.duration_mins) as Speed,  count(a.roll_id) as Count
from customer_orders a
inner join driver_order b on a.order_id = b.order_id
where b.distance_km is not null
group by a.order_id, b.driver_id, Speed;

-- Qus 6: What is the successful delivery percentage of each driver?
-- Formula to calculate successful delivery percentage: Total successful orders/Total orders taken ----------- equation(1)

select d.driver_id, (d.succ_deliveries/d.total_orders)*100 as successful_delivery_per from
(select a.driver_id, count(a.driver_id) as total_orders, sum(a.new_cancellation) as succ_deliveries from
(select driver_id, case when lower(cancellation) like '%cancel%' then 0 else 1 end as new_cancellation from driver_order) a
group by a.driver_id) d;

