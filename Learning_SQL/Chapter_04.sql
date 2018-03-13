
/*****************************************************************/
/*																 */
/* Practice code from Alan Beaulieu Beijing (2009) Learning SQL  */
/*																 */
/*     Modeified and created by Nathaniel Lai (2017)			 */
/*																 */
/*****************************************************************/


/***********************************************/
/* 											   */
/*          Chapter 4: Filtering 			   */
/*											   */
/***********************************************/

SELECT pt.name product_type, p.name product
FROM product p INNER JOIN product_type pt
ON p.product_type_cd = pt.product_type_cd;

SELECT pt.name product_type, p.name product
FROM product p INNER JOIN product_type pt
ON p.product_type_cd = pt.product_type_cd
WHERE pt.name = 'Customer Accounts';

SELECT pt.name product_type, p.name product
FROM product p INNER JOIN product_type pt
ON p.product_type_cd = pt.product_type_cd
WHERE pt.name <> 'Customer Accounts';

SELECT emp_id, fname, lname, start_date
FROM employee
WHERE start_date < '2007-01-01';


select* 
from employee;

SELECT emp_id, fname, lname, start_date
FROM employee
WHERE start_date < '2005-01-01'
AND start_date >= '2003-01-01';

SELECT emp_id, fname, lname, start_date
FROM employee
WHERE start_date between '2003-01-01' and '2005-01-01';

SELECT emp_id, fname, lname, start_date
FROM employee
WHERE start_date between '2005-01-01' and '2003-01-01';

/*Unlike SAS, MySQL's 'between and' has to start from a low value to high value*/

SELECT emp_id, fname, lname
FROM employee
WHERE lname LIKE 'F%' OR lname LIKE 'G%';

SELECT emp_id, fname, lname
FROM employee
WHERE lname REGEXP '^[FG]';

/*The regexp operator takes a regular expression ('^[FG]' in this example) and applies it
to the expression on the lefthand side of the condition (the column lname). The query
now contains a single condition using a regular expression rather than two conditions
using wildcard characters.*/

SELECT emp_id, fname, lname, superior_emp_id
FROM employee
WHERE superior_emp_id != 6 OR superior_emp_id IS NULL;

/*When working with a database that you are not familiar with, it is a good idea 
to find out which columns in a table allow nulls so that you can take appropriate
measures with your filter conditions to keep data from slipping through the cracks.*/

drop table exercise_chpt4;
create Table exercise_chpt4 
(Txn_id SMALLINT AUTO_INCREMENT,
 Txn_date DATE,
 Account_id Tinyint,
 Txn_type_cd VARCHAR(10),
 Amount Smallint(8.2),
 constraint pk_exercise_chpt4 primary key (Txn_id));
 
INSERT INTO exercise_chpt4
(Txn_id, Txn_date, Account_id, Txn_type_cd, Amount)
VALUES(1, '2005-02-22', 101, 'CDT', 1000.00);
INSERT INTO exercise_chpt4
(Txn_id, Txn_date, Account_id, Txn_type_cd, Amount)
VALUES(2, '2005-02-23', 102, 'CDT', 525.75);
INSERT INTO exercise_chpt4
(Txn_id, Txn_date, Account_id, Txn_type_cd, Amount)
VALUES(3, '2005-02-24', 101, 'DBT', 100.00);
INSERT INTO exercise_chpt4
(Txn_id, Txn_date, Account_id, Txn_type_cd, Amount)
VALUES(4, '2005-02-24', 103, 'CDT', 55);
INSERT INTO exercise_chpt4
(Txn_id, Txn_date, Account_id, Txn_type_cd, Amount)
VALUES(5, '2005-02-25', 101, 'DBT', 50);
INSERT INTO exercise_chpt4
(Txn_id, Txn_date, Account_id, Txn_type_cd, Amount)
VALUES(6, '2005-02-25', 103, 'DBT', 25);
INSERT INTO exercise_chpt4
(Txn_id, Txn_date, Account_id, Txn_type_cd, Amount)
VALUES(7, '2005-02-25', 102, 'CDT', 125.37);
INSERT INTO exercise_chpt4
(Txn_id, Txn_date, Account_id, Txn_type_cd, Amount)
VALUES(8, '2005-02-26', 103, 'DBT', 10);
INSERT INTO exercise_chpt4
(Txn_id, Txn_date, Account_id, Txn_type_cd, Amount)
VALUES(9, '2005-02-27', 101, 'CDT', 75);
drop table exercise_chpt4;

/*Construct a query that finds all nonbusiness customers whose last name contains an
a in the second position and an e anywhere after the a.*/

select*
from individual
where lname like '_a%e%';
