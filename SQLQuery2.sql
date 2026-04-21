--Q1.List all the states in which we have customers who have bought cellphones from 2005 till today.
select   distinct state from DIM_LOCATION  a join FACT_TRANSACTIONS
b on a.IDLocation=b.IDLocation where year(date)>2005 ;

--Q2.What state in the US is buying the most 'Samsung' cell phones?
SELECT top 1  state,count(IDCustomer) c FROM FACT_TRANSACTIONS  A join DIM_MODEL
b on a.IDModel=b.IDModel join DIM_MANUFACTURER c on 
b.IDManufacturer=c.IDManufacturer join DIM_LOCATION d 
on a.IDLocation=d.IDLocation  where Country='US' and Manufacturer_Name='Samsung' group by state 
order by  c desc;

--Q3.Show the number of transactions for each model per zip code per state.
select count(idcustomer) transactions ,Model_Name , ZipCode ,State 
from FACT_TRANSACTIONS a
join DIM_MODEL  b on a.IDModel=b.IDModel join DIM_LOCATION  c
on c.IDLocation=a.IDLocation group by Model_Name ,ZipCode ,State ;

--Q4.Cheapest cell phone with value.
select top 1 unit_price ,Model_Name 
from DIM_MODEL  order by Unit_price asc ;

--Q5.Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price.
SELECT    MODEL_NAME , AVG(UNIT_PRICE) AVERAGE  FROM DIM_MODEL B  JOIN DIM_MANUFACTURER C
ON C.IDManufacturer=B.IDManufacturer WHERE MANUFACTURER_NAME IN
(
SELECT TOP 5 MANUFACTURER_NAME FROM  FACT_TRANSACTIONS A
JOIN DIM_MODEL B ON A.IDModel=B.IDModel JOIN DIM_MANUFACTURER C
ON C.IDManufacturer=B.IDManufacturer GROUP BY Manufacturer_Name 
ORDER BY SUM(QUANTITY) DESC)
GROUP BY Model_Name;

--Q6.List the names of the customers and the average amount spent in 2009, where the average is higher than 500
select Customer_Name , avg(totalprice) from FACT_TRANSACTIONS a join DIM_CUSTOMER b 
on a.IDCustomer=b.IDCustomer  where year(date)=2009 group by 
Customer_Name having avg(totalprice)>500 ;

--Q7.List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010
with a
as (
SELECT  TOP 5 sum(QUANTITY) CNT , Model_Name FROM FACT_TRANSACTIONS A 
JOIN DIM_MODEL B 
ON A.IDModel=B.IDModel  WHERE YEAR(DATE)=2008 GROUP BY Model_Name ORDER BY  CNT DESC),
 b 
 as (
SELECT  TOP 5 sum(QUANTITY) CNT , Model_Name FROM FACT_TRANSACTIONS A 
JOIN DIM_MODEL B 
ON A.IDModel=B.IDModel  WHERE YEAR(DATE)=2009 GROUP BY Model_Name ORDER BY  CNT DESC) ,
c
as (SELECT  TOP 5 sum(QUANTITY) CNT , Model_Name FROM FACT_TRANSACTIONS A 
JOIN DIM_MODEL B 
ON A.IDModel=B.IDModel  WHERE YEAR(DATE)=2010 GROUP BY Model_Name ORDER BY  CNT DESC)

select a.model_name  from a join b 
on a.Model_Name=b.Model_Name join c on b.Model_Name=c.Model_Name ;

--Q8.Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010.
WITH A AS (
SELECT  Manufacturer_Name  FROM FACT_TRANSACTIONS A JOIN DIM_MODEL B ON
A.IDModel=B.IDModel JOIN DIM_MANUFACTURER  C 
ON C.IDManufacturer=B.IDManufacturer  WHERE YEAR(DATE)=2009
GROUP BY Manufacturer_Name ORDER BY  SUM(TOTALPRICE)  DESC OFFSET 1 ROW FETCH NEXT  1 ROW ONLY ),
B AS 
(
SELECT  Manufacturer_Name FROM FACT_TRANSACTIONS A JOIN DIM_MODEL B ON
A.IDModel=B.IDModel JOIN DIM_MANUFACTURER  C 
ON C.IDManufacturer=B.IDManufacturer  WHERE YEAR(DATE)=2010
GROUP BY Manufacturer_Name ORDER BY  SUM(TOTALPRICE)  DESC OFFSET 1 ROW FETCH NEXT  1 ROW ONLY)

SELECT A.MANUFACTURER_NAME  ,   B.MANUFACTURER_NAME   FROM A JOIN B ON 1=1;

--Q9.Show the manufacturers that sold cellphones in 2010 but did not in 2009.
WITH A AS 
(
SELECT  DISTINCT  Manufacturer_Name FROM FACT_TRANSACTIONS B JOIN DIM_MODEL C ON
B.IDModel=C.IDModel JOIN DIM_MANUFACTURER  D
ON C.IDManufacturer=D.IDManufacturer  WHERE YEAR(DATE)=2010 ),
B AS (
SELECT  DISTINCT  Manufacturer_Name FROM FACT_TRANSACTIONS B JOIN DIM_MODEL C ON
B.IDModel=C.IDModel JOIN DIM_MANUFACTURER  D
ON C.IDManufacturer=D.IDManufacturer  WHERE YEAR(DATE)=2009 )

SELECT  A.MANUFACTURER_NAME  FROM A LEFT JOIN B ON 
A.Manufacturer_Name=B.Manufacturer_Name   WHERE B.Manufacturer_Name IS NULL;

--Q10.Find top 100 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend.
WITH A AS(
SELECT  TOP 100 Customer_Name ,AVG(TOTALPRICE*QUANTITY) AVERAGE_SPEND , 
AVG(QUANTITY) QUANTITY_BOUGHT ,YEAR(DATE) IN_THE_YEAR
FROM FACT_TRANSACTIONS  A  JOIN DIM_CUSTOMER  B ON A.IDCustomer=B.IDCustomer
JOIN DIM_MODEL C ON  C.IDModel=A.IDModel
GROUP BY Customer_Name , YEAR(DATE) ORDER BY SUM(TOTALPRICE) DESC) 

WITH CustomerAvgSpend AS (
    SELECT 
        r.Customer_Name,
        YEAR(s.date) AS year,
        AVG(s.totalprice) AS avg_spend,
        AVG(s.Quantity) AS avg_quantity,
        SUM(s.totalprice) AS total_spend
    FROM FACT_TRANSACTIONS s
    JOIN DIM_CUSTOMER r 
        ON s.IDCustomer = r.IDCustomer
    GROUP BY r.Customer_Name, YEAR(s.date)
),
CustomerSpendWithLag AS (
    SELECT 
        Customer_Name,
        year,
        avg_spend,
        avg_quantity,
        total_spend,
        LAG(total_spend) OVER (PARTITION BY Customer_Name ORDER BY year) AS previous_year_spend
    FROM CustomerAvgSpend
)
SELECT 
    Customer_Name,
    year,
    avg_spend,
    avg_quantity,
    total_spend,
    previous_year_spend,
    CASE 
        WHEN previous_year_spend IS NULL THEN NULL
        ELSE ((total_spend - previous_year_spend) / previous_year_spend) * 100
    END AS percentage_change_in_spend
FROM CustomerSpendWithLag
ORDER BY Customer_Name, year;







