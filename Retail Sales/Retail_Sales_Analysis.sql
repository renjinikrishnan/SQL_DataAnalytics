
USE [retail_sales]
GO


--if OBJECT_ID('[SQL - RetailSalesAnalysis ]', 'U') is not null
--BEGIN 
--	DROP TABLE [SQL - RetailSalesAnalysis ]
--END


----Create the table

--create table [SQL - RetailSalesAnalysis ](

--	transactions_id	int primary key,
--	sale_date date,
--	sale_time time,  	
--	customer_id	int,
--	gender varchar(15),
--	age	int,
--	category varchar(25),	
--	quantiy	int,
--	price_per_unit float,
--	cogs float,	
--	total_sale float

--);

--Import data to the table above, use the csv file - SQL_RetailSalesAnalysis.csv


-------------------------------------------
--Data Cleaning
-------------------------------------------

select * from [SQL - RetailSalesAnalysis ]


--Total records in the table
select count(*) from [SQL - RetailSalesAnalysis ]


--Number of records with null in any column
select * from [SQL - RetailSalesAnalysis ]  
	where	transactions_id is null or
			sale_date is null or
			sale_time is null or
			customer_id is null or
			gender is null or
			age is null or
			category is null or
			quantiy is null or 
			price_per_unit is null or
			cogs is null or
			total_sale is null

--Delete Number of records with null in any column
delete from [SQL - RetailSalesAnalysis ] 
	where	transactions_id is null or
			sale_date is null or
			sale_time is null or
			customer_id is null or
			gender is null or
			age is null or
			category is null or
			quantiy is null or 
			price_per_unit is null or
			cogs is null or
			total_sale is null



-------------------------------------------
--Data Exploration
-------------------------------------------



--How many sales?
select count(*) from [SQL - RetailSalesAnalysis ]

--How many unique customers?
select count(distinct customer_id) customer_id from [SQL - RetailSalesAnalysis ]

--Total number of unique categories
select count(distinct category) [Total no:of category] from [SQL - RetailSalesAnalysis ]


--Number of customers who are female 
select count(*) as female_customers from [SQL - RetailSalesAnalysis ] 
where gender = 'Female'

--Number of customers who are male 
select count(*) as male_customers from [SQL - RetailSalesAnalysis ] 
where gender = 'Male'

--get the transactions with max total
select * from [SQL - RetailSalesAnalysis ] where total_sale = (select max(total_sale) from
												[SQL - RetailSalesAnalysis ])




-----------------------------------------------------
--Data Analysis & Business Key Problems and Answers
-----------------------------------------------------

select top 10 * from [SQL - RetailSalesAnalysis ] 

--Q1 Retrieve all columns for sales made on '2022-11-05'

select * from [SQL - RetailSalesAnalysis ] where sale_date = '2022-11-05'


--Q2 Find the average age of customers who 
--purchased items from 'beauty' category

select AVG(age) as AvgAge from [SQL - RetailSalesAnalysis ] 
				where category = 'Beauty'
				

--Q3 Find all transaction where total_sale is greater than 1000

select * from [SQL - RetailSalesAnalysis ] where total_sale > 1000


--Q4 Find total number of transactions made by each gender in each category

select count(*) no_of_sales, gender, category from [SQL - RetailSalesAnalysis ]
				group by category, gender order by 3


--Q5 Find all transactions where category is "Clothing" and quantity sold is more than 3 in the month of nov 2022

select * from [SQL - RetailSalesAnalysis ] where category = 'Clothing' and quantiy > 3 and DATEPART(mm, sale_date) = 11 and 
							DATEPART(yy, sale_date) = 2022


--Q6 Find the total sales and orders for each category
select category, sum(total_sale) [total sales], count(*) [total orders] from [SQL - RetailSalesAnalysis ]
		group by category



--Q7 Calculate the total sales for each category, also count the total orders
select category, sum(total_sale) [sum of sales], count(*) [Total Orders] from [SQL - RetailSalesAnalysis ]
		group by category order by [sum of sales] desc



--Q8 Find avg sales in each month. Find out the best selling month of each year

select * from (
select dense_rank() over(partition by year(sale_date) order by round(avg(total_sale), 2) desc) Month_wise_rank, 
			round(avg(total_sale), 2) Avgtotalsale, YEAR(sale_date) Year, datename(mm,sale_date) Month from [SQL - RetailSalesAnalysis ]
			group by YEAR(sale_date), datename(mm,sale_date)
) as t1 
where t1.Month_wise_rank = 1



--Q9 Find top 5 customers based on the highest total sales

select top 5 customer_id, sum(total_sale) TotalSales from [SQL - RetailSalesAnalysis ]
				group by customer_id order by TotalSales desc



--Q10 Find the no:of unique customers who purchased items from each category

select category [Product Category], count(distinct customer_id) [Total Unique Customers] from [SQL - RetailSalesAnalysis ]
				group by category 
				order by 2



--Q11 Find each shift and number of orders in it
-- Morning <12, Afternoon 12 & 17 and Evening > 17

	
with tempretailsales 
as(					
select *, 
		case
			when DATEPART(HOUR, sale_time) < 12 then 'Morning'
			when DATEPART(HOUR, sale_time) >= 12 and DATEPART(HOUR, sale_time) <= 17 then 'Afternoon'
			when DATEPART(HOUR, sale_time) > 17 then 'Evening'
		end as shift
		from [SQL - RetailSalesAnalysis ]
)
select shift, count(*) [total orders] from tempretailsales 
		group by shift
	


--End of Project