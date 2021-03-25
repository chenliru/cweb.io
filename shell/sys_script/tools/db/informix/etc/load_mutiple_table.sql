#Simple schema command file
#The schema command file in this example extracts a table from the most recent level-0 backup of dbspace1. 
#The data is placed in the table test1:tlr 
#and the logs are applied to bring the table tlr to the current point in time.
database test1;
create table tlr (
   a_serial serial,
   b_integer integer,
   c_char char,
   d_decimal decimal
   ) in dbspace1;
insert into tlr select * from tlr;

#Restore a table from a previous backup
#The schema command file in this example extracts a table from the level-0 backup of dbspace1. 
#The logical logs are used to bring the table to the time of "2003-01-01 01:01:01". 
#The data is placed in the table test1:tlr.
database test1;
create table tlr (
   a_serial serial,
   b_integer integer,
   c_char char,
   d_decimal decimal
   ) in dbspace1;
insert into tlr select * from tlr;
restore to '2003-01-01 01:01:01';

#Restore to a different table
#The schema command file in this example extracts a table called test1:tlr 
#from the most recent backup of dbspace1 and places the data in the table test1:tlr_dest.
database test1;
create table tlr    (
   a_serial   serial,
   b_integer  integer,
   c_char     char(20),
   d_decimal  decimal,
   ) in dbspace1;
create table tlr_dest    (
   a_serial   serial,
   b_integer  integer,
   c_char     char(20),
   d_decimal  decimal
   ) in dbspace2;
insert into tlr_dest select * from tlr;

#Extract a subset of columns
#The schema command file in this example extracts a table test1:tlr 
#from the most recent backup of dbspace1 and places a subset of the data into the table test1:new_dest
database test1;
create table tlr    (
   a_serial   serial,
   b_integer  integer,
   c_char     char(20),
   d_decimal  decimal
   ) in dbspace1;
create table new_dest (
   X_char     char(20),
   Y_decimal  decimal,
   Z_name     char(40)
   ) in dbspace2;
insert into new_dest (X_char, Y_decimal) select c_char,d_decimal from tlr;

#Use data filtering
#The schema command file in this example extracts a table test1:tlr 
#from the most recent backup of dbspace1 and places the data 
#in the table test1:tlr only where the list conditions are true.
#Important: Filters can only be applied to a physical restore.
database test1;
create table tlr (
   a_serial   serial,
   b_integer  integer,
   c_char     char(20),
   d_decimal  decimal,
   ) in dbspace1;
insert into tlr 
  select * from tlr
  where c_char matches ‘john*'
  and d_decimal is NOT NULL
  and b_integer > 100;
restore to current with no log;

#Restore to an external table
#The schema command file in this example extracts a table called test1:tlr 
#from the most recent backup of dbspace1 and places the data in a file called /tmp/tlr.unl.
database test1;
create table tlr
(a_serial serial,
  b_integer integer
) in dbspace1;
create external table tlr_dest
  (a_serial serial,
   b_integer integer
  ) using ("/tmp/tlr.unl", delimited );
insert into tlr_dest select * from tlr;
restore to current with no log;

#Restore multiple tables
#The schema command file in this example extracts a table test1:tlr_1 and test1:tlr_2 
#from the most recent backup of dbspace1 and places the data in test1:tlr_1_dest and test1:tlr_2_dest. 
#This is an efficient way of restoring multiple tables because it requires only one scan of the archive and logical log files.
database test1;
create table tlr_1 
  (  columns  ) in dbspace1;
create table tlr_1_dest (  columns  ); 
create table tlr_2 
  (  columns  ) in dbspace1;
create table tlr_2_dest (  columns  );
insert into tlr_1_dest select * from tlr_1;
insert into tlr_2_dest select * from tlr_2;

#Perform a distributed restore
#The schema command file in this example extracts a table test:tlr_1 
#from the most recent backup of dbspace1 and places the data 
#on the database server rem_srv in the table rem_dbs:tlr_1.
database rem_dbs
create table tlr_1 
   ( columns  );
database test1;
create table tlr_1 
  (  columns  ) in dbspace1;
insert into rem_dbs@rem_srv.tlr_1 
  select * from tlr_1;


