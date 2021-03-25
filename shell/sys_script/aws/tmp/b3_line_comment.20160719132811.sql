SELECT b3_line_comment.b3linecommentiid,'^~^',b3_line_comment.b3lineiid,'^~^',b3_line_comment.comment1,'^~^',b3_line_comment.comment2,'^~^'
FROM B3,b3_subheader,b3_line,b3_line_comment
WHERE liibrchno = '436'
AND liirefno = '530052'
AND b3_subheader.b3iid = b3.b3iid
AND b3_line.b3subiid = b3_subheader.b3subiid
AND b3_line_comment.b3lineiid = b3_line.b3lineiid
;
