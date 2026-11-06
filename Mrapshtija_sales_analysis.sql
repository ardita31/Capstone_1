-- Capstone_1 
-- Assigned Sales Territory: New Jersey
-- Author: Ardita Mrapshtija

USE sample_sales;

-- The purpose of this query is to identify who is the manager of my assigned territory. 
SELECT SalesManager, State, RegionalDirector, Region
FROM management 
WHERE State LIKE '%New Jersey%';
-- The manager assigned to New Jersey is Miami Vue (Region:Northeast)

-- 1. What is the total revenue overall for sales in the assigned territoy, plus the start date and the end date that tell you 
-- what period the data covers? 

SELECT sl.State,
	SUM(ss.Sale_Amount) AS Total_Revenue,
	MIN(ss.Transaction_Date) AS Start_Date,
	MAX(ss.Transaction_Date) AS End_Date
FROM store_sales ss
INNER JOIN store_locations sl
		ON ss.Store_ID = sl.StoreID
WHERE sl.State = 'New Jersey';
-- For us to find out the total revenue for New Jersey, we need to calculate the sum of all sales transaction for that territory. 
-- Store ID is the commonality between store_sales table and the store_locations table, which we need to filter our results for New Jersey.
-- The SUM function calculates total revenue, and MIN MAX identify start date and end date from the result. 

-- 2. What is the revenue breakdown by year and month for the sales territory?

SELECT DATE_FORMAT(ss.Transaction_Date,'%Y-%m') AS Revenue_Month,
	SUM(ss.Sale_Amount) AS Monthly_Rvenue
FROM store_sales ss
INNER JOIN store_locations sl
		ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'New Jersey'
GROUP BY Revenue_Month
ORDER BY Revenue_Month DESC;

-- We can find patterns when breaking down sales by month. For us to see results filtered for New Jersy, we join the store_sales table with the store_location table, 
-- which contains the State fied. We use Group BY to ensure that are results are caluclated per month. 

-- 3. Provide a comparison of total revenue for the specific sales territory and the region it belongs to.

WITH Northeast_Sales AS (
    SELECT sl.State, ss.Sale_Amount AS Revenue
    FROM store_sales ss
    INNER JOIN store_locations sl 
		ON ss.Store_ID = sl.StoreId
    INNER JOIN management m 
		ON sl.State = m.State
    WHERE m.Region = 'Northeast'
)
SELECT 
    'Northeast' AS Region,
    State,
    SUM(Revenue) AS Total_Revenue,
    (SELECT SUM(Revenue) FROM Northeast_Sales) AS Northeast_Total,
    ROUND(SUM(Revenue) / (SELECT SUM(Revenue) FROM Northeast_Sales) * 100, 2) 
    AS Region_Percentage_Contribution
FROM Northeast_Sales
GROUP BY State
ORDER BY Total_Revenue DESC;
-- This query calculates each Northeast state's total sales revenue and its percentage contribution to the Northeast region's overall revenue.
-- The CTE creates a temporary result set called Northeast_Sales. I joined store_sales to store_locations to determine which state each sale belongs to and 
-- added management to identify the region associated with each state so the data includes only states in the Northeast region.
-- GROUP BY State gives us revenue into one row for each Northeast state. A subquery pulls Northeast total as a reference column on every row
-- for direct comparison. ORDER BY sorts by Total_Revenue DESC to show highest performing states first. Each store's SUM is divided by the 
-- grand total and multiplied by 100 to get its percentage share.

-- 4. What is the number of transactions per month and average transaction amount by product category for the sales territory?

SELECT DATE_FORMAT(ss.Transaction_Date, '%Y-%m') AS Revenue_Month,
		ic.Category AS Product_Category,
        COUNT(*) AS Transction_Count,
        ROUND(AVG(ss.Sale_Amount),2) AS Average_Transaction_Amount,
        SUM(ss.Sale_Amount) AS Category_Revenue
FROM store_sales ss
INNER JOIN store_locations sl
		ON ss.Store_ID = sl.StoreId
INNER JOIN products p 
		ON ss.Prod_Num = p.ProdNum
INNER JOIN inventory_categories ic
		ON p.Categoryid = ic.Categoryid
WHERE sl.State = 'New Jersey'
GROUP BY Revenue_Month, Product_Category
ORDER BY Revenue_Month, Category_Revenue DESC;
-- Store_sales joins store_locations through StoreId and Store_ID, Store_sales joins products through ProdNum, and inventory_categories is reached through 
-- shared Categoryid.
-- COUNT calculates the number of transactions, AVG calculates the average transaction amount, and SUM calculates category revenue. Results are filtered directly by sl.State.
-- Results are grouped by month and category and ordered by category revenue DESC to display top performing categories first

-- 5. Can you provide a ranking of in-store sales performance by each store in the sales territory?
SELECT ss.Store_ID AS Store_ID,
	   sl.StoreLocation AS Store_City,
    SUM(ss.Sale_Amount) AS Total_Revenue,
	COUNT(ss.Sale_Amount) AS Transaction_Count,
	ROUND(AVG(ss.Sale_Amount), 2) AS Average_Transaction_Size,
	RANK() OVER (ORDER BY SUM(ss.Sale_Amount) DESC) AS Store_Rank
FROM store_sales ss
INNER JOIN store_locations sl
	ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'New Jersey'
GROUP BY Store_ID, Store_City
ORDER BY Store_Rank;
-- Store_sales is linked to store_locations through shared Store_ID and StoreId to filter by New Jersey and display store city names.
-- COUNT(ss.Sale_Amount) calculates total transactions, SUM(ss.Sale_Amount) calculates total revenue, and AVG(ss.Sale_Amount) measures average revenue per transaction.
-- RANK() assigns a rank to each store ordered determined by total revenue.
-- GROUP BY collapses all transactions into one row per store.
-- Results are ordered by Store_Rank to display top performing stores first.

-- 6. What is your recommendation for where to focus sales attention in the next quarter? 
/*
1)Based on the results of my queries we can see that Newark ($623k) and Trenton($598k) earn about twice what the next stores do, 
and they account for roughly 24% of total revenue ($5.18M). Our focus should be on protecting these stores, ensuring that they have
full inventory, enough staff, and strong promos. 
2)The other stores that have growth potential are Hoboken, Atlantic City, New Brunswik, Morristown, and Vineland. Their revenue varies between 
$306k and $317k. Average transactions almost identical, $137 to $141, so the reason behind the revenue difference is the number of visitors.
We can tackle that by implementing strategies to raise foor traffic: local promotions, events or loyalty based offers. 
Another startegy would also be add-on bundles at checkout, with the intention of rasing the basket size. 
3)Investigate Paterson before investing in it.It earned only $67K from 427 transactions, 
while others have around 2,200, though its average ticket ($157) is the highest. 
Find out whether it opened late, closed for a period, or has missing data. Then decide whether to fix it, support it, or leave it out of comparisons.
4)Keep technology strong and reduce reliance on it.
Technology & Accessories (70%) and Textbooks (18%) make up 88% of revenue. Prioritize stock and promotions for both. 
Use the small categories (apparel, art supplies, general books, stationery) as add-ons to bigger purchases, and track whether their share rises.
5) Learn from 2025’s jump and October spike.Revenue rose 29% from December 2024 to January 2025, and October 2025 reached $251K, about 60% above its neighbors. 
Find the cause of each, such as a promotion, a new product line, a large order, or a data error. If it’s repeatable, plan to repeat it.
*/