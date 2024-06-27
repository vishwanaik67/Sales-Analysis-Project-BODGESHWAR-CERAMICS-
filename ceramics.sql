create database ceramic_shop 
use ceramic_shop

             -- SALES ANALYSIS --
--*Branch Performance:*
select Branch ,SUM([Amount])as Totalrevenue ,
        round(SUM( [Gross_Profit]),1)as Gross_profit
   from  [dbo].[transactions]
   group by Branch 

-- * Sales Trends:*
select FORMAT([Order_Date], 'yyyy-MM') AS Month,
       SUM([Amount]) AS Total_Sales
	from  [dbo].[transactions]
	group by FORMAT([Order_Date], 'yyyy-MM')
	order by Month

--*Sales by Product Category:*
select [Product_Category] ,SUM([Amount]) AS Total_Sales
     from  [dbo].[transactions] as t 
join [dbo].[product] as p on t.[Product_ID]=P.[Product_ID]
 group by [Product_Category]
 order by Total_Sales desc

 -- *Top Selling Products:*
 select top 1 [Sub_Category] ,[Product_Category],SUM([Amount]) AS Total_Sales
     from  [dbo].[transactions] as t 
join [dbo].[product] as p on t.[Product_ID]=P.[Product_ID]
 group by [Sub_Category],[Product_Category]
 order by Total_Sales desc


             --CUSTOMER BEHAVIOR ANALYSIS--
--Customer Purchase Frequency:
select Top 10 [Customer_Name],COUNT([Transaction_ID]) as PurchaseCount
from [dbo].[customer] AS c
join [dbo].[transactions] as t on t.[Customer_ID] =c.[Customer_ID]
group by [Customer_Name]
order by PurchaseCount desc
     
--*Age Distribution*
SELECT Age,COUNT(*) AS CustomerCount
FROM [dbo].[customer]
GROUP BY Age
ORDER BY Age

--Correlation Between Age and Purchasing Behavior 
 SELECT c.Age,
       COUNT(t.Transaction_ID) AS TotalPurchases,
       SUM(t.Amount) AS TotalSpent,
       AVG(t.Amount) AS AvgPurchaseAmount
 FROM   customer c
        JOIN [dbo].[transactions] as t ON c.Customer_ID = t.Customer_ID
 GROUP BY    c.Age
 ORDER BY      Age;

 --Location-Based Customer Analysis:
 SELECT  c.Address AS Location,
        COUNT(t.Transaction_ID) AS TotalPurchases,
        round(SUM(t.Amount),1) AS TotalSpent,
        COUNT(DISTINCT t.Customer_ID)as number_of_customer
 FROM   customer c
       JOIN [dbo].[transactions] as t ON c.Customer_ID = t.Customer_ID
 GROUP BY c.Address
 order by  TotalSpent desc 
       


	     --PRODUCT PERFORMANCE ANALYSIS--
 --Product Popularity-
SELECT  t.Product_ID,[Product_Category],[Sub_Category],
        SUM(Quantity) AS TotalSalesVolume
FROM  [dbo].[Transactions]  as t
join [dbo].[product] as p on t.Product_ID=P.Product_ID
GROUP BY  t.Product_ID ,[Product_Category],[Sub_Category]
ORDER BY  TotalSalesVolume DESC;

--Price Sensitivity--
WITH PriceRanges AS (
    SELECT Product_ID,
          CASE
			WHEN [Amount] < 10000 THEN 'Low'
			WHEN [Amount] BETWEEN 10000 AND 50000 THEN 'Medium'
			ELSE 'High'  
            END AS PriceRange,
         SUM(Quantity) AS TotalSalesVolume
    FROM  [dbo].[transactions]
    GROUP BY  Product_ID,
              CASE
            WHEN [Amount] < 10000 THEN 'Low'
            WHEN [Amount] BETWEEN 10000 AND 50000 THEN 'Medium'
            ELSE 'High'
         END)
SELECT  PriceRange,
    SUM(TotalSalesVolume) AS SalesVolume
FROM  PriceRanges
GROUP BY  PriceRange
ORDER BY  SalesVolume DESC



----*Company Performance:*
select Company ,SUM(Gross_Profit)as Totalrevenue ,
        round(SUM([Gross_Profit]),2) AS Gross_Profit
   from  [dbo].[transactions] as t
 join [dbo].[product] as p on p.product_ID =t.product_ID
   group by Company 
   order by Gross_Profit desc




   --Customer Purchase Frequency:
select Top 10 t.[Customer_ID],SUM([Amount])as Total_sales,
               COUNT([Transaction_ID]) as PurchaseCount
  from [dbo].[customer] AS c
join [dbo].[transactions] as t on t.[Customer_ID] =c.[Customer_ID]
  group by t.Customer_ID 
   order by Total_sales desc

--Total expenses by date
select [Month]as Date ,[Total_expenses]
from [dbo].[trasport_cost]

--creating temporary GrossProfitByMonth
SELECT YEAR(Order_Date) AS Year,
    MONTH(Order_Date) AS Month,
    SUM(Gross_Profit) AS TotalGrossProfit
INTO #GrossProfitByMonth
FROM [dbo].[transactions]
GROUP BY YEAR(Order_Date),MONTH(Order_Date)
    
-- creating temporary ExpensesByMonth
SELECT YEAR(Month) AS Year,
     MONTH(Month) AS Month,
     SUM(Total_expenses) AS TotalExpenses
INTO #ExpensesByMonth
FROM[dbo].[trasport_cost]
GROUP BY YEAR(Month), MONTH(Month);
    
    
--Calculate Net Profit by Joining the Two Temporary Tables
SELECT gp.Year,gp.Month,
    gp.TotalGrossProfit - ISNULL(e.TotalExpenses, 0) AS NetProfit
FROM #GrossProfitByMonth gp
LEFT JOIN #ExpensesByMonth e  ON  gp.Year = e.Year AND gp.Month = e.Month
ORDER BY gp.Year, gp.Month;

DROP TABLE #GrossProfitByMonth;
DROP TABLE #ExpensesByMonth;

  





