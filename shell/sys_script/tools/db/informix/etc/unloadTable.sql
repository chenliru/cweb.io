CONNECT TO 'ip_0p@ipdb' USER 'lchen' USING 'admin12';

-- UNLOAD TO "/home/lchen/ifx01.lii_client" SELECT * FROM lii_client; 
-- UNLOAD TO "/home/lchen/ifx01.lii_account" SELECT * FROM lii_account;

-- UNLOAD TO "/home/lchen/ifx01.client" SELECT * FROM client; 
-- UNLOAD TO "/home/lchen/ifx01.securuser" SELECT * FROM securuser; 

-- UNLOAD TO "/home/lchen/ifx01.user_locus_xref" SELECT * FROM user_locus_xref;
-- UNLOAD TO "/recyclebox/lchen/status_history.20141007" SELECT * FROM status_history;

-- UNLOAD TO "/recyclebox/lchen/hs_duty_rate.20150110" SELECT * FROM hs_duty_rate;
-- UNLOAD TO "/recyclebox/lchen/hs_uom.20150110" SELECT * FROM hs_uom;

UNLOAD TO "/recyclebox/lchen/securuser.20150622" SELECT * FROM securuser;

