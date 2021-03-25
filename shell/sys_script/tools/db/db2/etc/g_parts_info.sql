-- based on itemid from root table 
-- get all parts information;


select ITEMID, VERSIONID, RESOURCENUM, RTARGETITEMID, 
       RTARGETITEMTYPEID,RTARGETCOMPID,RTARGETCOMPTYPEID
from icmut01700001
where itemid = 'A1001001A06G24B04341J85782';
