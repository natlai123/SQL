
/*****************************************************************/
/*																 */
/* Practice code from Alan Beaulieu Beijing (2009) Learning SQL  */
/*																 */
/*     Modeified and created by Nathaniel Lai (2017)			 */
/*																 */
/*****************************************************************/


/***********************************************/
/*											   */
/* 		Chapter 5: Querying Multiple Tables    */
/*  										   */
/***********************************************/


select* 
from employee;
select*
from department;

SELECT e.fname, e.lname, d.name
FROM employee e JOIN department d;

SELECT e.fname, e.lname, d.name
FROM employee e INNER JOIN department d
on e.dept_id= d.dept_id;

SELECT e.fname, e.lname, d.name
FROM employee e INNER JOIN department d
USING (dept_id);


/*If the names of the columns used to join the two tables are identical, which is true in
the previous query, you can use the using subclause instead of the on subclause. See above*/

/*The ANSI Standard might be more user-friendly then 'where =' */

SELECT a.account_id, a.cust_id, a.open_date, a.product_cd
FROM account a INNER JOIN employee e
ON a.open_emp_id = e.emp_id
INNER JOIN branch b
ON e.assigned_branch_id = b.branch_id
WHERE e.start_date < '2007-01-01'
AND (e.title = 'Teller' OR e.title = 'Head Teller')
AND b.name = 'Woburn Branch';


/*Keep in mind that SQL is a nonprocedural language, meaning that you describe what 
you want to retrieve and which database objects need to be involved, but it is up to the 
database server to determine how best to execute your query. Therefore, the order
in which tables appear in your from clause is not significant.

If, however, you believe that the tables in your query should always be joined in a
particular order, you can place the tables in the desired order and then specify the
keyword STRAIGHT_JOIN in MySQL, request the FORCE ORDER option in SQL Server, or
use either the ORDERED or the LEADING optimizer hint in Oracle Database. For example,
to tell the MySQL server to use the customer table as the driving table and to then join
the account and employee tables, you could do the following:*/

SELECT STRAIGHT_JOIN a.account_id, c.fed_id, e.fname, e.lname
FROM customer c INNER JOIN account a
ON a.cust_id = c.cust_id
INNER JOIN employee e
ON a.open_emp_id = e.emp_id
WHERE c.cust_type_cd = 'B';

/*Find all accounts opened by experienced tellers currently assigned to the
Woburn branch)*/

SELECT e.emp_id, a.account_id, a.cust_id, a.open_date, a.product_cd
FROM account a INNER JOIN
(SELECT emp_id, assigned_branch_id
FROM employee
WHERE start_date < '2007-01-01'
AND (title = 'Teller' OR title = 'Head Teller')) e
ON a.open_emp_id = e.emp_id INNER JOIN
(SELECT branch_id
FROM branch
WHERE name = 'Woburn Branch') b
ON e.assigned_branch_id = b.branch_id;

/*all accounts*/
SELECT open_emp_id, account_id, a.cust_id, a.open_date, a.product_cd
from account a;

/*opened by experienced tellers*/
SELECT emp_id, assigned_branch_id
FROM employee
WHERE start_date < '2007-01-01'
AND (title = 'Teller' OR title = 'Head Teller');

/*currently assigned to the Woburn branch*/
SELECT branch_id
FROM branch
WHERE name = 'Woburn Branch';


/*
   Self Join 
The employee table, for example, includes a self-referencing
foreign key, which means that it includes a column (superior_emp_id) that
points to the primary key within the same table

*/

select*
from employee;

SELECT e.fname, e.lname, e_mgr.fname mgr_fname, e_mgr.lname mgr_lname, 
       e.superior_emp_id, e_mgr.emp_id
FROM employee e INNER JOIN employee e_mgr
ON e.superior_emp_id = e_mgr.emp_id;


/*Euqi-Join vs Non-Equi-Joins*/

select*
from employee;
select*
from product;

SELECT e1.fname, e1.lname, 'VS' vs, e2.fname, e2.lname
FROM employee e1 INNER JOIN employee e2
ON e1.emp_id < e2.emp_id
WHERE e1.title = 'Teller' AND e2.title = 'Teller';

/*This query joins two tables that have no foreign key relationships. The intent is to find
all employees who began working for the bank while the No-Fee Checking product
was being offered. Thus, an employee’s start date must be between the date the product
was offered and the date the product was retired.*/

SELECT e1.fname, e1.lname, 'VS' vs, e2.fname, e2.lname
FROM employee e1 INNER JOIN employee e2
ON e1.emp_id != e2.emp_id
WHERE e1.title = 'Teller' AND e2.title = 'Teller';

/* Avoiding reverse pairing*/
SELECT e1.fname, e1.lname, 'VS' vs, e2.fname, e2.lname
FROM employee e1 INNER JOIN employee e2
ON e1.emp_id > e2.emp_id
WHERE e1.title = 'Teller' AND e2.title = 'Teller';

SELECT e1.fname, e1.lname, 'VS' vs, e2.fname, e2.lname
FROM employee e1 INNER JOIN employee e2
ON e1.emp_id < e2.emp_id
WHERE e1.title = 'Teller' AND e2.title = 'Teller';


SELECT*
FROM branch;

SELECT e.emp_id, e.fname, e.lname, b.name
FROM employee e INNER JOIN branch b
ON e.assigned_branch_id = b.branch_id ;

/*Write a query that returns the account ID for each nonbusiness customer
(customer.cust_type_cd = 'I') along with the customer’s federal ID (cus
tomer.fed_id) and the name of the product on which the account is based (prod
uct.name).*/

select* from account;
select* from customer;
select* from product;

select a.account_id, c.fed_id, p.name
from account a INNER JOIN customer c 
  on a.cust_id = c.cust_id
    INNER JOIN product p 
  on a.product_cd = p.product_cd
where c.cust_type_cd = 'I';

/*Construct a query that finds all employees whose supervisor is assigned to a different
department. Retrieve the employees’ ID, first name, and last name.*/

select* from employee;
/*Answer 1*/
select e.emp_id, e.fname, e.lname, e.superior_emp_id, mgr.emp_id
from employee e INNER JOIN employee mgr 
  on e.superior_emp_id = mgr.emp_id
where e.dept_id != mgr.dept_id;
/*Answer 2*/
select e.emp_id, e.fname, e.lname, mgr.superior_emp_id, e.emp_id
from employee e INNER JOIN employee mgr 
  on e.emp_id = mgr.superior_emp_id 
where e.dept_id != mgr.dept_id;
/*Answer 1 is the correct answer which return employee 4 and 5
Answer 2 is illogical */

