set isolation to dirty read;
SELECT status_history.b3iid,'^~^',status_history.status,'^~^',status_history.statusdate,'^~^'
FROM B3,status_history
WHERE liibrchno = '436'
AND liirefno = '530052'
AND status_history.b3iid = b3.b3iid
AND status_history.status = b3.status
;
