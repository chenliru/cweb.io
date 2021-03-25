-- Get actual volume location by volumeid;

select vol_volumeid,vol_attributes,vol_status,
       substr(vol_mountpoint,1,35) vol_mountpoint 
from rmvolumes 
where vol_volumeid = 5;
