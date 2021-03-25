-- Based on keyword name, say item type name, get all relevant info;

select KEYWORDCLASS,KEYWORDCODE,substr(KEYWORDNAME,1,25) keywordname,
       substr(KEYWORDDEscription,1,25) Description
from icmstnlskeywords
where keywordname = 'ICMParts1308';
