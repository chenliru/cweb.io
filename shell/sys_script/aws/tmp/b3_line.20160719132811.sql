SELECT b3_line.b3lineiid,'^~^',b3_line.b3subiid,'^~^',b3_line.b3lineno,'^~^',b3_line.advaldutyrateumeas,'^~^',b3_line.advalrate1,'^~^',b3_line.convtoqty1,'^~^',b3_line.convtoqty2,'^~^',b3_line.convtoqty3,'^~^',b3_line.excduty,'^~^',b3_line.excdutyrateumeas,'^~^',b3_line.excdutyrate,'^~^',b3_line.exchgrate,'^~^',b3_line.exctax,'^~^',b3_line.exctaxrateumeas,'^~^',b3_line.exctaxrate,'^~^',b3_line.gst,'^~^',b3_line.gstrate,'^~^',b3_line.hsno,'^~^',b3_line.oicspecialaut,'^~^',b3_line.partkeywrd,'^~^',b3_line.partsufx,'^~^',b3_line.partdesc,'^~^',b3_line.simacode,'^~^',b3_line.simaval,'^~^',b3_line.spcdutyrateumeas,'^~^',b3_line.spcrate,'^~^',b3_line.tariffcode,'^~^',b3_line.vfcc,'^~^',b3_line.vfd,'^~^',b3_line.vfdcode,'^~^',b3_line.vft,'^~^',b3_line.linecomment,'^~^',b3_line.advalduty,'^~^',b3_line.spcduty,'^~^',b3_line.totalduty,'^~^',b3_line.gstexemptcode,'^~^',b3_line.exctaxexmptcode,'^~^',b3_line.rulingnumber,'^~^',b3_line.trqno,'^~^',b3_line.prevtransno,'^~^',b3_line.prevlineno,'^~^'
FROM B3,b3_subheader,b3_line
WHERE liibrchno = '436'
AND liirefno = '530052'
AND b3_subheader.b3iid = b3.b3iid
AND b3_line.b3subiid = b3_subheader.b3subiid
;
