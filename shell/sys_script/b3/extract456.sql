unload to brch456_aug18.txt 
select * from b3,  status_history, b3_subheader, b3_line, b3_recap_details, outer b3_line_comment
 where liibrchno=456 and
liirefno between 7752 and 8500 and
b3.b3iid=b3_subheader.b3iid and
status_history.b3iid=b3.b3iid and
b3_subheader.b3subiid=b3_line.b3subiid and
b3_line.b3lineiid=b3_recap_details.b3lineiid and
b3_line.b3lineiid=b3_line_comment.b3lineiid

UNLOAD TO "/home/lchen/b3456" SELECT * FROM b3 
where liibrchno = 456 and liirefno > 7752 and liirefno < 9001

UNLOAD TO "/home/lchen/status_history456" 
SELECT status_history.b3iid, status_history.status, status_history.statusdate
FROM b3, status_history
where liibrchno = 456 and liirefno > 7752 and liirefno < 9001 
and b3.b3iid = status_history.b3iid


select * FROM b3
where liibrchno=456 and
liirefno between 7752 and 8500

DELETE FROM b3
where liibrchno=456 and
liirefno between 7752 and 7900
