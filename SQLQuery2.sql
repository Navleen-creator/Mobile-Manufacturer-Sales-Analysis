select top 1 * from DIM_CUSTOMER
select top 1 * from DIM_DATE
select top 1 * from DIM_LOCATION
select top 1 * from DIM_MANUFACTURER
select top 1 * from DIM_MODEL
select top 1 * from FACT_TRANSACTIONS

--Q1. 
select   distinct state from DIM_LOCATION  a join FACT_TRANSACTIONS
b on a.IDLocation=b.IDLocation where year(date)>2005 ;

--Q2.
SELECT top 1  state,count(IDCustomer) c FROM FACT_TRANSACTIONS  A join DIM_MODEL
b on a.IDModel=b.IDModel join DIM_MANUFACTURER c on 
b.IDManufacturer=c.IDManufacturer join DIM_LOCATION d 
on a.IDLocation=d.IDLocation  where Country='US' and Manufacturer_Name='Samsung' group by state 
order by  c desc;

--Q3.TRANSACTION PER MODEL PER ZIP CODE PER STATE.
select count(idcustomer) transactions ,Model_Name , ZipCode ,State 
from FACT_TRANSACTIONS a
join DIM_MODEL  b on a.IDModel=b.IDModel join DIM_LOCATION  c
on c.IDLocation=a.IDLocation group by Model_Name ,ZipCode ,State ;

--Q4.Chaeapest cell phone with value
select top 1 unit_price ,Model_Name 
from DIM_MODEL  order by Unit_price asc ;

--Q5.TOP 5 MANUFACTURER  IN TERMS OF SALES QUANTITY
SELECT    MODEL_NAME , AVG(UNIT_PRICE) AVERAGE  FROM DIM_MODEL B  JOIN DIM_MANUFACTURER C
ON C.IDManufacturer=B.IDManufacturer WHERE MANUFACTURER_NAME IN
(
SELECT TOP 5 MANUFACTURER_NAME FROM  FACT_TRANSACTIONS A
JOIN DIM_MODEL B ON A.IDModel=B.IDModel JOIN DIM_MANUFACTURER C
ON C.IDManufacturer=B.IDManufacturer GROUP BY Manufacturer_Name 
ORDER BY SUM(QUANTITY) DESC)
GROUP BY Model_Name;

--Q6.CUSTOMER AND AVG AMNT SPEND IN 2009 , WHERE AVG IS >500
select Customer_Name , avg(totalprice) from FACT_TRANSACTIONS a join DIM_CUSTOMER b 
on a.IDCustomer=b.IDCustomer  where year(date)=2009 group by 
Customer_Name having avg(totalprice)>500 ;

--Q7.MODELNAME  IN TOP 5 QUANTITY IN 2008 ,2009 ,2010.

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

--Q8.
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

--Q9.
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

--Q10.

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

.---LAG (scalar_expression [, offset [, default ]])     OVER ( [ partition_by_clause ] order_by_clause )


 --Q10.Find top 100 customers and their average spend , average quantity by each year. Find the percentage of change in the spend ?

with CTE1 as (

 select top 100  customer_name,year(date) year, avg(totalprice) a ,avg(Quantity) b ,sum(totalprice) c from 
 DIM_CUSTOMER r join FACT_TRANSACTIONS s on r.IDCustomer=s.IDCustomer 
 join DIM_MODEL l on s.IDModel=l.IDModel group by Customer_Name ,year(date)  order by c desc),
 
 CTE2 as
 (
 select  customer_name ,c,year ,a,b, lag(c) over(partition by customer_name order by year) previous  from CTE1 )

 select customer_name ,year , a,b,c ,previous ,
 case when previous is null then null
 else c-previous/previous *100 
 end as percent_change from CTE2 order by Customer_Name,year;






