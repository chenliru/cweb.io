


select substr(obj_itemid,1,26) obj_itemid,obj_volumeid, obj_path,
          substr(obj_orgfilename,1,25) obj_orgfilename, 
          substr(obj_filename,1,35) obj_filename ,obj_size
from rmobjects 
where obj_itemid = 'A1001001A08F08B10523E55366';

