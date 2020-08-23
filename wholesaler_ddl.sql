DROP SCHEMA IF EXISTS wholesaler CASCADE;
CREATE SCHEMA wholesaler;
SET SEARCH_PATH TO wholesaler;

-- Database Design (with Column Constraints):
CREATE TABLE Category
(
	CategoryID		INTEGER		PRIMARY KEY,
	Name			VARCHAR(50)	UNIQUE		NOT NULL,
	CategoryType	VARCHAR(20)	NOT NULL
);

CREATE TABLE SalesRep
(
	SalesRepID		INTEGER		PRIMARY KEY,
	Name			VARCHAR(50)	NOT NULL
);

CREATE TABLE Shop
(
	ShopID			INTEGER		PRIMARY KEY,
	Name			VARCHAR(50)	UNIQUE		NOT NULL
);

CREATE TABLE Publisher
(
	PublisherID		INTEGER		PRIMARY KEY,
	Name			VARCHAR(50)	UNIQUE		NOT NULL
);

CREATE TABLE Book
(
	BookID			INTEGER			PRIMARY KEY,
	Title			VARCHAR(50)		NOT NULL,
	Price			DECIMAL(10,2)	NOT NULL,
	CategoryID		INTEGER,
	PublisherID		INTEGER
);

CREATE TABLE ShopOrder
(
	ShopOrderID		INTEGER		PRIMARY KEY,
	OrderDate		DATE		NOT NULL	DEFAULT CURRENT_DATE,
	ShopID			INTEGER,
	SalesRepID		INTEGER
);

CREATE TABLE Orderline
(
	ShopOrderID		INTEGER,
	BookID			INTEGER,
	Quantity		INTEGER		NOT NULL,
	UnitSellingPrice	DECIMAL(10,2)	NOT NULL,
	PRIMARY KEY(ShopOrderID, BookID)
);

-- Domain Constraints:
ALTER TABLE Category 
	ADD CONSTRAINT Category_CategoryType_check 
		CHECK (CategoryType IN ('fiction', 'Non-fiction'));

ALTER TABLE Book
	ADD CONSTRAINT Book_Price_check
		CHECK (Price >= 0);

ALTER TABLE ShopOrder
	ADD CONSTRAINT ShopOrder_OrderDate_min_check
		CHECK (OrderDate >= '1970-01-01');

ALTER TABLE OrderLine
	ADD CONSTRAINT OrderLine_Quantity_check
		CHECK (Quantity > 0);

ALTER TABLE Orderline
	ADD CONSTRAINT Orderline_UnitSellingPrice_check
		CHECK (UnitSellingPrice >= 0);


-- Referential Integrity Constraints:
ALTER TABLE Book
	ADD CONSTRAINT Book_CategoryID_fk
		FOREIGN KEY (CategoryID)
		REFERENCES Category(CategoryID)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,

	ADD CONSTRAINT Book_PublisherID_fk
		FOREIGN KEY (PublisherID)
		REFERENCES Publisher(PublisherID)
		ON DELETE RESTRICT
		ON UPDATE CASCADE;

ALTER TABLE ShopOrder
	ADD CONSTRAINT ShopOrder_ShopID_fk
		FOREIGN KEY (ShopID)
		REFERENCES Shop(ShopID)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,

	ADD CONSTRAINT ShopOrder_SalesRepID_fk
		FOREIGN KEY (SalesRepID)
		REFERENCES SalesRep(SalesRepID)
		ON DELETE RESTRICT
		ON UPDATE CASCADE;

ALTER TABLE Orderline
	ADD CONSTRAINT Orderline_ShopOrderID_fk
		FOREIGN KEY (ShopOrderID)
		REFERENCES ShopOrder(ShopOrderID)
		ON DELETE CASCADE
		ON UPDATE CASCADE,

	ADD CONSTRAINT Orderline_BookID_fk
		FOREIGN KEY (BookID)
		REFERENCES Book(BookID)
		ON DELETE RESTRICT
		ON UPDATE CASCADE;

-- Triggers and Functions:
-- The trigger activates when a new entry is added to the Orderline table. 
-- If the UnitSellingPrice value is higher than the matching value of 
-- Book.Price, this trigger sets UnitSellingPrice to that value to ensure it 
-- doesn't go over. 
CREATE FUNCTION unitprice_max()
RETURNS TRIGGER AS $$
DECLARE BookPrice DECIMAL := (SELECT Price FROM Book 
	WHERE BookID = NEW.BookID); -- Variable decleration for below.
BEGIN
	IF (NEW.UnitSellingPrice > BookPrice) THEN
	NEW.UnitSellingPrice = BookPrice;
	END IF;
	RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER Orderline_UnitSellingPrice_max
BEFORE INSERT ON Orderline
FOR EACH ROW
EXECUTE PROCEDURE unitprice_max();

	
-- Indexes:
-- As indexes should be avoided for small tables, I have opted not to use one on
-- Publisher.Name (for task 4) as I have assumed that table will not contain 
-- many items.

-- Unique Index not required for Book.BookID (for task 5) as Postgres 
-- automatically creates these for all Primary Keys.

-- Index for ShopOrder.OrderDate to assist with Task 6:
CREATE INDEX OrderDate_Index
	ON ShopOrder(OrderDate);


-- Views:
-- A view to simplify Statement 3:
CREATE VIEW Books_Summary ("Name", "Number of Titles", "Category Average Price") AS
	SELECT(
		SELECT Name FROM Category WHERE Category.CategoryID = Book.CategoryID),
		COUNT(CategoryID)
			AS "Number of Titles",
		'£' || ROUND(AVG(Price),2)
			AS "Category Average Price"
	FROM Book
	GROUP BY CategoryID;