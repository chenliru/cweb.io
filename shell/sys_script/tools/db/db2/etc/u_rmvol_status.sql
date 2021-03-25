-- Manually update vol status ;

connect to rmdblb user rmadmin using cmrm83;

update rmvolumes
set vol_status = 'F'
where vol_logicalname = '/dev/lbosdata11lv';

TERMINATE;
