# What It Does #
This is a interactive site written with a python backend with Flask that communicates to a PostgreSQL database via psychopg2 to carry out SQL statements. The database itself is for a book wholesaler and contains the expected data for such a system, details on books, publishers and staff. PostgreSQL Data definitions and test data have been provided in this repository.

# What I Learned #
* Intermediate to advanced SQL (subqueries, indexes, constraints, triggers, functions, views etc)
* Connecting a Python backend to a database to send and retrieve data with SQL statements
* Working with PostgreSQL schemas via pgAdmin 3.
* Refreshed my knowledge of basic SQL and  working with Flask, Python, HTML5 and CSS3 to create a modern website.

# Usage Notes #
For the database, start up a new PostgreSQL database instance and note the host, database name, username and password. Load wholesaler_ddl.sql as a schema. Edit ownSite.py on line 13 to reference your previously built Postgres database.

To run, ensure Python 3, Flask and psychopg2 are installed on your machine of choice and navigate to the root of the project in your console. Use 'python ownSite.py' to start the server in development mode. Navigate to http://127.0.0.1:5000 in your browser to see the site in action. 

Sadly, this project is not currently being maintained on a live system, but you are able to compile and run a local copy with the instructions above. 