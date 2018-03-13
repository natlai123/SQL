
/*****************************************************************/
/*																 */
/* Practice code from Alan Beaulieu Beijing (2009) Learning SQL  */
/*																 */
/*     Modeified and created by Nathaniel Lai (2017)			 */
/*																 */
/*****************************************************************/


/****************************/
/*	    		 		    */
/*   Chapter 15: Metadata   */
/*	    		 		    */
/****************************/
/*

Data dictionary / System Catalog

Information_Schema

*/

SELECT table_name, table_type
FROM information_schema.tables #####
WHERE table_schema = 'bank'
ORDER BY 2;

SELECT table_name, is_updatable
FROM information_schema.views ##### 
WHERE table_schema = 'bank'
ORDER BY 1;

SELECT column_name, data_type, character_maximum_length char_max_len,
numeric_precision num_prcsn, numeric_scale num_scale
FROM information_schema.columns #### 
WHERE table_schema = 'bank' AND table_name = 'account'
ORDER BY ordinal_position;

SELECT index_name, non_unique, seq_in_index, column_name
FROM information_schema.statistics   ####   -> indexes
WHERE table_schema = 'bank' 
ORDER BY 1, 3;

SELECT constraint_name, table_name, constraint_type
FROM information_schema.table_constraints   ###### 
WHERE table_schema = 'bank'
ORDER BY 3,1;

/*  

    Table 15-1. 
	Information_schema views

	View name Provides information about…
	Schemata Databases
	Tables Tables and views
	Columns Columns of tables and views
	Statistics Indexes
    User_Privileges Who has privileges on which schema objects
	Schema_Privileges Who has privileges on which databases
	Table_Privileges Who has privileges on which tables
	Column_Privileges Who has privileges on which columns of which tables
	Character_Sets What character sets are available
	Collations What collations are available for which character sets
	Collation_Character_Set_Applicability Which character sets are available for which collation
	Table_Constraints The unique, foreign key, and primary key constraints
	Key_Column_Usage The constraints associated with each key column
	Routines Stored routines (procedures and functions)
	Views Views
	Triggers Table triggers
	Plugins Server plug-ins
	Engines Available storage engines
	Partitions Table partitions
	Events Scheduled events
	Process_List Running processes
	Referential_Constraints Foreign keys
	Global_Status Server status information
	Session_Status Session status information
	Server status variables
	Session_Variables Session status variables
	Parameters Stored procedure and function parameters
	Profiling User profiling information

    
    */
    
select * from information_schema.User_Privileges;


/*Schema Generation Scripts (Not useful for my purpose)*/

/*
a query that will generate the create table statement. The first step is to query
the information_schema.columns table to retrieve information about the columns in the
table:
*/

SELECT 'CREATE TABLE customer (' create_table_statement
UNION ALL
SELECT cols.txt
FROM
(SELECT concat(' ',column_name, ' ', column_type,
CASE
WHEN is_nullable = 'NO' THEN ' not null'
ELSE ''
END,
CASE
WHEN extra IS NOT NULL THEN concat(' ', extra)
ELSE ''
END,
',') txt
FROM information_schema.columns
WHERE table_schema = 'bank' AND table_name = 'customer'
ORDER BY ordinal_position
) cols
UNION ALL
SELECT ')';


/*Deployment Verification*/

/*

Here’s a query that returns the number of columns, number of indexes, and number of primary key
constraints (0 or 1) for each table in the bank schema:

*/

SELECT tbl.table_name,
(SELECT count(*) FROM information_schema.columns clm
WHERE clm.table_schema = tbl.table_schema
AND clm.table_name = tbl.table_name) num_columns,
(SELECT count(*) FROM information_schema.statistics sta
WHERE sta.table_schema = tbl.table_schema
AND sta.table_name = tbl.table_name) num_indexes,
(SELECT count(*) FROM information_schema.table_constraints tc
WHERE tc.table_schema = tbl.table_schema
AND tc.table_name = tbl.table_name
AND tc.constraint_type = 'PRIMARY KEY') num_primary_keys
FROM information_schema.tables tbl ####
WHERE tbl.table_schema = 'bank' AND tbl.table_type = 'BASE TABLE'
ORDER BY 1;


/*Dynamic SQL Generation*/

/*Submitting strings to a database engine rather than utilizing its SQL interface is 
generally knownas dynamic SQL execution.*/

SET @qry = 'SELECT cust_id, cust_type_cd, fed_id FROM customer';

PREPARE dynsql1 FROM @qry;

EXECUTE dynsql1;


SET @qry = 'SELECT product_cd, name, product_type_cd, date_offered, 
            date_retired FROM product WHERE product_cd = ?'; #? = placeholder

PREPARE dynsql2 FROM @qry;

SET @prodcd = 'CHK';

EXECUTE dynsql2 USING @prodcd;

SET @prodcd = 'SAV';

EXECUTE dynsql2 USING @prodcd;

/*Exercise 15-1
Write a query that lists all of the indexes in the bank schema. Include the table names.*/

SELECT DISTINCT table_name, index_name
FROM information_schema.statistics
WHERE table_schema = 'bank';

#Compare
SELECT index_name, non_unique, seq_in_index, column_name
FROM information_schema.statistics   ####   -> indexes
WHERE table_schema = 'bank' 
ORDER BY 1, 3;

/*Exercise 15-2
Write a query that generates output that can be used to create all of the indexes on the
bank.employee table. Output should be of the form:

"ALTER TABLE <table_name> ADD INDEX <index_name> (<column_list>)"*/

SELECT concat(
CASE
WHEN st.seq_in_index = 1 THEN
concat('ALTER TABLE ', st.table_name, ' ADD',
CASE
WHEN st.non_unique = 0 THEN ' UNIQUE '
ELSE ' '
END,
'INDEX ',
st.index_name, ' (', st.column_name)
ELSE concat(' ', st.column_name)
END,
CASE
WHEN st.seq_in_index =
(SELECT max(st2.seq_in_index)
FROM information_schema.statistics st2  #SELF JOIN
WHERE st2.table_schema = st.table_schema
AND st2.table_name = st.table_name
AND st2.index_name = st.index_name)
THEN ');'
ELSE ''
END
) index_creation_statement
FROM information_schema.statistics st #####
WHERE st.table_schema = 'bank'
AND st.table_name = 'employee'
ORDER BY st.index_name, st.seq_in_index;