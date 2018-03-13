
/*****************************************************************/
/*																 */
/* Practice code from Alan Beaulieu Beijing (2009) Learning SQL  */
/*																 */
/*     Modeified and created by Nathaniel Lai (2017)			 */
/*																 */
/*****************************************************************/


/*************************/
/*	    		 		 */
/*   Chapter 14: Views   */
/*	    		 		 */
/*************************/

/*

A view is simply a mechanism for querying data. Unlike tables, views do not involve
data storage; you won’t need to worry about views filling up your disk space. You create
a view by assigning a name to a select statement, and then storing the query for others
to use. Other users can then use your view to access data just as though they were
querying tables directly (in fact, they may not even know they are using a view).

Why Views? 

Data Security 
Data Aggregation
Hiding Complexity
Joining Partitioned Data

*/

CREATE VIEW customer_vw
(cust_id,
fed_id,
cust_type_cd,
address,
city,
state,
zipcode
)
AS
SELECT cust_id,
concat('ends in ', substr(fed_id, 8, 4)) fed_id,
cust_type_cd,
address,
city,
state,
postal_code
FROM customer;

SELECT * FROM customer_vw;

DESC customer_vw;

select fed_id from customer;

CREATE VIEW business_customer_vw
(cust_id,
fed_id,
cust_type_cd,
address,
city,
state,
zipcode
)
AS
SELECT cust_id,
concat('ends in ', substr(fed_id, 8, 4)) fed_id,
cust_type_cd,
address,
city,
state,
postal_code
FROM customer
WHERE cust_type_cd = 'B';

select* from business_customer_vw;
# Business customer's fed_id is 7-digit.

/*Generate report each month showing the
number of accounts and total deposits for every customer*/

CREATE VIEW customer_totals_vw
(cust_id,
cust_type_cd,
cust_name,
num_accounts,
tot_deposits
)
AS
SELECT cst.cust_id, cst.cust_type_cd,
CASE
WHEN cst.cust_type_cd = 'B' THEN
(SELECT bus.name FROM business bus WHERE bus.cust_id = cst.cust_id)
ELSE
(SELECT concat(ind.fname, ' ', ind.lname)
FROM individual ind
WHERE ind.cust_id = cst.cust_id)
END cust_name,
sum(CASE WHEN act.status = 'ACTIVE' THEN 1 ELSE 0 END) tot_active_accounts,
sum(CASE WHEN act.status = 'ACTIVE' THEN act.avail_balance ELSE 0 END) tot_balance
FROM customer cst INNER JOIN account act
ON act.cust_id = cst.cust_id
GROUP BY cst.cust_id, cst.cust_type_cd;

SELECT * FROM customer_totals_vw;

# Use a table instead 
CREATE TABLE customer_totals AS
SELECT * FROM customer_totals_vw;

# Modify the View
CREATE OR REPLACE VIEW customer_totals_vw
(cust_id,
cust_type_cd,
cust_name,
num_accounts,
tot_deposits) AS
SELECT cust_id, cust_type_cd, cust_name, num_accounts, tot_deposits
FROM customer_totals;

/*Generate a report tp show the number of employees, the total number of active accounts, and the
total number  of transactions for each branch.*/

CREATE VIEW branch_activity_vw
(branch_name,
city,
state,
num_employees,
num_active_accounts,
tot_transactions) AS
SELECT br.name, br.city, br.state,
(SELECT count(*)
FROM employee emp
WHERE emp.assigned_branch_id = br.branch_id) num_emps,
(SELECT count(*)
FROM account acnt
WHERE acnt.status = 'ACTIVE' AND acnt.open_branch_id = br.branch_id) num_accounts,
(SELECT count(*)
FROM transaction txn
WHERE txn.execution_branch_id = br.branch_id) num_txns
FROM branch br;


/*Updating Views*/

/*

For this purpose, MySQL,
Oracle Database, and SQL Server all allow you to modify data through a view, as long
as you abide by certain restrictions. In the case of MySQL, a view is updatable if the
following conditions are met:
• No aggregate functions are used (max(), min(), avg(), etc.).
• The view does not employ group by or having clauses.
• No subqueries exist in the select or from clause, and any subqueries in the where
  clause do not refer to tables in the from clause.
• The view does not utilize union, union all, or distinct.
• The from clause includes at least one table or updatable view.
• The from clause uses only inner joins if there is more than one table or view.

*/

SET SQL_SAFE_UPDATES=0;

#Reusing a predefined view
CREATE VIEW customer_vw
(cust_id,
fed_id,
cust_type_cd,
address,
city,
state,
zipcode) AS
SELECT cust_id,
concat('ends in ', substr(fed_id, 8, 4)) fed_id,
cust_type_cd,
address,
city,
state,
postal_code
FROM customer;

UPDATE customer_vw
SET city = 'Woooburn'
WHERE city = 'Woburn';


/*
While you can modify most of the columns in the view in this fashion, you will not be
able to modify the fed_id column, since it is derived from an expression:

UPDATE customer_vw
SET city = 'Woburn', fed_id = '999999999'
WHERE city = 'Woooburn';
ERROR 1348 (HY000): Column 'fed_id' is not updatable

In this case, it may not be a bad thing, since the whole point of the view is to obscure
the federal identifiers.

*/

select* from business_customer_vw; 
DROP VIEW business_customer_vw; 

#Joining the business and customer tables
CREATE VIEW business_customer_vw
(cust_id,
fed_id,
address,
city,
state,
postal_code,
business_name,
state_id,
incorp_date
)
AS
SELECT cst.cust_id,
cst.fed_id,
cst.address,
cst.city,
cst.state,
cst.postal_code,
bsn.name,
bsn.state_id,
bsn.incorp_date
FROM customer cst INNER JOIN business bsn
ON cst.cust_id = bsn.cust_id
WHERE cust_type_cd = 'B';


/*Exercise 14-1*/

CREATE VIEW employee_vw 
(supervisor_name, employee_name) AS 
SELECT concat(s.fname, s.lname) supervisor_name,
       concat(e.fname, e.lname) employee_name
FROM employee e LEFT OUTER JOIN employee s 
ON e.superior_emp_id = s.emp_id;

SELECT * FROM employee_vw;

DROP VIEW employee_vw;

# The subquery:  
SELECT *
FROM employee e LEFT OUTER JOIN employee s 
ON e.superior_emp_id = s.emp_id;

/*Exercise 14-2
The bank president would like to have a report showing the name and city of each
branch, along with the total balances of all accounts opened at the branch. Create a
view to generate the data.*/

CREATE VIEW branch_name_city_vw 
(branch_name, branch_city, branch_total_balance) AS 
select b.name, b.city, sum(a.avail_balance) 
from account a INNER JOIN branch b
where a.open_branch_id = b.branch_id
group by 1, 2;   

SELECT * FROM branch_name_city_vw;

SELECT * from branch;
SELECT * from account;

DROP VIEW branch_name_city_vw ;
