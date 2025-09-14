
Create table foodpanda_analysis(
	customer_id INT PRIMARY KEY,
	gender TEXT,
	age	TEXT,
	city TEXT,
	signup_date	DATE,
	order_id INT,
	order_date	DATE,
	restaurant_name	TEXT,
	dish_name TEXT,
	category TEXT,
	quantity INT,
	price INT,
	payment_method TEXT,
	order_frequency INT,
	last_order_date DATE,
	loyalty_points INT,
	churned TEXT,
	rating INT,
	rating_date DATE,
	delivery_status TEXT
);
--- Total Orders per Customer 
Select Customer_id, 
	COUNT(order_id) AS total_orders 
FROM foodpanda_analysis 
Group By customer_id;
--- Total Revenue per City
SELECT city, sum(price) AS total_revenue
FROM foodpanda_analysis
Group By city;
Select dish_name, AVG(rating) AS avg_rating 
From foodpanda_analysis
Where rating is not null
Group by Dish_name;

--Order by Payment
Select payment_method, Count(order_id) AS total_order 
from foodpanda_analysis 
Group By payment_method;
--Top three cities by order volume
Select city, Count(order_id) As order_count
from foodpanda_analysis
Group By city 
Order By order_count DESC 
limit 3;

Select* from foodpanda_analysis;

--Dish Pupularity By CAtegory
Select category, dish_name, sum(quantity) AS total_quantity
From foodpanda_analysis 
Group By dish_name, category
Order By category, total_quantity DESC;
--Churned Customer with High Loyalty Points
Select customer_id, churned , loyalty_points, last_order_date
From foodpanda_analysis
Where  loyalty_points > 400
Order BY loyalty_points DESC;

--Daily successful Orders by Restaurants
SELECT 
  customer_id,order_date,
  count(order_id) AS per_day
FROM foodpanda_analysis 
WHERE delivery_status = 'Delivered'
GROUP BY customer_id, order_date
ORDER BY order_date, per_day DESC;

SELECT 
  customer_id,
  COUNT(DISTINCT DATE(order_date)) AS active_days
FROM foodpanda_analysis 
WHERE delivery_status = 'Delivered'
  AND order_date >= DATE(last_order_date, '-7 days')
GROUP BY customer_id
HAVING COUNT(DISTINCT DATE(order_date)) > 1;

--revenue by restaurant
Select restaurant_name, sum(price) AS total_revenue
From foodpanda_analysis 
where delivery_status = 'Delivered'
Group BY restaurant_name 
Order By total_revenue;
-- customer life time value
select customer_id, sum(price) As lifetime_value,
Count(order_id) AS total_orders
from foodpanda_analysis 
where delivery_status = 'Delivered'
Group by customer_id 
Order By lifetime_value DESC;
--date wise revenue
Select  order_date ,count(*) AS count, sum(price) as perDay_revenue
from foodpanda_analysis
Group By  order_date
Having count(*)>=1
Order By perDay_revenue DESC;
--top 5 dishes by rating
Select dish_name, Round(AVG(rating), 2) AS top_rating_dish, count(*) As total_review
from foodpanda_analysis
Where rating is not null
Group by dish_name
Having count(*)>10
order by top_rating_dish desc;

--Delivery success rate by city
select city, count(CAse when delivery_status = 'Delivered' Then 1 ENd)*100.0/ count(*) as success_rate, delivery_status
from foodpanda_analysis 
Group By city 
order by success_rate desc;
--Avg Order Value by Payment Method
Select payment_method, Round(sum(price),2) As totalValue, count(order_id) AS Torder
from foodpanda_analysis 
Group By payment_method
Order By totalValue;
Select* from foodpanda_analysis;
--order frequency segments
SELECT 
  city,
  COUNT(CASE WHEN order_frequency >= 15 THEN 1 END) AS high_frequency,
  COUNT(CASE WHEN order_frequency BETWEEN 8 AND 14 THEN 1 END) AS medium_frequency,
  COUNT(CASE WHEN order_frequency < 8 THEN 1 END) AS low_frequency
FROM foodpanda_analysis
GROUP BY city;

Select strftime('%Y-%m-01', signup_date) As cohort_month,
Count(Distinct customer_id) AS new_signups,
Round(AVG(loyalty_points),2) AS avg_loyality_points 
From foodpanda_analysis 
Group By cohort_month 
order by cohort_month;
--window function e.g- ROW_NUMBER(), RANK(), DENSE_RANK(), LEAD(), LAG(), FIRST_VALUE(), LAST_VALUE(), SUM(), AVG()
select * from foodpanda_analysis fa ;	
---Rank Customers by loyalty Points
select customer_id, city, loyalty_points,
Rank() OVER (PARTITION BY city ORDER BY loyalty_points DESC) AS city_rank
from foodpanda_analysis;
Select count(*) As total_rows 
From foodpanda_analysis;
--Row Number of Each Order per Customer 
Select customer_id, order_id,
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) AS order_sequence
from foodpanda_analysis ;
--Running Total of Orders per City
SELECT city, order_date, count(order_id) OVER (PARTITION BY city ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
AS cumulative_orders
from foodpanda_analysis ;
---Average Rating per Dish (Repeated per Row)
SELECT 
  dish_name,
  rating,
  AVG(rating) OVER (PARTITION BY dish_name) AS avg_dish_rating
FROM foodpanda_analysis
WHERE rating IS NOT NULL;
--First and Last Order Date per Customer
SELECT 
  customer_id,
  order_date,
  FIRST_VALUE(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS first_order,
  LAST_VALUE(order_date) OVER (PARTITION BY customer_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_order
FROM foodpanda_analysis;


--Compare Current Order Value to Previous
SELECT 
  customer_id,
  order_id,
  quantity * price AS current_order_value,
  LAG(quantity * price) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_value
FROM foodpanda_analysis;

--Churn Risk Score Based on Order Gaps
SELECT 
  customer_id,
  order_date,
  LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_date,
  JULIANDAY(order_date) - JULIANDAY(LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)) AS days_since_last_order
FROM foodpanda_analysis;
--Cohort Loyalty Trend
SELECT 
  strftime('%Y-%m', signup_date) AS cohort_month,
  customer_id,
  loyalty_points,
  AVG(loyalty_points) OVER (PARTITION BY strftime('%Y-%m', signup_date)) AS avg_cohort_loyalty
FROM foodpanda_analysis;

--Top 3 Rated Restaurants per City

SELECT *
FROM (
  SELECT 
    city,
    restaurant_name,
    avg_rating,
    RANK() OVER (PARTITION BY city ORDER BY avg_rating DESC) AS city_rank
  FROM (
    SELECT 
      city,
      restaurant_name,
      AVG(rating) AS avg_rating
    FROM foodpanda_analysis
    WHERE rating IS NOT NULL
    GROUP BY city, restaurant_name
  )
)
WHERE city_rank <= 3;





