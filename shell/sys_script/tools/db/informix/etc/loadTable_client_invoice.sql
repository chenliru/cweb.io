CONNECT TO 'ip_systest@systestdb' USER 'lchen' USING 'admini@12';
UNLOAD TO "/recyclebox/lchen/ipdev.client_invoice" SELECT * FROM client_invoice;


SET CONSTRAINTS,INDEXES,TRIGGERS FOR client_invoice DISABLED;
LOAD FROM "/recyclebox/lchen/openItem/ifx01.client_invoice20120815" INSERT INTO client_invoice; 
SET CONSTRAINTS,INDEXES,TRIGGERS FOR client_invoice ENABLED;

COMMIT;

-- DISCONNECT CURRENT;
