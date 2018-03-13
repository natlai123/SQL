
/*****************************************************************/
/*																 */
/* Practice code from Alan Beaulieu Beijing (2009) Learning SQL  */
/*																 */
/*     Modeified and created by Nathaniel Lai (2017)			 */
/*																 */
/*****************************************************************/


/*********************************/
/*								 */
/* 		Chapter 9 Subqueries 	 */
/*								 */
/*********************************/

/*Subquery Types
 - Noncorrelated 
 - Correlated 

/*The following query uses a correlated subquery to count the number of accounts 
for each customer, and the containing query then retrieves those customers having
exactly two accounts:*/

SELECT c.cust_id, c.cust_type_cd, c.city
FROM customer c
WHERE 2 = (SELECT COUNT(*)
FROM account a
WHERE a.cust_id = c.cust_id); #filter condition 

/*EXIST*/

SELECT a.account_id, a.product_cd, a.cust_id, a.avail_balance
FROM account a
WHERE EXISTS (SELECT 1
FROM transaction t
WHERE t.account_id = a.account_id
AND t.txn_date = '2008-09-22');

SELECT c.cust_id, c.cust_type_cd, c.city
FROM customer c
WHERE (SELECT SUM(a.avail_balance)
FROM account a
WHERE a.cust_id = c.cust_id)
BETWEEN 5000 AND 10000;

SELECT SUM(avail_balance)
FROM account 
Group by cust_id; #Return 13 rows -> thus make the correlated subquery execute 13 times

SELECT SUM(avail_balance)
FROM account 
Group by cust_id 
HAVING SUM(avail_balance) BETWEEN 5000 AND 10000;

SELECT CONCAT('ALERT! : Account #', a.account_id,
' Has Incorrect Balance!')
FROM account a
WHERE (a.avail_balance, a.pending_balance) <>
(SELECT SUM(<expression to generate available balance>),
SUM(<expression to generate pending balance>)
FROM transaction t
WHERE t.account_id = a.account_id);

SELECT * FROM bank.transaction;
SELECT * FROM bank.account;

/*Full Solution P210*/

SELECT CONCAT('ALERT! : Account #', a.account_id,
' Has Incorrect Balance!')
FROM account a
WHERE (a.avail_balance, a.pending_balance) <>
(SELECT
  SUM(CASE
   WHEN t.funds_avail_date > CURRENT_TIMESTAMP()
   THEN 0
   WHEN t.txn_type_cd = 'DBT'
   THEN t.amount * -1
   ELSE t.amount
      END),
  SUM(CASE
   WHEN t.txn_type_cd = 'DBT'
   THEN t.amount * -1
   ELSE t.amount
      END)
 FROM transaction t 
 WHERE t.account_id = a.account_id);


/*You use the exists operator when you want to identify that a
relationship exists without regard for the quantity; for example, the following query
finds all the accounts for which a transaction was posted on a particular day, without
regard for how many transactions were posted:*/

SELECT a.account_id, a.product_cd, a.cust_id, a.avail_balance
FROM account a
WHERE EXISTS (SELECT 1
FROM transaction t
WHERE t.account_id = a.account_id
AND t.txn_date = '2001-03-12');

SELECT a.account_id, a.product_cd, a.cust_id, a.avail_balance
FROM account a
WHERE EXISTS (SELECT*
FROM transaction t
WHERE t.account_id = a.account_id
AND t.txn_date = '2008-09-22');


SELECT a.account_id, a.product_cd, a.cust_id
FROM account a
WHERE NOT EXISTS (SELECT 1
 FROM business b
 WHERE b.cust_id = a.cust_id);
/*This query finds all customers whose customer ID does not appear in the business
table, which is a roundabout way of finding all nonbusiness customers.*/


/*Here’s an example of a correlated
subquery used to modify the last_activity_date column in the account table:*/
SET SQL_SAFE_UPDATES=0;
UPDATE account a
SET a.last_activity_date =
(SELECT MAX(t.txn_date)
FROM transaction t
WHERE t.account_id = a.account_id);

/*This statement modifies every row in the account table (since there is no where clause)
by finding the latest transaction date for each account. While it seems reasonable to
expect that every account will have at least one transaction linked to it, it would be best
to check whether an account has any transactions before attempting to update the
last_activity_date column; otherwise, the column will be set to null, since the subquery
would return no rows. Here’s another version of the update statement, this time
employing a where clause with a second correlated subquery:*/

SET SQL_SAFE_UPDATES=0;
UPDATE account a
SET a.last_activity_date =
(SELECT MAX(t.txn_date)
FROM transaction t
WHERE t.account_id = a.account_id)
WHERE EXISTS (SELECT 1
FROM transaction t
WHERE t.account_id = a.account_id);

/*The two correlated subqueries are identical except for the select clauses. The subquery
in the set clause, however, executes only if the condition in the update statement’s
where clause evaluates to true (meaning that at least one transaction was found for the
account), thus protecting the data in the last_activity_date column from being overwritten
with a null.*/

DELETE FROM department
WHERE NOT EXISTS (SELECT 1
FROM employee
WHERE employee.dept_id = department.dept_id);

/*In MySQL, keep in mind that, for whatever reason, table aliases are not allowed when using delete,*/

SELECT d.dept_id, d.name, e_cnt.how_many num_employees
FROM department d INNER JOIN
(SELECT dept_id, COUNT(*) how_many
FROM employee
GROUP BY dept_id) e_cnt
ON d.dept_id = e_cnt.dept_id;

SELECT dept_id, COUNT(*) how_many
FROM employee
GROUP BY dept_id;


/*When to use Subquery? 

Subqueries As Data Sources
 -Data fabrication
 -Task-oriented subqueries
Subqueries in Filter Conditions 
Subqueries As Expression Generators*/



/*Data fabrication*/

/*The Subquery*/
SELECT SUM(a.avail_balance) cust_balance
FROM account a INNER JOIN product p
ON a.product_cd = p.product_cd
WHERE p.product_type_cd = 'ACCOUNT'
GROUP BY a.cust_id;

SELECT groups.name, COUNT(*) num_customers
FROM 
   (SELECT SUM(a.avail_balance) cust_balance
	FROM account a INNER JOIN product p
	ON a.product_cd = p.product_cd
	WHERE p.product_type_cd = 'ACCOUNT'
	GROUP BY a.cust_id) cust_rollup
		INNER JOIN
   (SELECT 'Small Fry' name, 0 low_limit, 4999.99 high_limit
          UNION ALL
    SELECT 'Average Joes' name, 5000 low_limit, 9999.99 high_limit
          UNION ALL
    SELECT 'Heavy Hitters' name, 10000 low_limit, 9999999.99 high_limit) groups
ON cust_rollup.cust_balance
BETWEEN groups.low_limit AND groups.high_limit
GROUP BY groups.name;

/*The data generated by cust_rollup is then joined to the groups table via a range condition
(cust_rollup.cust_balance BETWEEN groups.low_limit AND groups.high_limit).S*/


/*M1*//*********************************************************/
SELECT p.name product, b.name branch,
CONCAT(e.fname, ' ', e.lname) name,
SUM(a.avail_balance) tot_deposits
FROM account a INNER JOIN employee e
ON a.open_emp_id = e.emp_id
INNER JOIN branch b
ON a.open_branch_id = b.branch_id
INNER JOIN product p
ON a.product_cd = p.product_cd
WHERE p.product_type_cd = 'ACCOUNT'
GROUP BY p.name, b.name, e.fname, e.lname
ORDER BY 1,2;

/*Subquery for M2*/
SELECT product_cd, open_branch_id branch_id, open_emp_id emp_id,
SUM(avail_balance) tot_deposits
FROM account
GROUP BY product_cd, open_branch_id, open_emp_id;

/*Using the abpve Subquery*/

/*M2*//*********************************************************/
SELECT p.name product, b.name branch,
CONCAT(e.fname, ' ', e.lname) name,
account_groups.tot_deposits
FROM  
(SELECT product_cd, open_branch_id branch_id, open_emp_id emp_id,
SUM(avail_balance) tot_deposits
FROM account 
GROUP BY product_cd, open_branch_id, open_emp_id) account_groups
 INNER JOIN employee e ON e.emp_id = account_groups.emp_id
 INNER JOIN branch b ON b.branch_id = account_groups.branch_id
 INNER JOIN product p ON p.product_cd = account_groups.product_cd
WHERE p.product_type_cd = 'ACCOUNT'
ORDER BY 1, 2 ;


/*Subqueries in Filter Conditions which happens in the HAVING Clause*/

SELECT open_emp_id, COUNT(*) how_many
FROM account
GROUP BY open_emp_id
HAVING COUNT(*) = (SELECT MAX(emp_cnt.how_many)
FROM (SELECT COUNT(*) how_many
FROM account
GROUP BY open_emp_id) emp_cnt);

SELECT open_emp_id, concat(fname, ' ', lname) name, COUNT(*) how_many_account_open
FROM account a INNER JOIN employee e
ON a.open_emp_id = e.emp_id
GROUP BY a.open_emp_id
HAVING COUNT(*) = (SELECT MAX(emp_cnt.how_many_account_open)
FROM (SELECT COUNT(*) how_many_account_open
FROM account
GROUP BY open_emp_id) emp_cnt);


/*Subqueries As Expression Generators*/

SELECT
(SELECT p.name FROM product p
WHERE p.product_cd = a.product_cd
 AND p.product_type_cd = 'ACCOUNT') product,
(SELECT b.name FROM branch b
WHERE b.branch_id = a.open_branch_id) branch,
(SELECT CONCAT(e.fname, ' ', e.lname) FROM employee e
WHERE e.emp_id = a.open_emp_id) name,
SUM(a.avail_balance) tot_deposits
FROM account a
GROUP BY a.product_cd, a.open_branch_id, a.open_emp_id
ORDER BY 1,2;

/*Eliminating the NULL Products obs (3 of them)*/

/*M3*//*********************************************************/
SELECT all_prods.product, all_prods.branch,
all_prods.name, all_prods.tot_deposits
FROM
 (SELECT
 (SELECT p.name FROM product p
 WHERE p.product_cd = a.product_cd
 AND p.product_type_cd = 'ACCOUNT') product,
 (SELECT b.name FROM branch b
 WHERE b.branch_id = a.open_branch_id) branch,
 (SELECT CONCAT(e.fname, ' ', e.lname) FROM employee e
 WHERE e.emp_id = a.open_emp_id) name,
 SUM(a.avail_balance) tot_deposits
 FROM account a
GROUP BY a.product_cd, a.open_branch_id, a.open_emp_id
 ) all_prods
 WHERE all_prods.product IS NOT NULL
 ORDER BY 1,2;
/*The end result is a query that performs all grouping against raw
data in the account table, and then embellishes the output using data in three other
tables, and without doing any joins*/ 


/*Using Subquery in UPDATE Statement*/

INSERT INTO account
(account_id, product_cd, cust_id, open_date, last_activity_date,
status, open_branch_id, open_emp_id, avail_balance, pending_balance)
VALUES (NULL,
(SELECT product_cd FROM product WHERE name = 'savings account'),
(SELECT cust_id FROM customer WHERE fed_id = '555-55-5555'),
'2008-09-25', '2008-09-25', 'ACTIVE',
(SELECT branch_id FROM branch WHERE name = 'Quincy Branch'),
(SELECT emp_id FROM employee WHERE lname = 'Portman' AND fname = 'Frank'),
0, 0);


SET SQL_SAFE_UPDATES=0;
DELETE FROM account WHERE account_id is null;

/*Exercise 9-1
Construct a query against the account table that uses a filter condition with a noncorrelated
subquery against the product table to find all loan accounts (product.prod
uct_type_cd = 'LOAN'). Retrieve the account ID, product code, customer ID, and available
balance.*/

#The noncorelated subquery is:
SELECT product_cd FROM product WHERE product_type_cd = 'LOAN';

#Add it to the outer query:
SELECT account_id, product_cd, cust_id, avail_balance
FROM account
WHERE product_cd IN (SELECT product_cd
FROM product
WHERE product_type_cd = 'LOAN') ;


/*Exercise 9-2
Rework the query from Exercise 9-1 using a correlated subquery against the product
table to achieve the same results.*/

SELECT a.account_id, a.product_cd, a.cust_id, a.avail_balance
FROM account a 
WHERE EXISTS 
  (SELECT 1 product_cd FROM product p
   WHERE product_type_cd = 'LOAN'AND
   p.product_cd = a.product_cd);
   

SELECT account_id, p.product_cd, cust_id, avail_balance
FROM 
 (SELECT product_cd FROM product WHERE product_type_cd = 'LOAN') p
   INNER JOIN
 account a
   ON p.product_cd = a.product_cd;
   
   
/*Exercise 9-3
Join the following query to the employee table to show the experience level of each
employee:

SELECT 'trainee' name, '2004-01-01' start_dt, '2005-12-31' end_dt
UNION ALL
SELECT 'worker' name, '2002-01-01' start_dt, '2003-12-31' end_dt
UNION ALL
SELECT 'mentor' name, '2000-01-01' start_dt, '2001-12-31' end_dt

Give the subquery the alias levels, and include the employee ID, first name, last name,
and experience level (levels.name). (Hint: build a join condition using an inequality
condition to determine into which level the employee.start_date column falls.)*/


SELECT e.emp_id, e.fname, e.lname, levels.name
FROM employee e INNER JOIN 
(SELECT 'trainee' name, '2004-01-01' start_dt, '2005-12-31' end_dt
UNION ALL
SELECT 'worker' name, '2002-01-01' start_dt, '2003-12-31' end_dt
UNION ALL
SELECT 'mentor' name, '2000-01-01' start_dt, '2001-12-31' end_dt) levels 
ON e.start_date BETWEEN levels.start_dt AND levels.end_dt;

/*The code below follows the example in the book. You cannot simply add 'group by' to the code
 above because emp_id, emp_lname and em.fname are incompatible with 'group by'*/
 
SELECT levels.name, count(*) num_employee
FROM employee e INNER JOIN 
(SELECT 'trainee' name, '2004-01-01' start_dt, '2005-12-31' end_dt
UNION ALL
SELECT 'worker' name, '2002-01-01' start_dt, '2003-12-31' end_dt
UNION ALL
SELECT 'mentor' name, '2000-01-01' start_dt, '2001-12-31' end_dt) levels 
ON e.start_date BETWEEN levels.start_dt AND levels.end_dt
GROUP BY levels.name;


/*Exercise 9-4
Construct a query against the employee table that retrieves the employee ID, first name,
and last name, along with the names of the department and branch to which the employee
is assigned. Do not join any tables.*/


SELECT e.emp_id, e.fname, e.lname, 
      (SELECT d.name FROM department d WHERE d.dept_id = e.dept_id) dept_name,
      (SELECT b.name FROM branch b WHERE b.branch_id = e.assigned_branch_id) branch_name
FROM employee e;

