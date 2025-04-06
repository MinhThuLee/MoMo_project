CREATE DATABASE MoMo_project

GO 
USE MoMo_project
GO

--Check if the tables work.
SELECT * FROM dbo.COMMISSION
SELECT * FROM dbo.TRANSACTIONS
SELECT * FROM dbo.USER_INF

--The first step is to create a staging table where I can work on and clean the data. 
--This allows me to keep the raw data intact as a backup in case anything goes wrong.
SELECT * INTO COMMISSION_DUP
FROM dbo.COMMISSION;

SELECT * INTO TRANSACTIONS_DUP
FROM dbo.TRANSACTIONS;

SELECT * INTO USER_INF_DUP
FROM dbo.USER_INF;

---- When I am data cleaning we usually follow a few steps
-- 1. Check for duplicates and remove any
-- 2. Look at null values and see what 
--3. Standardize data and fix errors
-- 4. Remove any columns and rows that are not necessary - few ways



--1. Clean the TRANSACTION_DUP
SELECT * FROM TRANSACTIONS_DUP

--Check the number order_id and distinct order_id.
SELECT COUNT (order_id) FROM TRANSACTIONS_DUP --There are 13495 values.
SELECT COUNT (distinct order_id) FROM TRANSACTIONS_DUP --There are 13495 values. All the order_id in transaction table are unique.

--Let's check each column to identify missing values.
SELECT * FROM TRANSACTIONS_DUP
WHERE order_id = '' or order_id is null

SELECT * FROM TRANSACTIONS_DUP
WHERE Date = '' or Date is null

SELECT * FROM TRANSACTIONS_DUP
WHERE Amount = '' or Amount is null

SELECT * FROM TRANSACTIONS_DUP
WHERE Merchant_id = '' or Merchant_id is null

SELECT * FROM TRANSACTIONS_DUP
WHERE Purchase_status = '' or Purchase_status is null
--Only Purchase_status column has missing values.
--Standardize missing data in Purchase_status column.
SELECT DISTINCT Purchase_status
FROM TRANSACTIONS_DUP

UPDATE TRANSACTIONS_DUP
SET Purchase_status = N'Trực tiếp'
WHERE Purchase_status IS NULL

--Check the Date column
SELECT DISTINCT Date
FROM TRANSACTIONS_DUP
ORDER BY Date DESC--Some data is in an unusual format and arranged as strings.

--Standardize the date format
SELECT DISTINCT Date, FORMAT(CONVERT(DATE, Date, 103), 'yyyy-MM-dd')
FROM TRANSACTIONS_DUP
WHERE TRY_CONVERT(DATE, Date, 103) IS NOT NULL
AND TRY_CONVERT(DATE, Date, 120) IS NULL;


UPDATE TRANSACTIONS_DUP
SET Date = FORMAT(CONVERT(DATE, Date, 103), 'yyyy-MM-dd')
WHERE TRY_CONVERT(DATE, Date, 103) IS NOT NULL
AND TRY_CONVERT(DATE, Date, 120) IS NULL;

--Changing the Date column type
ALTER TABLE TRANSACTIONS_DUP ADD Date_DATE DATE;

UPDATE TRANSACTIONS_DUP SET Date_DATE = CAST (Date AS date)

ALTER TABLE TRANSACTIONS_DUP DROP COLUMN Date

sp_rename 'TRANSACTIONS_DUP.Date_DATE','Date','COLUMN';

--The Amount column.
SELECT DISTINCT Amount, REPLACE(Amount, ',', '') AS CleanAmount
FROM TRANSACTIONS_DUP
ORDER BY Amount DESC --The Amount column appears to be sorted in string order instead of numerical order.

UPDATE TRANSACTIONS_DUP
SET Amount = REPLACE(Amount, ',', '');

ALTER TABLE TRANSACTIONS_DUP ADD Amount_int INT;

UPDATE TRANSACTIONS_DUP SET Amount_int = CAST (Amount as int);

ALTER TABLE TRANSACTIONS_DUP DROP COLUMN Amount;

sp_rename 'TRANSACTIONS_DUP.Amount_int','Amount','COLUMN';

SELECT DISTINCT Amount FROM TRANSACTIONS_DUP ORDER BY Amount DESC

----TABLE TRANSACTION IS CLEANED


--2. Clean the DATA_USER_INF_DUP

SELECT * FROM USER_INF_DUP

--Check the number user_id and distinct user_id.
SELECT COUNT (User_id) FROM USER_INF_DUP --There are 13428 values.
SELECT COUNT (DISTINCT User_id) FROM USER_INF_DUP --There are 13390 values. What causes the dup?

--Check the duplicates and delete
WITH DUP_CTE AS 
(
SELECT
	*
	, ROW_NUMBER () OVER (PARTITION BY User_id ORDER BY (SELECT NULL)) AS ROW_NUM
FROM USER_INF_DUP
)
SELECT User_id, ROW_NUM FROM DUP_CTE WHERE ROW_NUM >1;


WITH DUP_CTE AS 
(
SELECT
	*
	, ROW_NUMBER () OVER (PARTITION BY User_id ORDER BY (SELECT NULL)) AS ROW_NUM
FROM USER_INF_DUP
)
DELETE FROM DUP_CTE WHERE ROW_NUM >1;

--Let's check each column to identify missing values.
SELECT * FROM USER_INF_DUP WHERE User_id ='' OR User_id IS NULL 
SELECT * FROM USER_INF_DUP WHERE First_tran_date ='' OR First_tran_date IS NULL
SELECT * FROM USER_INF_DUP WHERE Location ='' OR Location IS NULL
SELECT * FROM USER_INF_DUP WHERE Age ='' OR Age IS NULL
SELECT * FROM USER_INF_DUP WHERE Gender ='' OR Gender IS NULL--There is no missing value in each column.

--Check the First_tran_date column
SELECT DISTINCT  First_tran_date 
FROM USER_INF_DUP 
ORDER BY First_tran_date DESC
--Some values in the First_tran_date column have years greater than 2020, which is inconsistent with the dataset as it should only cotain records prior to 2020.
--It appears that the first two digits of the year '20' were incorrectly transformed into '99' and '30'.
--Correct the year.
SELECT 
	First_tran_date
	, stuff(First_tran_date, 1, 2, '20') AS NEW_DATE 
FROM USER_INF_DUP 
WHERE LEFT(First_tran_date, 2) = '99' OR LEFT(First_tran_date, 2) = '30'
ORDER BY First_tran_date DESC

UPDATE USER_INF_DUP
SET First_tran_date =  stuff(First_tran_date, 1, 2, '20')
WHERE LEFT(First_tran_date, 2) = '99' OR LEFT(First_tran_date, 2) = '30'

--Change the First_tran_date column data type.
ALTER TABLE USER_INF_DUP ADD First_tran_date2 DATE;

UPDATE USER_INF_DUP SET First_tran_date2 = CAST (First_tran_date AS DATE);

ALTER TABLE USER_INF_DUP DROP COLUMN First_tran_date;

sp_rename 'USER_INF_DUP.First_tran_date2','First_tran_date','COLUMN';

--Check the Location column
SELECT DISTINCT LOCATION FROM USER_INF_DUP --HCMC, Ho Chi Minh City, Unknown, HN, Other Cities, Others
--Fix data integration in Location column.
UPDATE USER_INF_DUP SET Location = N'Thành phố Hồ Chí Minh' WHERE Location IN (N'HCMC', N'Ho Chi Minh City')
UPDATE USER_INF_DUP SET Location = N'Hà Nội' WHERE Location = N'HN'
UPDATE USER_INF_DUP SET Location = N'Thành phố khác' WHERE Location IN (N'Unknown', N'Other Cities',  N'Other')

--Check the Age column.
SELECT DISTINCT Age FROM USER_INF_DUP;

--Check the Gender column.
SELECT DISTINCT Gender FROM USER_INF_DUP --MALE, FEMALE, N, M, female, Nam, f, male
UPDATE USER_INF_DUP SET Gender = N'Nam' WHERE Gender IN (N'M', N'MALE');
UPDATE USER_INF_DUP SET Gender = N'Nữ' WHERE Gender IN (N'f', N'FEMALE');




-----Part A
---Problem 1
/*Using data from the 'Commission' table, 
 * add a column 'Revenue' in the 'Transactions' table that displays MoMo's earned revenue for each order, 
 * and then calculate MoMo's total revenue in January 2020.*/

 /* add a column 'Revenue' in the 'Transactions' table that displays MoMo's earned revenue for each order*/
 ALTER TABLE TRANSACTIONS_DUP ADD Revenue numeric (18,2);

WITH revenue_cte AS (
    SELECT 
		t.order_id
		, t.merchant_id
		, t.amount
		, c.rate_pct
		, (c.rate_pct * t.amount / 100) AS revenue
    FROM TRANSACTIONS_DUP t
    JOIN COMMISSION_DUP c ON c.merchant_id = t.merchant_id
)
UPDATE t
SET t.revenue = rev.revenue
FROM TRANSACTIONS_DUP t
JOIN revenue_cte rev
ON t.order_id = rev.order_id;

/**calculate MoMo's total revenue in January 2020**/
SELECT 
	SUM (Revenue) AS rev
FROM TRANSACTIONS_DUP
WHERE Date BETWEEN '2020-01-01'AND '2020-01-31'; --MOMO'S REVENUE IN JAN 2020 IS 1,409,827VND

--Problem 2
/*What is MoMo's most profitable month?*/
SELECT
	MONTH(Date) AS month
	, SUM(revenue) AS monthly_revenue 
FROM TRANSACTIONS_DUP t 
GROUP BY MONTH(Date) 
ORDER BY monthly_revenue desc;
--The most profitable month is September:1,690,900.
--The least profitable month is February:1,378,500.

--PROBLEM 3
/*What day of the week does MoMo make the most money, on average? The least money?*/
SELECT
	CASE DATEPART(WEEKDAY, DATE)
		WHEN 1 THEN 'Sunday'
		WHEN 2 THEN 'Monday'
		WHEN 3 THEN 'Tuesday'
		WHEN 4 THEN 'Wednesday'
		WHEN 5 THEN 'Thursday'
		WHEN 6 THEN 'Friday'
		WHEN 7 THEN 'Saturday'
	END AS date_of_a_week
	, SUM(revenue) AS daily_revenue 
FROM TRANSACTIONS_DUP t 
GROUP BY DATEPART(WEEKDAY, DATE)
ORDER BY daily_revenue  desc;
--MoMo makes the most money on wednesday and the least money on monday.

--PROBLEM 4
/*Combined with the 'User_Info' table, add columns: Age, Gender, Location, Type_user (New/Current) in 'Transactions' table and calculate the total number of new users in December 2020.
 *(New = the transaction was in the month of the first time the user used Topup; Current = the user had used Topup before that month)*/
--Add new columns to TRANSACTIONS_DUP table
ALTER TABLE TRANSACTIONS_DUP 
	ADD 
		age NVARCHAR(20),
		gender NVARCHAR(20),
		location NVARCHAR (255),
		type_user varchar(64),
		first_tran_date date;

--Populate the new column with the right data from USER_INF_DUP table
UPDATE t
SET 
	t.age = u.age
	, t.gender = u.gender
	, t.location = u.location
	, t.first_tran_date = u.first_tran_date 
FROM TRANSACTIONS_DUP t
JOIN USER_INF_DUP u
ON t.user_id = u.user_id;

--Set conditions for type_user column with new/current values.
SELECT 
	CASE
		WHEN CONCAT(YEAR (first_tran_date) ,'-', MONTH (first_tran_date)) = '2020-12' THEN 'new'
		ELSE 'current'
	END AS type_user
	, user_id
	, CONCAT(YEAR (first_tran_date) ,'-', MONTH (first_tran_date)) AS year_month
FROM TRANSACTIONS_DUP


UPDATE TRANSACTIONS_DUP
SET type_user =
	CASE
		WHEN CONCAT(YEAR (first_tran_date) ,'-', MONTH (first_tran_date)) = '2020-12' THEN 'new'
		ELSE 'current'
	END;

--Calculate the total number of new users in December 2020
SELECT COUNT (DISTINCT user_id)
FROM TRANSACTIONS_DUP
WHERE type_user = 'new' --There are 76 new users in Dec 2020.


----Part C: 
--Problem 6: Based on the provided data, what observations and insights can you draw about user demographics and transaction behavior (e.g. trends, classifications)?
--Age group analysis: which age groups make generate the most revenue?
SELECT * FROM TRANSACTIONS_DUP

SELECT
	Age
	, COUNT (*) AS total_transaction
	, SUM (Amount) 
	, SUM (Revenue) AS total_rev
FROM TRANSACTIONS_DUP t
GROUP BY Age
Order BY SUM (Revenue) DESC
--Individuals aged 23 to 32 account for the largest share of both transaction volumn and value.

--Gender distribution
WITH high_value_order AS
(
SELECT 
	user_id
	, order_id
	, Amount
FROM TRANSACTIONS_DUP
WHERE Amount > (SELECT AVG(Amount) FROM TRANSACTIONS_DUP) --Assuming that values exceeding the averaage are considered high-value.
)
SELECT
	u.gender
	, COUNT(h.order_id) as high_value_order_count
    , SUM(h.amount) as total_high_order_amount
    , AVG(h.amount) as avg_high_order_amount
FROM USER_INF_DUP u
JOIN high_value_order h
ON u.user_id = h.user_id
GROUP BY u.gender
--Men use the service more frequently and spend more money than female customers.
--This suggests that more marketing efforts should be directed toward attracting female customers to improve revenue from this segment.

--Geography analysis:
SELECT
	location
	, COUNT(order_id) AS total_trans
	, SUM(revenue) AS total_rev
	, AVG(revenue) AS average_revenue
FROM TRANSACTIONS_DUP t
GROUP BY location
ORDER BY average_revenue DESC;
--Ho Chi Minh city makes the highest average and total revenue.



---------RFM ANALYSIS
WITH RFM_metrics AS
(
SELECT
	user_id
	, max(Date) AS latest_acitve_date
	, DATEDIFF(day, max(date), convert(date, getdate())) as recency
	, count (distinct order_id) as frequency
	, sum (revenue) as monetary
FROM TRANSACTIONS_DUP
GROUP BY user_id
), RFM_score AS
(
SELECT 
	*
	, NTILE (5) OVER (ORDER BY recency) AS R_score
	, NTILE (5) OVER (ORDER BY frequency) AS F_score
	, NTILE (5) OVER (ORDER BY monetary) AS M_score
FROM RFM_metrics
)
SELECT 
	(R_score + F_score + M_score)/3 as RFM_group,
	COUNT(rfm.user_id) as user_count,
	SUM(rfm.M_score) as total_revenue,
	CAST(SUM(rfm.M_score)/COUNT(rfm.user_id) as decimal(12,2)) as avg_revenue_per_user
FROM RFM_score AS rfm 
JOIN RFM_metrics AS metrics
ON metrics.user_id = rfm.user_id
GROUP BY (R_score + F_score + M_score)/3
ORDER BY RFM_group desc;
--A higher RFM score signifies that the customer is more engaged, loyal and valuable to the business. This group should be prioritized for rentention and further nurturing.
--Group 5 makes up only 3.56% but has the highest average spending.
--Group 4 has strong potential to be converted into high-value users with the right trigger.
--The mid-tier group (33%) is the largest, we must maintain engagement and aim t upgrade them to group 4.











