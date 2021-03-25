-- Used to get CM tables;
--select substr(tabschema,1,15) schema,substr(tabname,1,20) tabname,type,status 
select substr(tabschema,1,15) schema,substr(tabname,1,20) tabname,type,status 
from syscat.tables 
where tabschema='ICMADMIN' 
  and type='T';
