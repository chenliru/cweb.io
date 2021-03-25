CONNECT TO 'ip_systest@systestdb' USER 'lchen' USING 'admin12';

BEGIN WORK;

	INSERT INTO ip_systest@systestdb:informix.securuser 
		SELECT * FROM securuser WHERE NOT EXISTS 
		(SELECT * from ip_systest@systestdb:informix.securuser remote 
		WHERE remote.useriid=securuser.useriid);

COMMIT WORK;
