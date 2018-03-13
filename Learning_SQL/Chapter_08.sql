
/*****************************************************************/
/*																 */
/* Practice code from Alan Beaulieu Beijing (2009) Learning SQL  */
/*																 */
/*     Modeified and created by Nathaniel Lai (2017)			 */
/*																 */
/*****************************************************************/


/********************************************/
/*											*/
/* 	 Chapter 8: Grouping and Aggregates 	*/
/*											*/
/********************************************/

SELECT open_emp_id
FROM account;

SELECT open_emp_id, count(open_emp_id) how_many
FROM account
GROUP BY open_emp_id
HAVING how_many > 4;

SELECT MAX(avail_balance) max_balance,
MIN(avail_balance) min_balance,
AVG(avail_balance) avg_balance,
SUM(avail_balance) tot_balance,
COUNT(*) num_accounts
FROM account
WHERE product_cd = 'CHK';

SELECT product_cd,
MAX(avail_balance) max_balance,
MIN(avail_balance) min_balance,
AVG(avail_balance) avg_balance,
SUM(avail_balance) tot_balance,
COUNT(*) num_accts
FROM account
GROUP BY product_cd;

SELECT COUNT(DISTINCT open_emp_id)
FROM account;

CREATE TABLE number_tbl
(val SMALLINT);
INSERT INTO number_tbl VALUES (1);
INSERT INTO number_tbl VALUES (3);
INSERT INTO number_tbl VALUES (5);

select* from number_tbl;

SELECT COUNT(*) num_rows,
COUNT(val) num_vals,
SUM(val) total,
MAX(val) max_val,
AVG(val) avg_val
FROM number_tbl;

INSERT INTO number_tbl VALUES (NULL);

SELECT COUNT(*) num_rows,
COUNT(val) num_vals,
SUM(val) total,
MAX(val) max_val,
AVG(val) avg_val
FROM number_tbl;

/*The difference is that count(*) counts the number of rows, whereas count(val) counts 
the number of values contained in the val column and ignores any null values encountered*/

SELECT product_cd, SUM(avail_balance) prod_balance
FROM account
GROUP BY product_cd;

SELECT product_cd, open_branch_id,
SUM(avail_balance) tot_balance
FROM account
GROUP BY product_cd, open_branch_id;

/*Grouping via Expressions*/

SELECT EXTRACT(YEAR FROM start_date) year,
COUNT(*) how_many
FROM employee
GROUP BY year;
# This query groups employees by the year they began working for the bank. 

/*Generating Rollups*/

SELECT product_cd, open_branch_id,
SUM(avail_balance) tot_balance
FROM account
GROUP BY product_cd, open_branch_id WITH ROLLUP;

SELECT product_cd, SUM(avail_balance) prod_balance
FROM account
WHERE status = 'ACTIVE'
GROUP BY product_cd
HAVING SUM(avail_balance) >= 10000;
/*This query fails because you cannot include an aggregate function in a query’s where
clause. This is because the filters in the where clause are evaluated before the grouping
occurs, so the server can’t yet perform any functions on groups!!!*/

/*Exercise 8-1
Construct a query that counts the number of rows in the account table.*/

select count(*) from account;

/*Exercise 8-2
Modify your query from Exercise 8-1 to count the number of accounts held by each
customer. Show the customer ID and the number of accounts for each customer.*/

select cust_id, count(*) as 'Number of Accounts'
from account
group by cust_id;

/*Exercise 8-3
Modify your query from Exercise 8-2 to include only those customers having at least
two accounts.*/

select cust_id, count(*) as 'Number of Accounts'
from account
group by cust_id
having count(*) >= 2;

/*Exercise 8-4 (Extra Credit)
Find the total available balance by product and branch where there is more than one
account per product and branch. Order the results by total balance (highest to lowest).*/

select product_cd, open_branch_id, sum(avail_balance) 
from account
group by product_cd, open_branch_id
having count(*) >1
order by 3 DESC; 