--SQL Advance Case Study


--Q1--BEGIN 
   --1. List all the states in which we have customers who have bought cellphones from 2005 till today.

SELECT DISTINCT l.State
FROM [dbo].[FACT_TRANSACTIONS] AS f
JOIN [dbo].[DIM_LOCATION] AS l ON l.IDLocation = f.IDLocation
JOIN [dbo].[DIM_DATE] AS d ON d.DATE = f.Date
JOIN [dbo].[DIM_MODEL] AS m ON m.IDModel = f.IDModel
WHERE d.YEAR >= 2005 
ORDER BY l.State

--Q1--END




--Q2--BEGIN
  ---2. What state in the US is buying the most 'Samsung' cell phones?

	SELECT TOP 1 l.State, COUNT(f.Quantity) AS qty
	FROM [dbo].[FACT_TRANSACTIONS] f
	JOIN [dbo].[DIM_LOCATION] l ON l.IDLocation = f.IDLocation
	JOIN [dbo].[DIM_MODEL] ml ON ml.IDModel = f.IDModel
	JOIN [dbo].[DIM_MANUFACTURER] m ON m.IDManufacturer = ml.IDManufacturer
	WHERE m.Manufacturer_Name = 'Samsung' AND l.Country = 'US'
	GROUP BY l.State
	ORDER BY qty DESC
--Q2--END




--Q3--BEGIN      
	--3. Show the number of transactions for each model per zip code per state

	SELECT m.Model_Name, l.ZipCode, l.State, COUNT(f.TotalPrice) AS number_of_transactions
	FROM [dbo].[FACT_TRANSACTIONS] f
	JOIN [dbo].[DIM_MODEL] m ON m.IDModel = f.IDModel
	JOIN [dbo].[DIM_LOCATION] l ON l.IDLocation = f.IDLocation
	GROUP BY m.Model_Name, l.ZipCode, l.State
	ORDER BY number_of_transactions DESC


--Q3--END




--Q4--BEGIN
   ---4. Show the cheapest cellphone (Output should contain the price also)

      SELECT TOP 1 mf.Manufacturer_Name,m.Unit_price 
	  FROM [dbo].[DIM_MODEL] m
	  JOIN [dbo].[DIM_MANUFACTURER] mf ON mf.IDManufacturer = m.IDManufacturer
	  ORDER BY Unit_price ASC

--Q4--END




--Q5--BEGIN
	---5. Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price.
					
  WITH TopManufacturers AS (
    SELECT TOP 5 mf.Manufacturer_Name, SUM(f.Quantity) AS total_quantity
    FROM [dbo].[FACT_TRANSACTIONS] f
    JOIN [dbo].[DIM_MODEL] m ON m.IDModel = f.IDModel
    JOIN [dbo].[DIM_MANUFACTURER] mf ON mf.IDManufacturer = m.IDManufacturer
    GROUP BY mf.Manufacturer_Name
    ORDER BY total_quantity DESC
																		)
 SELECT mn.Manufacturer_Name, mdl.Model_Name, AVG(f.TotalPrice) AS avg_price
 FROM [dbo].[FACT_TRANSACTIONS] f
 JOIN [dbo].[DIM_MODEL] mdl ON mdl.IDModel = f.IDModel
 JOIN [dbo].[DIM_MANUFACTURER] mn ON mn.IDManufacturer = mdl.IDManufacturer
 WHERE mn.Manufacturer_Name IN (SELECT Manufacturer_Name FROM TopManufacturers)
 GROUP BY mn.Manufacturer_Name, mdl.Model_Name
 ORDER BY avg_price;

--Q5--END



--Q6--BEGIN
   ---6. List the names of the customers and the average amount spent in 2009, where the average is higher than 500

	SELECT c.Customer_Name, AVG(f.TotalPrice) AS avg_amount
	FROM [dbo].[FACT_TRANSACTIONS] f
	JOIN [dbo].[DIM_CUSTOMER] c ON c.IDCustomer = f.IDCustomer
	JOIN [dbo].[DIM_DATE] d ON d.DATE = f.Date
	WHERE d.YEAR = 2009
	GROUP BY c.Customer_Name
	HAVING AVG(f.TotalPrice) > 500;

--Q6--END

	

--Q7--BEGIN  
	---7. List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010

		WITH TopModels2008 AS (
    SELECT TOP 5 m.Model_Name, SUM(f.Quantity) AS total_quantity
    FROM [dbo].[FACT_TRANSACTIONS] f
    JOIN [dbo].[DIM_MODEL] m ON m.IDModel = f.IDModel
    WHERE YEAR(f.Date) = 2008
    GROUP BY m.Model_Name
    ORDER BY total_quantity DESC
													),
TopModels2009 AS (
    SELECT TOP 5 m.Model_Name, SUM(f.Quantity) AS total_quantity
    FROM [dbo].[FACT_TRANSACTIONS] f
    JOIN [dbo].[DIM_MODEL] m ON m.IDModel = f.IDModel
    WHERE YEAR(f.Date) = 2009
    GROUP BY m.Model_Name
    ORDER BY total_quantity DESC
																),
TopModels2010 AS (
    SELECT TOP 5 m.Model_Name, SUM(f.Quantity) AS total_quantity
    FROM [dbo].[FACT_TRANSACTIONS] f
    JOIN [dbo].[DIM_MODEL] m ON m.IDModel = f.IDModel
    WHERE YEAR(f.Date) = 2010
    GROUP BY m.Model_Name
    ORDER BY total_quantity DESC
														)
SELECT a.Model_Name
FROM TopModels2008 a
JOIN TopModels2009 b ON a.Model_Name = b.Model_Name
JOIN TopModels2010 c ON a.Model_Name = c.Model_Name

--Q7--END




--Q8--BEGIN
---8. Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010.

	 SELECT d1.Manufacturer_Name, d1.YEAR, d1.sales
    FROM (
    SELECT mf.Manufacturer_Name, da.YEAR, SUM(f.TotalPrice) AS sales,
           RANK() OVER (PARTITION BY da.YEAR ORDER BY SUM(f.TotalPrice) DESC) AS sales_rank
    FROM [dbo].[DIM_MODEL] d
    JOIN [dbo].[FACT_TRANSACTIONS] f ON d.IDModel = f.IDModel
    JOIN [dbo].[DIM_DATE] da ON da.DATE = f.Date
    JOIN [dbo].[DIM_MANUFACTURER] mf ON mf.IDManufacturer = d.IDManufacturer
    WHERE da.YEAR IN (2009, 2010)
    GROUP BY mf.Manufacturer_Name, da.YEAR
															) d1
	WHERE d1.sales_rank = 2

--Q8--END



--Q9--BEGIN
	---9. Show the manufacturers that sold cellphones in 2010 but did not in 2009.

	WITH Sales2009 AS (
    SELECT DISTINCT mf.Manufacturer_Name
    FROM [dbo].[FACT_TRANSACTIONS] f
    JOIN [dbo].[DIM_DATE] d ON d.DATE = f.Date
    JOIN [dbo].[DIM_MODEL] m ON m.IDModel = f.IDModel
    JOIN [dbo].[DIM_MANUFACTURER] mf ON mf.IDManufacturer = m.IDManufacturer
    WHERE d.YEAR = 2009
																					),
Sales2010 AS (
    SELECT DISTINCT mf.Manufacturer_Name
    FROM [dbo].[FACT_TRANSACTIONS] f
    JOIN [dbo].[DIM_DATE] d ON d.DATE = f.Date
    JOIN [dbo].[DIM_MODEL] m ON m.IDModel = f.IDModel
    JOIN [dbo].[DIM_MANUFACTURER] mf ON mf.IDManufacturer = m.IDManufacturer
    WHERE d.YEAR = 2010
																						)
SELECT s2010.Manufacturer_Name
FROM Sales2010 s2010
LEFT JOIN Sales2009 s2009 ON s2010.Manufacturer_Name = s2009.Manufacturer_Name
WHERE s2009.Manufacturer_Name IS NULL;

	
--Q9--END




--Q10--BEGIN
	----10. Find top 100 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend.

		WITH Top100Customers AS (
    SELECT TOP 100 IDCustomer, SUM(TotalPrice) AS total_spent
    FROM [dbo].[FACT_TRANSACTIONS]
    GROUP BY IDCustomer
    ORDER BY total_spent DESC
														),
CustomerYearlyStats AS (
    SELECT f.IDCustomer, YEAR(f.Date) AS Year, 
           AVG(f.TotalPrice) AS avg_spend, AVG(f.Quantity) AS avg_quantity,
           SUM(f.TotalPrice) AS total_spend
    FROM [dbo].[FACT_TRANSACTIONS] f
    JOIN Top100Customers tc ON f.IDCustomer = tc.IDCustomer
    GROUP BY f.IDCustomer, YEAR(f.Date)
																),
CustomerYearlyChange AS (
    SELECT IDCustomer, Year, avg_spend, avg_quantity, total_spend,
           LAG(total_spend) OVER (PARTITION BY IDCustomer ORDER BY Year) AS previous_year_spend
    FROM CustomerYearlyStats
																					)
SELECT  IDCustomer, Year, avg_spend, avg_quantity, 
       (total_spend - previous_year_spend) / previous_year_spend * 100 AS spend_change_percentage
FROM CustomerYearlyChange;

--Q10--END


