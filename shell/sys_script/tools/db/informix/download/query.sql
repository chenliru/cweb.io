CONNECT TO 'ip_systest@systestdb' USER 'lchen' USING 'admini@12';

unload to "/home/lchen/informix/download/query.tmp"

select "informix".vw_user_cltacct.liiclientno as ClientNumber,
"informix".b3.acctsecurno || substr('000000000' || "informix".b3.transno, length('' || "informix".b3.transno) + 1, 9) as TransactionNumber,
"informix".b3.liibrchno || '-' || substr('000000' || "informix".b3.liirefno, length('' || "informix".b3.liirefno) + 1, 6) as LivingstonInvoiceNumber,
(CASE WHEN informix.b3.reldate = '1753/01/01 00:00:00' THEN NULL ELSE datetimeParse(informix.b3.reldate) END) as CustomsReleaseDate,
(CASE WHEN informix.b3.k84date = '1753/01/01 00:00:00' THEN NULL ELSE datetimeParse(informix.b3.k84date) END) as CustomsK84Date
from ((((((((((("informix".b3 INNER JOIN "informix".b3_subheader ON "informix".b3.b3iid = "informix".b3_subheader.b3iid )
INNER JOIN "informix".b3_line ON "informix".b3_subheader.b3subiid = "informix".b3_line.b3subiid )
INNER JOIN "informix".b3_recap_details ON "informix".b3_line.b3lineiid = "informix".b3_recap_details.b3lineiid )
LEFT OUTER JOIN "informix".ctry_code  ctry_code1 ON "informix".b3_subheader.ctryorigin = ctry_code1.ctrycode )
LEFT OUTER JOIN "informix".ctry_code ON "informix".b3_subheader.placeexp = "informix".ctry_code.ctrycode )
LEFT OUTER JOIN "informix".vw_tarifftrtmnt ON "informix".b3_subheader.tarifftrtmnt = "informix".vw_tarifftrtmnt.tarifftrtmnt )
INNER JOIN "informix".vw_user_cltacct ON "informix".vw_user_cltacct.liiclientno = "informix".b3.liiclientno
AND "informix".vw_user_cltacct.liiaccountno = "informix".b3.liiaccountno )
LEFT OUTER JOIN "informix".carrier ON "informix".b3.carriercode = "informix".carrier.carriercode )
LEFT OUTER JOIN "informix".canct_off canct_off1 ON "informix".b3.custoff =  canct_off1.canctoffcode )
LEFT OUTER JOIN "informix".transp_mode ON "informix".b3.modetransp = "informix".transp_mode.transpmode )
LEFT OUTER JOIN "informix".canct_off ON "informix".b3.portunlading = "informix".canct_off.canctoffcode )
LEFT OUTER JOIN "informix".usport_exit ON "informix".b3.usportexit = "informix".usport_exit.portexit
where "informix".b3.status BETWEEN 505 and 508 and
(CASE WHEN informix.b3.reldate = '1753/01/01 00:00:00' THEN NULL ELSE datetimeparsetest("informix".b3.reldate) END) BETWEEN 2012/11/01 and 2012/11/02 and
"informix".vw_user_cltacct.liiclientno =  100013  and ("informix".vw_user_cltacct.useriid = 6589)

