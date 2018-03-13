
/*****************************************************************/
/*																 */
/* Practice code from Alan Beaulieu Beijing (2009) Learning SQL  */
/*																 */
/*     Modeified and created by Nathaniel Lai (2017)			 */
/*																 */
/*****************************************************************/


/***********************************************/
/*										       */
/*		 Chapter 6: Working with Sets	       */
/*											   */
/***********************************************/


select* from individual;
select* from business;

SELECT 'IND' type_cd, cust_id, concat(fname, ' ', lname) name
FROM individual
UNION ALL
SELECT 'BUS' type_cd, cust_id, name
FROM business;

SELECT 'IND' type_cd, cust_id, concat(fname, ' ', lname) name
FROM individual
UNION 
SELECT 'BUS' type_cd, cust_id, name
FROM business;

/*union all operator doesn’t remove duplicates*/
SELECT 'IND' type_cd, cust_id, concat(fname, ' ', lname) name
FROM individual
UNION ALL
SELECT 'BUS' type_cd, cust_id, name
FROM business
UNION ALL
SELECT 'BUS' type_cd, cust_id, name
FROM business;

/*union perator removes duplicates*/
SELECT 'IND' type_cd, cust_id, concat(fname, ' ', lname) name
FROM individual
UNION
SELECT 'BUS' type_cd, cust_id, name
FROM business
UNION
SELECT 'BUS' type_cd, cust_id, name
FROM business;

/*UNION ALL VS UNION*/

SELECT emp_id
FROM employee
WHERE assigned_branch_id = 2;

SELECT DISTINCT open_emp_id
FROM account
WHERE open_branch_id = 2;

SELECT emp_id
FROM employee
WHERE assigned_branch_id = 2
AND (title = 'Teller' OR title = 'Head Teller')
UNION ALL
SELECT DISTINCT open_emp_id
FROM account
WHERE open_branch_id = 2;

SELECT emp_id
FROM employee
WHERE assigned_branch_id = 2
AND (title = 'Teller' OR title = 'Head Teller')
UNION 
SELECT DISTINCT open_emp_id
FROM account
WHERE open_branch_id = 2;

/*INTERSECT (Unfortunately, version 6.0 of MySQL does not implement 
the intersect operator) -> Use the 'join' oprator*/
 
SELECT emp_id
FROM employee
WHERE assigned_branch_id = 2
AND (title = 'Teller' OR title = 'Head Teller')
intersect
SELECT DISTINCT open_emp_id
FROM account
WHERE open_branch_id = 2;


/*Write a compound query that finds the first and last names of all individual customers
along with the first and last names of all employees.*/

select* from employee;
select* from individual;

SELECT 'EMP' type_, fname, lname
from employee
union
select 'IND' type_cd, fname, lname
from individual
order by lname;
