-- get all relevant linked items;

select substr(sourceitemid,1,26) sourceitemid,
       substr(targetitemid,1,26) targetitemid,
       linktype,changed
from icmstlinks001001
where sourceitemid = 'A1001001A06G24B00535D11767';

-- sourceitemid represents the folder item;
-- targeritemid represents the documents item;
