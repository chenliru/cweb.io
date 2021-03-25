-- used to get table statistics ; 

select substr(tabname,1,20) tabname,tableid,substr(tbspace,1,15) tbspace,
      tbspaceid,npages t_used,fpages t_allocated
from syscat.tables;

