-- Based on item type name; get necessary information;

select k.keywordname, it.itemtypeid, it.itemtypeclass, 
       it.autolinkenable,it.changed
from icmstnlskeywords k, icmstitemtypedefs it
where k.keywordname='RIV'
  and k.keywordclass=2
  and k.keywordcode=it.itemtypeid;

