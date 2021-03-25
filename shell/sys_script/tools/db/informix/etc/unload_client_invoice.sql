CONNECT TO 'ip_0p@ipdb' USER 'lchen' USING 'admini@12';
UNLOAD TO "/recyclebox/lchen/openItem/ifx01.client_invoice" SELECT * FROM client_invoice; 
