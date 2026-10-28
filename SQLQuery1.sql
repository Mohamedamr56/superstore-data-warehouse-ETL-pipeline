--#QUERY 1 Rank customers based on their total sales

select c.customer_name, c.customer_id,sum(f.sales) as TOTAL_SALES,
rank() over( order by SUM(f.sales) DESC )AS SALES_RANK
from dim_customer c
join fact_table f
  ON C.CUSTOMER_KEY=F.CUSTOMER_KEY
GROUP BY c.customer_name, c.customer_id


--# query 2 For each Category, find the product with the highest total sales

WITH product_rank AS( select p.product_id, p.product_name ,p.category , sum(f.sales) as total_sales ,ROW_NUMBER() over(partition by category order by sum(f.sales) desc) as PRODUCT_RANK
from dim_product p
join fact_table f
  on p.product_key = f.product_key
  group by  p.product_id,p.product_name,p.category)
  SELECT*
  FROM product_rank PR
  where PR.PRODUCT_RANK = 1

 -- #QUERY 3 Products with total sales higher than the average individual sale
    
select p.product_name,p.product_id,avg(f.sales) AS average_sales
     from dim_product p
  join fact_table f
     on  p.product_key = f.product_key
     group by p.product_name,p.product_id
     having sum(f.sales) > (  select avg(f2.sales) as average_sales
  from fact_table f2) 

  --#query 4 High-Value Customers by Sales

  select c.customer_name, c.customer_id , sum(f.sales) as total_sales
  FROM dim_customer c
  join fact_table f
    on c.customer_key = f.customer_key
  group by c.customer_name, c.customer_id
  having sum(f.sales) > 7000
  order by total_sales desc

  --#query 5 Categories with Total Profit Above 10000

  select p.category,sum(f.profit) as total_profit ,sum(f.sales) as total_sales
  from dim_product p
  join fact_table f
    ON p.product_key = f.product_key
  group by p.category
  having sum(f.profit) > 10000
  order by total_profit desc

  --#QUERY 6 Total sales and profit by ship mode, Ranked by Sales

  select s.ship_mode
  ,sum(f.sales) AS total_sales
  ,sum(f.profit) AS total_profit
  from dim_ship_mode s
  join fact_table f
    ON s.ship_mode_key = f.ship_mode_key
    group by s.ship_mode
    order by total_sales desc
      
    --#QUERY 7 the top 3 customers in each customer segment based on total sales
 
with customer_rank as( SELECT c.customer_name
,sum(f.sales) as total_sales, c.segment
, RANK() OVER( PARTITION BY segment order by sum(f.sales) desc) AS customer_rank
  from dim_customer c
  join fact_table f
    on c.customer_key = f.customer_key
    group by  c.customer_name , c.segment)

    select*
    from customer_rank c
    where customer_rank<=3
    ORDER BY segment, customer_rank 

   --#Query8 Categories with Sales Above Average

SELECT 
    p.category,
    SUM(f.sales) AS total_sales,
    SUM(f.profit) AS total_profit,
    AVG(f.discount) AS average_discount
FROM dim_product p
JOIN fact_table f
    ON p.product_key = f.product_key
GROUP BY p.category
HAVING SUM(f.sales) >
(
    SELECT AVG(category_sales)
    FROM
    (
        SELECT SUM(f2.sales) AS category_sales
        FROM dim_product p2
        JOIN fact_table f2
            ON p2.product_key = f2.product_key
        GROUP BY p2.category
    ) AS category_totals
)
ORDER BY total_sales DESC;

    --#Query 9 CREATE VIEW This view summarizes sales performance by category and sub-category including total orders, total sales, and total profit.
    GO 
    CREATE VIEW VW_Category_Performancce AS 
    SELECT p.category,p.sub_category ,count(distinct f.order_id) as total_orders,sum(f.sales) as total_sales,sum(f.profit) AS total_profit
    from dim_product p
    join fact_table f
    on p.product_key = f.product_key
    group by p.category,p.sub_category

    --#query10 Most Profitable Sub-category per Category

    with rank_category as (select v.sub_category,v.category,total_profit
    ,ROW_NUMBER() over(partition by v.category
    order by v.total_profit desc) as top_profit_for_each_category
    from dbo.VW_Category_Performancce v)
   
    SELECT category, sub_category, total_profit
FROM rank_category
    where top_profit_for_each_category =1

--qury 11 create stored procedures This stored procedure calculates key performance indicators (KPIs) for a specific customer

CREATE PROCEDURE dbo.Get_Customer_KPIS @CustomerID VARCHAR(20)AS BEGIN
    SELECT c.customer_id, c.customer_name, COUNT(DISTINCT f.order_id) AS total_orders,
 SUM(f.sales) AS total_sales,
  SUM(f.profit) AS total_profit, SUM(f.quantity) AS total_quantity,

        CASE
            WHEN SUM(f.sales) >= 5000 THEN 'High Value'
            WHEN SUM(f.sales) >= 2000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS customer_value,

        SUM(f.profit) * 100.0 / NULLIF(SUM(f.sales), 0) AS profit_margin
    FROM fact_table f
    JOIN dim_customer c
        ON f.customer_key = c.customer_key
    WHERE c.customer_id = @CustomerID
    GROUP BY
        c.customer_id,
        c.customer_name;
END;


 --#query 12 calculate total sales, and rank state based on total sales for each state

 select l.state,sum(f.sales) as total_sales
 ,rank() over( order by sum(f.sales) desc) as state_rank
, CASE
 when sum(sales)>= 50000 then 'high_sales'
 when sum(sales)>= 10000 then 'medium_sales'
 else 'low_sales'
 end as sales_category
 from dim_location l
 join fact_table f
 on f.location_key = l.location_key
 group by l.state

--#query13 total sales and profit for each year and month, and compare sales between months.

 select d.year,d.month,d.quarter,sum(f.sales) as total_sales
from dim_date d
join fact_table f
ON d.date_key = f.order_date_key
group by d.year,d.month,d.quarter
order by d.year,d.month

--#query14 Sales Trend by Year

select d.year,sum(f.sales) as total_sales,lag(sum(f.sales)) over(order by year) as previous_year
from dim_date d
join fact_table f
ON f.order_date_key = d.date_key
group by d.year

-- #Q15 Top 5 Products by Quantity Sold

SELECT TOP 5 p.product_id, p.product_name, SUM(f.quantity) AS total_quantity
FROM dim_product p
JOIN fact_table f
  ON p.product_key = f.product_key
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity DESC

--#query16 Discount Impact on Profit

SELECT
    CASE
        WHEN f.discount = 0 THEN 'No Discount'
        WHEN f.discount <= 0.20 THEN 'Low Discount'
        WHEN f.discount <= 0.50 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_level,
    SUM(f.sales) AS total_sales,
    SUM(f.profit) AS total_profit,
    AVG(f.discount) AS average_discount
FROM fact_table f
GROUP BY
    CASE
        WHEN f.discount = 0 THEN 'No Discount'
        WHEN f.discount <= 0.20 THEN 'Low Discount'
        WHEN f.discount <= 0.50 THEN 'Medium Discount'
        ELSE 'High Discount'
        END
ORDER BY total_profit DESC;

--#query17 Repeat Customers

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT f.order_id) AS total_orders,
    SUM(f.sales) AS total_sales
FROM dim_customer c
JOIN fact_table f
    ON c.customer_key = f.customer_key
GROUP BY
    c.customer_id,
    c.customer_name
HAVING COUNT(DISTINCT f.order_id) > 1
ORDER BY total_orders DESC














     