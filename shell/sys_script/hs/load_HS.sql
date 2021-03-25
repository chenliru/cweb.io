-- CONNECT TO 'ip_systest@systestdb' USER 'informix' USING 'infdev';
CONNECT TO 'ip_0p@ipdb' USER 'informix' USING 'infxrmvb';

UNLOAD TO "/recyclebox/lchen/hs_duty_rate.20160110" SELECT * FROM hs_duty_rate;
UNLOAD TO "/recyclebox/lchen/hs_uom.20160110" SELECT * FROM hs_uom;

-- TRUNCATE hs_duty_rate;
-- TRUNCATE hs_uom;

/* --!!Start hs_duty_rate; uncomment it if EGENT!!
SET CONSTRAINTS,INDEXES,TRIGGERS FOR hs_duty_rate DISABLED;
TRUNCATE hs_duty_rate;

ALTER TABLE hs_duty_rate DROP CONSTRAINT u58858_619280;
ALTER TABLE hs_duty_rate TYPE(RAW);

LOAD FROM "/recyclebox/lchen/hs_duty_rate.20160109" INSERT INTO hs_duty_rate;

ALTER TABLE hs_duty_rate TYPE(STANDARD);
ALTER TABLE hs_duty_rate ADD CONSTRAINT primary key (hsno,hstarifftrtmnt,effdate);

SET CONSTRAINTS,INDEXES,TRIGGERS FOR hs_duty_rate ENABLED;
--Stop hs_duty_rate */

/* --Start hs_uom; uncomment it if EGENT!!
SET CONSTRAINTS,INDEXES,TRIGGERS FOR hs_uom DISABLED;
TRUNCATE hs_uom;

LOAD FROM "/recyclebox/lchen/hs_uom.20160109" INSERT INTO hs_uom;

SET CONSTRAINTS,INDEXES,TRIGGERS FOR hs_uom ENABLED;
--Stop hs_uom */

DISCONNECT CURRENT;
