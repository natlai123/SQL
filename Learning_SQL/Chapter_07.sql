
/*****************************************************************/
/*																 */
/* Practice code from Alan Beaulieu Beijing (2009) Learning SQL  */
/*																 */
/*     Modeified and created by Nathaniel Lai (2017)			 */
/*																 */
/*****************************************************************/


/**************************************************************/
/*															  */
/*  Chapter 7: Data Generation, Conversion, and Manipulation  */
/*															  */	
/**************************************************************/


String Types: CHAR, VARCHAR, TEXT
String Functions: 
	quote()
    char()
    length()
    concat()
    ascii()
    || operator
    position()
    locate()
    strcmp()
    regexp
    insert()
    replace()
    substring()
    upper()
    lower()
    right()
    left()
    count()
    trim()
    rtrim()
    ltrim()
    daypart()
    soundex()
    
    LIMIT 
    similar to outobs in SAS
    The offset specifies the offset of the first row to return. 
       The offset of the first row is 0, not 1.
    The count specifies the maximum number of rows to return.

*/

CREATE TABLE string_tbl
(char_fld CHAR(30),
vchar_fld VARCHAR(30),
text_fld TEXT
);

INSERT INTO string_tbl (char_fld, vchar_fld, text_fld)
VALUES ('This is char data',
'This is varchar data',
'This is text data');


select* from string_tbl;

SET SQL_SAFE_UPDATES=0;

UPDATE string_tbl
SET vchar_fld = 'This is a piece of extremely long varchar data';
/*Error Code: 1406. Data too long for column 'vchar_fld' at row 1MySQL throws 
an exception, not truncate the value,. To truncate the value, set to ANSI mode*/

SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SET SESSION sql_mode = 'ANSI';

UPDATE string_tbl
SET vchar_fld = 'This is a piece of extremely long varchar data';
select vchar_fld from string_tbl;
/*now return 'This is a piece of extremely l'

The best way to avoid string truncation (or exceptions, in the case
of Oracle Database or MySQL in strict mode) when working with varchar columns is
to set the upper limit of a column to a high enough value to handle the longest strings
that might be stored in the column*/

/*Including singel quotes*/

UPDATE string_tbl
SET text_fld = 'This string didn''t work, but it does now'; 

SELECT quote(text_fld)
FROM string_tbl;

SELECT 'abcdefg', CHAR(97,98,99,100,101,102,103);
SELECT CHAR(128,129,130,131,132,133,134,135,136,137);
SELECT CHAR(138,139,140,141,142,143,144,145,146,147);

SELECT CONCAT('danke sch', CHAR(148), 'n');

DELETE FROM string_tbl;

INSERT INTO string_tbl (char_fld, vchar_fld, text_fld)
VALUES ('This string is 28 characters',
'This string is 28 characters',
'This string is 28 characters');

select* from string_tbl;

SELECT LENGTH(char_fld) char_length,
LENGTH(vchar_fld) varchar_length,
LENGTH(text_fld) text_length
FROM string_tbl;

SELECT POSITION('characters' IN vchar_fld)
FROM string_tbl;

SELECT LOCATE('is', vchar_fld, 5)
FROM string_tbl;

DELETE FROM string_tbl;

INSERT INTO string_tbl(vchar_fld) VALUES ('abcd');
INSERT INTO string_tbl(vchar_fld) VALUES ('xyz');
INSERT INTO string_tbl(vchar_fld) VALUES ('QRSTUV');
INSERT INTO string_tbl(vchar_fld) VALUES ('qrstuv');
INSERT INTO string_tbl(vchar_fld) VALUES ('12345');

SELECT vchar_fld
FROM string_tbl
ORDER BY vchar_fld;

SELECT STRCMP('12345','12345') as 12345_12345,
       STRCMP('abcd','xyz') as abcd_xyz,
	   STRCMP('abcd','QRSTUV') as abcd_QRSTUV,
	   STRCMP('qrstuv','QRSTUV') as qrstuv_QRSTUV,
	   STRCMP('12345','xyz') as 12345_xyz,
       STRCMP('xyz','qrstuv') as xyz_qrstuv;
       
SELECT name, name LIKE '%ns' ends_in_ns
FROM department;

SELECT cust_id, cust_type_cd, fed_id,
fed_id REGEXP '.{3}-.{2}-.{4}' is_ss_no_format
FROM customer;

/*For more on pattern matching, see
 https://dev.mysql.com/doc/refman/5.7/en/pattern-matching.html
 https://dev.mysql.com/doc/refman/5.7/en/regexp.html
 */
 
DELETE FROM string_tbl;

INSERT INTO string_tbl (text_fld)
VALUES ('This string was 29 characters');
UPDATE string_tbl
SET text_fld = CONCAT(text_fld, ', but now it is longer');
/*double quotes*/
select text_fld from string_tbl;

SELECT CONCAT(fname, ' ', lname, ' has been a ',
title, ' since ', start_date) emp_narrative
FROM employee
WHERE title = 'Teller' OR title = 'Head Teller';

/*MySQL allows more than two arguements in the concat function.
  Other severs may use different functions*/
  
SELECT INSERT('goodbye world', 9, 0, 'cruel ') string;
SELECT INSERT('goodbye world', 8, 0, 'cruel ') string;
SELECT INSERT('goodbye world', 9, 5, 'cruel ') string;
SELECT length(INSERT('goodbye world', 9, 5, 'cruel ')) length1;
SELECT length(INSERT('goodbye world', 10, 5, 'cruel ')) length2;
SELECT INSERT('goodbye world', 1, 7, 'hello') string;

SELECT REPLACE('goodbye world', 'goodbye', 'hello')
FROM dual;

SELECT SUBSTRING('goodbye cruel world', 9, 5);

/*
  Numeric Functions
  
Acos(x) Calculates the arc cosine of x
Asin(x) Calculates the arc sine of x
Atan(x) Calculates the arc tangent of x
Cos(x) Calculates the cosine of x
Cot(x) Calculates the cotangent of x
Exp(x) Calculates ex
Ln(x) Calculates the natural log of x
Sin(x) Calculates the sine of x
Sqrt(x) Calculates the square root of x
Tan(x) Calculates the tangent of x

MOD()   calculates the remainder when one number is divided into another number
POW()   calculates the power of a number 
CEIL()
FLOOR()
ROUND()
TRUNCATE()
SIGN()  returns -1,0,1 for negative, zero, and positie numbers

*/

SELECT MOD(22.75, 5);
SELECT MOD(10,4);
SELECT POW(2,10) kilobyte, POW(2,20) megabyte, POW(2,30) gigabyte, POW(2,40) terabyte;
SELECT CEIL(72.445), FLOOR(72.445);
SELECT ROUND(72.49999), ROUND(72.5), ROUND(72.50001);
SELECT TRUNCATE(72.0909, 1), TRUNCATE(72.0909, 2), TRUNCATE(72.0909, 3);
SELECT ROUND(17, −1), TRUNCATE(17, −1);

/*
  Temporal Data
  
 Today, we use a variation of GMT called Coordinated Universal Time, or UTC, which
is based on an atomic clock (or, to be more precise, the average time of 200 atomic
clocks in 50 locations worldwide, which is referred to as Universal Time). 
  
  Date format compoments:
  Component   Definition Range
	YYYY Year, including century 1000 to 9999
	MM Month   01 (January) to 12 (December)
	DD Day     01 to 31
	HH Hour    00 to 23
	HHH Hours (elapsed) −838 to 838
	MI Minute  00 to 59
	SS Second  00 to 59
  
  
  Required date components: 
  Type Default format
  Date YYYY-MM-DD
  Datetime YYYY-MM-DD HH:MI:SS
  Timestamp YYYY-MM-DD HH:MI:SS
  Time HHH:MI:SS

Temporal Functions: 

  utc_timestamp()
  cast()
  string_to_date()
  CURRENT_DATE()
  CURRENT_TIME()
  CURRENT_TIMESTAMP()
  DATE_ADD(CURRENT_DATE(), INTERVAL 5 DAY);
  LAST_DAY('2008-09-17') find the last day of September; Whetherimputing a date or datetime 
						value, the last_day() function always returns a date.
  DAYNAME('2008-09-18')  determine which day of the week a certain date falls on
  DATEDIF('2009-09-03', '2009-06-24') take two date values and determine the number of intervals (days, weeks, 
									  years) between the two dates
  
*/

SELECT @@global.time_zone, @@session.time_zone;
SET time_zone = 'Europe'; #Somehow it doesn't work here
SELECT @@global.time_zone, @@session.time_zone;

#Building a string representation of the temporal data to be evaluated by the server

select txn_date, txn_id from transaction;

UPDATE transaction
SET txn_date = '2008-09-17 15:30:00'
WHERE txn_id = 9;

select txn_date from transaction WHERE txn_id = 9;

#CAST()
SELECT CAST('2008-09-17 15:30:00' AS DATETIME);
SELECT CAST('2008-09-17' AS DATE) date_field, CAST('108:17:57' AS TIME) time_field;
SELECT CAST('1456328' AS SIGNED INTEGER);
SELECT CAST('999ABC111' AS UNSIGNED INTEGER); #Only convert the first 3 numbers of the string 999

/*If you are converting a string to a date, time, or datetime value, then you will need to
stick with the default formats for each type, since you can’t provide the cast() function
with a format string. If your date string is not in the default format (i.e., YYYY-MMDD
HH:MI:SS for datetime types), then you will need to resort to using another function,
such as MySQL’s str_to_date() function

MySQL will accept all of the
following strings as valid representations of 3:30 P.M. on September 17, 2008:
'2008-09-17 15:30:00'
'2008/09/17 15:30:00'
'2008,09,17,15,30,00'
'20080917153000'*/

UPDATE individual
SET birth_date = STR_TO_DATE('September 17, 2008', '%M %d, %Y')
WHERE cust_id = 9;

/*  Table 7-4. Date format components
	Format component Description
	%M Month name (January to December)
	%m Month numeric (01 to 12)
	%d Day numeric (01 to 31)
	%j Day of year (001 to 366)
	%W Weekday name (Sunday to Saturday)
	%Y Year, four-digit numeric
	%y Year, two-digit numeric
	%H Hour (00 to 23)
	%h Hour (01 to 12)
	%i Minutes (00 to 59)
	%s Seconds (00 to 59)
	%f Microseconds (000000 to 999999)
	%p A.M. or P.M. 

  -> string_to_date() more flexible than cast()  
*/

SELECT CURRENT_DATE(), CURRENT_TIME(), CURRENT_TIMESTAMP();

SELECT DATE_ADD(CURRENT_DATE(), INTERVAL 5 DAY);

UPDATE transaction
SET txn_date = DATE_ADD(txn_date, INTERVAL '3:27:11' HOUR_SECOND)
WHERE txn_id = 9;

/*Table 7-5. Common interval types
Interval name Description
Second Number of seconds
Minute Number of minutes
Hour Number of hours
Day Number of days
Month Number of months
Year Number of years
Minute_second Number of minutes and seconds, separated by “:”
Hour_second Number of hours, minutes, and seconds, separated by “:”
Year_month Number of years and months, separated by “-”*/

SELECT LAST_DAY('2008-09-17');

SELECT DATEDIFF('2009-09-03', '2009-06-24');
SELECT DATEDIFF('2009-09-03 23:59:59', '2009-06-24 00:00:01');
SELECT DATEDIFF('2009-06-24', '2009-09-03'); #Eariler date goes later to return a positive number 


/*Write a query that returns the 17th through 25th characters of the string 'Please find
the substring in this string'.*/
select substring('Please find the substring in this string', 17, 9); #return 'substring'

/*Write a query that returns the absolute value and sign (−1, 0, or 1) of the number −25.
76823. Also return the number rounded to the nearest hundredth.*/ 
select abs(-25.76823), sign(-25.76823), round(-25.76823,2);

/*Write a query to return just the month portion of the current date.*/
select extract(month from current_date());
