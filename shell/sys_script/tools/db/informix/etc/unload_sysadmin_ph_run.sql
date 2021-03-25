CONNECT TO 'sysadmin@ipdb' USER 'informix' USING 'infxrmvb';
UNLOAD TO "/recyclebox/lchen/sysadmin.ph_run.2010" SELECT * FROM ph_run where to_char(run_time, '%Y') like '2010%'; 
