CONNECT TO 'ip_0p@ipdb' USER 'lchen' USING 'admin12';
UNLOAD TO "/recyclebox/lchen/ifx01.tariff_137651" select * from tariff where liiclientno=137651; 
