--SQL Advance Case Study


--Q1--BEGIN 
	select f.IDCustomer ,l.State,d.YEAR from [dbo].[FACT_TRANSACTIONS] as f
	join [dbo].[DIM_LOCATION] as l on l.IDLocation =f.IDLocation
	join [dbo].[DIM_DATE] as d on d.DATE = f.Date
	where d.YEAR >= '2005'
	order by d.YEAR


--Q1--END




--Q2--BEGIN
	select top 1  l.State, m.Manufacturer_Name, count(Quantity) qty from [dbo].[FACT_TRANSACTIONS] f
	join [dbo].[DIM_LOCATION] l on l.IDLocation=f.IDLocation
	join [dbo].[DIM_MODEL] ml on ml.IDModel=f.IDModel
	join [dbo].[DIM_MANUFACTURER] m on m.IDManufacturer = ml.IDManufacturer
	where m.Manufacturer_Name = 'samsung' and l.Country = 'us'
	group by l.State,m.Manufacturer_Name
	order by qty desc

--Q2--END




--Q3--BEGIN      
	
		select m.Model_Name,l.ZipCode ,l.State,count(TotalPrice) [number of transaction] from [dbo].[FACT_TRANSACTIONS] f
		join [dbo].[DIM_MODEL] m on m.IDModel = f.IDModel
		join [dbo].[DIM_LOCATION] l on l.IDLocation = f.IDLocation
		group by m.Model_Name,l.ZipCode ,l.State
		order by [number of transaction]

--Q3--END




--Q4--BEGIN

      select top 1 mf.Manufacturer_Name,m.Unit_price from [dbo].[DIM_MODEL] m
	  join [dbo].[DIM_MANUFACTURER] mf on mf.IDManufacturer = m.IDManufacturer
	  order by Unit_price asc


--Q4--END


--Q5--BEGIN

      with mnf as (select top 5 mf.Manufacturer_Name,sum(f.Quantity) s_QTY from [dbo].[FACT_TRANSACTIONS] f
					join [dbo].[DIM_MODEL] m on m.IDModel = f.IDModel
					join [dbo].[DIM_MANUFACTURER] mf on mf.IDManufacturer= m.IDManufacturer
					group by mf.Manufacturer_Name
					)

		select mn.Manufacturer_Name,m.Model_Name, avg(TotalPrice) [avg price] from [dbo].[FACT_TRANSACTIONS] f 
		join [dbo].[DIM_MODEL] m on m.IDModel = f.IDModel
		join [dbo].[DIM_MANUFACTURER] mf on mf.IDManufacturer = m.IDManufacturer
		cross join mnf as mn
		group by  mn.Manufacturer_Name,m.Model_Name
		order by [avg price]
					

--Q5--END


--Q6--BEGIN

		select c.Customer_Name,d.YEAR,avg(TotalPrice) [avg amt] from [dbo].[FACT_TRANSACTIONS] f
		join [dbo].[DIM_CUSTOMER] c on c.IDCustomer = f.IDCustomer
		join [dbo].[DIM_DATE] d on d.DATE = f.Date
		where d.YEAR = 2009
		group by  c.Customer_Name,d.YEAR 
		having avg(TotalPrice)> 500
		 

--Q6--END

	
--Q7--BEGIN  
	
		with a as
				(select top 5 m.Model_Name, sum([Quantity]) as 'total' from [dbo].[FACT_TRANSACTIONS] t
				join [dbo].[DIM_MODEL] m on m.IDModel = t.IDModel
				where year ([Date]) = 2008
				group by m.Model_Name
				order by sum([Quantity]) desc),

		 b as
				(select top 5 m.Model_Name, sum([Quantity]) as 'total' from [dbo].[FACT_TRANSACTIONS] t
				join [dbo].[DIM_MODEL] m on m.IDModel = t.IDModel
				where year ([Date]) = 2009
				group by m.Model_Name
				order by sum([Quantity]) desc),

		 c as
					(select top 5 m.Model_Name, sum([Quantity]) as 'total' from [dbo].[FACT_TRANSACTIONS] t
					join [dbo].[DIM_MODEL] m on m.IDModel = t.IDModel
						where year ([Date]) = 2010
						group by m.Model_Name
						order by sum([Quantity]) desc)


			 select a.Model_Name from a 
			 inner join b on a.Model_Name=b.Model_Name
			 inner join c on a.Model_Name=c.Model_Name ;

    

--Q7--END



--Q8--BEGIN

	(select top 1 d1.IDManufacturer,m.Manufacturer_Name,d1.sales from ( select d.[IDManufacturer],m.Manufacturer_Name,da.YEAR,sum(TotalPrice) as sales from DIM_MODEL d 
			           inner join FACT_TRANSACTIONS f on d.IDModel = f.IDModel
					   join DIM_DATE da on da.DATE = f.Date
					   join [dbo].[DIM_MANUFACTURER] m on m.IDManufacturer = d.IDManufacturer
					   where da.YEAR = 2009
					   group by d.IDManufacturer,m.Manufacturer_Name,da.YEAR
					   order by  sum(TotalPrice) desc offset 1 row  )D1  join  [dbo].[DIM_MANUFACTURER] m on m.IDManufacturer = d1.IDManufacturer )

					   union

     (select top 1 d1.IDManufacturer,m.Manufacturer_Name,d1.sales from ( select d.[IDManufacturer],m.Manufacturer_Name,da.YEAR,sum(TotalPrice) as sales from DIM_MODEL d 
			           inner join FACT_TRANSACTIONS f on d.IDModel = f.IDModel
					   join DIM_DATE da on da.DATE = f.Date
					   join [dbo].[DIM_MANUFACTURER] m on m.IDManufacturer = d.IDManufacturer
					   where da.YEAR = 2010
					   group by d.IDManufacturer,m.Manufacturer_Name,da.YEAR
					   order by  sum(TotalPrice) desc offset 1 row  )D1  join  [dbo].[DIM_MANUFACTURER] m on m.IDManufacturer = d1.IDManufacturer )

	 
--Q8--END



--Q9--BEGIN
	
	select mf.Manufacturer_Name,d.YEAR  from  [dbo].[FACT_TRANSACTIONS] f
	join [dbo].[DIM_DATE] d on d.DATE = f.date
	join [dbo].[DIM_MODEL] m on m.IDModel= f.IDModel
    join [dbo].[DIM_MANUFACTURER] mf on mf.IDManufacturer = m.IDManufacturer
	where not d.YEAR  = 2009 and d.YEAR = 2010 
	group by  mf.Manufacturer_Name,d.YEAR

	
--Q9--END



--Q10--BEGIN
	
	select [IDCustomer],
	      avg ([Quantity]) as avg_qty,
		  YEAR(date) as year, avg(totalprice)as total_price,
		  lag(sum(totalprice))over(partition by idcustomer order by year(date)) as lag1,
		  concat ( ((sum(totalprice) - lag(sum(totalprice))over (partition by idcustomer order by year(date))/
									lag(sum(totalprice))over (partition by idcustomer order by year(date)))*100),'%') as yoy	from [dbo].[FACT_TRANSACTIONS]
	    	group by idcustomer,date
















--Q10--END
	