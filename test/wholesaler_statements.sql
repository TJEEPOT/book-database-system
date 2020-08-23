-- Below I have listed the correct working SQL statement fpr each of the 7 
-- tasks. These statements and all other testing has been saved to 
-- Testing_Results.pdf (for printability) and Testing_Results.htm (for 
-- readability) and enclosed with this file.


-- 1. Given a category ID,name and type, create a new category.
INSERT INTO category VALUES(9, 'Technology', 'Non-fiction');


-- 2. Given a category ID, remove the record for that category. 
DELETE FROM category WHERE CategoryID = 8;
 

-- 3. Produce a summary report of books available in each category. 
-- The report should include the number of book titles and the average price 
-- in each category as well as an appropriate report header and a summary line 
-- with totals (hint: summary line may be produced by a separate query). Format
-- your field values appropriately. 
SELECT * FROM Books_Summary
UNION ALL
SELECT 'Totals:', COUNT(1), '£' || SUM(price) FROM Book;
-- Note: We may be able to use ROLLUP as demonstrated in the course text 
-- (beginning at page 1300), as this is now part of the Postgres standard since 
-- v9.5, however I felt this wasn't the intention of this excersise and went 
-- with the more approprate UNION ALL instead.


-- 4. Given a publisher name, produce a report of books ordered by year and 
-- month. For each year and month the report should show bookid, title, total 
-- number of orders for the title, total quantity and total selling value 
-- (both order value and retail value). 
SELECT to_char(OrderDate, 'MM') AS "Month",
	to_char(OrderDate, 'YYYY') AS "Year",
	Orderline.BookID, 
	Title,
	SUM(1) AS "Total Orders", 
	SUM(Quantity) AS "Total Quantity",
	'£' || SUM(UnitSellingPrice * Quantity) AS "Total Order Value",
	'£' || SUM(Price * Quantity) AS "Total Retail Value"
FROM Orderline, ShopOrder, Book, Publisher
WHERE Orderline.ShopOrderID = ShopOrder.ShopOrderID
	AND Orderline.BookID = Book.BookID
	AND Book.PublisherID = Publisher.PublisherID
	AND Publisher.Name = 'Hatchet Liver'
GROUP BY "Month", "Year", Orderline.BookID, Title
ORDER BY "Year", "Month";


-- 5. Given a book ID, produce the order history (i.e. all order lines) for 
-- that book. The query should include order date, order title, price, 
-- unitselling price, total quantity, order value and shop name. Include a 
-- summary line showing the total number of copies ordered and the total 
-- selling value (hint: summary line may be produced by a separate query). 
WITH Order_History ("Order Date", "Order Title", "Retail Price","Unit Price",
	"Total Quantity", "Order Value", "Shop Name") AS (
	SELECT OrderDate,
		Title,
		'£' || Price,
		'£' || UnitSellingPrice,
		Quantity,
		UnitSellingPrice * Quantity,
		Name
	FROM Orderline, ShopOrder, Book, Shop
	WHERE Orderline.ShopOrderID = ShopOrder.ShopOrderID
		AND Orderline.BookID = Book.BookID
		AND ShopOrder.ShopID = Shop.ShopID
		AND Book.BookID = 2)
SELECT * FROM Order_History
UNION ALL
SELECT NULL, 'Totals:', NULL, NULL, SUM("Total Quantity"), SUM("Order Value"), NULL 
	FROM Order_History
ORDER BY "Order Date";


-- 6. Given start and end dates, produce a report showing the performance of 
-- each sales representative over that period. The report should begin with 
-- the rep who generated most orders by value and include total units sold and 
-- total order value. It should include all sales reps. 
WITH Sales_Report ("Staff ID", "Name", "Units Sold", "Value of Orders") AS (
	SELECT SalesRep.SalesRepID AS s,
			SalesRep.Name,
			SUM(quantity),
			SUM(UnitSellingPrice * Quantity) AS v
	FROM SalesRep
	LEFT JOIN (Orderline 
		JOIN ShopOrder 
			ON (Orderline.ShopOrderID = ShopOrder.ShopOrderID))
		ON (SalesRep.SalesRepID = ShopOrder.SalesRepID)
		AND OrderDate >= '2018-01-01'
		AND OrderDate <= '2019-03-31'
	GROUP BY s
	ORDER BY v DESC NULLS LAST)
SELECT * FROM Sales_Report
UNION ALL
SELECT NULL, 'Totals:', SUM("Units Sold"), SUM("Value of Orders")
	FROM Sales_Report;


-- 7. Given a category ID and discount percentage, apply a discount to the 
-- standard price of all books in that category.
WITH t AS (
	UPDATE Book
		SET Price = (Price * ((100.00 - 10.00) / 100.00)) --10% discount
		WHERE CategoryID = 7
		RETURNING BookID, Title, '£' || Price AS "New Price")
SELECT * FROM t; -- Returns the books after discount.