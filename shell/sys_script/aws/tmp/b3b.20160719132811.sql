SELECT b3b.b3biid,'^~^',b3b.b3iid,'^~^',b3b.cargcntrlno,'^~^',b3b.quantity,'^~^',b3b.ccdseqno,'^~^'
FROM B3,b3b
WHERE liibrchno = '436'
AND liirefno = '530052'
AND b3b.b3iid = b3.b3iid
;
