from flask import Flask, render_template, request
import os
import psycopg2, psycopg2.extras
from configparser import SafeConfigParser

app = Flask(__name__)

def getConn():
    # Function to retrieve the db connection config settings, make a connection 
    # and return it.
    db = SafeConfigParser()
    db.read('config.ini')
    conn = psycopg2.connect(
        host     = db.get('Database', 'Host'),
        dbname   = db.get('Database', 'DbName'),
        user     = db.get('Database', 'Username'),
        password = db.get('Database', 'Password'))
    return  conn

@app.route('/') # Homepage route.
def index():
    return render_template('index.html')

@app.route('/newCategory', methods =['POST']) # Statement 1.
def newCategory():
    try:
        conn = None # Retrieve values passed from HTML form:
        categoryID = request.form['categoryID']
        categoryName = request.form['categoryName']
        categoryType = request.form['categoryType']
        if categoryID == '': # Validation for CategoryID.
            raise Exception('Error: Missing Category ID')
        if categoryName == '': # Validation for CategoryName.
            raise Exception('Error: Missing Category Name')

        conn = getConn()
        cur = conn.cursor()
        cur.execute('SET search_path to wholesaler')

        cur.execute('INSERT INTO Category VALUES(%s, %s, %s)', \
        [categoryID, categoryName, categoryType]) # Assign form values to SQL statement.
        conn.commit()
        return render_template('index.html', msg1 = 'Category Added')

    except Exception as e: # If there's an error, post it back to the homepage.
        return render_template('index.html', msg1 = 'Record NOT Added ', error1 = e)

    finally:
        if conn:
            conn.close() # Close the connection.


@app.route('/deleteCategory', methods =['POST']) # Statement 2.
def deleteCategory():
    try:
        conn = None
        categoryID = request.form['categoryID'] # Retrieve from form.
        if categoryID == '': # Validation for CategoryID.
            raise Exception('Error: Missing Category ID')

        conn = getConn()
        cur = conn.cursor()
        cur.execute('SET search_path to wholesaler')

        cur.execute('DELETE FROM category WHERE CategoryID = %s', \
        [categoryID]) # Assign CategoryID from form to SQL.
        conn.commit()
        return render_template('index.html', msg2 = 'Category Deleted')

    except Exception as e:
        return render_template('index.html', msg2 = 'Record NOT Deleted ', error2 = e)

    finally:
        if conn:
            conn.close()


@app.route('/bookSummary', methods =['GET']) # Statement 3.
def bookSummary():
    try:
        conn = None # No data to take from the form this time.
        conn = getConn()
        cur = conn.cursor() 
        cur.execute('SET search_path to wholesaler')

        cur.execute ('SELECT * FROM Books_Summary \
        UNION ALL \
        SELECT \'Totals:\', COUNT(1), \'£\' || SUM(price) FROM Book;')
        
        rows = cur.fetchall()
        if rows:
            return render_template('bookSummary.html', rows = rows)
        else: 
            return render_template('index.html', msg3 = 'No data found')

    except Exception as e: 
        return render_template('index.html', msg3 = 'No data found', error3 = e)

    finally:
        if conn:
            conn.close() 


@app.route('/booksOrdered', methods =['POST']) # Statement 4.
def booksOrdered():
    try:
        conn = None # Take Publisher Name from HTML form.
        publisherName = request.form['publisherName']
        if publisherName == '': # Validation for PublisherName.
            raise Exception('Error: Missing Publisher Name')
        
        conn = getConn()
        cur = conn.cursor() 
        cur.execute('SET search_path to wholesaler')

        cur.execute ('SELECT to_char(OrderDate, \'MM\') AS "Month", \
            to_char(OrderDate, \'YYYY\') AS "Year", \
            Orderline.BookID, \
            Title, \
            SUM(1) AS "Total Orders", \
            SUM(Quantity) AS "Total Quantity", \
            \'£\' || SUM(UnitSellingPrice * Quantity) AS "Total Order Value", \
            \'£\' || SUM(Price * Quantity) AS "Total Retail Value" \
        FROM Orderline, ShopOrder, Book, Publisher \
        WHERE Orderline.ShopOrderID = ShopOrder.ShopOrderID \
            AND Orderline.BookID = Book.BookID \
            AND Book.PublisherID = Publisher.PublisherID \
            AND Publisher.Name = %s \
        GROUP BY "Month", "Year", Orderline.BookID, Title \
        ORDER BY "Year", "Month"', \
        [publisherName]) # Assign value from form to SQL statement.

        rows = cur.fetchall()
        if rows:
            return render_template('booksOrdered.html', rows = rows, publisherName = publisherName)
        else: 
            return render_template('index.html', msg4 = 'No data found')

    except Exception as e: 
        return render_template('index.html', msg4 = 'No data found', error4 = e)

    finally:
        if conn:
            conn.close() 


@app.route('/orderHistory', methods =['POST']) # Statement 5.
def orderHistory():
    try:
        conn = None
        bookID = request.form['bookID'] # From form.
        if bookID == '': # Validation for BookID.
            raise Exception('Error: Missing Book ID')
        
        conn = getConn()
        cur = conn.cursor() 
        cur.execute('SET search_path to wholesaler')

        cur.execute ('WITH Order_History ("Date", "Order Title", "Retail Price", \
                "Unit Price","Total Quantity", "Order Value", "Shop Name") AS ( \
            SELECT OrderDate, \
                Title, \'£\' || Price, \'£\' || UnitSellingPrice, Quantity, \
                UnitSellingPrice * Quantity, Name \
            FROM Orderline, ShopOrder, Book, Shop \
            WHERE Orderline.ShopOrderID = ShopOrder.ShopOrderID \
                AND Orderline.BookID = Book.BookID \
                AND ShopOrder.ShopID = Shop.ShopID \
                AND Book.BookID = %s) \
        SELECT * FROM Order_History \
        UNION ALL \
        SELECT NULL, \'Totals:\', NULL, NULL, SUM("Total Quantity"), \
            SUM("Order Value"), NULL \
            FROM Order_History \
        ORDER BY "Date"', \
        [bookID]) # Send BookID into the SQL query.

        rows = cur.fetchall()
        if rows:
            return render_template('orderHistory.html', rows = rows, bookID = bookID)
        else: 
            return render_template('index.html', msg5 = 'No data found')

    except Exception as e: 
        return render_template('index.html', msg5 = 'No data found', error5 = e)

    finally:
        if conn:
            conn.close()

@app.route('/salesPerformance', methods =['POST']) # Statement 6.
def salesPerformance():
    try:
        conn = None 
        startDate = request.form['startDate'] # Take data from form.
        endDate = request.form['endDate']
        if startDate == '': # Validation for StartDate.
            raise Exception('Error: Missing Start Date')
        if endDate == '': # Validation for EndDate.
            raise Exception('Error: Missing End Date')

        conn = getConn()
        cur = conn.cursor() 
        cur.execute('SET search_path to wholesaler')

        cur.execute ('WITH Sales_Report ("Staff ID", "Name", "Units Sold", \
                "Value of Orders") AS ( \
            SELECT SalesRep.SalesRepID AS s, SalesRep.Name, \
                    SUM(quantity), SUM(UnitSellingPrice * Quantity) AS v \
            FROM SalesRep \
            LEFT JOIN (Orderline \
                JOIN ShopOrder \
                    ON (Orderline.ShopOrderID = ShopOrder.ShopOrderID)) \
                ON (SalesRep.SalesRepID = ShopOrder.SalesRepID) \
                AND OrderDate >= %s \
                AND OrderDate <= %s \
            GROUP BY s \
            ORDER BY v DESC NULLS LAST) \
        SELECT * FROM Sales_Report \
        UNION ALL \
        SELECT NULL, \'Totals:\', SUM("Units Sold"), SUM("Value of Orders") \
            FROM Sales_Report;', \
        [startDate, endDate]) # Assign form values to SQL.

        rows = cur.fetchall()
        if rows:
            return render_template('salesPerformance.html', rows = rows, 
            startDate = startDate, endDate = endDate)
        else: 
            return render_template('index.html', msg6 = 'No data found')

    except Exception as e: 
        return render_template('index.html', msg6 = 'No data found', error6 = e)

    finally:
        if conn:
            conn.close()

@app.route('/categoryDiscount', methods =['POST']) # Statement 7.
def categoryDiscount():
    try:
        conn = None
        categoryID = request.form['categoryID'] # Take data from submission.
        discount = request.form['discount']
        if categoryID == '': # Validation for CategoryID.
            raise Exception('Error: Missing Category ID')
        if discount == '': # Validation for Discount value.
            raise Exception('Error: Missing Discount value')

        conn = getConn()
        cur = conn.cursor()
        cur.execute('SET search_path to wholesaler')

        cur.execute('WITH t AS ( \
            UPDATE Book \
	            SET Price = (Price * ((100.00 - %s) / 100.00)) \
	            WHERE CategoryID = %s \
                RETURNING BookID, Title, \'£\' || Price AS "New Price") \
            SELECT * FROM t;', \
        [discount, categoryID]) # Assign data to SQL.
        conn.commit()

        rows = cur.fetchall()
        if rows:
            return render_template('categoryDiscount.html', rows = rows, 
            categoryID = categoryID, discount = discount)
        else: 
            return render_template('index.html', msg7 = 'CategoryID not found')

    except Exception as e:
        return render_template('index.html', msg7 = 'Discount NOT applied', error7 = e)

    finally:
        if conn:
            conn.close()

# Check to ensure only one instance of the server is running:
if __name__ == "__main__":
    app.run(debug = True)