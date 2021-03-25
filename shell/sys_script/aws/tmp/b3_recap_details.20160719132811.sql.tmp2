SELECT b3_recap_details.b3recapiid,'^~^',b3_recap_details.b3lineiid,'^~^',b3_recap_details.ccipageno,'^~^',b3_recap_details.ccilineno,'^~^',b3_recap_details.uom,'^~^',b3_recap_details.quantity,'^~^',b3_recap_details.amount,'^~^',b3_recap_details.proddesc,'^~^',b3_recap_details.percentsplit,'^~^',b3_recap_details.detailponumber,'^~^',b3_recap_details.unitprice,'^~^'
FROM B3,b3_subheader,b3_line,b3_recap_details
WHERE liibrchno = '436'
AND liirefno = '530052'
AND b3_subheader.b3iid = b3.b3iid
AND b3_line.b3subiid = b3_subheader.b3subiid
AND b3_recap_details.b3lineiid = b3_line.b3lineiid
;
