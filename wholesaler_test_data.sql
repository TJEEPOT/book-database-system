SET SEARCH_PATH TO wholesaler;

-- This data should correctly insert into the database. Only data that should 
-- pass correctly is submitted here. All sets of IDs and data are non-linear / 
-- non-alphabetical to ensure this does not cause an issue in the database.

INSERT INTO Category VALUES(1, 'Art','fiction');
INSERT INTO Category VALUES(2, 'Business','Non-fiction');
INSERT INTO Category VALUES(3, 'Kids','fiction');
INSERT INTO Category VALUES(6, 'Computing','Non-fiction');
INSERT INTO Category VALUES(8, 'Horror','fiction');
INSERT INTO Category VALUES(7, 'Sports','Non-fiction');

INSERT INTO SalesRep VALUES(1, 'Mary Smith');
INSERT INTO SalesRep VALUES(2, 'Sarah Jones');
INSERT INTO SalesRep VALUES(4, 'John Williams');
INSERT INTO SalesRep VALUES(3, 'William Taylor');
INSERT INTO SalesRep VALUES(6, 'Harry Davies');
INSERT INTO SalesRep VALUES(7, 'James Smith');
INSERT INTO SalesRep VALUES(8, 'Emily Brown');
INSERT INTO SalesRep VALUES(9, 'Olivia Davies');
INSERT INTO SalesRep VALUES(10, 'Sarah Jones'); -- non-unique Name test.

INSERT INTO Shop VALUES(1, 'Norwich Books South');
INSERT INTO Shop VALUES(3, 'Norwich Books North');
INSERT INTO Shop VALUES(2, 'Happy Books - Ipswich');
INSERT INTO Shop VALUES(5, 'Independant Books Cambridge');
INSERT INTO Shop VALUES(6, 'Kings Cross London Bookshop');

INSERT INTO Publisher VALUES(2, 'Dodo');
INSERT INTO Publisher VALUES(1, 'Hatchet Liver');
INSERT INTO Publisher VALUES(3, 'CollinHarpers');
INSERT INTO Publisher VALUES(4, 'Appleson Education');
INSERT INTO Publisher VALUES(5, 'Orly');

INSERT INTO Book VALUES(2, 'Painting With Bob', 10.99, 1, 1);
-- Under new Publisher:
INSERT INTO Book VALUES(3, 'Painting With Bob', 10.99, 1, 3);
-- Under new Category designation:
INSERT INTO Book VALUES(5, 'Painting With Bob 2', 10.99, 3, 1);
-- Deluxe edition price:
INSERT INTO Book VALUES(4, 'Painting With Bob Deluxe', 15.99, 1, 1);
INSERT INTO Book VALUES(6, 'The Art of No Deal', 10.75, 2, 4);
INSERT INTO Book VALUES(7, 'The Hungry Hungry Centipede', 4.99, 3, 1);
INSERT INTO Book VALUES(8, 'Fear and Lothing in Norwich City', 10.99, 1, 1);
-- No decimal places in price:
INSERT INTO Book VALUES(10, 'Quantum Computing: An Introduction', 25, 6, 5);
INSERT INTO Book VALUES(11, 'Best Goals of 2016 in Pictures', 4.59, 7, 2);
INSERT INTO Book VALUES(12, 'Best Goals of 2015 in Pictures', 4.49, 7, 2);

INSERT INTO ShopOrder VALUES(1, '2019-03-16', 1, 1);
-- Same person and day, different shop:
INSERT INTO ShopOrder VALUES(2, '2019-03-16', 3, 1);
-- Undefined date (defaults to today's date):
INSERT INTO ShopOrder(ShopOrderID, ShopID, SalesRepID) VALUES(3, 1, 6);
INSERT INTO ShopOrder VALUES(4, '2019-03-05', 5, 3);
INSERT INTO ShopOrder VALUES(5, '2019-04-11', 5, 6);
INSERT INTO ShopOrder VALUES(8, '2019-02-28', 6, 10);
INSERT INTO ShopOrder VALUES(7, '2019-01-17', 2, 8);
INSERT INTO ShopOrder VALUES(6, '2019-01-08', 1, 9);
INSERT INTO ShopOrder VALUES(9, '2018-10-08', 1, 4);
INSERT INTO ShopOrder VALUES(10, '2017-06-19', 2, 7);
INSERT INTO ShopOrder VALUES(11, '2018-04-14', 5, 7);
INSERT INTO ShopOrder VALUES(12, '2017-10-07', 6, 10);
INSERT INTO ShopOrder VALUES(13, '2019-02-12', 2, 1);
INSERT INTO ShopOrder VALUES(14, '2018-04-17', 3, 6);
INSERT INTO ShopOrder VALUES(15, '2018-12-28', 3, 8);
INSERT INTO ShopOrder VALUES(16, '2018-07-14', 5, 1);
INSERT INTO ShopOrder VALUES(17, '2018-11-30', 3, 9);
INSERT INTO ShopOrder VALUES(18, '2018-11-06', 1, 6);

INSERT INTO Orderline VALUES(1, 2, 1, 10.99);
-- Multiple books on one order test:
INSERT INTO Orderline VALUES(1, 4, 4, 9.95);
INSERT INTO Orderline VALUES(2, 4, 1, 15.99);
INSERT INTO Orderline VALUES(3, 5, 2, 9.50);
INSERT INTO Orderline VALUES(3, 2, 11, 5.35);
INSERT INTO Orderline VALUES(4, 12, 2, 3.25);
INSERT INTO Orderline VALUES(6, 10, 3, 25.00);
INSERT INTO Orderline VALUES(5, 5, 1, 10.99);
INSERT INTO Orderline VALUES(7, 11, 6, 3.55);
INSERT INTO Orderline VALUES(7, 2, 5, 10.90);
INSERT INTO Orderline VALUES(8, 12, 2, 3.55);
INSERT INTO Orderline VALUES(8, 11, 7, 3.35);
INSERT INTO Orderline VALUES(8, 7, 4, 10.95);
INSERT INTO Orderline VALUES(9, 11, 1, 4.59);
INSERT INTO Orderline VALUES(10, 5, 4, 10.99);
INSERT INTO Orderline VALUES(11, 5, 14, 9.99);
INSERT INTO Orderline VALUES(12, 7, 11, 10.99);
INSERT INTO Orderline VALUES(13, 2, 12, 10.99);
INSERT INTO Orderline VALUES(14, 12, 7, 4.49);
INSERT INTO Orderline VALUES(15, 7, 10, 4.49);
INSERT INTO Orderline VALUES(16, 10, 13, 24.99);
INSERT INTO Orderline VALUES(17, 4, 9, 14.99);
INSERT INTO Orderline VALUES(17, 11, 8, 4.59);
INSERT INTO Orderline VALUES(18, 10, 6, 20.59);