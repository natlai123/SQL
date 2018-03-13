
/*****************************************************************/
/*																 */
/* Practice code from Alan Beaulieu Beijing (2009) Learning SQL  */
/*																 */
/*     Modeified and created by Nathaniel Lai (2017)			 */
/*																 */
/*****************************************************************/


/*********************************/
/*								 */
/* 	Chapter 11 Conditional Logic */
/*								 */
/*********************************/


SELECT c.cust_id, c.fed_id,
CASE
WHEN c.cust_type_cd = 'I'
THEN CONCAT(i.fname, ' ', i.lname)
WHEN c.cust_type_cd = 'B'
THEN b.name
ELSE 'Unknown'
END name
FROM customer c LEFT OUTER JOIN individual i
ON c.cust_id = i.cust_id
LEFT OUTER JOIN business b
ON c.cust_id = b.cust_id
order by cust_id;

#same as:

SELECT c.cust_id, c.fed_id,
CASE c.cust_type_cd
WHEN 'I'
THEN CONCAT(i.fname, ' ', i.lname)
WHEN 'B'
THEN b.name
ELSE 'Unknown'
END name
FROM customer c LEFT OUTER JOIN individual i
ON c.cust_id = i.cust_id
LEFT OUTER JOIN business b
ON c.cust_id = b.cust_id
order by cust_id;

#same as:

SELECT c.cust_id, c.fed_id,
CASE
WHEN c.cust_type_cd = 'I' THEN
(SELECT CONCAT(i.fname, ' ', i.lname)
FROM individual i
WHERE i.cust_id = c.cust_id)
WHEN c.cust_type_cd = 'B' THEN
(SELECT b.name
FROM business b
WHERE b.cust_id = c.cust_id)
ELSE 'Unknown'
END name
FROM customer c
order by c.cust_id;

/*
 
 Conditional Logic can be used in:

Result Set Transformations
Selective Aggregation (Code in Chapter 9)
Checking for Existence
Division-by-Zero Errors
Conditional Updates
Handling Null Values

*/

/*Result Set Transformations*/

SELECT YEAR(open_date) year, COUNT(*) how_many
FROM account
WHERE open_date > '1999-12-31'
AND open_date < '2006-01-01'
GROUP BY YEAR(open_date);

SELECT
SUM(CASE
WHEN EXTRACT(YEAR FROM open_date) = 2000 THEN 1
ELSE 0
END) year_2000,
SUM(CASE
WHEN EXTRACT(YEAR FROM open_date) = 2001 THEN 1
ELSE 0
END) year_2001,
SUM(CASE
WHEN EXTRACT(YEAR FROM open_date) = 2002 THEN 1
ELSE 0
END) year_2002,
SUM(CASE
WHEN EXTRACT(YEAR FROM open_date) = 2003 THEN 1
ELSE 0
END) year_2003,
SUM(CASE
WHEN EXTRACT(YEAR FROM open_date) = 2004 THEN 1
ELSE 0
END) year_2004,
SUM(CASE
WHEN EXTRACT(YEAR FROM open_date) = 2005 THEN 1
ELSE 0
END) year_2005
FROM account
WHERE open_date > '1999-12-31' AND open_date < '2006-01-01';


/*Checking for Existence*/

/*Show whether the customer has any checking accounts and the other to show 
whether the customer has any savings accounts:*/

SELECT c.cust_id, c.fed_id, c.cust_type_cd,
CASE
WHEN EXISTS (SELECT 1 FROM account a
WHERE a.cust_id = c.cust_id
AND a.product_cd = 'CHK') THEN 'Y'
ELSE 'N'
END has_checking,
CASE
WHEN EXISTS (SELECT 1 FROM account a
WHERE a.cust_id = c.cust_id
AND a.product_cd = 'SAV') THEN 'Y'
ELSE 'N'
END has_savings
FROM customer c;

/*The next query uses a simple case expression to count the number of
accounts for each customer, and then returns either 'None', '1', '2', or '3+':*/

SELECT c.cust_id, c.fed_id, c.cust_type_cd,
CASE (SELECT COUNT(*) FROM account a
WHERE a.cust_id = c.cust_id)
WHEN 0 THEN 'None'
WHEN 1 THEN '1'
WHEN 2 THEN '2'
ELSE '3+'
END num_accounts
FROM customer c;

#Joing the above tables for comparison 
Select aaa.cust_id, aaa.fed_id, aaa.cust_type_cd, has_checking, has_savings, num_accounts
From (SELECT c.cust_id, c.fed_id, c.cust_type_cd,
CASE (SELECT COUNT(*) FROM account a
WHERE a.cust_id = c.cust_id)
WHEN 0 THEN 'None'
WHEN 1 THEN '1'
WHEN 2 THEN '2'
ELSE '3+'
END num_accounts
FROM customer c) bbb, 
(SELECT c.cust_id, c.fed_id, c.cust_type_cd,
CASE
WHEN EXISTS (SELECT 1 FROM account a
WHERE a.cust_id = c.cust_id
AND a.product_cd = 'CHK') THEN 'Y'
ELSE 'N'
END has_checking,
CASE
WHEN EXISTS (SELECT 1 FROM account a
WHERE a.cust_id = c.cust_id
AND a.product_cd = 'SAV') THEN 'Y'
ELSE 'N'
END has_savings
FROM customer c) aaa
Where bbb.cust_id = aaa.cust_id;


/*Division-by-Zero Errors*/

SELECT a.cust_id, a.product_cd, a.avail_balance /
CASE
WHEN prod_tots.tot_balance = 0 THEN 1
ELSE prod_tots.tot_balance
END percent_of_total
FROM account a INNER JOIN
(SELECT a.product_cd, SUM(a.avail_balance) tot_balance
FROM account a
GROUP BY a.product_cd) prod_tots
ON a.product_cd = prod_tots.product_cd;


/*Conditional Updates*/

UPDATE account
SET last_activity_date = CURRENT_TIMESTAMP(),
pending_balance = pending_balance +
(SELECT t.amount *
CASE t.txn_type_cd WHEN 'DBT' THEN -1 ELSE 1 END
FROM transaction t
WHERE t.txn_id = 999),
avail_balance = avail_balance +
(SELECT
CASE
WHEN t.funds_avail_date > CURRENT_TIMESTAMP() THEN 0
ELSE t.amount *
CASE t.txn_type_cd WHEN 'DBT' THEN -1 ELSE 1 END
END
FROM transaction t
WHERE t.txn_id = 999)
WHERE account.account_id =
(SELECT t.account_id
FROM transaction t
WHERE t.txn_id = 999);


/*Exercise 11-1
Rewrite the following query, which uses a simple case expression, so that the same
results are achieved using a searched case expression. Try to use as few when clauses as
possible.*/


SELECT emp_id,
CASE title
WHEN 'President' THEN 'Management'
WHEN 'Vice President' THEN 'Management'
WHEN 'Treasurer' THEN 'Management'
WHEN 'Loan Manager' THEN 'Management'
WHEN 'Operations Manager' THEN 'Operations'
WHEN 'Head Teller' THEN 'Operations'
WHEN 'Teller' THEN 'Operations'
ELSE 'Unknown'
END
FROM employee;


SELECT emp_id,
CASE 
WHEN title in ('President', 'Vice President', 'Treasurer', 'Loan Manager') THEN 'Management'
WHEN title in ('Operations Manager', 'Head Teller') THEN 'Operations'
WHEN title = 'Teller' THEN 'Operations'
ELSE 'Unknown'
END
FROM employee;

/*Exercise 11-2
Rewrite the following query so that the result set contains a single row with four columns
(one for each branch). Name the four columns branch_1 through branch_4.*/

SELECT open_branch_id, COUNT(*)
FROM account
GROUP BY open_branch_id;

SELECT
SUM(CASE open_branch_id WHEN 1 THEN 1 ELSE 0 END) branch_1,
SUM(CASE open_branch_id WHEN 2 THEN 1 ELSE 0 END) branch_2,
SUM(CASE open_branch_id WHEN 3 THEN 1 ELSE 0 END) branch_3,
SUM(CASE open_branch_id WHEN 4 THEN 1 ELSE 0 END) branch_4
FROM account;