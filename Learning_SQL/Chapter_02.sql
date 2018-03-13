
/*****************************************************************/
/*																 */
/* Practice code from Alan Beaulieu Beijing (2009) Learning SQL  */
/*																 */
/*     Modeified and created by Nathaniel Lai (2017)			 */
/*																 */
/*****************************************************************/

/*

SQL contains three parts:

Data definition language contains statements that help you define the database and its objects e.g., tables, views, triggers, stored procedures, etc.
Data manipulation language contains statements that allow you to update and query data.
Data control language allows you to grant the permissions to a user to access a certain data in the database.

select, update (set), delete, insert

Hierarchical Database 
Network Database
Relational Database

SQL = Nonprocedural Language

*/

/*************************************************/
/*                                               */
/* Chapter 2: Creating and Populating a Database */
/*											     */
/*************************************************/


CREATE TABLE person
(person_id SMALLINT AUTO_INCREMENT,
fname VARCHAR(20),
lname VARCHAR(20),
gender ENUM('M','F'),
birth_date DATE,
street VARCHAR(30),
city VARCHAR(20),
state VARCHAR(20),
country VARCHAR(20),
postal_code VARCHAR(20),
CONSTRAINT pk_person PRIMARY KEY (person_id)
);

/*SAS Code*/
/*
proc sql;
create table discounts
   (Product_ID num format=z12.,
    Start_Date date,
    End_Date date,
    Discount num format=percent.);
quit;
*/

CREATE TABLE favorite_food
(person_id SMALLINT AUTO_INCREMENT,
food VARCHAR(20),
CONSTRAINT pk_favorite_food PRIMARY KEY (person_id, food),
CONSTRAINT fk_fav_food_person_id FOREIGN KEY (person_id)
REFERENCES person (person_id)
);

DESC person;
DESCRIBE favorite_food;

/*DESC in MySQL stands for describe. SQL code specifies more on primary and foreign keys*/

INSERT INTO person
(person_id, fname, lname, gender, birth_date) /*Column List*/
VALUES (Null, 'William','Turner', 'M', '1972-05-27');

SELECT person_id, fname, lname, birth_date
FROM person
WHERE person_id = 1;

SELECT person_id, fname, lname, birth_date
FROM person
WHERE lname = 'Turner';

INSERT INTO favorite_food (person_id, food)
VALUES (1, 'pizza');
INSERT INTO favorite_food (person_id, food)
VALUES (1, 'cookies');
INSERT INTO favorite_food (person_id, food)
VALUE (1, 'nachos');

SELECT food
FROM favorite_food
WHERE person_id = 1
ORDER BY food;

INSERT INTO person(person_id, fname, lname, gender, birth_date,
street, city, state, country, postal_code)
VALUES (Null, 'Susan','Smith', 'F', '1975-11-02',
 '23 Maple St.', 'Arlington', 'VA', 'USA', '20220');
 
UPDATE person
SET street = '1225 Tremont St.',
city = 'Boston',
state = 'MA',
country = 'USA',
postal_code = '02138'
WHERE person_id = 1;

/*

Non-unique Primary Key

INSERT INTO person
(person_id, fname, lname, gender, birth_date)
VALUES (1, 'Charles','Fulton', 'M', '1968-01-15');

* Nonexistent Foreign Key 
INSERT INTO favorite_food (person_id, food)
VALUES (999, 'lasagna')

*Column Value Violation
UPDATE person
SET gender = 'Z'
WHERE person_id = 1;

The default format is "YYYY-MM-DD"
Formatters  converting strings to datetimes in MySQL:

%a The short weekday name, such as Sun, Mon, ...
%b The short month name, such as Jan, Feb, ...
%c The numeric month (0..12)
%d The numeric day of the month (00..31)
%f The number of microseconds (000000..999999)
%H The hour of the day, in 24-hour format (00..23)
%h The hour of the day, in 12-hour format (01..12)
%i The minutes within the hour (00..59)
%j The day of year (001..366)
%M The full month name (January..December)
%m The numeric month
%p AM or PM
%s The number of seconds (00..59)
%W The full weekday name (Sunday..Saturday)
%w The numeric day of the week (0=Sunday..6=Saturday)
%Y The four-digit year

ALTER TABLE ... MODIFY ... ; 
*/

UPDATE person
SET birth_date = str_to_date('DEC-21-1980', '%b-%d-%Y')
WHERE person_id = 1;


Delete from person where person_id in (3, 4);

SELECT person_id, fname, lname, birth_date
FROM person;

SHOW TABLES;
DESC customer;

DROP TABLE favorite_food;
DROP TABLE person;