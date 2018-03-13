
/*****************************************************************/
/*																 */
/* Practice code from Alan Beaulieu Beijing (2009) Learning SQL  */
/*																 */
/*     Modeified and created by Nathaniel Lai (2017)			 */
/*																 */
/*****************************************************************/


/***********************************************/
/*                        					   */
/*		  Chapter 3: Query Primer    		   */
/*											   */
/***********************************************/

select *
from employee;

/*
  Select 

• Literals, such as numbers or strings
• Expressions, such as transaction.amount * −1
• Built-in function calls, such as ROUND(transaction.amount, 2)
• User-defined function calls

See the first bloc of code
*/

SELECT emp_id,
'ACTIVE',
emp_id * 3.14159,
UPPER(lname)
FROM employee;

SELECT VERSION(),
USER(),
DATABASE();

SELECT emp_id,
'ACTIVE' status,
emp_id * 3.14159 empid_x_pi,
UPPER(lname) last_name_upper,
LOWER(fname) first_name_lower
FROM employee;

SELECT employee.emp_id, employee.fname,
employee.lname, department.name dept_name
FROM employee INNER JOIN department
ON employee.dept_id = department.dept_id
order by emp_id;

SELECT e.emp_id, e.fname,
e.lname, d.name dept_name
FROM employee e, department d 
WHERE e.dept_id = d.dept_id
order by emp_id;

SELECT emp_id, fname, lname, start_date, title
FROM employee
WHERE title = 'Head Teller';

SELECT cust_id, cust_type_cd, city, state, fed_id
FROM customer
ORDER BY LEFT(fed_id, 3);

SELECT cust_id, cust_type_cd, city, state, fed_id
FROM customer
ORDER BY RIGHT(fed_id, 3);

SELECT open_emp_id, account_id, COUNT(*) how_many
FROM account
GROUP BY open_emp_id;

SELECT open_emp_id, COUNT(*) how_many
FROM account
GROUP BY open_emp_id;

SELECT open_emp_id, COUNT(*) how_many
FROM account
GROUP BY open_emp_id
limit 3; /*return first three observations*/

SELECT open_emp_id, COUNT(*) how_many
FROM account
GROUP BY open_emp_id 
limit 2, 3; /*return two observations, starting from the third obs
                -> the 3th and the 4th obseration*/

/*Retrieve the employee ID, first name, and last name for all bank employees. 
Sort by last name and then by first name.*/

select emp_id, fname, lname
from employee
order by lname, fname;

/*Retrieve the account ID, customer ID, and available balance for all accounts whose
status equals 'ACTIVE' and whose available balance is greater than $2,500.*/

select* 
from product;

select account_id, cust_id, avail_balance
from account
where status = 'ACTIVE' and avail_balance > 2500;

/*Write a query against the account table that returns the IDs of the employees who
opened the accounts (use the account.open_emp_id column). Include a single row for
each distinct employee.*/

SELECT DISTINCT open_emp_id
FROM account;

SELECT p.product_cd, a.cust_id, a.avail_balance
FROM product p INNER JOIN account a
ON p.product_cd = a.product_cd
WHERE p.product_type_cd = 'ACCOUNT'
order by product_cd, cust_id;
