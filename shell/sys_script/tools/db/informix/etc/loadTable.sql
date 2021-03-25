-- CONNECT TO 'ip_systest@systestdb' USER 'informix' USING 'infdev'
-- CONNECT TO 'ip_0p@ipdb' USER 'informix' USING 'infxrmvb'
-- CONNECT TO 'sysadmin@systestdb';

-- SET CONSTRAINTS,INDEXES,TRIGGERS FOR hs_duty_rate DISABLED;

-- TRUNCATE hs_duty_rate;
-- TRUNCATE securuser;

-- DROP INDEX 58858_619251;
-- ALTER TABLE hs_duty_rate DROP CONSTRAINT u58858_619251;

-- ALTER TABLE hs_duty_rate TYPE(RAW);

-- LOAD FROM "/login/lchen/securuser.20150507" INSERT INTO securuser;

-- ALTER TABLE hs_duty_rate TYPE(STANDARD);

-- ALTER TABLE hs_duty_rate ADD CONSTRAINT primary key (hsno,hstarifftrtmnt,effdate);
-- CREATE UNIQUE INDEX ON hs_duty_rate (hsno,hstarifftrtmnt,effdate); 

-- SET CONSTRAINTS,INDEXES,TRIGGERS FOR hs_duty_rate ENABLED;

-- DISCONNECT CURRENT;
