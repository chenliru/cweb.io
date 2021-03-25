-- based on itemtype name, get all relevant infor from nlskeywords table;

select substr(keywordname,1,25) name,substr(keyworddescription,1,25) desc
from icmstnlskeywords
where keywordname = 'AS010';
-- where keywordcode = 1698;
