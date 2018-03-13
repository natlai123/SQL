
/*****************************************************************/
/*																 */
/* Practice code from Alan Beaulieu Beijing (2009) Learning SQL  */
/*																 */
/*     Modeified and created by Nathaniel Lai (2017)			 */
/*																 */
/*****************************************************************/


/*********************************/
/*								 */
/* 	 Chapter 10: Join Revisited  */
/*								 */
/*********************************/

SELECT a.account_id, a.cust_id, b.name
FROM account a LEFT OUTER JOIN business b
ON a.cust_id = b.cust_id;

SELECT a.account_id, a.cust_id, b.name
FROM account a RIGHT OUTER JOIN business b
ON a.cust_id = b.cust_id;


SELECT a.account_id, a.product_cd,
	   CONCAT(i.fname, ' ', i.lname) person_name,
       b.name business_name
FROM account a LEFT OUTER JOIN individual i
   ON a.cust_id = i.cust_id
LEFT OUTER JOIN business b
   ON a.cust_id = b.cust_id;

/*Which is the same as using subquery below*/

SELECT account_ind.account_id, account_ind.product_cd,
account_ind.person_name,
b.name business_name
FROM
   (SELECT a.account_id, a.product_cd, a.cust_id,
	CONCAT(i.fname, ' ', i.lname) person_name
	FROM account a LEFT OUTER JOIN individual i
	ON a.cust_id = i.cust_id) account_ind
LEFT OUTER JOIN business b
ON account_ind.cust_id = b.cust_id;


/*generate a list of employees and their supervisors:By changing the join from an inner join to an outer join,
however, the result set will include all employees (18 rows), including those without supervisors:*/

SELECT e.fname, e.lname,
e_mgr.fname mgr_fname, e_mgr.lname mgr_lname
FROM employee e LEFT OUTER JOIN employee e_mgr
ON e.superior_emp_id = e_mgr.emp_id;

/*If you change the join to be a
right outer join, you would see the following results:*/

SELECT e.fname, e.lname,
e_mgr.fname mgr_fname, e_mgr.lname mgr_lname
FROM employee e RIGHT OUTER JOIN employee e_mgr
ON e.superior_emp_id = e_mgr.emp_id;

/*This query shows each supervisor (still the third and fourth columns) along with the
set of employees he or she supervises (28 rows since supervisor can supervise more than 
one employee)*/

/*Frabricating a large table using Cross Join*/

SELECT ones.num + tens.num + hundreds.num
FROM
(SELECT 0 num UNION ALL
SELECT 1 num UNION ALL
SELECT 2 num UNION ALL
SELECT 3 num UNION ALL
SELECT 4 num UNION ALL
SELECT 5 num UNION ALL
SELECT 6 num UNION ALL
SELECT 7 num UNION ALL
SELECT 8 num UNION ALL
SELECT 9 num) ones
 CROSS JOIN
(SELECT 0 num UNION ALL
SELECT 10 num UNION ALL
SELECT 20 num UNION ALL
SELECT 30 num UNION ALL
SELECT 40 num UNION ALL
SELECT 50 num UNION ALL
SELECT 60 num UNION ALL
SELECT 70 num UNION ALL
SELECT 80 num UNION ALL
SELECT 90 num) tens
 CROSS JOIN
(SELECT 0 num UNION ALL
SELECT 100 num UNION ALL
SELECT 200 num UNION ALL
SELECT 300 num) hundreds;

# return 400 rows (10*10*4)
/*The next step is to convert the set of numbers to a set of dates. To do this, I will use
the date_add() function to add each number in the result set to January 1, 2008. Then
I’ll add a filter condition to throw away any dates that venture into 2009:*/

SELECT DATE_ADD('2008-01-01',
INTERVAL (ones.num + tens.num + hundreds.num) DAY) dt
FROM
(SELECT 0 num UNION ALL
SELECT 1 num UNION ALL
SELECT 2 num UNION ALL
SELECT 3 num UNION ALL
SELECT 4 num UNION ALL
SELECT 5 num UNION ALL
SELECT 6 num UNION ALL
SELECT 7 num UNION ALL
SELECT 8 num UNION ALL
SELECT 9 num) ones
 CROSS JOIN
(SELECT 0 num UNION ALL
SELECT 10 num UNION ALL
SELECT 20 num UNION ALL
SELECT 30 num UNION ALL
SELECT 40 num UNION ALL
SELECT 50 num UNION ALL
SELECT 60 num UNION ALL
SELECT 70 num UNION ALL
SELECT 80 num UNION ALL
SELECT 90 num) tens
CROSS JOIN
(SELECT 0 num UNION ALL
SELECT 100 num UNION ALL
SELECT 200 num UNION ALL
SELECT 300 num) hundreds
WHERE DATE_ADD('2008-01-01',
INTERVAL (ones.num + tens.num + hundreds.num) DAY) < '2009-01-01'
ORDER BY 1;
# Return 366 dates. The sever figures out leap day for you

/*To generate a query that shows every day in 2008 along with the number of banking 
transactions conducted on that day, the number of accounts opened on that day*/

#Changing Year to 2003 (365 days)

SELECT days.dt, COUNT(t.txn_id) 
FROM transaction t RIGHT OUTER JOIN
(SELECT DATE_ADD('2003-01-01',
INTERVAL (ones.num + tens.num + hundreds.num) DAY) dt
 FROM
 (SELECT 0 num UNION ALL
SELECT 1 num UNION ALL 
SELECT 2 num UNION ALL
SELECT 3 num UNION ALL
SELECT 4 num UNION ALL
SELECT 5 num UNION ALL
SELECT 6 num UNION ALL
SELECT 7 num UNION ALL
SELECT 8 num UNION ALL
SELECT 9 num) ones
CROSS JOIN
(SELECT 0 num UNION ALL
SELECT 10 num UNION ALL
SELECT 20 num UNION ALL
SELECT 30 num UNION ALL
SELECT 40 num UNION ALL
SELECT 50 num UNION ALL
SELECT 60 num UNION ALL
SELECT 70 num UNION ALL
SELECT 80 num UNION ALL
SELECT 90 num) tens
CROSS JOIN
(SELECT 0 num UNION ALL
SELECT 100 num UNION ALL
SELECT 200 num UNION ALL
SELECT 300 num) hundreds
WHERE DATE_ADD('2003-01-01',
 INTERVAL (ones.num + tens.num + hundreds.num) DAY) <
 '2004-01-01') days
ON days.dt = t.txn_date
GROUP BY days.dt
ORDER BY 1;

/*This is one of the more interesting queries thus far in the book, in that it includes cross
joins, outer joins, a date function, grouping, set operations (union all), and an aggregate
function (count()).*/


/*Natural Join*/

/*You can choose a join type that allows you to name
the tables to be joined but lets the database server determine what the join conditions
need to be. Known as the natural join, this join type relies on identical column names
across multiple tables to infer the proper join conditions. For example, the account
table (25 rows) includes a column named cust_id, which is the foreign key to the customer table,
(13 rows) whose primary key is also named cust_id. Thus, you can write a query that uses natural
join to join the two tables:*/

SELECT a.account_id, a.cust_id, c.cust_type_cd, c.fed_id
FROM account a NATURAL JOIN customer c;
/* But better yet avoid using this join because if two tables do not share a same column name,
a Cross product is resulted */


/*Exercise 10-1
Write a query that returns all product names along with the accounts based on that
product (use the product_cd column in the account table to link to the product table).
Include all products, even if no accounts have been opened for that product.*/

SELECT name product_name, a.account_id, a.cust_id, a.avail_balance
FROM product p
   LEFT OUTER JOIN 
     account a
  ON p.product_cd = a.product_cd;   

/*Exercise 10-2
Reformulate your query from Exercise 10-1 to use the other outer join type (e.g., if you
used a left outer join in Exercise 10-1, use a right outer join this time) such that the
results are identical to Exercise 10-1.*/

SELECT name product_name, a.account_id, a.cust_id, a.avail_balance
FROM account a
   RIGHT OUTER JOIN 
     product p
  ON p.product_cd = a.product_cd;  

/*Exercise 10-3
Outer-join the account table to both the individual and business tables (via the
account.cust_id column) such that the result set contains one row per account. Columns
to include are account.account_id, account.product_cd, individual.fname,
individual.lname, and business.name.*/

SELECT a.account_id, a.product_cd, i.fname, i.lname, b.name
FROM account a LEFT OUTER JOIN individual i 
ON a.cust_id = i.cust_id
LEFT OUTER JOIN business b
ON a.cust_id = b.cust_id
ORDER BY account_id, fname, lname ;

/*Exercise 10-4 (Extra Credit)
Devise a query that will generate the set {1, 2, 3,..., 99, 100}. (Hint: use a cross join
with at least two from clause subqueries.)*/

SELECT ones.num + tens.num + 1
FROM
(SELECT 0 num UNION ALL
SELECT 1 num UNION ALL 
SELECT 2 num UNION ALL
SELECT 3 num UNION ALL
SELECT 4 num UNION ALL
SELECT 5 num UNION ALL
SELECT 6 num UNION ALL
SELECT 7 num UNION ALL
SELECT 8 num UNION ALL
SELECT 9 num) ones
CROSS JOIN
(SELECT 0 num UNION ALL
SELECT 10 num UNION ALL
SELECT 20 num UNION ALL
SELECT 30 num UNION ALL
SELECT 40 num UNION ALL
SELECT 50 num UNION ALL
SELECT 60 num UNION ALL
SELECT 70 num UNION ALL
SELECT 80 num UNION ALL
SELECT 90 num) tens;

#Breaking it down: 
SELECT 0 num UNION ALL
SELECT 1 num UNION ALL 
SELECT 2 num UNION ALL
SELECT 3 num UNION ALL
SELECT 4 num UNION ALL
SELECT 5 num UNION ALL
SELECT 6 num UNION ALL
SELECT 7 num UNION ALL
SELECT 8 num UNION ALL
SELECT 9 num;

# The whole Cross join 
SELECT * , ones.num + tens.num, ones.num + tens.num+1
FROM
(SELECT 0 num UNION ALL
SELECT 1 num UNION ALL 
SELECT 2 num UNION ALL
SELECT 3 num UNION ALL
SELECT 4 num UNION ALL
SELECT 5 num UNION ALL
SELECT 6 num UNION ALL
SELECT 7 num UNION ALL
SELECT 8 num UNION ALL
SELECT 9 num) ones
CROSS JOIN
(SELECT 0 num UNION ALL
SELECT 10 num UNION ALL
SELECT 20 num UNION ALL
SELECT 30 num UNION ALL
SELECT 40 num UNION ALL
SELECT 50 num UNION ALL
SELECT 60 num UNION ALL
SELECT 70 num UNION ALL
SELECT 80 num UNION ALL
SELECT 90 num) tens ;

# Darn Beauty ! 