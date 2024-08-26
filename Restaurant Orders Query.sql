/*
Practice Project 

Answering questions and analyzing Restaurant Order dataset using basic to advanced SQL queries
*/

--Retrieve all columns from the menu_items table.
select * from menu_items

--Display the first 5 rows from the order_details table.
select top 5 * from order_details

-- Select the item_name and price columns for items in the 'Mexican' category.
-- Sort the result by price in descending order.

select item_name, price from menu_items 
where category = 'Mexican'
order by price desc

--Calculate the average price of menu items.
select AVG(price) as average_price from menu_items 

-- Find the total number of orders placed.
select count ( distinct order_id) as total_number_of_orders from order_details 

--Retrieve the item_name, order_date, and order_time for all items in the order_details table, 
--including their respective menu item details.
select item_name, category, price, order_date, order_time from menu_items 
join order_details 
on item_id = menu_item_id

-- List the menu items (item_name) with a price greater than the average price of all menu items.
select item_name from menu_items
where price > ( select AVG(price) as average_price from menu_items )

-- Extract the month from the order_date and count the number of orders placed in each month
select MONTH (order_date) as 'Month', COUNT(distinct order_id) as Total_orders from order_details
group by MONTH (order_date)
order  by 'Month'

-- Show the categories with the average price greater than $15.
--Include the count of items in each category.
select category, count(item_name) as number_of_items from menu_items
group by category
having avg (price) > 15 

-- Display the item_name and price, and indicate if the item is priced above $20 with a new column named 'Expensive'.
select item_name, price, 
case
when price >20 then 'Expensive' 
end 
from menu_items

--Update the price of the menu item with item_id = 101 to $25.
Update menu_items
set price = 25
where menu_item_id = 101

--Insert a new record into the menu_items table for a dessert item.
insert into menu_items values (133, 'Cheesecake', 'Dessert', 7)

--Delete all records from the order_details table where the order_id is less than 100.
delete from order_details
where order_id < 100

--Rank menu items based on their prices, displaying the item_name and its rank.
select item_name, price,
rank() over (order by price) as rank
from menu_items 

--Display the item_name and the price difference from the previous and next menu item.
SELECT item_name, price,
price - LAG(price, 1, price) OVER (ORDER BY item_name, price) AS prev_price_diff,
LEAD(price, 1, price) OVER (ORDER BY item_name, price) - price AS next_price_diff
FROM menu_items

-- Create a CTE that lists menu items with prices above $15.
-- Use the CTE to retrieve the count of such items.
with expensive_items as( 
select item_name, price from menu_items
where price > 15)

SELECT COUNT(*) AS expensive_item_count
FROM expensive_items

-- Retrieve the order_id, item_name, and price for all orders with their respective menu item details.
-- Include rows even if there is no matching menu item.
select order_id, menu_item_id, item_name, category, price from menu_items 
full join order_details 
on item_id = menu_item_id

-- Unpivot the menu_items table to show a list of menu item properties (item_id, item_name, category, price).
SELECT menu_item_id, property, Value
FROM
( SELECT menu_item_id, 
CAST(item_name AS VARCHAR(255)) AS item_name,
CAST(category AS VARCHAR(255)) AS category,
CAST(price AS VARCHAR(255)) AS price
FROM menu_items) AS SourceTable
UNPIVOT
( Value FOR Property IN (item_name, category, price)) AS unpvt

-- Write a dynamic SQL query that allows users to filter menu items based on category and price range.
CREATE PROCEDURE filter_menu_items
@Category NVARCHAR(50) = NULL,
@MinPrice DECIMAL(10, 2) = NULL,
@MaxPrice DECIMAL(10, 2) = NULL
AS
BEGIN
DECLARE @SQL NVARCHAR(MAX)

SET @SQL = 'SELECT item_name, category, price FROM menu_items WHERE 1=1'
IF @Category IS NOT NULL
BEGIN
SET @SQL = @SQL + ' AND category = @Category'
END

IF @MinPrice IS NOT NULL
BEGIN
SET @SQL = @SQL + ' AND price >= @MinPrice'
END

IF @MaxPrice IS NOT NULL
BEGIN
SET @SQL = @SQL + ' AND price <= @MaxPrice'
END

EXEC sp_executesql @SQL, N'@Category NVARCHAR(50), @MinPrice DECIMAL(10, 2), @MaxPrice DECIMAL(10, 2)', @Category, @MinPrice, @MaxPrice
END

EXEC filter_menu_items @Category = 'Mexican'
EXEC filter_menu_items @Minprice = 5 

-- Create a stored procedure that takes a menu category as input and returns the average price for that category.
CREATE PROCEDURE average_price_by_category
@Category NVARCHAR(255)  
BEGIN
SELECT AVG(price) AS AveragePrice
FROM menu_items
WHERE category = @Category;
END

EXEC average_price_by_category @Category = 'Italian'

-- Design a trigger that updates a log table whenever a new order is inserted into the order_details table.
CREATE TABLE order_log 
(log_id bigint IDENTITY(1,1), order_details_id bigint, order_id bigint, order_date DATETIME,
order_time time, item_id bigint, log_date DATETIME DEFAULT GETDATE())

CREATE TRIGGER new_order
ON order_details
AFTER INSERT
AS
BEGIN
INSERT INTO order_log (order_details_id,order_id, order_date, order_time, item_id)
SELECT order_details_id,order_id, order_date, order_time, item_id
FROM inserted;
END

Insert into order_details values (233, 99, GETDATE(),'', 109)

select * from order_log

-- Design a temporal table structure to track changes in menu item prices over time. 
-- (Create new table or alter & add to an empty one)
CREATE TABLE MenuItems (
    menu_item_id INT PRIMARY KEY,
    item_name NVARCHAR(255),
    category NVARCHAR(50),
    price DECIMAL(10, 2),
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.MenuItemsHistory))

INSERT INTO MenuItems (menu_item_id, item_name, category, price) VALUES
(101, 'Hamburger', 'American', 12.95),
(102, 'Cheeseburger', 'American', 13.95)

UPDATE MenuItems
SET price = 14.95
WHERE menu_item_id = 101

select * from MenuItems

SELECT * FROM MenuItems
FOR SYSTEM_TIME ALL
WHERE menu_item_id = 101 --Could add a trigger to track the time and date of any changes 

ALTER TABLE MenuItems
ADD PriceChangedAt DATETIME2

CREATE TRIGGER trg_UpdatePriceChangedAt
ON MenuItems
AFTER UPDATE
AS
BEGIN
IF UPDATE(price)
BEGIN
UPDATE MenuItems
SET PriceChangedAt = GETDATE()
FROM MenuItems
INNER JOIN inserted ON MenuItems.menu_item_id = inserted.menu_item_id;
END
END

UPDATE MenuItems
SET price = 15
WHERE menu_item_id = 101

SELECT *
FROM MenuItems
WHERE menu_item_id = 101

SELECT * FROM MenuItems
FOR SYSTEM_TIME ALL
WHERE menu_item_id = 101

 -- Create a role in the database and assign permissions to the role to restrict access to sensitive tables.
USE [Placement_Dost_Projects ]
GO
CREATE ROLE SensitiveDataAccess
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON menu_items TO SensitiveDataAccess

DENY SELECT, INSERT, UPDATE, DELETE ON order_details TO SensitiveDataAccess

ALTER ROLE SensitiveDataAccess ADD MEMBER --User Name (create new or existing)

-- Analyze the menu_items table and suggest an appropriate index to improve the performance of queries 
--involving category-based filtering.
Create INDEX idx_category ON menu_items(category) -- Single column indexing for categories as it's frequently for filtring
select * from menu_items where category='American'

create unique index idx_item_name on menu_items (menu_item_ID, item_name) --Unique index on both item id and name to ensure all the values are unique 