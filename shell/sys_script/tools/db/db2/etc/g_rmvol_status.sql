-- Check how rm volumes been used;

connect to rmdblb user rmadmin using cmrm83;

select substr(vol_logicalname,1,20) vol_logicalname,vol_status,
       ((vol_size-vol_freespace)*1.00/vol_size)*100 as VOL_USAGE
from rmvolumes;

TERMINATE;
