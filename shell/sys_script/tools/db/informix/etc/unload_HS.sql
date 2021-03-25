-- CONNECT TO 'ip_0p@ipdb' USER 'lchen' USING 'admin12';
CONNECT TO 'ip_0p@ipdb' USER 'informix' USING 'infxrmvb';

UNLOAD TO "/recyclebox/lchen/hs_duty_rate.20150110" SELECT * FROM hs_duty_rate;
UNLOAD TO "/recyclebox/lchen/hs_uom.20150110" SELECT * FROM hs_uom;

TRUNCATE hs_duty_rate;
TRUNCATE hs_uom;
