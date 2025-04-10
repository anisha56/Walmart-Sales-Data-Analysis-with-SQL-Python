CREATE DATABASE walmart_db;
use walmart_db;
select *
from walmart
limit 10;

# 1. Find distinct payment type
select 
	payment_method, count(*)
from walmart
group by payment_method;

# 2. count distinct branch
select count(distinct branch)
from walmart;

-- Business Problem
-- Q.1 Find different payment method, for each method find number of transaction and number of qty sold
select payment_method, count(invoice_id) as no_payments, sum(quantity) as qty_sold
from walmart
group by payment_method
order by qty_sold desc;

-- Q.2 Identify the highest average rating category in each branch, display the branch, category avg rating
select branch, category, avg_rating
from
	(select branch, category, round(avg(rating),2) as avg_rating, 
		dense_rank() over (partition by branch order by round(avg(rating),2) desc) as ranking 
	from walmart
    group by branch, category) as temp
where ranking =1;

-- Q.3 Identify the busiest day for each branch based on the number of transaction
select branch, day, count_transaction
from 
	(select branch, dayname(date) as day, count(*) as count_transaction,
	dense_rank() over (partition by branch order by count(*) desc) as ranking
	from walmart
	group by branch, day) as temp
where ranking = 1;

-- Q.4 Calculate total qty of items sold per payment method. List payment_method and total_quantity

select payment_method, sum(quantity) as total_quantity
from walmart
group by payment_method
order by total_quantity desc;

 -- Q.5  What are the average, minimum, and maximum ratings for each category in each city?
 select city, category, round(avg(rating), 2) as avg_rating, min(rating) as min_rating, max(rating) as max_rating
 from walmart 
 group by city, category;
 
 -- Q.6  What is the total profit for each category, by considering total_profit as (unit_price * qty * profit_margin)
 -- List category and total_profit ordered from from highest to lowest profit?
 
 select category, sum(total) as total_revenue ,round(sum(total * profit_margin), 2) as total_profit
 from walmart 
 group by category
 order by total_profit desc;
 
 -- Q.7  What is the most common used payment method in each branch. Display branch and the preferred_payment_method
 select branch, payment_method 
 from
	 (select branch, payment_method, count(payment_method) as count_pay,
	 dense_rank() over (partition by branch order by count(payment_method) desc) as common_payment_method
	 from walmart 
	 group by branch, payment_method) as temp
 where common_payment_method = 1;
 
 -- CTE Method
 With common_payment_method As (
	select branch, payment_method, count(payment_method) as count_pay,
	 dense_rank() over (partition by branch order by count(payment_method) desc) as payment_method_rank
	 from walmart 
	 group by branch, payment_method
     ) 
 
 select branch, payment_method 
 from common_payment_method
 where payment_method_rank = 1;
 
 -- Q.8 Categorize sales into 3 groups Morning, Afternoon, Evening. Find out each of the shift and number of invoices
 select
 Case 
	when hour(time) < 12 then 'Morning'
    when hour(time) between 12 and  17 then 'Afternoon'
    else 'Evening' end as Shift,
    count(invoice_id) as invoice_count
from walmart
group by Shift
order by invoice_count desc;

-- Q.9 Identify 5 branch with highest decrease ratio in revenue compare to last year (current year 2023 and last year 2022)

with revenue_2022 
As (
	select branch, sum(total) as revenue
	from walmart 
	where year(STR_TO_DATE(date, '%d/%m/%Y')) = '2022'
	group by branch
	),

revenue_2023 
As (
	select branch, sum(total) as revenue
	from walmart 
	where year(STR_TO_DATE(date, '%d/%m/%Y')) = '2023'
	group by branch
    )

select r_2022.branch, r_2022.revenue as last_year_revenue, r_2023.revenue as current_year_revenue,
round((r_2022.revenue - r_2023.revenue)/r_2022.revenue * 100,2) as rev_dec_ratio
from revenue_2022 r_2022
join revenue_2023 r_2023 on r_2022.branch = r_2023.branch
where r_2022.revenue > r_2023.revenue
order by rev_dec_ratio desc
limit 5;



    
 
 
 
 





