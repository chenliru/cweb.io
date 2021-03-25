SELECT containers.containeriid,'^~^',containers.b3iid,'^~^',containers.containerno,'^~^'
FROM B3,containers
WHERE liibrchno = '436'
AND liirefno = '530052'
AND containers.b3iid = b3.b3iid
;
