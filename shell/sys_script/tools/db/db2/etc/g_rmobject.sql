-- used to find relevant object in RM database;

select substr(obj_itemid,1,26) obj_itemid,vol_logicalname,obj_path,
       obj_status,substr(obj_orgfilename,1,25) obj_orgfilename,
       substr(obj_filename,1,35) obj_filename,obj_size
from rmobjects,rmvolumes
where obj_itemid = 'A1001001A06G24B01233B88634'
  and rmobjects.obj_volumeid = rmvolumes.vol_volumeid;


