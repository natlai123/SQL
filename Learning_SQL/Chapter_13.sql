
/*****************************************************************/
/*																 */
/* Practice code from Alan Beaulieu Beijing (2009) Learning SQL  */
/*																 */
/*     Modeified and created by Nathaniel Lai (2017)			 */
/*																 */
/*****************************************************************/


/*******************************************/
/*								 		   */
/*   Chapter 13: Indexes and Constraints   */
/*								 		   */
/*******************************************/

/*

Database server uses indexes to locate rows in a table. Indexes are special tables that,
unlike normal data tables, are kept in a specific order. Instead of containing all of the
data about an entity, however, an index contains only the column (or columns) used
to locate rows in the data table, along with information describing where the rows are
physically located. Therefore, the role of indexes is to facilitate the retrieval of a subset
of a table’s rows and columns without the need to inspect every row in the table.


Types of indexes
  
 B-tree indexes 
 Bitmap indexes for low-cardinality data
 Tent indexes 

*/


select* from department;

ALTER TABLE department
ADD INDEX dept_name_idx (name);

SHOW INDEX FROM department;

ALTER TABLE department
DROP INDEX dept_name_idx;

SHOW INDEX FROM department;

ALTER TABLE department
ADD UNIQUE dept_name_idx (name);

INSERT INTO department (dept_id, name)
VALUES (999, 'Operations');
/* You should not build unique indexes on your primary key column(s), since the server
already checks uniqueness for primary key values. That's why it returns an error.*/

ALTER TABLE employee
ADD INDEX emp_names_idx (lname, fname);

SHOW INDEX FROM employee;

/*This index will be useful for queries that specify the first and last names or just the last
name, but you cannot use it for queries that specify only the employee’s first name*/


EXPLAIN SELECT cust_id, SUM(avail_balance) tot_bal
FROM account
WHERE cust_id IN (1, 5, 9, 11)
GROUP BY cust_id;

ALTER TABLE account
ADD INDEX acc_bal_idx (cust_id, avail_balance);

SHOW INDEX FROM employee;

EXPLAIN SELECT cust_id, SUM(avail_balance) tot_bal
FROM account
WHERE cust_id IN (1, 5, 9, 11)
GROUP BY cust_id;


/*
    Contraints 
  
Primary key constraints

    Identify the column or columns that guarantee uniqueness within a table
    
Foreign key constraints

	Restrict one or more columns to contain only values found in another table’s primary
    key columns, and may also restrict the allowable values in other tables if
	update cascade or delete cascade rules are established
    
Unique constraints

	Restrict one or more columns to contain unique values within a table (primary key
	constraints are a special type of unique constraint)
    
Check constraints

	Restrict the allowable values for a column

	-> Cascading Update	
	-> Cascading Delete	 
*/


ALTER TABLE product
DROP FOREIGN KEY fk_product_type_cd;

ALTER TABLE product
ADD CONSTRAINT fk_product_type_cd FOREIGN KEY (product_type_cd)
REFERENCES product_type (product_type_cd)
ON UPDATE CASCADE
ON DELETE CASCADE; 

UPDATE product_type
SET product_type_cd = 'XYZ'
WHERE product_type_cd = 'LOAN';

SELECT product_type_cd, name
FROM product_type;

SELECT product_type_cd, product_cd, name
FROM product
ORDER BY product_type_cd;

/*Exercise 13-1
Modify the account table so that customers may not have more than one account for
each product.*/

ALTER TABLE account
ADD CONSTRAINT account_unq1 UNIQUE (cust_id, product_cd);

#Check if Constraint exists

SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='bank' 
AND CONSTRAINT_NAME='account_unq1' AND TABLE_NAME='account';

ALTER TABLE account
DROP CONSTRAINT account_unq1; #This will not work

ALTER TABLE account
DROP INDEX account_unq1;
 
/*Exercise 13-2
Generate a multicolumn index on the transaction table that could be used by both of
the following queries:*/

ALTER TABLE transaction
ADD INDEX txn_amount_idx (txn_date, amount);

EXPLAIN SELECT txn_date, account_id, txn_type_cd, amount
FROM transaction
WHERE txn_date > cast('2008-12-31 23:59:59' as datetime);

EXPLAIN SELECT txn_date, account_id, txn_type_cd, amount
FROM transaction
WHERE txn_date > cast('2008-12-31 23:59:59' as datetime)
AND amount < 1000;

CREATE INDEX txn_idx01
ON transaction (txn_date, amount);

SHOW INDEX FROM transaction;

ALTER TABLE transaction
DROP INDEX txn_idx01;


/*Combination Insert and Update Statement*/

CREATE TABLE branch_usage
(branch_id SMALLINT UNSIGNED NOT NULL,
cust_id INTEGER UNSIGNED NOT NULL,
last_visited_on DATETIME,
CONSTRAINT pk_branch_usage PRIMARY KEY (branch_id, cust_id)
);

INSERT INTO branch_usage (branch_id, cust_id, last_visited_on)
VALUES (1, 5, CURRENT_TIMESTAMP())
ON DUPLICATE KEY UPDATE last_visited_on = CURRENT_TIMESTAMP();
# This is called the upsert statement, a combination of update and an insert.


/*Ordered Updates and Deletes*/

CREATE TABLE login_history
(cust_id INTEGER UNSIGNED NOT NULL,
login_date DATETIME,
CONSTRAINT pk_login_history PRIMARY KEY (cust_id, login_date)
);

INSERT INTO login_history (cust_id, login_date)
SELECT c.cust_id,
ADDDATE(a.open_date, INTERVAL a.account_id * c.cust_id HOUR)
FROM customer c CROSS JOIN account a;
#eg SELECT DATE_ADD('2008-01-02', INTERVAL 31 DAY);

SELECT * FROM login_history;
SELECT distinct * FROM account;
SELECT distinct * FROM customer;

SELECT login_date
FROM login_history
ORDER BY login_date DESC
LIMIT 49,1;
#The 50th most recent login from the 312 rows (24*13)

DELETE FROM login_history
WHERE login_date < '2004-07-02 09:00:00';

SET SQL_SAFE_UPDATES=0;

DELETE FROM login_history
ORDER BY login_date ASC
LIMIT 275;
/* Not using desc option because MySQL does not allow the optional second parameter when
using the limit clause in delete or update statements.*/

UPDATE account
SET avail_balance = avail_balance + 100
WHERE product_cd IN ('CHK', 'SAV', 'MM')
ORDER BY open_date ASC
LIMIT 10;

/*This statement sorts accounts by the open date in ascending order and then modifies
the first 10 records, which, in this case, are the 10 oldest accounts*/

/*Multitable Updates and Deletes*/

CREATE TABLE individual2 AS
SELECT * FROM individual;
CREATE TABLE customer2 AS
SELECT * FROM customer;
CREATE TABLE account2 AS
SELECT * FROM account;

DELETE FROM account2
WHERE cust_id = 1;
DELETE FROM customer2
WHERE cust_id = 1;
DELETE FROM individual2
WHERE cust_id = 1;

/*Instead of writing individual delete statements, however, MySQL allows you to write
a single multitable delete statement, which, in this case, looks as follows:*/

DELETE account2, customer2, individual2
FROM account2 INNER JOIN customer2
ON account2.cust_id = customer2.cust_id
INNER JOIN individual2
ON customer2.cust_id = individual2.cust_id
WHERE individual2.cust_id = 1;

/*
 Delete
Specifies the tables targeted for deletion.
from
Specifies the tables used to identify the rows to be deleted. This clause is identical
in form and function to the from clause in a select statement, and not all tables
named herein need to be included in the delete clause.
where
Contains filter conditions used to identify the rows to be deleted.
*/

SELECT account2.account_id
FROM account2 INNER JOIN customer2
ON account2.cust_id = customer2.cust_id
INNER JOIN individual2
ON individual2.cust_id = customer2.cust_id
WHERE individual2.fname = 'John'
AND individual2.lname = 'Hayward';

/*multitable delete*/
DELETE account2.account_id
FROM account2 INNER JOIN customer2
ON account2.cust_id = customer2.cust_id
INNER JOIN individual2
ON individual2.cust_id = customer2.cust_id
WHERE individual2.fname = 'John'
AND individual2.lname = 'Hayward';
# Somehow it does not work ... SAME AS 

DELETE FROM account2
WHERE cust_id =
(SELECT cust_id
FROM individual2
WHERE fname = 'John' AND lname = 'Hayward');

DROP TABLE individual2, customer2, account2;

CREATE TABLE individual2 AS
SELECT * FROM individual;
CREATE TABLE customer2 AS
SELECT * FROM customer;
CREATE TABLE account2 AS
SELECT * FROM account;

/*multitable update*/
UPDATE individual2 INNER JOIN customer2
ON individual2.cust_id = customer2.cust_id
INNER JOIN account2
ON customer2.cust_id = account2.cust_id
SET individual2.cust_id = individual2.cust_id + 10000,
customer2.cust_id = customer2.cust_id + 10000,
account2.cust_id = account2.cust_id + 10000
WHERE individual2.cust_id = 3;

/*Just like the singletable
update, the multitable version includes a set clause, the difference being that any
tables referenced in the update clause may be modified via the set clause.*/

SELECT * FROM individual2;
SELECT * FROM account2;
SELECT * FROM customer2;

