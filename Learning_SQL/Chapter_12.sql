
/*****************************************************************/
/*																 */
/* Practice code from Alan Beaulieu Beijing (2009) Learning SQL  */
/*																 */
/*     Modeified and created by Nathaniel Lai (2017)			 */
/*																 */
/*****************************************************************/


/*********************************/
/*								 */
/*    Chapter 12: Transaction    */
/*								 */
/*********************************/

/*
Read + Write Lock

Versioning (Write lock but no read lock)

Table lock, Page lock, Row lock

Transaction is a device for grouping together multiple SQL statements such that either 
all or none of the statements succeed (a property known as atomicity) p219.

Commit command instructs the server to mark the changes as permanent and release any resources 
(i.e., page or row locks) used during the transaction.

Rollback command instructs the server to return the data to its pretransaction state. After 
the rollback has been completed, any resources used by your session are released.

Deadlock p222
Savepoint p223 must + commit 
*/


/*Exercise 12-1
Generate a transaction to transfer $50 from Frank Tucker’s money market account to
his checking account. You will need to insert two rows into the transaction table and
update two rows in the account table.*/

SET AUTOCOMMIT=0;  #MySQL allows you to disable auto-commit mode via this

START TRANSACTION;
SELECT i.cust_id,
(SELECT a.account_id FROM account a
WHERE a.cust_id = i.cust_id
AND a.product_cd = 'MM') mm_id,
(SELECT a.account_id FROM account a
WHERE a.cust_id = i.cust_id
AND a.product_cd = 'chk') chk_id
INTO @cst_id, @mm_id, @chk_id
FROM individual i
WHERE i.fname = 'Frank' AND i.lname = 'Tucker';

INSERT INTO transaction (txn_id, txn_date, account_id,
txn_type_cd, amount)
VALUES (NULL, now(), @mm_id, 'CDT', 50);

INSERT INTO transaction (txn_id, txn_date, account_id,
txn_type_cd, amount)
VALUES (NULL, now(), @chk_id, 'DBT', 50);

UPDATE account
SET last_activity_date = now(),
avail_balance = avail_balance - 50
WHERE account_id = @mm_id;

UPDATE account
SET last_activity_date = now(),
avail_balance = avail_balance + 50
WHERE account_id = @chk_id;

COMMIT;

