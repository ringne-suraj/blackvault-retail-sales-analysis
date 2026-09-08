
/*
Project: Black Vault
Author: Suraj
*/

-- Create a Database 

CREATE DATABASE black_vault;

USE black_vault;

/*import table from 
csv file folder
using import table wizard */

SHOW TABLES;

-- shows all data
SELECT * FROM Orders;

-- shows count of rows 
SELECT COUNT(*) FROM orders;

SELECT COUNT(*) FROM returns;

SELECT COUNT(*) FROM people;

SHOW TABLES;

-- displays columns from the table/schema
DESCRIBE orders;

DESCRIBE returns;

DESCRIBE people;

-- rename the column name 
ALTER TABLE orders
RENAME COLUMN `Order ID` TO Order_ID,
RENAME COLUMN `Order Date` TO Order_Date,
RENAME COLUMN `Ship Date` TO Ship_Date,
RENAME COLUMN `Ship Mode` TO Ship_Mode,
RENAME COLUMN `Customer ID` TO Customer_ID,
RENAME COLUMN `Customer Name` TO Customer_Name,
RENAME COLUMN `Postal Code` TO Postal_Code,
RENAME COLUMN `Product ID` TO Product_ID,
RENAME COLUMN `Sub-Category` TO Sub_Category,
RENAME COLUMN `Product Name` TO Product_Name,
RENAME COLUMN `Shipping Cost` TO Shipping_Cost,
RENAME COLUMN `Order Priority` TO Order_Priority;


ALTER TABLE returns
RENAME COLUMN `Order ID` TO Order_ID,
RENAME COLUMN `ï»¿Returned` TO Returned;

ALTER TABLE people
RENAME COLUMN `ï»¿Person` TO Person;

-- checkout
DESCRIBE orders;
DESCRIBE returns;
DESCRIBE people;

-- Manually finding missing VALUES
SELECT COUNT(*) AS Missing_Order_ID
FROM orders
WHERE Order_ID IS NULL;

-- Project version
SELECT
    COUNT(*) AS Total_Rows,

    SUM(Order_ID IS NULL) AS Missing_Order_ID,
    SUM(Customer_ID IS NULL) AS Missing_Customer_ID,
    SUM(Product_ID IS NULL) AS Missing_Product_ID,
    SUM(Order_Date IS NULL) AS Missing_Order_Date,

    SUM(Sales IS NULL) AS Missing_Sales,
    SUM(Quantity IS NULL) AS Missing_Quantity,
    SUM(Discount IS NULL) AS Missing_Discount,
    SUM(Profit IS NULL) AS Missing_Profit,
    SUM(Shipping_Cost IS NULL) AS Missing_Shipping_Cost

FROM orders;

SELECT
    COUNT(*) AS Total_Rows,

    SUM(Order_ID IS NULL) AS Missing_Order_ID,
    SUM(Returned IS NULL) AS Missing_Returned

FROM returns;


SELECT
    COUNT(*) AS Total_Rows,

    SUM(Person IS NULL) AS Missing_Person,
    SUM(Region IS NULL) AS Missing_Region

FROM people;

USE Black_vault;


/* ===========================================================
Phase 2: Uniqueness Check
Objective: Find Order_IDs that appear more than once.
Purpose:
- Detect repeated Order_IDs.
- This is an initial investigation only.
- A repeated Order_ID is NOT necessarily a duplicate record.
=========================================================== */
SELECT
    Order_ID,
    COUNT(*) AS Duplicate_Count
FROM orders
GROUP BY Order_ID
HAVING COUNT(*) > 1
ORDER BY Duplicate_Count DESC;

/* ===========================================================
Investigation Query
Objective:
Inspect one repeated Order_ID to understand why it appears
multiple times.

Business Question:
Does one Order_ID contain multiple products?
=========================================================== */
SELECT *
FROM orders
WHERE Order_ID = 'IN-2011-10286';


/* ===========================================================
Phase 2: Business Key Validation

Objective:
Check whether the same Product_ID appears more than once
within the same Order_ID.

Business Key:
(Order_ID + Product_ID)

Expected Result:
0 rows = No duplicate transaction lines.
=========================================================== */


SELECT
    Order_ID,
    Product_ID,
    COUNT(*) AS Duplicate_Count
FROM orders
GROUP BY Order_ID, Product_ID
HAVING COUNT(*) > 1
ORDER BY Duplicate_Count DESC;


/* ===========================================================
Phase 3 : Validity Check
Objective : Find invalid business values
=========================================================== */
DESCRIBE orders;


SELECT
    COUNT(*) AS Total_Rows,

    SUM(Sales < 0) AS Negative_Sales,
    SUM(Profit IS NULL) AS Missing_Profit,
    SUM(Quantity <= 0) AS Invalid_Quantity,
    SUM(Discount < 0 OR Discount > 1) AS Invalid_Discount,
    SUM(Shipping_Cost < 0) AS Negative_Shipping_Cost

FROM orders;


/* ===========================================================
Phase 4 : Consistency Check
Objective : Verify that Region values are standardized
=========================================================== */

SELECT
    Region,
    COUNT(*) AS Total_Records
FROM orders
GROUP BY Region
ORDER BY Region;

/* ===========================================================
Objective : Verify Ship_Mode values are consistent
=========================================================== */

SELECT
    Ship_Mode,
    COUNT(*) AS Total_Records
FROM orders
GROUP BY Ship_Mode
ORDER BY Ship_Mode;


/* ===========================================================
Objective : Verify Market values are standardized
=========================================================== */

SELECT
    Market,
    COUNT(*) AS Total_Records
FROM orders
GROUP BY Market
ORDER BY Market;

/* ===========================================================
Phase 5 : Relationship Check
Objective : Verify every returned order exists in orders table
=========================================================== */

SELECT
    r.Order_ID
FROM returns r
LEFT JOIN orders o
ON r.Order_ID = o.Order_ID
WHERE o.Order_ID IS NULL;

SELECT
    Order_ID,
    LENGTH(Order_ID) AS Length_ID
FROM returns
LIMIT 10;

SELECT
    Order_ID,
    LENGTH(Order_ID) AS Length_ID
FROM orders
LIMIT 10;

SELECT
    COUNT(*) AS Matching_Orders
FROM returns r
INNER JOIN orders o
ON r.Order_ID = o.Order_ID;

SELECT *
FROM returns
LIMIT 10;

SELECT DISTINCT Order_ID
FROM returns
LIMIT 10;

SELECT DISTINCT Order_ID
FROM orders
LIMIT 10;

/* ===========================================================
Phase 5 : Relationship Investigation
Objective : Find returned orders that don't exist in orders
=========================================================== */
SELECT
COUNT(DISTINCT Order_ID) AS Orders_Distinct
FROM orders;

SELECT
COUNT(DISTINCT Order_ID) AS Returns_Distinct
FROM returns;

SELECT
COUNT(*) AS Returned_Orders
FROM orders o
INNER JOIN returns r
ON o.Order_ID = r.Order_ID;


SELECT
r.Order_ID
FROM returns r
LEFT JOIN orders o
ON r.Order_ID = o.Order_ID
WHERE o.Order_ID IS NULL;

SELECT
r.Order_ID
FROM returns r
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.Order_ID = r.Order_ID
)
LIMIT 20;



SELECT
COUNT(*) AS Matched_Regions
FROM orders o
INNER JOIN people p
ON o.Region = p.Region;


SELECT DISTINCT
o.Region
FROM orders o
LEFT JOIN people p
ON o.Region = p.Region
WHERE p.Region IS NULL;

/* ============================================================
   PHASE 5 : RELATIONSHIP VALIDATION
   Purpose: Verify relationships between Orders, Returns, and People tables.
   ============================================================ */

/* Step 1: Verify unique Order_IDs in the Orders table */

/* Step 2: Verify unique Order_IDs in the Returns table */

/* Step 3: Validate the relationship between Orders and Returns (INNER JOIN) */

/* Step 4: Find Order_IDs present in Returns but missing in Orders (LEFT JOIN) */

/* Step 5: Find Order_IDs present in Returns but missing in Orders (NOT EXISTS) */

/* Step 6: Validate the relationship between Orders and People using Region */

/* Step 7: Find Regions in Orders that do not exist in the People table */


-- Phase 6 Data cleaning and preparation 
USE black_vault;
DESCRIBE orders;

-- VERIFY 
SELECT
    Order_Date,
    Ship_Date
FROM orders
LIMIT 10;

-- CHECK FOR INVALID DATE VALUES
SELECT *
FROM orders
WHERE Order_Date IS NULL
   OR Ship_Date IS NULL
   OR TRIM(Order_Date) = ''
   OR TRIM(Ship_Date) = '';

-- CONVERT INTO VALUES
UPDATE orders
SET
    Order_Date = STR_TO_DATE(Order_Date, '%d-%m-%Y'),
    Ship_Date = STR_TO_DATE(Ship_Date, '%d-%m-%Y');
    
-- CHANGE THE DATA TYPE
ALTER TABLE orders
MODIFY COLUMN Order_Date DATE,
MODIFY COLUMN Ship_Date DATE;

-- VERIFY 
SELECT
    Order_Date,
    Ship_Date
FROM orders
LIMIT 10;

DESCRIBE orders;

-- negative sales
SELECT *
FROM orders
WHERE Sales < 0;

-- Invalid Quantity
SELECT *
FROM orders
WHERE Quantity <= 0;

-- Invalid Discount
SELECT *
FROM orders
WHERE Discount < 0
   OR Discount > 1;
   
-- negative shipping cost
SELECT *
FROM orders
WHERE Shipping_Cost < 0;


-- RANGE OF PROFIT
SELECT
    MIN(Profit) AS Minimum_Profit,
    MAX(Profit) AS Maximum_Profit
FROM orders;


-- CHECK FOR BLANK TEXT VALUES
SELECT *
FROM orders
WHERE TRIM(Customer_Name) = ''
   OR TRIM(City) = ''
   OR TRIM(State) = ''
   OR TRIM(Category) = ''
   OR TRIM(Sub_Category) = '';
   
-- CHECK FOR LEADING AND TRAILING SPACES
SELECT
    Customer_Name,
    LENGTH(Customer_Name) AS Original_Length,
    LENGTH(TRIM(Customer_Name)) AS Trimmed_Length
FROM orders
WHERE LENGTH(Customer_Name) <> LENGTH(TRIM(Customer_Name))
LIMIT 20;

-- PHASE 4: SQL BUSINESS ANALYSIS

-- -- Calculate total company sales
SELECT
ROUND(SUM(Sales),2) As Total_Sales
FROM orders;

-- TOTAL ORDERS
SELECT
COUNT(DISTINCT Order_ID) AS Total_Orders
FROM orders;

-- TOTAL CUSTOMERS
SELECT 
COUNT(DISTINCT Customer_ID) AS Total_Customers
FROM orders;

-- TOTAL QUANTITY
SELECT
SUM(Quantity) AS Total_Quantity
FROM orders;

-- AVERAGE ORDER VALUE

SELECT
	ROUND(
    SUM(Sales) / COUNT(DISTINCT Order_ID),
    2
    ) AS Average_Order_Value
FROM orders;

-- Average Profit Per Order

SELECT
    ROUND(
        SUM(Profit) / COUNT(DISTINCT Order_ID),
        2
    ) AS Avg_Profit_Per_Order
FROM orders;

-- Profit Margin %
SELECT
	ROUND(
    (SUM(Profit) / SUM(Sales)) * 100,
    2
    ) AS Profit_Margin
FROM orders;

-- AVERAGE DISCOUT
SELECT
	ROUND(AVG(Discount), 2) AS Average_Discount
FROM orders;

-- TOTAL SHIPPING COST
SELECT
ROUND(SUM(Shipping_Cost), 2) AS Total_Shipping_Cost
FROM orders;

--  PRODUCT ANALYSIS


-- TOP 10 PRODUCTS BY SALES
SELECT Product_Name,
       ROUND(SUM(Sales),2) AS Total_Sales
FROM orders
GROUP BY Product_Name
ORDER BY Total_Sales DESC
LIMIT 10;

-- TOP 10 PRODUCTS BY PROFIT
SELECT Product_Name,
       ROUND(SUM(Profit),2) AS Total_Profit
FROM orders
GROUP BY Product_Name
ORDER BY Total_Profit DESC
LIMIT 10;

-- PRODUCT CAUSING LOSSES
SELECT
    Product_Name,
    ROUND(SUM(Profit),2) AS Total_Profit
FROM orders
GROUP BY Product_Name
HAVING SUM(Profit) < 0
ORDER BY Total_Profit;

-- TOP/BEST PERFORMING CATEGORIES
SELECT
    Category,
    ROUND(SUM(Sales),2) AS Total_Sales,
    ROUND(SUM(Profit),2) AS Total_Profit
FROM orders
GROUP BY Category
ORDER BY Total_Profit DESC;

-- MOST PROFITABLE SUB-CATEGORIES
SELECT
    Sub_Category,
    ROUND(SUM(Sales),2) AS Total_Sales,
    ROUND(SUM(Profit),2) AS Total_Profit
FROM orders
GROUP BY Sub_Category
ORDER BY Total_Profit DESC;

-- LOSS MAKING SUB-CATEGORIES
SELECT
    Sub_Category,
    ROUND(SUM(Profit),2) AS Total_Profit
FROM orders
GROUP BY Sub_Category
HAVING SUM(Profit) < 0
ORDER BY Total_Profit;


-- CUSTOMER ANALYSIS

--  TOP 10 CUSTOMERS BY SALES
SELECT
    Customer_ID,
    Customer_Name,
    ROUND(SUM(Sales),2) AS Total_Sales
FROM orders
GROUP BY Customer_ID, Customer_Name
ORDER BY Total_Sales DESC
LIMIT 10;

-- TOP 10 CJSTOMERS BY PROFIT
SELECT
    Customer_ID,
    Customer_Name,
    ROUND(SUM(Profit),2) AS Total_Profit
FROM orders
GROUP BY Customer_ID, Customer_Name
ORDER BY Total_Profit DESC
LIMIT 10;

-- CUSTOMER SEGMENT PERFORMANCE
SELECT
    Segment,
    COUNT(DISTINCT Customer_ID) AS Total_Customers,
    ROUND(SUM(Sales),2) AS Total_Sales,
    ROUND(SUM(Profit),2) AS Total_Profit
FROM orders
GROUP BY Segment
ORDER BY Total_Profit DESC;

-- CUSTOMER CAUSING LOSSES
SELECT
    Customer_ID,
    Customer_Name,
    ROUND(SUM(Profit),2) AS Total_Profit
FROM orders
GROUP BY Customer_ID, Customer_Name
HAVING SUM(Profit) < 0
ORDER BY Total_Profit;

-- HIGH VALUE CUSTOMERS (BASED ON SALES AND ORDERS
SELECT
    Customer_ID,
    Customer_Name,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    ROUND(SUM(Sales),2) AS Total_Sales
FROM orders
GROUP BY Customer_ID, Customer_Name
HAVING SUM(Sales) > 10000
ORDER BY Total_Sales DESC;

-- REGION & MARKET ANALYSIS

-- WHICH REGION GENERATE HIGH SALES AND PROFIT
SELECT
    Region,
    ROUND(SUM(Sales),2) AS Total_Sales,
    ROUND(SUM(Profit),2) AS Total_Profit
FROM orders
GROUP BY Region
ORDER BY Total_Profit DESC;

-- BEST MARKETS (PERFORMANCE)
SELECT
    Market,
    ROUND(SUM(Sales),2) AS Total_Sales,
    ROUND(SUM(Profit),2) AS Total_Profit
FROM orders
GROUP BY Market
ORDER BY Total_Profit DESC;

-- TOP 10 COUNTREIS BY SALES
SELECT
    Country,
    ROUND(SUM(Sales),2) AS Total_Sales,
    ROUND(SUM(Profit),2) AS Total_Profit
FROM orders
GROUP BY Country
ORDER BY Total_Sales DESC
LIMIT 10;

-- BOTTOM 10 COUNTRIES BY PROFIT
SELECT
    Country,
    ROUND(SUM(Profit),2) AS Total_Profit
FROM orders
GROUP BY Country
ORDER BY Total_Profit ASC
LIMIT 10;

-- TOP 10 CITIES BY SALES
SELECT
    City,
    ROUND(SUM(Sales),2) AS Total_Sales,
    ROUND(SUM(Profit),2) AS Total_Profit
FROM orders
GROUP BY City
ORDER BY Total_Sales DESC
LIMIT 10;

-- TIME AND SHIPPING ANALYSIS
 
-- MONTHLY SALES AND PROFIT TREND
SELECT
    YEAR(Order_Date) AS Year,
    MONTH(Order_Date) AS Month,
    ROUND(SUM(Sales),2) AS Total_Sales,
    ROUND(SUM(Profit),2) AS Total_Profit
FROM orders
GROUP BY Year, Month
ORDER BY Year, Month;

-- YEARLY PERFORMANCE
SELECT
    YEAR(Order_Date) AS Year,
    ROUND(SUM(Sales),2) AS Total_Sales,
    ROUND(SUM(Profit),2) AS Total_Profit
FROM orders
GROUP BY Year
ORDER BY Year;

-- TOP SELLING MONTHS
SELECT
    DATE_FORMAT(Order_Date,'%M %Y') AS Month,
    ROUND(SUM(Sales),2) AS Total_Sales
FROM orders
GROUP BY Month
ORDER BY Total_Sales DESC
LIMIT 1;

-- SHIPPING AND RETURN ANALYSIS

-- SHIP MODE PERFORMANCE
SELECT
    Ship_Mode,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    ROUND(SUM(Sales),2) AS Total_Sales,
    ROUND(SUM(Profit),2) AS Total_Profit
FROM orders
GROUP BY Ship_Mode
ORDER BY Total_Profit DESC;

-- MARKET-WISE RETURNS
SELECT
    o.Market,
    COUNT(r.Order_ID) AS Returned_Orders
FROM returns r
JOIN orders o
ON r.Order_ID = o.Order_ID
GROUP BY o.Market
ORDER BY Returned_Orders DESC;

-- CATEGORY-WISE RETURNS
SELECT
    o.Category,
    COUNT(r.Order_ID) AS Returned_Orders
FROM returns r
JOIN orders o
ON r.Order_ID = o.Order_ID
GROUP BY o.Category
ORDER BY Returned_Orders DESC;

SELECT VERSION();




