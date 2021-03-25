-- CONNECT TO 'ip_systest@systestdb' USER 'informix' USING 'ifxdev'
CONNECT TO 'ip_0p@ipdb' USER 'lchen' USING 'admin12';

-- SET CONSTRAINTS,INDEXES,TRIGGERS FOR ph_run DISABLED;

UNLOAD TO "/recyclebox/lchen/ifx01.tariff_137651" select * from tariff where liiclientno=137651;
delete from tariff where liiclientno=137651; 

-- LOAD FROM "/recyclebox/lchen/ifx01.tariff_137651" INSERT INTO tariff;

-- DISCONNECT CURRENT;
