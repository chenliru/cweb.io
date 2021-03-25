
DBSCHEMA Schema Utility       INFORMIX-SQL Version 11.50.UC3W2  
grant dba to "informix";
grant resource to "ipgown";
grant connect to "public";









{ TABLE "informix".client_invoice row size = 87 number of columns = 13 index size 
              = 91 }
create table "informix".client_invoice 
  (
    liiclientno integer not null ,
    liiaccountno integer not null ,
    liibrchno integer not null ,
    liirefno integer not null ,
    liireftext char(3) not null ,
    itemstatus integer not null ,
    itemtypecode char(2) not null ,
    totduty float not null ,
    itemdate char(20) not null ,
    totamt float not null ,
    balance float not null ,
    transactionno char(15) not null ,
    itemformcode char(3) not null ,
    primary key (liiclientno,liiaccountno,liibrchno,liirefno,liireftext) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".client_invoice from "public" as "informix";

{ TABLE "informix".ctry_code row size = 39 number of columns = 2 index size = 9 }
create table "informix".ctry_code 
  (
    ctrycode char(4) not null ,
    description char(35) not null ,
    primary key (ctrycode) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".ctry_code from "public" as "informix";

{ TABLE "informix".tservice row size = 2535 number of columns = 2 index size = 40 
              }
create table "informix".tservice 
  (
    servicename char(35) not null ,
    sqlstatement char(2500) not null ,
    primary key (servicename) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".tservice from "public" as "informix";

{ TABLE "informix".state_model row size = 57 number of columns = 3 index size = 9 
              }
create table "informix".state_model 
  (
    statemodelcode integer not null ,
    statemodeldesc char(50) not null ,
    statemodeltype char(3) not null ,
    primary key (statemodelcode) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".state_model from "public" as "informix";

{ TABLE "informix".tariff_treatment row size = 40 number of columns = 3 index size 
              = 7 }
create table "informix".tariff_treatment 
  (
    tariff_trtmnt char(2) not null ,
    description char(35) not null ,
    tariff_trtmnt_code char(3) not null ,
    primary key (tariff_trtmnt) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".tariff_treatment from "public" as "informix";

{ TABLE "informix".usport_exit row size = 39 number of columns = 2 index size = 9 
              }
create table "informix".usport_exit 
  (
    portexit char(4) not null ,
    description char(35) not null ,
    primary key (portexit) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".usport_exit from "public" as "informix";

{ TABLE "informix".stringtable row size = 41 number of columns = 3 index size = 8 
              }
create table "informix".stringtable 
  (
    strtype char(3) not null ,
    strcode char(3) not null ,
    description char(35) not null ,
    primary key (strcode) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".stringtable from "public" as "informix";

{ TABLE "informix".claim_log row size = 172 number of columns = 17 index size = 141 
              }
create table "informix".claim_log 
  (
    claimlogiid integer not null ,
    liiclientno integer not null ,
    claimrefno char(14) not null ,
    b2brchno integer not null ,
    b2refno integer not null ,
    claimamount float not null ,
    claimstatus integer not null ,
    claimcode char(2) not null ,
    b3acctsecurno integer not null ,
    b3transno integer not null ,
    b3transseqno integer not null ,
    customsdesn char(1) not null ,
    receiveddate char(20) not null ,
    submitdate char(20) not null ,
    stampedcopydate char(20) not null ,
    customsdesndate char(20) not null ,
    claimvendorname char(35) not null ,
    primary key (claimlogiid) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".claim_log from "public" as "informix";

{ TABLE "informix".branch row size = 39 number of columns = 2 index size = 9 }
create table "informix".branch 
  (
    liibrchno integer not null ,
    description char(35) not null ,
    primary key (liibrchno) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".branch from "public" as "informix";

{ TABLE "informix".carrier row size = 39 number of columns = 2 index size = 9 }
create table "informix".carrier 
  (
    carriercode char(4) not null ,
    description char(35) not null ,
    primary key (carriercode) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".carrier from "public" as "informix";

{ TABLE "informix".hs_uom row size = 53 number of columns = 4 index size = 35 }
create table "informix".hs_uom 
  (
    hsno char(10) not null ,
    effdate char(20) not null ,
    exprydate char(20) not null ,
    unitmeas char(3) not null ,
    primary key (hsno,effdate) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".hs_uom from "public" as "informix";

{ TABLE "informix".as_accounted row size = 88 number of columns = 7 index size = 
              30 }
create table "informix".as_accounted 
  (
    asacctiid integer not null ,
    claimlogiid integer not null ,
    hsno char(10) not null ,
    b3description char(58) not null ,
    b2subhdrno integer not null ,
    b3lineno integer not null ,
    b2lineno integer not null ,
    primary key (asacctiid) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".as_accounted from "public" as "informix";

{ TABLE "informix".as_claimed row size = 88 number of columns = 7 index size = 30 
              }
create table "informix".as_claimed 
  (
    asclaimediid integer not null ,
    claimlogiid integer not null ,
    hsno char(10) not null ,
    b3description char(58) not null ,
    b2subhdrno integer not null ,
    b3lineno integer not null ,
    b2lineno integer not null ,
    primary key (asclaimediid) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".as_claimed from "public" as "informix";

{ TABLE "informix".status_history row size = 28 number of columns = 3 index size 
              = 22 }
create table "informix".status_history 
  (
    b3iid integer not null ,
    status integer not null ,
    statusdate char(20) not null ,
    primary key (b3iid,status) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".status_history from "public" as "informix";

{ TABLE "informix".transp_mode row size = 37 number of columns = 2 index size = 7 
              }
create table "informix".transp_mode 
  (
    transpmode char(2) not null ,
    description char(35) not null ,
    primary key (transpmode) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".transp_mode from "public" as "informix";

{ TABLE "informix".user_locus_xref row size = 16 number of columns = 4 index size 
              = 48 }
create table "informix".user_locus_xref 
  (
    userlocusxrefiid integer not null ,
    liiaccountno integer not null ,
    liiclientno integer not null ,
    useriid integer not null ,
    primary key (userlocusxrefiid) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".user_locus_xref from "public" as "informix";

{ TABLE "informix".b3_iid row size = 44 number of columns = 3 index size = 25 }
create table "informix".b3_iid 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_iid from "public" as "informix";

{ TABLE "informix".b3_line_iid row size = 44 number of columns = 3 index size = 25 
              }
create table "informix".b3_line_iid 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_line_iid from "public" as "informix";

{ TABLE "informix".b3_linecomment_iid row size = 44 number of columns = 3 index size 
              = 25 }
create table "informix".b3_linecomment_iid 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_linecomment_iid from "public" as "informix";

{ TABLE "informix".b3_recapdetail_iid row size = 44 number of columns = 3 index size 
              = 25 }
create table "informix".b3_recapdetail_iid 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_recapdetail_iid from "public" as "informix";

{ TABLE "informix".b3_subhdr_iid row size = 44 number of columns = 3 index size = 
              25 }
create table "informix".b3_subhdr_iid 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_subhdr_iid from "public" as "informix";

{ TABLE "informix".b3b_iid row size = 44 number of columns = 3 index size = 25 }
create table "informix".b3b_iid 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3b_iid from "public" as "informix";

{ TABLE "informix".status_history_iid row size = 44 number of columns = 3 index size 
              = 25 }
create table "informix".status_history_iid 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".status_history_iid from "public" as "informix";

{ TABLE "informix".as_accounted_iid row size = 44 number of columns = 3 index size 
              = 25 }
create table "informix".as_accounted_iid 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".as_accounted_iid from "public" as "informix";

{ TABLE "informix".accountcontact_iid row size = 44 number of columns = 3 index size 
              = 25 }
create table "informix".accountcontact_iid 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".accountcontact_iid from "public" as "informix";

{ TABLE "informix".as_claimed_iid row size = 44 number of columns = 3 index size 
              = 25 }
create table "informix".as_claimed_iid 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".as_claimed_iid from "public" as "informix";

{ TABLE "informix".company_iid row size = 44 number of columns = 3 index size = 25 
              }
create table "informix".company_iid 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".company_iid from "public" as "informix";

{ TABLE "informix".claim_log_iid row size = 44 number of columns = 3 index size = 
              25 }
create table "informix".claim_log_iid 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".claim_log_iid from "public" as "informix";

{ TABLE "informix".client_iid row size = 44 number of columns = 3 index size = 25 
              }
create table "informix".client_iid 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".client_iid from "public" as "informix";

{ TABLE "informix".userlocusxref_iid row size = 44 number of columns = 3 index size 
              = 25 }
create table "informix".userlocusxref_iid 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".userlocusxref_iid from "public" as "informix";

{ TABLE "informix".ip_rmd_iid row size = 44 number of columns = 3 index size = 25 
              }
create table "informix".ip_rmd_iid 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".ip_rmd_iid from "public" as "informix";

{ TABLE "informix".ip_cci_iid row size = 44 number of columns = 3 index size = 25 
              }
create table "informix".ip_cci_iid 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".ip_cci_iid from "public" as "informix";

{ TABLE "informix".ip_cci_line_iid row size = 44 number of columns = 3 index size 
              = 25 }
create table "informix".ip_cci_line_iid 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".ip_cci_line_iid from "public" as "informix";

{ TABLE "informix".ip_b3b_iid row size = 44 number of columns = 3 index size = 25 
              }
create table "informix".ip_b3b_iid 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".ip_b3b_iid from "public" as "informix";

{ TABLE "informix".contact_type row size = 38 number of columns = 2 index size = 
              8 }
create table "informix".contact_type 
  (
    contacttype char(3) not null ,
    description char(35) not null ,
    primary key (contacttype) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".contact_type from "public" as "informix";

{ TABLE "informix".currency_code row size = 62 number of columns = 5 index size = 
              8 }
create table "informix".currency_code 
  (
    currcode char(3) not null ,
    createdate char(20) not null ,
    ctrycode char(3) not null ,
    description char(35) not null ,
    naftaflag char(1) not null ,
    primary key (currcode) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".currency_code from "public" as "informix";

{ TABLE "informix".documents_list row size = 84 number of columns = 4 index size 
              = 20 }
create table "informix".documents_list 
  (
    docname char(15) not null ,
    description char(35) not null ,
    entityid integer not null ,
    modulename char(30) not null ,
    primary key (docname) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".documents_list from "public" as "informix";

{ TABLE "informix".canct_off row size = 39 number of columns = 2 index size = 9 }
create table "informix".canct_off 
  (
    canctoffcode char(4) not null ,
    description char(35) not null ,
    primary key (canctoffcode) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".canct_off from "public" as "informix";

{ TABLE "informix".client row size = 67 number of columns = 5 index size = 9 }
create table "informix".client 
  (
    clientiid integer not null ,
    clientname char(35) not null ,
    active integer not null ,
    moduserid integer not null ,
    moddate char(20) not null ,
    primary key (clientiid) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".client from "public" as "informix";

{ TABLE "informix".ip_cci row size = 1984 number of columns = 96 index size = 22 
              }
create table "informix".ip_cci 
  (
    cciiid integer not null ,
    refno integer not null ,
    fromsiteid integer not null ,
    ipstatus char(1) not null ,
    cciexpenseflag char(1) not null ,
    commerinvflag char(1) not null ,
    commerinvno char(40) not null ,
    condsale char(35) not null ,
    costnotincl float not null ,
    createdate char(20) not null ,
    createuserid integer not null ,
    currcode char(3) not null ,
    deptrulingdate char(20) not null ,
    deptrulingno char(20) not null ,
    directshiploc char(4) not null ,
    discnttype char(1) not null ,
    discount float not null ,
    entrytransship char(4) not null ,
    expnotincl float not null ,
    inclcost float not null ,
    inclexp float not null ,
    incltrans float not null ,
    invtot float not null ,
    invtotb4discnt float not null ,
    moddate char(20) not null ,
    modetransp char(2) not null ,
    moduserid integer not null ,
    nribroker float not null ,
    nriduty float not null ,
    nritax float not null ,
    nriinclpmntflg char(1) not null ,
    originator char(35) not null ,
    othercciref char(30) not null ,
    othernotes char(80) not null ,
    purchorderno char(15) not null ,
    purchorderref char(25) not null ,
    purchsupply char(1) not null ,
    royaltyproceeds char(1) not null ,
    shipdate char(20) not null ,
    status integer not null ,
    termspaymnt char(15) not null ,
    transpnotincl float not null ,
    transpshipflag char(1) not null ,
    unitmeasgross char(3) not null ,
    unitmeasnet char(3) not null ,
    cargcntrlno char(25) not null ,
    weightgross float not null ,
    weightnet float not null ,
    tositeid integer not null ,
    currcodedesc char(35) not null ,
    directshiplocation char(35) not null ,
    consigneename char(35) not null ,
    consigneeaddress1 char(35) not null ,
    consigneeaddress2 char(35) not null ,
    consigneeaddress3 char(35) not null ,
    exportername char(35) not null ,
    exporteraddress1 char(35) not null ,
    exporteraddress2 char(35) not null ,
    exporteraddress3 char(35) not null ,
    originatorname char(35) not null ,
    originatoraddress1 char(35) not null ,
    originatoraddress2 char(35) not null ,
    originatoraddress3 char(35) not null ,
    purchasername char(35) not null ,
    purchaseraddress1 char(35) not null ,
    purchaseraddress2 char(35) not null ,
    purchaseraddress3 char(35) not null ,
    vendname char(35) not null ,
    vendoraddress1 char(35) not null ,
    vendoraddress2 char(35) not null ,
    vendoraddress3 char(35) not null ,
    vendorstatecode char(3) not null ,
    vendorzipcode char(10) not null ,
    consigneecity char(35) not null ,
    consigneecountry char(35) not null ,
    consigneeprovince char(35) not null ,
    consigneepostcode char(10) not null ,
    exportercity char(35) not null ,
    exportercountry char(35) not null ,
    exportprovince char(35) not null ,
    exporterpostcode char(10) not null ,
    originatorcity char(35) not null ,
    originatorcountry char(35) not null ,
    originatorprovince char(35) not null ,
    originatorpostcode char(10) not null ,
    purchasercity char(35) not null ,
    purchasercountry char(35) not null ,
    purchaserprovince char(35) not null ,
    purchaserpostcode char(10) not null ,
    vendorcity char(35) not null ,
    vendorcountry char(35) not null ,
    vendorprovince char(35) not null ,
    vendorpostcode char(10) not null ,
    carrier char(35) not null ,
    edaeta char(20) not null ,
    portentry char(4) not null ,
    primary key (cciiid) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".ip_cci from "public" as "informix";

{ TABLE "informix".lii_contact row size = 127 number of columns = 9 index size = 
              23 }
create table "informix".lii_contact 
  (
    employeeno integer not null ,
    contactcode char(3) not null ,
    lastname char(35) not null ,
    firstname char(35) not null ,
    location char(25) not null ,
    phoneno char(10) not null ,
    faxno char(10) not null ,
    phoneext char(4) not null ,
    inactiveflag char(1) not null ,
    primary key (employeeno) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".lii_contact from "public" as "informix";

{ TABLE "informix".product row size = 38 number of columns = 2 index size = 8 }
create table "informix".product 
  (
    productcode char(3) not null ,
    description char(35) not null ,
    primary key (productcode) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".product from "public" as "informix";

{ TABLE "informix".tariff_code row size = 113 number of columns = 14 index size = 
              31 }
create table "informix".tariff_code 
  (
    tariffcode char(4) not null ,
    advalrate float not null ,
    createdate char(20) not null ,
    effdate char(20) not null ,
    exprydate char(20) not null ,
    maxamt float not null ,
    maxamttype char(3) not null ,
    maxamtunitmeas char(3) not null ,
    minamt float not null ,
    minamttype char(3) not null ,
    minamtunitmeas char(3) not null ,
    specrate float not null ,
    specunitmeas char(3) not null ,
    hstarifftrtmnt char(2) not null ,
    primary key (tariffcode,effdate,hstarifftrtmnt) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".tariff_code from "public" as "informix";

{ TABLE "informix".lii_client row size = 76 number of columns = 7 index size = 9 
              }
create table "informix".lii_client 
  (
    liiclientno integer not null ,
    name char(35) not null ,
    lastpaymntdate char(20) not null ,
    lastchequeamt float not null ,
    terms integer not null ,
    partnerbflag char(1) not null ,
    siteid integer not null ,
    primary key (liiclientno) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".lii_client from "public" as "informix";

{ TABLE "informix".ip_rmd row size = 237 number of columns = 26 index size = 22 }
create table "informix".ip_rmd 
  (
    iprmdiid integer not null ,
    acctsecurno integer not null ,
    transno integer not null ,
    tositeid integer not null ,
    ipstatus char(1) not null ,
    cargcntrlno char(25) not null ,
    carriercode char(4) not null ,
    createdate char(20) not null ,
    custoff char(4) not null ,
    vendname char(35) not null ,
    portunlading char(4) not null ,
    reldate char(20) not null ,
    weight integer not null ,
    cargcntrlqty float not null ,
    purchaseorder1 char(15) not null ,
    purchaseorder2 char(15) not null ,
    shipvia char(18) not null ,
    usportexit char(5) not null ,
    liibrchno integer not null ,
    liirefno integer not null ,
    fromsiteid integer not null ,
    b3type char(2) not null ,
    modetransp char(2) not null ,
    ctryorigin char(3) not null ,
    placeexp char(4) not null ,
    shipdate char(20) not null ,
    primary key (iprmdiid) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".ip_rmd from "public" as "informix";

{ TABLE "informix".securuser row size = 190 number of columns = 14 index size = 43 
              }
create table "informix".securuser 
  (
    useriid integer not null ,
    clientiid integer not null ,
    active integer not null ,
    fullname char(35) not null ,
    username char(20) not null ,
    password char(14) not null ,
    title char(25) not null ,
    userdesc char(50) not null ,
    moduserid integer not null ,
    moddate char(20) not null ,
    clienttype char(1),
    usprodimport integer 
        default 0,
    imagingtype char(1) 
        default 'N',
    caprodimport integer 
        default 0,
    primary key (useriid) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".securuser from "public" as "informix";

{ TABLE "informix".lii_account row size = 48 number of columns = 5 index size = 22 
              }
create table "informix".lii_account 
  (
    liiclientno integer not null ,
    liiaccountno integer not null ,
    name char(35) not null ,
    siteid integer not null ,
    partnerbflag char(1) not null ,
    primary key (liiclientno,liiaccountno) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".lii_account from "public" as "informix";

{ TABLE "informix".account_contact row size = 16 number of columns = 4 index size 
              = 44 }
create table "informix".account_contact 
  (
    acctcontiid integer not null ,
    employeeno integer not null ,
    liiclientno integer not null ,
    liiaccountno integer not null ,
    primary key (acctcontiid) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".account_contact from "public" as "informix";

{ TABLE "informix".b3b row size = 45 number of columns = 5 index size = 48 }
create table "informix".b3b 
  (
    b3biid integer not null ,
    b3iid integer not null ,
    cargcntrlno char(25) not null ,
    quantity float not null ,
    ccdseqno integer not null ,
    primary key (b3biid) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".b3b from "public" as "informix";

{ TABLE "informix".ip_cci_line row size = 250 number of columns = 22 index size = 
              18 }
create table "informix".ip_cci_line 
  (
    ccilineiid integer not null ,
    cciiid integer not null ,
    ccipageno integer not null ,
    ccilineno integer not null ,
    ctryorigin char(3) not null ,
    currcode char(3) not null ,
    partdesc char(58) not null ,
    discnttype char(1) not null ,
    dutiableval float not null ,
    hsno char(10) not null ,
    itemdiscnt float not null ,
    linetotval float not null ,
    nopacks integer not null ,
    partkeywrd char(25) not null ,
    partsufx char(4) not null ,
    quantity float not null ,
    reasoncode char(20) not null ,
    revtotval float not null ,
    typepack char(15) not null ,
    unitmeas char(3) not null ,
    unitprice float not null ,
    discnttypedesc char(40) not null ,
    primary key (ccilineiid) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".ip_cci_line from "public" as "informix";

{ TABLE "informix".product_used row size = 31 number of columns = 4 index size = 
              29 }
create table "informix".product_used 
  (
    productusediid integer not null ,
    productcode char(3) not null ,
    subscriptiondate char(20) not null ,
    liiclientno integer not null ,
    primary key (productusediid) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".product_used from "public" as "informix";

{ TABLE "informix".search_criteria row size = 12 number of columns = 3 index size 
              = 26 }
create table "informix".search_criteria 
  (
    useriid integer not null ,
    liiclientno integer not null ,
    liiaccountno integer not null ,
    primary key (useriid,liiclientno,liiaccountno) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".search_criteria from "public" as "informix";

{ TABLE "informix".b3_line_comment row size = 124 number of columns = 4 index size 
              = 18 }
create table "informix".b3_line_comment 
  (
    b3linecommentiid integer not null ,
    b3lineiid integer not null ,
    comment1 char(58) not null ,
    comment2 char(58) not null ,
    primary key (b3linecommentiid) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_line_comment from "public" as "informix";

{ TABLE "informix".ip_b3b row size = 41 number of columns = 4 index size = 18 }
create table "informix".ip_b3b 
  (
    ipb3biid integer not null ,
    cargcntrlno char(25) not null ,
    quantity float not null ,
    iprmdiid integer not null ,
    primary key (ipb3biid) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".ip_b3b from "public" as "informix";

{ TABLE "informix".privilege row size = 12 number of columns = 3 index size = 22 
              }
create table "informix".privilege 
  (
    privilegeiid integer not null ,
    serviceiid integer not null ,
    securgroupiid integer not null ,
    primary key (privilegeiid) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".privilege from "public" as "informix";

{ TABLE "informix".securgroup row size = 74 number of columns = 3 index size = 34 
              }
create table "informix".securgroup 
  (
    securgroupiid integer not null ,
    groupname char(20) not null ,
    groupdesc char(50) not null 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".securgroup from "public" as "informix";

{ TABLE "informix".services row size = 93 number of columns = 4 index size = 9 }
create table "informix".services 
  (
    serviceiid integer not null ,
    serviceno integer not null ,
    servicename char(35) not null ,
    servicedesc char(50) not null ,
    primary key (serviceiid) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".services from "public" as "informix";

{ TABLE "informix".usergroup row size = 36 number of columns = 5 index size = 22 
              }
create table "informix".usergroup 
  (
    usergroupiid integer not null ,
    securgroupiid integer not null ,
    useriid integer not null ,
    moduserid integer not null ,
    moddate char(20) not null ,
    primary key (usergroupiid) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".usergroup from "public" as "informix";

{ TABLE "informix".terr row size = 116 number of columns = 3 index size = 0 }
create table "informix".terr 
  (
    errsymbol char(32) not null ,
    errid integer not null ,
    errdesc char(80) not null 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".terr from "public" as "informix";

{ TABLE "informix".tipsysflds row size = 120 number of columns = 15 index size = 
              0 }
create table "informix".tipsysflds 
  (
    fld_batch integer not null ,
    fld_battablename char(15) not null ,
    fld_max_rows integer not null ,
    fld_direction integer not null ,
    fld_svc_parm char(32) not null ,
    fld_more_data integer not null ,
    fld_total_rows integer not null ,
    fld_columns smallint not null ,
    fld_key_id smallint not null ,
    fld_field_size integer not null ,
    fld_error_code integer not null ,
    fld_error_type integer not null ,
    s_user_id char(32) not null ,
    fld_dummy char(1) not null ,
    fld_recs_sent integer not null 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".tipsysflds from "public" as "informix";

{ TABLE "informix".fldidtbl_datatypes row size = 410 number of columns = 18 index 
              size = 0 }
create table "informix".fldidtbl_datatypes 
  (
    numdays integer not null ,
    sumvfd float not null ,
    sumduty float not null ,
    sumgst float not null ,
    sumbalance float not null ,
    sumrefunds float not null ,
    sumamends float not null ,
    cnttariff float not null ,
    custoffdesc char(35) not null ,
    usportexitdesc char(35) not null ,
    transpmodedesc char(35) not null ,
    portunladingdesc char(35) not null ,
    carrierdesc char(35) not null ,
    clientname char(35) not null ,
    accountname char(35) not null ,
    tarifftrtmntdesc char(35) not null ,
    ctrycodedesc char(35) not null ,
    placeexpdesc char(35) not null 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".fldidtbl_datatypes from "public" as "informix";

{ TABLE "informix".gst_rate_code row size = 44 number of columns = 4 index size = 
              6 }
create table "informix".gst_rate_code 
  (
    ratecode char(1) not null ,
    gstratedesc char(15) not null ,
    gstrate float not null ,
    effectivedate char(20) not null ,
    primary key (ratecode) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".gst_rate_code from "public" as "informix";

{ TABLE "informix".ip_ccn row size = 33 number of columns = 3 index size = 18 }
create table "informix".ip_ccn 
  (
    ccniid integer not null ,
    dociid integer not null ,
    cargcntlno char(25) not null ,
    primary key (ccniid) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".ip_ccn from "public" as "informix";

{ TABLE "informix".ip_ccn_iid row size = 44 number of columns = 3 index size = 25 
              }
create table "informix".ip_ccn_iid 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".ip_ccn_iid from "public" as "informix";

{ TABLE "informix".securuser_iid row size = 44 number of columns = 3 index size = 
              25 }
create table "informix".securuser_iid 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".securuser_iid from "public" as "informix";

{ TABLE "informix".b3_subhdr_iid_1 row size = 44 number of columns = 3 index size 
              = 25 }
create table "informix".b3_subhdr_iid_1 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_subhdr_iid_1 from "public" as "informix";

{ TABLE "informix".b3_line_iid_1 row size = 44 number of columns = 3 index size = 
              25 }
create table "informix".b3_line_iid_1 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_line_iid_1 from "public" as "informix";

{ TABLE "informix".b3_rcpdet_iid_1 row size = 44 number of columns = 3 index size 
              = 25 }
create table "informix".b3_rcpdet_iid_1 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_rcpdet_iid_1 from "public" as "informix";

{ TABLE "informix".b3_lincmt_iid_1 row size = 44 number of columns = 3 index size 
              = 25 }
create table "informix".b3_lincmt_iid_1 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_lincmt_iid_1 from "public" as "informix";

{ TABLE "informix".b3_subhdr_iid_2 row size = 44 number of columns = 3 index size 
              = 25 }
create table "informix".b3_subhdr_iid_2 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_subhdr_iid_2 from "public" as "informix";

{ TABLE "informix".b3_line_iid_2 row size = 44 number of columns = 3 index size = 
              25 }
create table "informix".b3_line_iid_2 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_line_iid_2 from "public" as "informix";

{ TABLE "informix".b3_rcpdet_iid_2 row size = 44 number of columns = 3 index size 
              = 25 }
create table "informix".b3_rcpdet_iid_2 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_rcpdet_iid_2 from "public" as "informix";

{ TABLE "informix".b3_lincmt_iid_2 row size = 44 number of columns = 3 index size 
              = 25 }
create table "informix".b3_lincmt_iid_2 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_lincmt_iid_2 from "public" as "informix";

{ TABLE "informix".b3_subhdr_iid_3 row size = 44 number of columns = 3 index size 
              = 25 }
create table "informix".b3_subhdr_iid_3 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_subhdr_iid_3 from "public" as "informix";

{ TABLE "informix".b3_line_iid_3 row size = 44 number of columns = 3 index size = 
              25 }
create table "informix".b3_line_iid_3 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_line_iid_3 from "public" as "informix";

{ TABLE "informix".b3_rcpdet_iid_3 row size = 44 number of columns = 3 index size 
              = 25 }
create table "informix".b3_rcpdet_iid_3 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_rcpdet_iid_3 from "public" as "informix";

{ TABLE "informix".b3_lincmt_iid_3 row size = 44 number of columns = 3 index size 
              = 25 }
create table "informix".b3_lincmt_iid_3 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_lincmt_iid_3 from "public" as "informix";

{ TABLE "informix".b3_subhdr_iid_4 row size = 44 number of columns = 3 index size 
              = 25 }
create table "informix".b3_subhdr_iid_4 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_subhdr_iid_4 from "public" as "informix";

{ TABLE "informix".b3_line_iid_4 row size = 44 number of columns = 3 index size = 
              25 }
create table "informix".b3_line_iid_4 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_line_iid_4 from "public" as "informix";

{ TABLE "informix".b3_rcpdet_iid_4 row size = 44 number of columns = 3 index size 
              = 25 }
create table "informix".b3_rcpdet_iid_4 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_rcpdet_iid_4 from "public" as "informix";

{ TABLE "informix".b3_lincmt_iid_4 row size = 44 number of columns = 3 index size 
              = 25 }
create table "informix".b3_lincmt_iid_4 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_lincmt_iid_4 from "public" as "informix";

{ TABLE "informix".b3_subhdr_iid_5 row size = 44 number of columns = 3 index size 
              = 25 }
create table "informix".b3_subhdr_iid_5 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_subhdr_iid_5 from "public" as "informix";

{ TABLE "informix".b3_line_iid_5 row size = 44 number of columns = 3 index size = 
              25 }
create table "informix".b3_line_iid_5 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_line_iid_5 from "public" as "informix";

{ TABLE "informix".b3_rcpdet_iid_5 row size = 44 number of columns = 3 index size 
              = 25 }
create table "informix".b3_rcpdet_iid_5 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_rcpdet_iid_5 from "public" as "informix";

{ TABLE "informix".b3_lincmt_iid_5 row size = 44 number of columns = 3 index size 
              = 25 }
create table "informix".b3_lincmt_iid_5 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_lincmt_iid_5 from "public" as "informix";

{ TABLE "ipgown".delimiter row size = 2 number of columns = 1 index size = 0 }
create table "ipgown".delimiter 
  (
    ch char(2) not null 
  ) extent size 32 next size 32 lock mode row;

revoke all on "ipgown".delimiter from "public" as "ipgown";

{ TABLE "informix".srch_crit_batch row size = 36 number of columns = 5 index size 
              = 51 }
create table "informix".srch_crit_batch 
  (
    tablename char(20) not null ,
    useriid integer not null ,
    liiclientno integer not null ,
    liiaccountno integer not null ,
    size integer 
        default 0
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".srch_crit_batch from "public" as "informix";

{ TABLE "ipgown".bulletin row size = 2524 number of columns = 3 index size = 0 }
create table "ipgown".bulletin 
  (
    msg_iid integer not null ,
    msg_desc char(2500) not null ,
    msg_expiry char(20) not null 
  ) extent size 32 next size 32 lock mode row;

revoke all on "ipgown".bulletin from "public" as "ipgown";

{ TABLE "informix".company row size = 33 number of columns = 3 index size = 73 }
create table "informix".company 
  (
    companyiid integer not null ,
    liiclientno integer not null ,
    companyname char(25) not null ,
    primary key (companyiid) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".company from "public" as "informix";

{ TABLE "ipgown".temp_b3 row size = 4 number of columns = 1 index size = 0 }
create table "ipgown".temp_b3 
  (
    b3iid integer
  ) extent size 32 next size 32 lock mode row;

revoke all on "ipgown".temp_b3 from "public" as "ipgown";

{ TABLE "informix".rpt_b3 row size = 625 number of columns = 52 index size = 22 }
create table "informix".rpt_b3 
  (
    rriid integer,
    b3iid integer not null ,
    siteid integer,
    refno integer,
    acctsecurno integer,
    b3comment char(80),
    b3type char(2),
    cargcntrlno char(25),
    carriercode char(4),
    createdate date,
    createuserid integer,
    custoff char(4),
    declcmpnyiid integer,
    decldate date,
    declarer char(35),
    deposit float,
    importeriid integer,
    k84amnt float,
    k84date date,
    lvsflag char(1),
    moddate date,
    modetransp char(1),
    moduserid integer,
    paymntcode char(1),
    prevacctsecurno integer,
    prevtransno integer,
    portunlading char(4),
    recapflag char(1),
    reldate date,
    status integer,
    totb3duty float,
    totb3entry float,
    totb3exctax float,
    totb3gst float,
    totb3sima float,
    totb3vfd float,
    transno integer,
    warehouseno char(25),
    weight float,
    purchaseorder1 char(15),
    shipvia char(18),
    useriid integer,
    importername char(35),
    purchaseorder2 char(15),
    sbrnno char(15),
    entname char(35),
    entaddr1 char(35),
    entaddr2 char(35),
    entaddr3 char(35),
    entaddr4 char(30),
    entpostcd char(9),
    locationofgoods char(17)
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".rpt_b3 from "public" as "informix";

{ TABLE "informix".rpt_b3_subheader row size = 130 number of columns = 19 index size 
              = 31 }
create table "informix".rpt_b3_subheader 
  (
    rriid integer,
    b3subiid integer not null ,
    b3iid integer,
    b3subno integer,
    cargcntrlno char(25),
    ctryorigin char(3),
    currcode char(3),
    freight float,
    placeexp char(4),
    shipdate date,
    tarifftrtmnt char(2),
    timelim integer,
    timelimunit char(3),
    usportexit char(5),
    consolidateflag char(1),
    vendstate char(3),
    vendorname char(35),
    vendorzip char(10),
    useriid integer
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".rpt_b3_subheader from "public" as "informix";

{ TABLE "informix".rpt_b3_line row size = 558 number of columns = 79 index size = 
              35 }
create table "informix".rpt_b3_line 
  (
    rriid integer,
    b3lineiid integer not null ,
    b3subiid integer,
    b3lineno integer,
    advaldutyrateumeas char(3),
    advalrate1 float,
    ccisiteiid integer,
    ccirefno integer,
    ccilineno integer,
    cciamnt float,
    convfrommeas1 char(3),
    convfrommeas2 char(3),
    convfrommeas3 char(3),
    convfromqty1 float,
    convfromqty2 float,
    convfromqty3 float,
    convtomeas1 char(3),
    convtomeas2 char(3),
    convtomeas3 char(3),
    convtoqty1 float,
    convtoqty2 float,
    convtoqty3 float,
    costrepair float,
    customduty float,
    discnttype char(1),
    discount float,
    excduty float,
    excdutyrateumeas char(3),
    excdutyrate float,
    exchgrate float,
    exctax float,
    exctaxrateumeas char(3),
    exctaxrate float,
    exctaxrefno char(3),
    flatdutyrate float,
    flatgstrate float,
    gst float,
    gstexemptcode char(3),
    gstratetype char(1),
    gstrate float,
    gstratecode char(1),
    hsno char(10),
    importval float,
    linetype char(2),
    oic75_1975 char(1),
    oicspecialaut char(16),
    partkeywrd char(25),
    partsufx char(4),
    partdesc char(58),
    simacode char(3),
    simaval float,
    spcdutyrateumeas char(3),
    spcrate float,
    spltpct float,
    tariffcode char(4),
    tariffcode233 char(1),
    timelim integer,
    timelimunit char(3),
    unajustedtot float,
    unitprice float,
    underwarranty char(1),
    usorigin char(1),
    vehicleid char(17),
    vfcc float,
    vfd float,
    vfdcode char(3),
    vft float,
    consolidateflag char(1),
    prorateadj float,
    lineflag char(2),
    linecomment char(50),
    currcode char(3),
    ccipageno integer,
    sortfield integer,
    useriid integer,
    spcduty float,
    trqno integer,
    prevtransno char(14),
    prevlineno integer 
        default 0
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".rpt_b3_line from "public" as "informix";

{ TABLE "informix".bat_control row size = 5 number of columns = 2 index size = 0 
              }
create table "informix".bat_control 
  (
    control_id integer not null ,
    continue char(1)
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".bat_control from "public" as "informix";

{ TABLE "informix".bat_id row size = 44 number of columns = 3 index size = 34 }
create table "informix".bat_id 
  (
    tablename char(20) not null ,
    last_id integer not null ,
    lastuseddate char(20)
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".bat_id from "public" as "informix";

{ TABLE "informix".bat_info row size = 325 number of columns = 12 index size = 9 
              }
create table "informix".bat_info 
  (
    bat_id integer not null ,
    user_id integer not null ,
    create_id char(20) not null ,
    fill_id char(20) not null ,
    srch_criteria char(200) not null ,
    bat_date char(20) not null ,
    process_status char(1) not null ,
    querytypeid integer not null ,
    qms_id char(20),
    submit_status char(1),
    convert_id char(30),
    convert_status char(1)
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".bat_info from "public" as "informix";

{ TABLE "informix".reporterr row size = 33 number of columns = 6 index size = 0 }
create table "informix".reporterr 
  (
    currentday date,
    tablename char(20),
    mode char(1),
    keyvalue integer,
    sqlerr smallint,
    isamerr smallint
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".reporterr from "public" as "informix";

{ TABLE "informix".b3 row size = 561 number of columns = 47 index size = 243 }
create table "informix".b3 
  (
    b3iid integer not null ,
    liiclientno integer not null ,
    liiaccountno integer not null ,
    liibrchno integer not null ,
    liirefno integer not null ,
    acctsecurno integer not null ,
    b3type char(2) not null ,
    cargcntrlno char(25) not null ,
    carriercode char(4) not null ,
    createdate char(20) not null ,
    custoff char(4) not null ,
    k84date char(20) not null ,
    modetransp char(2) not null ,
    portunlading char(4) not null ,
    reldate char(20) not null ,
    status integer not null ,
    totb3duty float not null ,
    totb3exctax float not null ,
    totb3gst float not null ,
    totb3sima float not null ,
    totb3vfd float not null ,
    transno integer not null ,
    weight integer not null ,
    purchaseorder1 char(15) not null ,
    purchaseorder2 char(15) not null ,
    shipvia char(18) not null ,
    locationofgoods char(17) not null ,
    containerno char(20) not null ,
    vendorname char(25) not null ,
    vendorstate char(3) not null ,
    vendorzip char(10) not null ,
    freight float not null ,
    usportexit char(5) not null ,
    billoflading char(10) not null ,
    cargcntrlqty float not null ,
    approveddate char(20) not null ,
    sbrnno char(15) 
        default '' not null ,
    ccnqty integer 
        default 0 not null ,
    ccinumlines integer 
        default 0 not null ,
    invoiceqty integer 
        default 0 not null ,
    warehousenum integer 
        default 0 not null ,
    entname char(35) 
        default '' not null ,
    entaddr1 char(35) 
        default '' not null ,
    entaddr2 char(35) 
        default '' not null ,
    entaddr3 char(35) 
        default '' not null ,
    entaddr4 char(30) 
        default '' not null ,
    entpostcd char(9) 
        default '' not null ,
    primary key (b3iid) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3 from "public" as "informix";

{ TABLE "informix".b3_subheader row size = 89 number of columns = 13 index size = 
              43 }
create table "informix".b3_subheader 
  (
    b3subiid integer not null ,
    b3iid integer not null ,
    b3subno integer not null ,
    ctryorigin char(3) not null ,
    currcode char(3) not null ,
    placeexp char(4) not null ,
    shipdate char(20) not null ,
    tarifftrtmnt char(2) not null ,
    timelim integer not null ,
    timelimunit char(3) not null ,
    vendorname char(25) not null ,
    vendorstate char(3) not null ,
    vendorzip char(10) not null ,
    primary key (b3subiid) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_subheader from "public" as "informix";

{ TABLE "informix".b3_line row size = 429 number of columns = 41 index size = 96 
              }
create table "informix".b3_line 
  (
    b3lineiid integer not null ,
    b3subiid integer not null ,
    b3lineno integer not null ,
    advaldutyrateumeas char(3) not null ,
    advalrate1 float not null ,
    convtoqty1 float not null ,
    convtoqty2 float not null ,
    convtoqty3 float not null ,
    excduty float not null ,
    excdutyrateumeas char(3) not null ,
    excdutyrate float not null ,
    exchgrate float not null ,
    exctax float not null ,
    exctaxrateumeas char(3) not null ,
    exctaxrate float not null ,
    gst float not null ,
    gstrate float not null ,
    hsno char(10) not null ,
    oicspecialaut char(16) not null ,
    partkeywrd char(25) not null ,
    partsufx char(4) not null ,
    partdesc char(58) not null ,
    simacode char(3) not null ,
    simaval float not null ,
    spcdutyrateumeas char(3) not null ,
    spcrate float not null ,
    tariffcode char(4) not null ,
    vfcc float not null ,
    vfd float not null ,
    vfdcode char(3) not null ,
    vft float not null ,
    linecomment char(58) not null ,
    advalduty float not null ,
    spcduty float not null ,
    totalduty float not null ,
    gstexemptcode char(3) not null ,
    exctaxexmptcode char(2) not null ,
    rulingnumber char(45) 
        default '' not null ,
    trqno integer 
        default 0 not null ,
    prevtransno char(14) 
        default '' not null ,
    prevlineno integer 
        default 0 not null ,
    primary key (b3lineiid) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_line from "public" as "informix";

{ TABLE "informix".b3_recap_details row size = 91 number of columns = 11 index size 
              = 68 }
create table "informix".b3_recap_details 
  (
    b3recapiid integer not null ,
    b3lineiid integer not null ,
    ccipageno integer not null ,
    ccilineno integer not null ,
    uom char(3) not null ,
    quantity float not null ,
    amount float not null ,
    proddesc char(25) not null ,
    percentsplit float 
        default 0.0000000000000000 not null ,
    detailponumber char(15) 
        default '' not null ,
    unitprice float 
        default 0.0000000000000000 not null ,
    primary key (b3recapiid) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".b3_recap_details from "public" as "informix";

{ TABLE "informix".insight_pdq row size = 42 number of columns = 5 index size = 18 
              }
create table "informix".insight_pdq 
  (
    pdq_id integer not null ,
    priority integer not null ,
    query_type integer not null ,
    explain char(10) not null ,
    comment char(20) not null 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".insight_pdq from "public" as "informix";

{ TABLE "informix".tariff row size = 555 number of columns = 47 index size = 359 
              }
create table "informix".tariff 
  (
    liiclientno integer not null ,
    vendorname char(25) not null ,
    productkeyword char(25) not null ,
    productsufx integer not null ,
    approvalcode char(1) not null ,
    b3description char(58) not null ,
    b3refbrch integer not null ,
    b3refno integer not null ,
    createdate char(20) not null ,
    cooindicator char(1) not null ,
    cooexprydate char(20) not null ,
    exctaxlicind char(1) not null ,
    gstexemptcode char(3) not null ,
    gstratecode char(1) not null ,
    hsno char(10) not null ,
    lastuseddate char(20) not null ,
    moddate char(20) not null ,
    moduser char(12) not null ,
    oic char(16) not null ,
    oicexprydate char(20) not null ,
    percentsplit float not null ,
    placeexp char(4) not null ,
    remissno char(16) not null ,
    remissexprydate char(20) not null ,
    rulingno char(45) not null ,
    rulingexprydate char(20) not null ,
    specialinstruct char(30) not null ,
    remarks char(58) not null ,
    tariffcode char(4) not null ,
    tarifftrtmnt char(2) not null ,
    vfdcode char(3) not null ,
    exctaxrate float not null ,
    exctaxamt float not null ,
    exctaxunit char(3) not null ,
    exctaxdeduct float not null ,
    exctaxdeductunit char(3) not null ,
    exctaxexmptcode char(2) not null ,
    projectcode char(5) 
        default '' not null ,
    businessunitcode char(5) 
        default '' not null ,
    materialclasscode char(3) 
        default '' not null ,
    countryorigin char(4) 
        default '' not null ,
    requirementid char(8) 
        default '' not null ,
    version char(4) 
        default '' not null ,
    ogdextension char(6) 
        default '' not null ,
    enduse char(3) 
        default '' not null ,
    miscellaneous char(3) 
        default '' not null ,
    regtype01 char(3) 
        default '' not null ,
    primary key (liiclientno,vendorname,productkeyword,productsufx) 
  ) in datadbs3  extent size 32 next size 32 lock mode row;

revoke all on "informix".tariff from "public" as "informix";

{ TABLE "informix".containers row size = 28 number of columns = 3 index size = 43 
              }
create table "informix".containers 
  (
    containeriid integer not null ,
    b3iid integer not null ,
    containerno char(20) not null ,
    primary key (containeriid) 
  ) in datadbs2  extent size 32 next size 32 lock mode row;

revoke all on "informix".containers from "public" as "informix";

{ TABLE "informix".container_iid row size = 44 number of columns = 3 index size = 
              25 }
create table "informix".container_iid 
  (
    tablename char(20) not null ,
    lastiid integer not null ,
    lastuseddate char(20) not null ,
    primary key (tablename) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".container_iid from "public" as "informix";

{ TABLE "informix".containershold row size = 40 number of columns = 6 index size 
              = 9 }
create table "informix".containershold 
  (
    containerholdiid serial not null ,
    liibrchno integer not null ,
    liirefno integer not null ,
    acctsecurno integer not null ,
    containerno char(20),
    transno integer not null ,
    primary key (containerholdiid) 
  ) in datadbs3  extent size 32 next size 32 lock mode row;

revoke all on "informix".containershold from "public" as "informix";

{ TABLE "informix".nbat_info row size = 582 number of columns = 8 index size = 9 
              }
create table "informix".nbat_info 
  (
    bat_id integer not null ,
    user_id integer not null ,
    srch_criteria lvarchar(512) not null ,
    bat_date char(20) not null ,
    process_status char(1) not null ,
    querytypeid integer not null ,
    filename char(30) not null ,
    filesize integer 
        default 0,
    primary key (bat_id) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".nbat_info from "public" as "informix";

{ TABLE "informix".nsrch_crit_batch row size = 16 number of columns = 4 index size 
              = 21 }
create table "informix".nsrch_crit_batch 
  (
    bat_id integer not null ,
    useriid integer not null ,
    liiclientno integer not null ,
    liiaccountno integer not null ,
    primary key (bat_id,useriid,liiclientno,liiaccountno) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".nsrch_crit_batch from "public" as "informix";

{ TABLE "informix".hs_duty_rate row size = 110 number of columns = 15 index size 
              = 37 }
create table "informix".hs_duty_rate 
  (
    hsno char(10) not null ,
    hstarifftrtmnt char(2) not null ,
    effdate char(20) not null ,
    advalrate float not null ,
    excrate float not null ,
    excunitmeas char(3) not null ,
    exprydate char(20) not null ,
    maxamt float not null ,
    maxamttype char(3) not null ,
    maxamtunitmeas char(3) not null ,
    minamt float not null ,
    minamttype char(3) not null ,
    minamtunitmeas char(3) not null ,
    specrate float not null ,
    specunitmeas char(3) not null ,
    primary key (hsno,hstarifftrtmnt,effdate) 
  ) extent size 32 next size 32 lock mode row;

revoke all on "informix".hs_duty_rate from "public" as "informix";


grant select on "informix".client_invoice to "public" as "informix";
grant update on "informix".client_invoice to "public" as "informix";
grant insert on "informix".client_invoice to "public" as "informix";
grant delete on "informix".client_invoice to "public" as "informix";
grant index on "informix".client_invoice to "public" as "informix";
grant select on "informix".ctry_code to "public" as "informix";
grant update on "informix".ctry_code to "public" as "informix";
grant insert on "informix".ctry_code to "public" as "informix";
grant delete on "informix".ctry_code to "public" as "informix";
grant index on "informix".ctry_code to "public" as "informix";
grant select on "informix".tservice to "public" as "informix";
grant update on "informix".tservice to "public" as "informix";
grant insert on "informix".tservice to "public" as "informix";
grant delete on "informix".tservice to "public" as "informix";
grant index on "informix".tservice to "public" as "informix";
grant select on "informix".state_model to "public" as "informix";
grant update on "informix".state_model to "public" as "informix";
grant insert on "informix".state_model to "public" as "informix";
grant delete on "informix".state_model to "public" as "informix";
grant index on "informix".state_model to "public" as "informix";
grant select on "informix".tariff_treatment to "public" as "informix";
grant update on "informix".tariff_treatment to "public" as "informix";
grant insert on "informix".tariff_treatment to "public" as "informix";
grant delete on "informix".tariff_treatment to "public" as "informix";
grant index on "informix".tariff_treatment to "public" as "informix";
grant select on "informix".usport_exit to "public" as "informix";
grant update on "informix".usport_exit to "public" as "informix";
grant insert on "informix".usport_exit to "public" as "informix";
grant delete on "informix".usport_exit to "public" as "informix";
grant index on "informix".usport_exit to "public" as "informix";
grant select on "informix".stringtable to "public" as "informix";
grant update on "informix".stringtable to "public" as "informix";
grant insert on "informix".stringtable to "public" as "informix";
grant delete on "informix".stringtable to "public" as "informix";
grant index on "informix".stringtable to "public" as "informix";
grant select on "informix".claim_log to "public" as "informix";
grant update on "informix".claim_log to "public" as "informix";
grant insert on "informix".claim_log to "public" as "informix";
grant delete on "informix".claim_log to "public" as "informix";
grant index on "informix".claim_log to "public" as "informix";
grant select on "informix".branch to "public" as "informix";
grant update on "informix".branch to "public" as "informix";
grant insert on "informix".branch to "public" as "informix";
grant delete on "informix".branch to "public" as "informix";
grant index on "informix".branch to "public" as "informix";
grant select on "informix".carrier to "public" as "informix";
grant update on "informix".carrier to "public" as "informix";
grant insert on "informix".carrier to "public" as "informix";
grant delete on "informix".carrier to "public" as "informix";
grant index on "informix".carrier to "public" as "informix";
grant select on "informix".hs_uom to "public" as "informix";
grant update on "informix".hs_uom to "public" as "informix";
grant insert on "informix".hs_uom to "public" as "informix";
grant delete on "informix".hs_uom to "public" as "informix";
grant index on "informix".hs_uom to "public" as "informix";
grant select on "informix".as_accounted to "public" as "informix";
grant update on "informix".as_accounted to "public" as "informix";
grant insert on "informix".as_accounted to "public" as "informix";
grant delete on "informix".as_accounted to "public" as "informix";
grant index on "informix".as_accounted to "public" as "informix";
grant select on "informix".as_claimed to "public" as "informix";
grant update on "informix".as_claimed to "public" as "informix";
grant insert on "informix".as_claimed to "public" as "informix";
grant delete on "informix".as_claimed to "public" as "informix";
grant index on "informix".as_claimed to "public" as "informix";
grant select on "informix".status_history to "public" as "informix";
grant update on "informix".status_history to "public" as "informix";
grant insert on "informix".status_history to "public" as "informix";
grant delete on "informix".status_history to "public" as "informix";
grant index on "informix".status_history to "public" as "informix";
grant select on "informix".transp_mode to "public" as "informix";
grant update on "informix".transp_mode to "public" as "informix";
grant insert on "informix".transp_mode to "public" as "informix";
grant delete on "informix".transp_mode to "public" as "informix";
grant index on "informix".transp_mode to "public" as "informix";
grant select on "informix".user_locus_xref to "public" as "informix";
grant update on "informix".user_locus_xref to "public" as "informix";
grant insert on "informix".user_locus_xref to "public" as "informix";
grant delete on "informix".user_locus_xref to "public" as "informix";
grant index on "informix".user_locus_xref to "public" as "informix";
grant select on "informix".b3_iid to "public" as "informix";
grant update on "informix".b3_iid to "public" as "informix";
grant insert on "informix".b3_iid to "public" as "informix";
grant delete on "informix".b3_iid to "public" as "informix";
grant index on "informix".b3_iid to "public" as "informix";
grant select on "informix".b3_line_iid to "public" as "informix";
grant update on "informix".b3_line_iid to "public" as "informix";
grant insert on "informix".b3_line_iid to "public" as "informix";
grant delete on "informix".b3_line_iid to "public" as "informix";
grant index on "informix".b3_line_iid to "public" as "informix";
grant select on "informix".b3_linecomment_iid to "public" as "informix";
grant update on "informix".b3_linecomment_iid to "public" as "informix";
grant insert on "informix".b3_linecomment_iid to "public" as "informix";
grant delete on "informix".b3_linecomment_iid to "public" as "informix";
grant index on "informix".b3_linecomment_iid to "public" as "informix";
grant select on "informix".b3_recapdetail_iid to "public" as "informix";
grant update on "informix".b3_recapdetail_iid to "public" as "informix";
grant insert on "informix".b3_recapdetail_iid to "public" as "informix";
grant delete on "informix".b3_recapdetail_iid to "public" as "informix";
grant index on "informix".b3_recapdetail_iid to "public" as "informix";
grant select on "informix".b3_subhdr_iid to "public" as "informix";
grant update on "informix".b3_subhdr_iid to "public" as "informix";
grant insert on "informix".b3_subhdr_iid to "public" as "informix";
grant delete on "informix".b3_subhdr_iid to "public" as "informix";
grant index on "informix".b3_subhdr_iid to "public" as "informix";
grant select on "informix".b3b_iid to "public" as "informix";
grant update on "informix".b3b_iid to "public" as "informix";
grant insert on "informix".b3b_iid to "public" as "informix";
grant delete on "informix".b3b_iid to "public" as "informix";
grant index on "informix".b3b_iid to "public" as "informix";
grant select on "informix".status_history_iid to "public" as "informix";
grant update on "informix".status_history_iid to "public" as "informix";
grant insert on "informix".status_history_iid to "public" as "informix";
grant delete on "informix".status_history_iid to "public" as "informix";
grant index on "informix".status_history_iid to "public" as "informix";
grant select on "informix".as_accounted_iid to "public" as "informix";
grant update on "informix".as_accounted_iid to "public" as "informix";
grant insert on "informix".as_accounted_iid to "public" as "informix";
grant delete on "informix".as_accounted_iid to "public" as "informix";
grant index on "informix".as_accounted_iid to "public" as "informix";
grant select on "informix".accountcontact_iid to "public" as "informix";
grant update on "informix".accountcontact_iid to "public" as "informix";
grant insert on "informix".accountcontact_iid to "public" as "informix";
grant delete on "informix".accountcontact_iid to "public" as "informix";
grant index on "informix".accountcontact_iid to "public" as "informix";
grant select on "informix".as_claimed_iid to "public" as "informix";
grant update on "informix".as_claimed_iid to "public" as "informix";
grant insert on "informix".as_claimed_iid to "public" as "informix";
grant delete on "informix".as_claimed_iid to "public" as "informix";
grant index on "informix".as_claimed_iid to "public" as "informix";
grant select on "informix".company_iid to "public" as "informix";
grant update on "informix".company_iid to "public" as "informix";
grant insert on "informix".company_iid to "public" as "informix";
grant delete on "informix".company_iid to "public" as "informix";
grant index on "informix".company_iid to "public" as "informix";
grant select on "informix".claim_log_iid to "public" as "informix";
grant update on "informix".claim_log_iid to "public" as "informix";
grant insert on "informix".claim_log_iid to "public" as "informix";
grant delete on "informix".claim_log_iid to "public" as "informix";
grant index on "informix".claim_log_iid to "public" as "informix";
grant select on "informix".client_iid to "public" as "informix";
grant update on "informix".client_iid to "public" as "informix";
grant insert on "informix".client_iid to "public" as "informix";
grant delete on "informix".client_iid to "public" as "informix";
grant index on "informix".client_iid to "public" as "informix";
grant select on "informix".userlocusxref_iid to "public" as "informix";
grant update on "informix".userlocusxref_iid to "public" as "informix";
grant insert on "informix".userlocusxref_iid to "public" as "informix";
grant delete on "informix".userlocusxref_iid to "public" as "informix";
grant index on "informix".userlocusxref_iid to "public" as "informix";
grant select on "informix".ip_rmd_iid to "public" as "informix";
grant update on "informix".ip_rmd_iid to "public" as "informix";
grant insert on "informix".ip_rmd_iid to "public" as "informix";
grant delete on "informix".ip_rmd_iid to "public" as "informix";
grant index on "informix".ip_rmd_iid to "public" as "informix";
grant select on "informix".ip_cci_iid to "public" as "informix";
grant update on "informix".ip_cci_iid to "public" as "informix";
grant insert on "informix".ip_cci_iid to "public" as "informix";
grant delete on "informix".ip_cci_iid to "public" as "informix";
grant index on "informix".ip_cci_iid to "public" as "informix";
grant select on "informix".ip_cci_line_iid to "public" as "informix";
grant update on "informix".ip_cci_line_iid to "public" as "informix";
grant insert on "informix".ip_cci_line_iid to "public" as "informix";
grant delete on "informix".ip_cci_line_iid to "public" as "informix";
grant index on "informix".ip_cci_line_iid to "public" as "informix";
grant select on "informix".ip_b3b_iid to "public" as "informix";
grant update on "informix".ip_b3b_iid to "public" as "informix";
grant insert on "informix".ip_b3b_iid to "public" as "informix";
grant delete on "informix".ip_b3b_iid to "public" as "informix";
grant index on "informix".ip_b3b_iid to "public" as "informix";
grant select on "informix".contact_type to "public" as "informix";
grant update on "informix".contact_type to "public" as "informix";
grant insert on "informix".contact_type to "public" as "informix";
grant delete on "informix".contact_type to "public" as "informix";
grant index on "informix".contact_type to "public" as "informix";
grant select on "informix".currency_code to "public" as "informix";
grant update on "informix".currency_code to "public" as "informix";
grant insert on "informix".currency_code to "public" as "informix";
grant delete on "informix".currency_code to "public" as "informix";
grant index on "informix".currency_code to "public" as "informix";
grant select on "informix".documents_list to "public" as "informix";
grant update on "informix".documents_list to "public" as "informix";
grant insert on "informix".documents_list to "public" as "informix";
grant delete on "informix".documents_list to "public" as "informix";
grant index on "informix".documents_list to "public" as "informix";
grant select on "informix".canct_off to "public" as "informix";
grant update on "informix".canct_off to "public" as "informix";
grant insert on "informix".canct_off to "public" as "informix";
grant delete on "informix".canct_off to "public" as "informix";
grant index on "informix".canct_off to "public" as "informix";
grant select on "informix".client to "public" as "informix";
grant update on "informix".client to "public" as "informix";
grant insert on "informix".client to "public" as "informix";
grant delete on "informix".client to "public" as "informix";
grant index on "informix".client to "public" as "informix";
grant select on "informix".ip_cci to "public" as "informix";
grant update on "informix".ip_cci to "public" as "informix";
grant insert on "informix".ip_cci to "public" as "informix";
grant delete on "informix".ip_cci to "public" as "informix";
grant index on "informix".ip_cci to "public" as "informix";
grant select on "informix".lii_contact to "public" as "informix";
grant update on "informix".lii_contact to "public" as "informix";
grant insert on "informix".lii_contact to "public" as "informix";
grant delete on "informix".lii_contact to "public" as "informix";
grant index on "informix".lii_contact to "public" as "informix";
grant select on "informix".product to "public" as "informix";
grant update on "informix".product to "public" as "informix";
grant insert on "informix".product to "public" as "informix";
grant delete on "informix".product to "public" as "informix";
grant index on "informix".product to "public" as "informix";
grant select on "informix".tariff_code to "public" as "informix";
grant update on "informix".tariff_code to "public" as "informix";
grant insert on "informix".tariff_code to "public" as "informix";
grant delete on "informix".tariff_code to "public" as "informix";
grant index on "informix".tariff_code to "public" as "informix";
grant select on "informix".lii_client to "public" as "informix";
grant update on "informix".lii_client to "public" as "informix";
grant insert on "informix".lii_client to "public" as "informix";
grant delete on "informix".lii_client to "public" as "informix";
grant index on "informix".lii_client to "public" as "informix";
grant select on "informix".ip_rmd to "public" as "informix";
grant update on "informix".ip_rmd to "public" as "informix";
grant insert on "informix".ip_rmd to "public" as "informix";
grant delete on "informix".ip_rmd to "public" as "informix";
grant index on "informix".ip_rmd to "public" as "informix";
grant select on "informix".securuser to "public" as "informix";
grant update on "informix".securuser to "public" as "informix";
grant insert on "informix".securuser to "public" as "informix";
grant delete on "informix".securuser to "public" as "informix";
grant index on "informix".securuser to "public" as "informix";
grant select on "informix".lii_account to "public" as "informix";
grant update on "informix".lii_account to "public" as "informix";
grant insert on "informix".lii_account to "public" as "informix";
grant delete on "informix".lii_account to "public" as "informix";
grant index on "informix".lii_account to "public" as "informix";
grant select on "informix".account_contact to "public" as "informix";
grant update on "informix".account_contact to "public" as "informix";
grant insert on "informix".account_contact to "public" as "informix";
grant delete on "informix".account_contact to "public" as "informix";
grant index on "informix".account_contact to "public" as "informix";
grant select on "informix".b3b to "public" as "informix";
grant update on "informix".b3b to "public" as "informix";
grant insert on "informix".b3b to "public" as "informix";
grant delete on "informix".b3b to "public" as "informix";
grant index on "informix".b3b to "public" as "informix";
grant select on "informix".ip_cci_line to "public" as "informix";
grant update on "informix".ip_cci_line to "public" as "informix";
grant insert on "informix".ip_cci_line to "public" as "informix";
grant delete on "informix".ip_cci_line to "public" as "informix";
grant index on "informix".ip_cci_line to "public" as "informix";
grant select on "informix".product_used to "public" as "informix";
grant update on "informix".product_used to "public" as "informix";
grant insert on "informix".product_used to "public" as "informix";
grant delete on "informix".product_used to "public" as "informix";
grant index on "informix".product_used to "public" as "informix";
grant select on "informix".search_criteria to "public" as "informix";
grant update on "informix".search_criteria to "public" as "informix";
grant insert on "informix".search_criteria to "public" as "informix";
grant delete on "informix".search_criteria to "public" as "informix";
grant index on "informix".search_criteria to "public" as "informix";
grant select on "informix".b3_line_comment to "public" as "informix";
grant update on "informix".b3_line_comment to "public" as "informix";
grant insert on "informix".b3_line_comment to "public" as "informix";
grant delete on "informix".b3_line_comment to "public" as "informix";
grant index on "informix".b3_line_comment to "public" as "informix";
grant select on "informix".ip_b3b to "public" as "informix";
grant update on "informix".ip_b3b to "public" as "informix";
grant insert on "informix".ip_b3b to "public" as "informix";
grant delete on "informix".ip_b3b to "public" as "informix";
grant index on "informix".ip_b3b to "public" as "informix";
grant select on "informix".privilege to "public" as "informix";
grant update on "informix".privilege to "public" as "informix";
grant insert on "informix".privilege to "public" as "informix";
grant delete on "informix".privilege to "public" as "informix";
grant index on "informix".privilege to "public" as "informix";
grant select on "informix".securgroup to "public" as "informix";
grant update on "informix".securgroup to "public" as "informix";
grant insert on "informix".securgroup to "public" as "informix";
grant delete on "informix".securgroup to "public" as "informix";
grant index on "informix".securgroup to "public" as "informix";
grant select on "informix".services to "public" as "informix";
grant update on "informix".services to "public" as "informix";
grant insert on "informix".services to "public" as "informix";
grant delete on "informix".services to "public" as "informix";
grant index on "informix".services to "public" as "informix";
grant select on "informix".usergroup to "public" as "informix";
grant update on "informix".usergroup to "public" as "informix";
grant insert on "informix".usergroup to "public" as "informix";
grant delete on "informix".usergroup to "public" as "informix";
grant index on "informix".usergroup to "public" as "informix";
grant select on "informix".terr to "public" as "informix";
grant update on "informix".terr to "public" as "informix";
grant insert on "informix".terr to "public" as "informix";
grant delete on "informix".terr to "public" as "informix";
grant index on "informix".terr to "public" as "informix";
grant select on "informix".tipsysflds to "public" as "informix";
grant update on "informix".tipsysflds to "public" as "informix";
grant insert on "informix".tipsysflds to "public" as "informix";
grant delete on "informix".tipsysflds to "public" as "informix";
grant index on "informix".tipsysflds to "public" as "informix";
grant select on "informix".fldidtbl_datatypes to "public" as "informix";
grant update on "informix".fldidtbl_datatypes to "public" as "informix";
grant insert on "informix".fldidtbl_datatypes to "public" as "informix";
grant delete on "informix".fldidtbl_datatypes to "public" as "informix";
grant index on "informix".fldidtbl_datatypes to "public" as "informix";
grant select on "informix".gst_rate_code to "public" as "informix";
grant update on "informix".gst_rate_code to "public" as "informix";
grant insert on "informix".gst_rate_code to "public" as "informix";
grant delete on "informix".gst_rate_code to "public" as "informix";
grant index on "informix".gst_rate_code to "public" as "informix";
grant select on "informix".ip_ccn to "public" as "informix";
grant update on "informix".ip_ccn to "public" as "informix";
grant insert on "informix".ip_ccn to "public" as "informix";
grant delete on "informix".ip_ccn to "public" as "informix";
grant index on "informix".ip_ccn to "public" as "informix";
grant select on "informix".ip_ccn_iid to "public" as "informix";
grant update on "informix".ip_ccn_iid to "public" as "informix";
grant insert on "informix".ip_ccn_iid to "public" as "informix";
grant delete on "informix".ip_ccn_iid to "public" as "informix";
grant index on "informix".ip_ccn_iid to "public" as "informix";
grant select on "informix".securuser_iid to "public" as "informix";
grant update on "informix".securuser_iid to "public" as "informix";
grant insert on "informix".securuser_iid to "public" as "informix";
grant delete on "informix".securuser_iid to "public" as "informix";
grant index on "informix".securuser_iid to "public" as "informix";
grant select on "informix".b3_subhdr_iid_1 to "public" as "informix";
grant update on "informix".b3_subhdr_iid_1 to "public" as "informix";
grant insert on "informix".b3_subhdr_iid_1 to "public" as "informix";
grant delete on "informix".b3_subhdr_iid_1 to "public" as "informix";
grant index on "informix".b3_subhdr_iid_1 to "public" as "informix";
grant select on "informix".b3_line_iid_1 to "public" as "informix";
grant update on "informix".b3_line_iid_1 to "public" as "informix";
grant insert on "informix".b3_line_iid_1 to "public" as "informix";
grant delete on "informix".b3_line_iid_1 to "public" as "informix";
grant index on "informix".b3_line_iid_1 to "public" as "informix";
grant select on "informix".b3_rcpdet_iid_1 to "public" as "informix";
grant update on "informix".b3_rcpdet_iid_1 to "public" as "informix";
grant insert on "informix".b3_rcpdet_iid_1 to "public" as "informix";
grant delete on "informix".b3_rcpdet_iid_1 to "public" as "informix";
grant index on "informix".b3_rcpdet_iid_1 to "public" as "informix";
grant select on "informix".b3_lincmt_iid_1 to "public" as "informix";
grant update on "informix".b3_lincmt_iid_1 to "public" as "informix";
grant insert on "informix".b3_lincmt_iid_1 to "public" as "informix";
grant delete on "informix".b3_lincmt_iid_1 to "public" as "informix";
grant index on "informix".b3_lincmt_iid_1 to "public" as "informix";
grant select on "informix".b3_subhdr_iid_2 to "public" as "informix";
grant update on "informix".b3_subhdr_iid_2 to "public" as "informix";
grant insert on "informix".b3_subhdr_iid_2 to "public" as "informix";
grant delete on "informix".b3_subhdr_iid_2 to "public" as "informix";
grant index on "informix".b3_subhdr_iid_2 to "public" as "informix";
grant select on "informix".b3_line_iid_2 to "public" as "informix";
grant update on "informix".b3_line_iid_2 to "public" as "informix";
grant insert on "informix".b3_line_iid_2 to "public" as "informix";
grant delete on "informix".b3_line_iid_2 to "public" as "informix";
grant index on "informix".b3_line_iid_2 to "public" as "informix";
grant select on "informix".b3_rcpdet_iid_2 to "public" as "informix";
grant update on "informix".b3_rcpdet_iid_2 to "public" as "informix";
grant insert on "informix".b3_rcpdet_iid_2 to "public" as "informix";
grant delete on "informix".b3_rcpdet_iid_2 to "public" as "informix";
grant index on "informix".b3_rcpdet_iid_2 to "public" as "informix";
grant select on "informix".b3_lincmt_iid_2 to "public" as "informix";
grant update on "informix".b3_lincmt_iid_2 to "public" as "informix";
grant insert on "informix".b3_lincmt_iid_2 to "public" as "informix";
grant delete on "informix".b3_lincmt_iid_2 to "public" as "informix";
grant index on "informix".b3_lincmt_iid_2 to "public" as "informix";
grant select on "informix".b3_subhdr_iid_3 to "public" as "informix";
grant update on "informix".b3_subhdr_iid_3 to "public" as "informix";
grant insert on "informix".b3_subhdr_iid_3 to "public" as "informix";
grant delete on "informix".b3_subhdr_iid_3 to "public" as "informix";
grant index on "informix".b3_subhdr_iid_3 to "public" as "informix";
grant select on "informix".b3_line_iid_3 to "public" as "informix";
grant update on "informix".b3_line_iid_3 to "public" as "informix";
grant insert on "informix".b3_line_iid_3 to "public" as "informix";
grant delete on "informix".b3_line_iid_3 to "public" as "informix";
grant index on "informix".b3_line_iid_3 to "public" as "informix";
grant select on "informix".b3_rcpdet_iid_3 to "public" as "informix";
grant update on "informix".b3_rcpdet_iid_3 to "public" as "informix";
grant insert on "informix".b3_rcpdet_iid_3 to "public" as "informix";
grant delete on "informix".b3_rcpdet_iid_3 to "public" as "informix";
grant index on "informix".b3_rcpdet_iid_3 to "public" as "informix";
grant select on "informix".b3_lincmt_iid_3 to "public" as "informix";
grant update on "informix".b3_lincmt_iid_3 to "public" as "informix";
grant insert on "informix".b3_lincmt_iid_3 to "public" as "informix";
grant delete on "informix".b3_lincmt_iid_3 to "public" as "informix";
grant index on "informix".b3_lincmt_iid_3 to "public" as "informix";
grant select on "informix".b3_subhdr_iid_4 to "public" as "informix";
grant update on "informix".b3_subhdr_iid_4 to "public" as "informix";
grant insert on "informix".b3_subhdr_iid_4 to "public" as "informix";
grant delete on "informix".b3_subhdr_iid_4 to "public" as "informix";
grant index on "informix".b3_subhdr_iid_4 to "public" as "informix";
grant select on "informix".b3_line_iid_4 to "public" as "informix";
grant update on "informix".b3_line_iid_4 to "public" as "informix";
grant insert on "informix".b3_line_iid_4 to "public" as "informix";
grant delete on "informix".b3_line_iid_4 to "public" as "informix";
grant index on "informix".b3_line_iid_4 to "public" as "informix";
grant select on "informix".b3_rcpdet_iid_4 to "public" as "informix";
grant update on "informix".b3_rcpdet_iid_4 to "public" as "informix";
grant insert on "informix".b3_rcpdet_iid_4 to "public" as "informix";
grant delete on "informix".b3_rcpdet_iid_4 to "public" as "informix";
grant index on "informix".b3_rcpdet_iid_4 to "public" as "informix";
grant select on "informix".b3_lincmt_iid_4 to "public" as "informix";
grant update on "informix".b3_lincmt_iid_4 to "public" as "informix";
grant insert on "informix".b3_lincmt_iid_4 to "public" as "informix";
grant delete on "informix".b3_lincmt_iid_4 to "public" as "informix";
grant index on "informix".b3_lincmt_iid_4 to "public" as "informix";
grant select on "informix".b3_subhdr_iid_5 to "public" as "informix";
grant update on "informix".b3_subhdr_iid_5 to "public" as "informix";
grant insert on "informix".b3_subhdr_iid_5 to "public" as "informix";
grant delete on "informix".b3_subhdr_iid_5 to "public" as "informix";
grant index on "informix".b3_subhdr_iid_5 to "public" as "informix";
grant select on "informix".b3_line_iid_5 to "public" as "informix";
grant update on "informix".b3_line_iid_5 to "public" as "informix";
grant insert on "informix".b3_line_iid_5 to "public" as "informix";
grant delete on "informix".b3_line_iid_5 to "public" as "informix";
grant index on "informix".b3_line_iid_5 to "public" as "informix";
grant select on "informix".b3_rcpdet_iid_5 to "public" as "informix";
grant update on "informix".b3_rcpdet_iid_5 to "public" as "informix";
grant insert on "informix".b3_rcpdet_iid_5 to "public" as "informix";
grant delete on "informix".b3_rcpdet_iid_5 to "public" as "informix";
grant index on "informix".b3_rcpdet_iid_5 to "public" as "informix";
grant select on "informix".b3_lincmt_iid_5 to "public" as "informix";
grant update on "informix".b3_lincmt_iid_5 to "public" as "informix";
grant insert on "informix".b3_lincmt_iid_5 to "public" as "informix";
grant delete on "informix".b3_lincmt_iid_5 to "public" as "informix";
grant index on "informix".b3_lincmt_iid_5 to "public" as "informix";
grant select on "ipgown".delimiter to "public" as "ipgown";
grant update on "ipgown".delimiter to "public" as "ipgown";
grant insert on "ipgown".delimiter to "public" as "ipgown";
grant delete on "ipgown".delimiter to "public" as "ipgown";
grant index on "ipgown".delimiter to "public" as "ipgown";
grant select on "informix".srch_crit_batch to "public" as "informix";
grant update on "informix".srch_crit_batch to "public" as "informix";
grant insert on "informix".srch_crit_batch to "public" as "informix";
grant delete on "informix".srch_crit_batch to "public" as "informix";
grant index on "informix".srch_crit_batch to "public" as "informix";
grant select on "ipgown".bulletin to "public" as "ipgown";
grant update on "ipgown".bulletin to "public" as "ipgown";
grant insert on "ipgown".bulletin to "public" as "ipgown";
grant delete on "ipgown".bulletin to "public" as "ipgown";
grant index on "ipgown".bulletin to "public" as "ipgown";
grant select on "informix".company to "public" as "informix";
grant update on "informix".company to "public" as "informix";
grant insert on "informix".company to "public" as "informix";
grant delete on "informix".company to "public" as "informix";
grant index on "informix".company to "public" as "informix";
grant select on "ipgown".temp_b3 to "public" as "ipgown";
grant update on "ipgown".temp_b3 to "public" as "ipgown";
grant insert on "ipgown".temp_b3 to "public" as "ipgown";
grant delete on "ipgown".temp_b3 to "public" as "ipgown";
grant index on "ipgown".temp_b3 to "public" as "ipgown";
grant select on "informix".rpt_b3 to "public" as "informix";
grant update on "informix".rpt_b3 to "public" as "informix";
grant insert on "informix".rpt_b3 to "public" as "informix";
grant delete on "informix".rpt_b3 to "public" as "informix";
grant index on "informix".rpt_b3 to "public" as "informix";
grant select on "informix".rpt_b3_subheader to "public" as "informix";
grant update on "informix".rpt_b3_subheader to "public" as "informix";
grant insert on "informix".rpt_b3_subheader to "public" as "informix";
grant delete on "informix".rpt_b3_subheader to "public" as "informix";
grant index on "informix".rpt_b3_subheader to "public" as "informix";
grant select on "informix".rpt_b3_line to "public" as "informix";
grant update on "informix".rpt_b3_line to "public" as "informix";
grant insert on "informix".rpt_b3_line to "public" as "informix";
grant delete on "informix".rpt_b3_line to "public" as "informix";
grant index on "informix".rpt_b3_line to "public" as "informix";
grant select on "informix".bat_control to "public" as "informix";
grant select on "informix".bat_id to "public" as "informix";
grant update on "informix".bat_id to "public" as "informix";
grant insert on "informix".bat_id to "public" as "informix";
grant delete on "informix".bat_id to "public" as "informix";
grant select on "informix".bat_info to "public" as "informix";
grant update on "informix".bat_info to "public" as "informix";
grant insert on "informix".bat_info to "public" as "informix";
grant delete on "informix".bat_info to "public" as "informix";
grant select on "informix".reporterr to "public" as "informix";
grant update on "informix".reporterr to "public" as "informix";
grant insert on "informix".reporterr to "public" as "informix";
grant delete on "informix".reporterr to "public" as "informix";
grant index on "informix".reporterr to "public" as "informix";
grant select on "informix".b3 to "public" as "informix";
grant update on "informix".b3 to "public" as "informix";
grant insert on "informix".b3 to "public" as "informix";
grant delete on "informix".b3 to "public" as "informix";
grant index on "informix".b3 to "public" as "informix";
grant select on "informix".b3_subheader to "public" as "informix";
grant update on "informix".b3_subheader to "public" as "informix";
grant insert on "informix".b3_subheader to "public" as "informix";
grant delete on "informix".b3_subheader to "public" as "informix";
grant index on "informix".b3_subheader to "public" as "informix";
grant select on "informix".b3_line to "public" as "informix";
grant update on "informix".b3_line to "public" as "informix";
grant insert on "informix".b3_line to "public" as "informix";
grant delete on "informix".b3_line to "public" as "informix";
grant index on "informix".b3_line to "public" as "informix";
grant select on "informix".b3_recap_details to "public" as "informix";
grant update on "informix".b3_recap_details to "public" as "informix";
grant insert on "informix".b3_recap_details to "public" as "informix";
grant delete on "informix".b3_recap_details to "public" as "informix";
grant index on "informix".b3_recap_details to "public" as "informix";
grant select on "informix".insight_pdq to "public" as "informix";
grant update on "informix".insight_pdq to "public" as "informix";
grant insert on "informix".insight_pdq to "public" as "informix";
grant delete on "informix".insight_pdq to "public" as "informix";
grant index on "informix".insight_pdq to "public" as "informix";
grant select on "informix".tariff to "public" as "informix";
grant update on "informix".tariff to "public" as "informix";
grant insert on "informix".tariff to "public" as "informix";
grant delete on "informix".tariff to "public" as "informix";
grant index on "informix".tariff to "public" as "informix";
grant select on "informix".containers to "public" as "informix";
grant update on "informix".containers to "public" as "informix";
grant insert on "informix".containers to "public" as "informix";
grant delete on "informix".containers to "public" as "informix";
grant index on "informix".containers to "public" as "informix";
grant select on "informix".container_iid to "public" as "informix";
grant update on "informix".container_iid to "public" as "informix";
grant insert on "informix".container_iid to "public" as "informix";
grant delete on "informix".container_iid to "public" as "informix";
grant index on "informix".container_iid to "public" as "informix";
grant select on "informix".containershold to "public" as "informix";
grant update on "informix".containershold to "public" as "informix";
grant insert on "informix".containershold to "public" as "informix";
grant delete on "informix".containershold to "public" as "informix";
grant index on "informix".containershold to "public" as "informix";
grant select on "informix".nbat_info to "public" as "informix";
grant update on "informix".nbat_info to "public" as "informix";
grant insert on "informix".nbat_info to "public" as "informix";
grant delete on "informix".nbat_info to "public" as "informix";
grant select on "informix".nsrch_crit_batch to "public" as "informix";
grant update on "informix".nsrch_crit_batch to "public" as "informix";
grant insert on "informix".nsrch_crit_batch to "public" as "informix";
grant delete on "informix".nsrch_crit_batch to "public" as "informix";
grant index on "informix".nsrch_crit_batch to "public" as "informix";
grant select on "informix".hs_duty_rate to "public" as "informix";
grant update on "informix".hs_duty_rate to "public" as "informix";
grant insert on "informix".hs_duty_rate to "public" as "informix";
grant delete on "informix".hs_duty_rate to "public" as "informix";
grant index on "informix".hs_duty_rate to "public" as "informix";

CREATE PROCEDURE "informix".ps_nxtcompanyiid(p_iid integer) RETURNING INT;
BEGIN
	UPDATE company_iid SET lastiid = lastiid + 1;
	SELECT lastiid INTO p_iid FROM company_iid;
	RETURN p_iid;
END;
END PROCEDURE;

create procedure "informix".ps_nxtasacctiid(i_iid integer) RETURNING INT;

BEGIN
      UPDATE as_accounted_iid set lastiid = lastiid + 1;
      SELECT lastiid INTO i_iid FROM as_accounted_iid;
      RETURN i_iid;
END;
END PROCEDURE;

create procedure "informix".ps_nxtasclmiid(i_iid integer) RETURNING INT;

BEGIN
      UPDATE as_claimed_iid set lastiid = lastiid + 1;
      SELECT lastiid INTO i_iid FROM as_claimed_iid;
      RETURN i_iid;
END;
END PROCEDURE;

create procedure "informix".sp1(str char(10))
	returning char(10);

	if LENGTH(str) = 9 then
		let str = '0'||str;
	else
		let str = str;
	end if 
	return str;
end procedure;

create procedure "ipgown".hsno(str char(10))
        returning char(10);   
        define result char(10);
        define errmsg char(255);
 
        if length(str) = 10 then
		let result = str;
                return result;
        elif length(str) = 9 then
                let result = '0'||str;
                return result;
        elif length(str) = 8 then
                let result = '00' || str;
                return result;
        elif length(str) = 7 then
                let result = '000' || str;
                return result;
        elif length(str) = 6 then
                let result = '0000' || str;
                return result;
        elif length(str) = 5 then
                let result = '00000' || str;
                return result;
        elif length(str) = 4 then
                let result = '000000' || str;
                return result;
        elif length(str) = 3 then
                let result = '0000000' || str;
                return result;
        elif length(str) = 2 then
                let result = '00000000' || str;
                return result;
        elif length(str) = 1 then
                let result = '000000000' || str;
                return result;
        else
                let errmsg = "The unknown hsno number.";
                raise exception -746, 0, errmsg;
        end if
end procedure;

CREATE PROCEDURE "informix".status_457( p_refno INT, p_status INT, p_statusdate CHAR(20))
   RETURNING INT,INT,INT, INT, CHAR(20);

   DEFINE h_b3iid  INT;

  FOREACH
   select b3iid
   INTO h_b3iid
   FROM b3
   where liibrchno = 457 AND liirefno = p_refno

   RETURN h_b3iid, 457, p_refno, p_status, p_statusdate
   WITH RESUME;

   insert into status_history
   values(h_b3iid, p_status,p_statusdate);
  END FOREACH;

END PROCEDURE;

create procedure "informix".ps_nxtbatid() returning int;
begin
	define p_id integer;
	update bat_id set last_id = last_id + 2;
	select last_id into p_id from bat_id;
	return p_id;
end;
end procedure;

CREATE PROCEDURE "informix".cleanupb3(startdate CHAR(20), enddate CHAR(20))
  RETURNING INT;

  -- Declare b3 table columns
  DEFINE s_b3iid           INT;

  --Define Working variables
  DEFINE tableName         CHAR(25);
  DEFINE currentDay        DATE;
  DEFINE mode              CHAR(1);
  DEFINE sqlErr            INT;
  DEFINE isamErr           INT;

  -- Trap Exception
  ON EXCEPTION SET sqlErr, isamErr
      CALL reportErr(currentDay,tableName,mode, s_b3iid, sqlErr,isamErr);
  END EXCEPTION WITH RESUME;

  LET currentDay = today;
  LET tableName  = 'B3';
  LET mode = 'D';

  FOREACH
     SELECT  b3iid
     INTO s_b3iid
     FROM b3
     WHERE (approveddate >= startdate and approveddate <= enddate) and
           (createdate >= startdate and approveddate <= enddate) and
           (b3iid < 5000000)

     RETURN s_b3iid WITH RESUME;

	 BEGIN
	   -- Trap Exception
		 ON EXCEPTION SET sqlErr, isamErr
	 	    CALL reportErr(currentDay,tableName,mode, s_b3iid, sqlErr,isamErr);
		 END EXCEPTION WITH RESUME;

         DELETE FROM b3
	     WHERE b3iid = s_b3iid and b3iid < 5000000;
     END
  END FOREACH;

END PROCEDURE;

CREATE PROCEDURE "informix".insert_st(h_brno INT, h_refno INT, h_status INT, h_statusdate CHAR(20))
   RETURNING INT, INT, CHAR(20);

   DEFINE h_b3iid  INT;

   select b3iid
   INTO h_b3iid
   FROM b3
   where liibrchno = h_brno AND liirefno = h_refno;

   insert into status_history
   values(h_b3iid, h_status,h_statusdate);

   RETURN h_b3iid, h_status, h_statusdate;

END PROCEDURE;

CREATE PROCEDURE "informix".archiveandpurge() RETURNING CHAR(20), CHAR(20), INT;

  --Define Working variables
  DEFINE startdate         CHAR(20);
  DEFINE enddate           CHAR(20);
  DEFINE archivecount      INT;
  DEFINE archiveDay        DATE;

  LET startdate = EXTEND(current, YEAR TO MONTH) - INTERVAL(1) YEAR TO YEAR - INTERVAL(7) MONTH TO MONTH;
  LET enddate = EXTEND(current, YEAR TO MONTH) - INTERVAL(1) YEAR TO YEAR - INTERVAL(6) MONTH TO MONTH;
  LET archiveDay = TODAY;
  
 -- EXECUTE PROCEDURE insertArch(startdate, enddate);

  SELECT COUNT(*) 
  INTO archivecount
  FROM reporterr
  WHERE currentday = archiveDay;

  IF archivecount = 0 THEN
--     EXECUTE PROCEDURE deleteB3(startdate, enddate);
  END IF

  RETURN startdate, enddate, archivecount;
  
END PROCEDURE;

create procedure "ipgown".p_invbrchno(i_liibrchno int)
	returning char(3);
	define s_liibrchno char(3);

	let s_liibrchno = i_liibrchno;
	if length(s_liibrchno) = 3 then
		let s_liibrchno = s_liibrchno;
		return s_liibrchno;
	elif length(s_liibrchno) = 2 then
		let s_liibrchno = '0'||s_liibrchno;
		return s_liibrchno;
	elif length(s_liibrchno) = 1 then
		let s_liibrchno = '00'||s_liibrchno;
		return s_liibrchno;
	end if
end procedure;

create procedure "ipgown".p_invrefno(i_liirefno int)
	returning char(6);
	define s_liirefno char(6);

	let s_liirefno = i_liirefno;
	if length(s_liirefno) = 6 then
		let s_liirefno = s_liirefno;
		return s_liirefno;
	elif length(s_liirefno) = 5 then
		let s_liirefno = '0'||s_liirefno;
		return s_liirefno;
	elif length(s_liirefno) = 4 then
		let s_liirefno = '00'||s_liirefno;
		return s_liirefno;
	elif length(s_liirefno) = 3 then
		let s_liirefno = '000'||s_liirefno;
		return s_liirefno;
	elif length(s_liirefno) = 2 then
		let s_liirefno = '0000'||s_liirefno;
		return s_liirefno;
	elif length(s_liirefno) = 1 then
		let s_liirefno = '00000'||s_liirefno;
		return s_liirefno;
	end if
end procedure;

CREATE PROCEDURE "informix".deletetariff(h_liiclientno INT)
  RETURNING INT, CHAR(25), CHAR(25), INT;

  -- Declare b3 table columns

  --Define Working variables
  DEFINE sqlErr            INT;
  DEFINE isamErr           INT;
  DEFINE s_vendorname      CHAR(25);
  DEFINE s_productkeyword  CHAR(25);
  DEFINE s_productsufx     INT;

  FOREACH
     SELECT  vendorname,productkeyword,productsufx
     INTO s_vendorname, s_productkeyword,s_productsufx
     FROM tariff
     WHERE liiclientno = h_liiclientno

     DELETE FROM ip_0p@ipdb:tariff
     WHERE liiclientno = h_liiclientno AND vendorname = s_vendorname
     AND productkeyword=  s_productkeyword AND  productsufx= s_productsufx;

     RETURN h_liiclientno, s_vendorname, s_productkeyword, s_productsufx WITH RESUME;

  END FOREACH;

END PROCEDURE;

create procedure "informix".ps_nxtcontaineriid() returning int;
begin
       define p_id integer;
       update container_iid set lastiid = lastiid + 1;
       select lastiid into p_id from container_iid;
       return p_id;
end;
end procedure;

CREATE FUNCTION "informix".settrbnulldate ( s CHAR(20) )
RETURNING CHAR(20)
AS
BEGIN
   IF s = '1753/01/01 00:00:00' then
    let s = '2099/12/31 00:00:00';
   END IF;
   RETURN s;
END FUNCTION;

CREATE FUNCTION "informix".datetimeformat ( dt DATETIME YEAR TO SECOND)
RETURNING CHAR(20)
AS
BEGIN
                RETURN( TO_CHAR( dt, '%Y/%m/%d %T' ) );
END FUNCTION;

CREATE FUNCTION "informix".dateformat ( dt DATE )
RETURNING CHAR(10)
AS
BEGIN
                RETURN( TO_CHAR( dt, '%Y/%m/%d' ) );
END FUNCTION;

CREATE FUNCTION "informix".datetimeparse ( s CHAR(20) )
RETURNING DATETIME YEAR TO SECOND
AS
BEGIN
                RETURN( TO_DATE( s, '%Y/%m/%d %T' ));
END FUNCTION;

CREATE FUNCTION "informix".dateparse ( s CHAR(10) )
RETURNING DATE
AS
BEGIN
                RETURN( TO_DATE( s, '%Y/%m/%d' ) );
END FUNCTION;

CREATE FUNCTION "informix".timepart( s CHAR(20) )
RETURNING CHAR(8)
AS
BEGIN
  RETURN ( TO_CHAR( EXTEND( TO_DATE( s, '%Y/%m/%d %T' ), HOUR TO SECOND ) , '%T' ) );
END FUNCTION
;


create procedure "informix".pi_company_ins(p_liiclientno LIKE company.liiclientno, 
					   p_companyname LIKE company.companyname)

DEFINE i_iid integer;
BEGIN
	LET i_iid = 0;
	IF NOT EXISTS
		(SELECT 1 FROM company
			WHERE	company.liiclientno=p_liiclientno
 			AND	company.companyname=p_companyname) THEN
	BEGIN
		CALL ps_nxtcompanyiid(i_iid) RETURNING i_iid;
		INSERT INTO company
			VALUES (i_iid, p_liiclientno, p_companyname);
	END;
            END IF
END;
END PROCEDURE;

create procedure "informix".pi_account_contact(new_employeeno integer,
                                    new_liiclientno integer,
                                    new_liiaccountno integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "lii_account" must exist when inserting a child in "account_contact"
    if new_liiclientno is not null and
       new_liiaccountno is not null then
       select count(*)
       into   numrows
       from   lii_account
       where  liiclientno = new_liiclientno
        and   liiaccountno = new_liiaccountno;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""lii_account"". Cannot create child in ""account_contact"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

    --  Parent "lii_contact" must exist when inserting a child in "account_contact"
    if new_employeeno is not null then
       select count(*)
       into   numrows
       from   lii_contact
       where  employeeno = new_employeeno;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""lii_contact"". Cannot create child in ""account_contact"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

end procedure;

create procedure "informix".pi_as_accounted(new_claimlogiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "claim_log" must exist when inserting a child in "as_accounted"
    if new_claimlogiid is not null then
       select count(*)
       into   numrows
       from   claim_log
       where  claimlogiid = new_claimlogiid;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""claim_log"". Cannot create child in ""as_accounted"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

end procedure;

create procedure "informix".pi_as_claimed(new_claimlogiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "claim_log" must exist when inserting a child in "as_claimed"
    if new_claimlogiid is not null then
       select count(*)
       into   numrows
       from   claim_log
       where  claimlogiid = new_claimlogiid;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""claim_log"". Cannot create child in ""as_claimed"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

end procedure;

create procedure "informix".pi_b3(new_liiclientno integer,
                       new_liiaccountno integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "lii_account" must exist when inserting a child in "b3"
    if new_liiclientno is not null and
       new_liiaccountno is not null then
       select count(*)
       into   numrows
       from   lii_account
       where  liiclientno = new_liiclientno
        and   liiaccountno = new_liiaccountno;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""lii_account"". Cannot create child in ""b3"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

end procedure;

create procedure "informix".pi_b3_line(new_b3subiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "b3_subheader" must exist when inserting a child in "b3_line"
    if new_b3subiid is not null then
       select count(*)
       into   numrows
       from   b3_subheader
       where  b3subiid = new_b3subiid;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""b3_subheader"". Cannot create child in ""b3_line"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

end procedure;

create procedure "informix".pi_b3_line_comment(new_b3lineiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "b3_line" must exist when inserting a child in "b3_line_comment"
    if new_b3lineiid is not null then
       select count(*)
       into   numrows
       from   b3_line
       where  b3lineiid = new_b3lineiid;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""b3_line"". Cannot create child in ""b3_line_comment"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

end procedure;

create procedure "informix".pi_b3_recap_detail(new_b3lineiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "b3_line" must exist when inserting a child in "b3_recap_details"
    if new_b3lineiid is not null then
       select count(*)
       into   numrows
       from   b3_line
       where  b3lineiid = new_b3lineiid;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""b3_line"". Cannot create child in ""b3_recap_details"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

end procedure;

create procedure "informix".pi_b3_subheader(new_b3iid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "b3" must exist when inserting a child in "b3_subheader"
    if new_b3iid is not null then
       select count(*)
       into   numrows
       from   b3
       where  b3iid = new_b3iid;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""b3"". Cannot create child in ""b3_subheader"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

end procedure;

create procedure "informix".pi_b3b(new_b3iid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "b3" must exist when inserting a child in "b3b"
    if new_b3iid is not null then
       select count(*)
       into   numrows
       from   b3
       where  b3iid = new_b3iid;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""b3"". Cannot create child in ""b3b"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

end procedure;

create procedure "informix".pi_client_invoice(new_liiclientno integer,
                                   new_liiaccountno integer,
                                   new_itemtypecode char(2))
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "lii_account" must exist when inserting a child in "client_invoice"
    if new_liiclientno is not null and
       new_liiaccountno is not null then
       select count(*)
       into   numrows
       from   lii_account
       where  liiclientno = new_liiclientno
        and   liiaccountno = new_liiaccountno;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""lii_account"". Cannot create child in ""client_invoice"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

end procedure;

create procedure "informix".pi_lii_account(new_liiclientno integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "lii_client" must exist when inserting a child in "lii_account"
    if new_liiclientno is not null then
       select count(*)
       into   numrows
       from   lii_client
       where  liiclientno = new_liiclientno;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""lii_client"". Cannot create child in ""lii_account"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

end procedure;

create procedure "informix".pi_privilege(new_serviceiid integer,
                              new_securgroupiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "securgroup" must exist when inserting a child in "privilege"
    if new_securgroupiid is not null then
       select count(*)
       into   numrows
       from   securgroup
       where  securgroupiid = new_securgroupiid;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""securgroup"". Cannot create child in ""privilege"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

    --  Parent "services" must exist when inserting a child in "privilege"
    if new_serviceiid is not null then
       select count(*)
       into   numrows
       from   services
       where  serviceiid = new_serviceiid;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""services"". Cannot create child in ""privilege"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

end procedure;

create procedure "informix".pi_search_criteria(new_useriid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "securuser" must exist when inserting a child in "search_criteria"
    if new_useriid is not null then
       select count(*)
       into   numrows
       from   securuser
       where  useriid = new_useriid;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""securuser"". Cannot create child in ""search_criteria"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

end procedure;

create procedure "informix".pi_securuser(new_clientiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "client" must exist when inserting a child in "securuser"
    if new_clientiid is not null then
       select count(*)
       into   numrows
       from   client
       where  clientiid = new_clientiid;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""client"". Cannot create child in ""securuser"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

end procedure;

create procedure "informix".pi_status_history(new_b3iid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "b3" must exist when inserting a child in "status_history"
    if new_b3iid is not null then
       select count(*)
       into   numrows
       from   b3
       where  b3iid = new_b3iid;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""b3"". Cannot create child in ""status_history"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

end procedure;

create procedure "informix".pi_tariff(new_liiclientno integer, 
					new_vendorname LIKE tariff.vendorname)

    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "lii_client" must exist when inserting a child in "tariff"
    if new_liiclientno is not null then
       select count(*)
       into   numrows
       from   lii_client
       where  liiclientno = new_liiclientno;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""lii_client"". Cannot create child in ""tariff"".";
          raise exception -746, 0, errmsg;
       else
          call pi_company_ins(new_liiclientno, new_vendorname);
       end if;
    end if;

end procedure;

create procedure "informix".pi_user_locus_xref(new_liiaccountno integer,
                                    new_liiclientno integer,
                                    new_useriid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "securuser" must exist when inserting a child in "user_locus_xref"
    if new_useriid is not null then
       select count(*)
       into   numrows
       from   securuser
       where  useriid = new_useriid;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""securuser"". Cannot create child in ""user_locus_xref"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

    --  Parent "lii_account" must exist when inserting a child in "user_locus_xref"
    if new_liiclientno is not null and
       new_liiaccountno is not null then
       select count(*)
       into   numrows
       from   lii_account
       where  liiclientno = new_liiclientno
        and   liiaccountno = new_liiaccountno;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""lii_account"". Cannot create child in ""user_locus_xref"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

end procedure;

create procedure "informix".pi_usergroup(new_securgroupiid integer,
                              new_useriid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "securuser" must exist when inserting a child in "usergroup"
    if new_useriid is not null then
       select count(*)
       into   numrows
       from   securuser
       where  useriid = new_useriid;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""securuser"". Cannot create child in ""usergroup"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

    --  Parent "securgroup" must exist when inserting a child in "usergroup"
    if new_securgroupiid is not null then
       select count(*)
       into   numrows
       from   securgroup
       where  securgroupiid = new_securgroupiid;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""securgroup"". Cannot create child in ""usergroup"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

end procedure;

create procedure "informix".pu_account_contact(old_acctcontiid integer,
                                    old_employeeno integer,
                                    old_liiclientno integer,
                                    old_liiaccountno integer,
                        new_acctcontiid integer,
                        new_employeeno integer,
                        new_liiclientno integer,
                        new_liiaccountno integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;

    --  Parent "lii_account" must exist when updating a child in "account_contact"
    if new_liiclientno is not null and
       new_liiaccountno is not null then
       select count(*)
       into   numrows
       from   lii_account
       where  liiclientno = new_liiclientno
        and   liiaccountno = new_liiaccountno;
       if (numrows = 0) then
          let errno  = -1003;
          let errmsg = """lii_account"" does not exist. Cannot modify child in ""account_contact"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

    --  Parent "lii_contact" must exist when updating a child in "account_contact"
    if new_employeeno is not null then
       select count(*)
       into   numrows
       from   lii_contact
       where  employeeno = new_employeeno;
       if (numrows = 0) then
          let errno  = -1003;
          let errmsg = """lii_contact"" does not exist. Cannot modify child in ""account_contact"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

   end procedure;

create procedure "informix".pu_as_accounted(old_asacctiid integer,
                                 old_claimlogiid integer,
                        new_asacctiid integer,
                        new_claimlogiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Cannot modify parent code of "claim_log" in child "as_accounted"
    if (old_claimlogiid != new_claimlogiid) then
       let errno  = -1004;
       let errmsg = "Cannot modify parent code of ""claim_log"" in child ""as_accounted"".";
       raise exception -746, 0, errmsg;
    end if;

end procedure;

create procedure "informix".pu_as_claimed(old_asclaimediid integer,
                               old_claimlogiid integer,
                        new_asclaimediid integer,
                        new_claimlogiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;

    --  Cannot modify parent code of "claim_log" in child "as_claimed"
    if (old_claimlogiid != new_claimlogiid) then
       let errno  = -1004;
       let errmsg = "Cannot modify parent code of ""claim_log"" in child ""as_claimed"".";
       raise exception -746, 0, errmsg;
    end if;

end procedure;

create procedure "informix".pu_b3(old_b3iid integer,
                       old_liiclientno integer,
                       old_liiaccountno integer,
                        new_b3iid integer,
                        new_liiclientno integer,
                        new_liiaccountno integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "lii_account" must exist when updating a child in "b3"
    if new_liiclientno is not null and
       new_liiaccountno is not null then
       select count(*)
       into   numrows
       from   lii_account
       where  liiclientno = new_liiclientno
        and   liiaccountno = new_liiaccountno;
       if (numrows = 0) then
          let errno  = -1003;
          let errmsg = """lii_account"" does not exist. Cannot modify child in ""b3"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

    --  Cannot modify Technical Primary Key of "B3"
    if (old_b3iid != new_b3iid) then
           let errmsg = "Updates not allowed to ""b3iid"" of ""B3"".";
           raise exception -746, 0, errmsg;
   end if;

 end procedure;

create procedure "informix".pu_b3_line(old_b3lineiid integer,
                            old_b3subiid integer,
                        new_b3lineiid integer,
                        new_b3subiid integer
                        )
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Cannot modify parent code of "b3_subheader" in child "b3_line"
    if (old_b3subiid != new_b3subiid) then
       let errno  = -1004;
       let errmsg = "Cannot modify parent code of ""b3_subheader"" in child ""b3_line"".";
       raise exception -746, 0, errmsg;
    end if;


    --  Cannot modify Technical Primary Key of "B3_Line"
    if (old_b3lineiid != new_b3lineiid) then
           let errmsg = "Updates not allowed to ""b3lineiid"" of ""B3_LINE"".";
           raise exception -746, 0, errmsg;
   end if;

 end procedure;

create procedure "informix".pu_b3_line_comment(old_b3linecommenti integer,
                                    old_b3lineiid integer,
                        new_b3linecommenti integer,
                        new_b3lineiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


 --  Cannot modify parent code of "b3_line" in child "b3_line_comment"
    if (old_b3lineiid != new_b3lineiid) then
       let errno  = -1004;
       let errmsg = "Cannot modify parent code of ""b3_line"" in child ""b3_line_comment"".";
       raise exception -746, 0, errmsg;
    end if;

end procedure;

create procedure "informix".pu_b3_recap_detail(old_b3recapiid integer,
                                    old_b3lineiid integer,
                        new_b3recapiid integer,
                        new_b3lineiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


--  Cannot modify parent code of "b3_line" in child "b3_recap_details"
    if (old_b3lineiid != new_b3lineiid) then
       let errno  = -1004;
       let errmsg = "Cannot modify parent code of ""b3_line"" in child ""b3_recap_details"".";
       raise exception -746, 0, errmsg;
    end if;

end procedure;

create procedure "informix".pu_b3_subheader(old_b3subiid integer,
                                 old_b3iid integer,
                        new_b3subiid integer,
                        new_b3iid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Cannot modify parent code of "b3" in child "b3_subheader"
    if (old_b3iid != new_b3iid) then
       let errno  = -1004;
       let errmsg = "Cannot modify parent code of ""b3"" in child ""b3_subheader"".";
       raise exception -746, 0, errmsg;
    end if;


    --  Cannot modify Technical Primary Key of "B3_SUBHEADER"
    if (old_b3subiid != new_b3subiid) then
           let errmsg = "Updates not allowed to ""b3subiid"" of ""B3_SUBHEADER"".";
           raise exception -746, 0, errmsg;
   end if;

end procedure;

create procedure "informix".pu_b3b(old_b3biid integer,
                        old_b3iid integer,
                        new_b3biid integer,
                        new_b3iid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


     --  Cannot modify parent code of "b3" in child "b3b"
    if (old_b3iid != new_b3iid) then
       let errno  = -1004;
       let errmsg = "Cannot modify parent code of ""b3"" in child ""b3b"".";
       raise exception -746, 0, errmsg;
    end if;

end procedure;

create procedure "informix".pu_claim_log(old_claimlogiid integer,
                              old_liiclientno integer,
                              old_claimcode char(2),
                        new_claimlogiid integer,
                        new_liiclientno integer,
                        new_claimcode char(2))
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "lii_client" must exist when updating a child in "claim_log"
    if new_liiclientno is not null then
       select count(*)
       into   numrows
       from   lii_client
       where  liiclientno = new_liiclientno;
       if (numrows = 0) then
          let errno  = -1003;
          let errmsg = """lii_client"" does not exist. Cannot modify child in ""claim_log"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;


    --  Cannot modify Technical Primary Key of "CLAIM_LOG"
    if (old_claimlogiid != new_claimlogiid) then
           let errmsg = "Updates not allowed to ""claimlogiid"" of ""CLAIM_LOG"".";
           raise exception -746, 0, errmsg;
   end if;

end procedure;

create procedure "informix".pu_client(old_clientiid integer,
                        new_clientiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Cannot modify Technical Primary Key of "CLIENT"
    if (old_clientiid != new_clientiid) then
           let errmsg = "Updates not allowed to ""clientiid"" of ""CLIENT"".";
           raise exception -746, 0, errmsg;
   end if;

   end procedure;

create procedure "informix".pu_client_invoice(old_liiclientno integer,
                                   old_liiaccountno integer,
                                   old_liibrchno integer,
                                   old_liirefno integer,
                                   old_liireftext char(3),
                                   old_itemtypecode char(2),
                        new_liiclientno integer,
                        new_liiaccountno integer,
                        new_liibrchno integer,
                        new_liirefno integer,
                        new_liireftext char(3),
                        new_itemtypecode char(2))
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Cannot modify parent code of "lii_account" in child "client_invoice"
    if (old_liiclientno != new_liiclientno) or
       (old_liiaccountno != new_liiaccountno) then
       let errno  = -1004;
       let errmsg = "Cannot modify parent code of ""lii_account"" in child ""client_invoice"".";
       raise exception -746, 0, errmsg;
    end if;



 end procedure;

create procedure "informix".pu_lii_account(old_liiclientno integer,
                                old_liiaccountno integer,
                        new_liiclientno integer,
                        new_liiaccountno integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


      --  Cannot modify  Primary Key of "lii_account"
   if (old_liiclientno != new_liiclientno) or
      (old_liiaccountno != new_liiaccountno)  then
       let errmsg = "Cannot modify primary key of ""lii_account"".";
       raise exception -746, 0, errmsg;
    end if;

  end procedure;

create procedure "informix".pu_lii_client(old_liiclientno integer,
                        new_liiclientno integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;

  --  Cannot modify  Primary Key of "lii_client"
   if (old_liiclientno != new_liiclientno)  then
       let errmsg = "Cannot modify primary key of ""lii_client"".";
       raise exception -746, 0, errmsg;
    end if;

 end procedure;

create procedure "informix".pu_lii_contact(old_employeeno integer,
                        new_employeeno integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


  --  Cannot modify  Primary Key of "lii_contact"
   if (old_employeeno != new_employeeno) then
       let errmsg = "Cannot modify primary key of ""lii_contact"".";
       raise exception -746, 0, errmsg;
    end if;


end procedure;

create procedure "informix".pu_privilege(old_privilegeiid integer,
                              old_serviceiid integer,
                              old_securgroupiid integer,
                        new_privilegeiid integer,
                        new_serviceiid integer,
                        new_securgroupiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "securgroup" must exist when updating a child in "privilege"
    if new_securgroupiid is not null then
       select count(*)
       into   numrows
       from   securgroup
       where  securgroupiid = new_securgroupiid;
       if (numrows = 0) then
          let errno  = -1003;
          let errmsg = """securgroup"" does not exist. Cannot modify child in ""privilege"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

    --  Parent "services" must exist when updating a child in "privilege"
    if new_serviceiid is not null then
       select count(*)
       into   numrows
       from   services
       where  serviceiid = new_serviceiid;
       if (numrows = 0) then
          let errno  = -1003;
          let errmsg = """services"" does not exist. Cannot modify child in ""privilege"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

  end procedure;

create procedure "informix".pu_securuser(old_useriid integer,
                              old_clientiid integer,
                        new_useriid integer,
                        new_clientiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;

    --  Cannot modify parent code of "client" in child "securuser"
    if (old_clientiid != new_clientiid) then
       let errno  = -1004;
       let errmsg = "Cannot modify parent code of ""client"" in child ""securuser"".";
       raise exception -746, 0, errmsg;
    end if;


  --  Cannot modify  Primary Key of "securuser"
   if (old_useriid != new_useriid) then
       let errmsg = "Cannot modify primary key of ""securuser"".";
       raise exception -746, 0, errmsg;
    end if;


end procedure;

create procedure "informix".pu_status_history(old_b3iid integer,
                                   old_status integer,
                        new_b3iid integer,
                        new_status integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;

      --  Cannot modify  Primary Key of "status_history"
   if (old_b3iid != new_b3iid) or
      (old_status != new_status) then
       let errmsg = "Cannot modify primary key of ""status_history"".";
       raise exception -746, 0, errmsg;
    end if;

end procedure;

create procedure "informix".pu_tariff(old_liiclientno integer,
                           old_vendorname char(25),
                           old_productkeyword char(25),
                           old_productsufx integer,
                        new_liiclientno integer,
                        new_vendorname char(25),
                        new_productkeyword char(25),
                        new_productsufx integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Cannot modify parent code of "lii_client" in child "tariff"
    if (old_liiclientno != new_liiclientno) then
       let errno  = -1004;
       let errmsg = "Cannot modify parent code of ""lii_client"" in child ""tariff"".";
       raise exception -746, 0, errmsg;
    end if;

end procedure;

create procedure "informix".pu_user_locus_xref(old_userlocusxrefi integer,
                                    old_liiaccountno integer,
                                    old_liiclientno integer,
                                    old_useriid integer,
                        new_userlocusxrefi integer,
                        new_liiaccountno integer,
                        new_liiclientno integer,
                        new_useriid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;

    --  Parent "securuser" must exist when updating a child in "user_locus_xref"
    if new_useriid is not null then
       select count(*)
       into   numrows
       from   securuser
       where  useriid = new_useriid;
       if (numrows = 0) then
          let errno  = -1003;
          let errmsg = """securuser"" does not exist. Cannot modify child in ""user_locus_xref"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

    --  Parent "lii_account" must exist when updating a child in "user_locus_xref"
    if new_liiclientno is not null and
       new_liiaccountno is not null then
       select count(*)
       into   numrows
       from   lii_account
       where  liiclientno = new_liiclientno
        and   liiaccountno = new_liiaccountno;
       if (numrows = 0) then
          let errno  = -1003;
          let errmsg = """lii_account"" does not exist. Cannot modify child in ""user_locus_xref"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;
end procedure;

create procedure "informix".pd_b3_line(old_b3lineiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Delete all children in "b3_recap_details"
    delete from b3_recap_details
    where  b3lineiid = old_b3lineiid;

    --  Delete all children in "b3_line_comment"
    delete from b3_line_comment
    where  b3lineiid = old_b3lineiid;

end procedure;

create procedure "informix".pd_b3_subheader(old_b3subiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Delete all children in "b3_line"
    delete from b3_line
    where  b3subiid = old_b3subiid;

end procedure;

create procedure "informix".pd_claim_log(old_claimlogiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Delete all children in "as_accounted"
    delete from as_accounted
    where  claimlogiid = old_claimlogiid;

    --  Delete all children in "as_claimed"
    delete from as_claimed
    where  claimlogiid = old_claimlogiid;

end procedure;

create procedure "informix".pd_client(old_clientiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Cannot delete parent "client" if children still exist in "securuser"
    select count(*)
    into   numrows
    from   securuser
    where  clientiid = old_clientiid;
    if (numrows > 0) then
       let errno  = -1006;
       let errmsg = "Children still exist in ""securuser"". Cannot delete parent ""client"".";
       raise exception -746, 0, errmsg;
    end if;

end procedure;

create procedure "informix".pd_lii_contact(old_employeeno integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Cannot delete parent "lii_contact" if children still exist in "account_contact"
    select count(*)
    into   numrows
    from   account_contact
    where  employeeno = old_employeeno;
    if (numrows > 0) then
       let errno  = -1006;
       let errmsg = "Children still exist in ""account_contact"". Cannot delete parent ""lii_contact"".";
       raise exception -746, 0, errmsg;
    end if;

end procedure;

create procedure "informix".pd_securgroup(old_securgroupiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Cannot delete parent "securgroup" if children still exist in "usergroup"
    select count(*)
    into   numrows
    from   usergroup
    where  securgroupiid = old_securgroupiid;
    if (numrows > 0) then
       let errno  = -1006;
       let errmsg = "Children still exist in ""usergroup"". Cannot delete parent ""securgroup"".";
       raise exception -746, 0, errmsg;
    end if;

    --  Cannot delete parent "securgroup" if children still exist in "privilege"
    select count(*)
    into   numrows
    from   privilege
    where  securgroupiid = old_securgroupiid;
    if (numrows > 0) then
       let errno  = -1006;
       let errmsg = "Children still exist in ""privilege"". Cannot delete parent ""securgroup"".";
       raise exception -746, 0, errmsg;
    end if;

end procedure;

create procedure "informix".pd_securuser(old_useriid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Cannot delete parent "securuser" if children still exist in "search_criteria"
    select count(*)
    into   numrows
    from   search_criteria
    where  useriid = old_useriid;
    if (numrows > 0) then
       let errno  = -1006;
       let errmsg = "Children still exist in ""search_criteria"". Cannot delete parent ""securuser"".";
       raise exception -746, 0, errmsg;
    end if;

    --  Cannot delete parent "securuser" if children still exist in "usergroup"
    select count(*)
    into   numrows
    from   usergroup
    where  useriid = old_useriid;
    if (numrows > 0) then
       let errno  = -1006;
       let errmsg = "Children still exist in ""usergroup"". Cannot delete parent ""securuser"".";
       raise exception -746, 0, errmsg;
    end if;

    --  Cannot delete parent "securuser" if children still exist in "user_locus_xref"
    select count(*)
    into   numrows
    from   user_locus_xref
    where  useriid = old_useriid;
    if (numrows > 0) then
       let errno  = -1006;
       let errmsg = "Children still exist in ""user_locus_xref"". Cannot delete parent ""securuser"".";
       raise exception -746, 0, errmsg;
    end if;

end procedure;

create procedure "informix".pd_services(old_serviceiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Cannot delete parent "services" if children still exist in "privilege"
    select count(*)
    into   numrows
    from   privilege
    where  serviceiid = old_serviceiid;
    if (numrows > 0) then
       let errno  = -1006;
       let errmsg = "Children still exist in ""privilege"". Cannot delete parent ""services"".";
       raise exception -746, 0, errmsg;
    end if;

end procedure;

create procedure "informix".pi_ip_b3b(new_iprmdiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "ip_rmd" must exist when inserting a child in "ip_b3b"
    if new_iprmdiid is not null then
       select count(*)
       into   numrows
       from   ip_rmd
       where  iprmdiid = new_iprmdiid;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""ip_rmd"". Cannot create child in ""ip_b3b"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

end procedure;

create procedure "informix".pu_ip_b3b(old_ipb3biid integer,
                           old_iprmdiid integer,
                        new_ipb3biid integer,
                        new_iprmdiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Cannot modify parent code of "ip_rmd" in child "ip_b3b"
    if (old_iprmdiid != new_iprmdiid) then
       let errno  = -1004;
       let errmsg = "Cannot modify parent code of ""ip_rmd"" in child ""ip_b3b"".";
       raise exception -746, 0, errmsg;
    end if;

end procedure;

create procedure "informix".pu_ip_cci(old_cciiid integer,
                        new_cciiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Cannot modify parent code in "IP_CCI" if children still exist in "IP_CCI_LINE"
    if (old_cciiid != new_cciiid) then
       let errmsg = "Updates not allowed to ""cciiid"" of ""ip_cci"".";
       raise exception -746, 0, errmsg;
    end if;

end procedure;

create procedure "informix".pd_ip_cci(old_cciiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Delete all children in "IP_CCI_LINE"
    delete from IP_CCI_LINE
    where  cciiid = old_cciiid;

end procedure;

create procedure "informix".pi_ip_cci_line(new_cciiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "IP_CCI" must exist when inserting a child in "IP_CCI_LINE"
    if new_cciiid is not null then
       select count(*)
       into   numrows
       from   IP_CCI
       where  cciiid = new_cciiid;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""IP_CCI"". Cannot create child in ""IP_CCI_LINE"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

end procedure;

create procedure "informix".pu_ip_cci_line(old_ccilineiid integer,
                                old_cciiid integer,
                        new_ccilineiid integer,
                        new_cciiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;

    --  Cannot modify parent code of "IP_CCI" in child "IP_CCI_LINE"
    if (old_cciiid != new_cciiid) then
       let errno  = -1004;
       let errmsg = "Cannot modify parent code of ""IP_CCI"" in child ""IP_CCI_LINE"".";
       raise exception -746, 0, errmsg;
    end if;

end procedure;

create procedure "informix".pu_ip_rmd(old_iprmdiid integer,
                        new_iprmdiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;




    --  Cannot modify parent code in "IP_RMD" if children still exist in "IP_B3B"
    if (old_iprmdiid != new_iprmdiid) then
       let errmsg = "Updates not allowed to ""iprmdiid"" of ""ip_rmd"".";
       raise exception -746, 0, errmsg;
    end if;


end procedure;

create procedure "informix".pd_ip_rmd(old_iprmdiid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Delete all children in "ip_b3b"
    delete from ip_b3b
    where  iprmdiid = old_iprmdiid;

end procedure;

create procedure "informix".pi_srch_crit_batch(new_useriid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "securuser" must exist when inserting a child in "srch_crit_batch"
    if new_useriid is not null then
       select count(*)
       into   numrows
       from   securuser
       where  useriid = new_useriid;
       if (numrows = 0) then
          let errno  = -1002;
          let errmsg = "Parent does not exist in ""securuser"". Cannot create child in ""srch_crit_batch"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

end procedure;

create procedure "informix".pu_srch_crit_batch(old_useriid integer,
                        new_useriid integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Parent "securuser" must exist when updating a child in "srch_crit_batch"
    if new_useriid is not null then
       select count(*)
       into   numrows
       from   securuser
       where  useriid = new_useriid;
       if (numrows = 0) then
          let errno  = -1003;
          let errmsg = """securuser"" does not exist. Cannot modify child in ""srch_crit_batch"".";
          raise exception -746, 0, errmsg;
       end if;
    end if;

end procedure;

create procedure "informix".pi_claim_log(new_liiclientno integer,
                              new_claimlogiid integer
                              )
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;

    --  Parent "lii_client exist when inserting a child in "claim_log"
    if new_liiclientno is not null then
       select count(*)
       into   numrows
       from   lii_client
       where  lii_client.liiclientno = new_liiclientno;
       if (numrows = 0) then
          let errno  = -1002;
      let errmsg = "Parent does not exist in ""lii_client"". Cannot create child in ""claim_log"".";
          raise exception -746, 0, errmsg;
       else
          CALL pi_claim_log_ins (new_claimlogiid);
       end if;
    end if;

end procedure;

create procedure "informix".pi_claim_log_ins(p_claimlogiid LIKE claim_log.claimlogiid)

DEFINE as_act_iid integer;
DEFINE as_clm_iid integer;

BEGIN
	LET as_act_iid = 0;
	LET as_clm_iid = 0;

	CALL ps_nxtasacctiid (as_act_iid) RETURNING as_act_iid;
	INSERT INTO as_accounted
	   VALUES (as_act_iid,p_claimlogiid,' ',' ',-32000,-32000,-32000);

        CALL ps_nxtasclmiid (as_clm_iid) RETURNING as_clm_iid;
        INSERT INTO as_claimed
           VALUES (as_clm_iid,p_claimlogiid,' ',' ',-32000,-32000,-32000);

END;
END PROCEDURE;

create procedure "informix".pd_lii_account(old_liiclientno integer,
                                old_liiaccountno integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Cannot delete parent "lii_account" if children still exist in "user_locus_xref"
    select count(*)
    into   numrows
    from   user_locus_xref
    where  liiclientno = old_liiclientno
     and   liiaccountno = old_liiaccountno;
    if (numrows > 0) then
       let errno  = -1006;
       let errmsg = "Children still exist in ""user_locus_xref"". Cannot delete parent ""lii_account"".";
       raise exception -746, 0, errmsg;
    end if;

    --  Cannot delete parent "lii_account" if children still exist in "account_contact"
    select count(*)
    into   numrows
    from   account_contact
    where  liiclientno = old_liiclientno
     and   liiaccountno = old_liiaccountno;
    if (numrows > 0) then
       let errno  = -1006;
       let errmsg = "Children still exist in ""account_contact"". Cannot delete parent ""lii_account"".";
       raise exception -746, 0, errmsg;
    end if;

    --  Cannot delete parent "lii_account" if children still exist in "b3"
    select count(*)
    into   numrows
    from   b3
    where  liiclientno = old_liiclientno
     and   liiaccountno = old_liiaccountno;
    if (numrows > 0) then
       let errno  = -1006;
       let errmsg = "Children still exist in ""b3"". Cannot delete parent ""lii_account"".";
       raise exception -746, 0, errmsg;
    end if;

       --  Cannot delete parent "lii_account" if children still exist in "client_invoice"
    select count(*)
    into   numrows
    from   client_invoice
    where  liiclientno = old_liiclientno
     and   liiaccountno = old_liiaccountno;
    if (numrows > 0) then
       let errno  = -1006;
       let errmsg = "Children still exist in ""client_invoice"". Cannot delete parent ""lii_account"".";
       raise exception -746, 0, errmsg;
    end if;

end procedure;

create procedure "informix".pd_lii_client(old_liiclientno integer)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;


    --  Cannot delete parent "lii_client" if children still exist in "lii_account"
    select count(*)
    into   numrows
    from   lii_account
    where  liiclientno = old_liiclientno;
    if (numrows > 0) then
       let errno  = -1006;
       let errmsg = "Children still exist in ""lii_account"". Cannot delete parent ""lii_client"".";
       raise exception -746, 0, errmsg;
    end if;

    --  Cannot delete parent "lii_client" if children still exist in "tariff"
    select count(*)
    into   numrows
    from   tariff
    where  liiclientno = old_liiclientno;
    if (numrows > 0) then
       let errno  = -1006;
       let errmsg = "Children still exist in ""tariff"". Cannot delete parent ""lii_client"".";
       raise exception -746, 0, errmsg;
    end if;

    --  Cannot delete parent "lii_client" if children still exist in "claim_log"
    select count(*)
    into   numrows
    from   claim_log
    where  liiclientno = old_liiclientno;
      if (numrows > 0) then
       let errno  = -1006;
       let errmsg = "Children still exist in ""claim_log"". Cannot delete parent ""lii_client"".";
       raise exception -746, 0, errmsg;
    end if;


end procedure;

create procedure "informix".pd_rpt_b3(old_b3iid integer)
	define 	errno 	integer;
	define	errmsg	char(255);
	define	numrows	integer;

	-- Delete all children in "rpt_b3_subheader"
	delete from rpt_b3_subheader
	where b3iid = old_b3iid;

end procedure;

create procedure "informix".pd_rpt_b3_sub(old_b3subiid integer)
	define	errno	integer;
	define	errmsg	char(255);
	define	numrows	integer;

	-- Delete all children in "rpt_b3_line"
	delete from rpt_b3_line
	where b3subiid = old_b3subiid;

end procedure;

CREATE PROCEDURE "informix".deleteb3(startdate CHAR(20), enddate CHAR(20))

  -- Declare b3 table columns
  DEFINE s_b3iid           INT;

  --Define Working variables
  DEFINE tableName         CHAR(25);
  DEFINE currentDay        DATE;
  DEFINE mode              CHAR(1);
  DEFINE sqlErr            INT;
  DEFINE isamErr           INT;

  -- Trap Exception
  ON EXCEPTION SET sqlErr, isamErr
      CALL reportErr(currentDay,tableName,mode, s_b3iid, sqlErr,isamErr);
  END EXCEPTION WITH RESUME;

  LET currentDay = today;
  LET tableName  = 'B3';
  LET mode = 'D';

  FOREACH WITH HOLD
     SELECT  b3iid
     INTO s_b3iid
     FROM b3
     WHERE approveddate >= startdate and approveddate < enddate

	 BEGIN
	   -- Trap Exception
		 ON EXCEPTION SET sqlErr, isamErr
	 	    CALL reportErr(currentDay,tableName,mode, s_b3iid, sqlErr,isamErr);
		 END EXCEPTION WITH RESUME;

           DELETE FROM ip_0p@ip1:b3
	   WHERE b3iid = s_b3iid and b3iid < 5000000;
         END
  END FOREACH;

END PROCEDURE;

CREATE PROCEDURE "informix".reporterr(currentDay date,tablename CHAR(20),mode CHAR(1),keyValue INT,sqlErr INT,isamErr INT)
    INSERT INTO reportErr values (currentDay,tablename,mode,keyvalue,sqlerr,isamerr);
END PROCEDURE;

CREATE PROCEDURE "informix".insertarch(startdate CHAR(20),enddate CHAR(20))

  -- Declare b3 table columns
  DEFINE s_b3iid              INT;
  DEFINE s_liiclientno        INT;
  DEFINE s_liiaccountno       INT;
  DEFINE s_liibrchno          INT;
  DEFINE s_liirefno           INT;
  DEFINE s_acctsecurno        INT;
  DEFINE s_b3type             CHAR(2);
  DEFINE s_cargcntrlno        CHAR(25);
  DEFINE s_carriercode        CHAR(4);
  DEFINE s_createdate         CHAR(20);
  DEFINE s_custoff            CHAR(4);
  DEFINE s_k84date            CHAR(20);
  DEFINE s_modetransp       CHAR(2);
  DEFINE s_portunlading       CHAR(4);
  DEFINE s_reldate            CHAR(20);
  DEFINE s_status             INT;
  DEFINE s_totb3duty          float;
  DEFINE s_totb3exctax        float;
  DEFINE s_totb3gst           float;
  DEFINE s_totb3sima          float;
  DEFINE s_totb3vfd           float;
  DEFINE s_transno            INT;
  DEFINE s_weight             INT;
  DEFINE s_purchaseorder1     CHAR(15);
  DEFINE s_purchaseorder2     CHAR(15);
  DEFINE s_shipvia            CHAR(18);
  DEFINE s_locationofgoods      CHAR(17);
  DEFINE s_containerno        CHAR(20);
  DEFINE s_vendorname         CHAR(25);
  DEFINE s_vendorstate        CHAR(3);
  DEFINE s_vendorzip          CHAR(10);
  DEFINE s_freight            float;
  DEFINE s_usportexit         CHAR(5);
  DEFINE s_billoflading       CHAR(10);
  DEFINE s_cargcntrlqty     float;
  DEFINE s_approveddate       CHAR(20);

  --Define Working variables
  DEFINE tableName         CHAR(25);
  DEFINE currentDay        DATE;
  DEFINE mode              CHAR(1);
  DEFINE sqlErr            INT;
  DEFINE isamErr           INT;


  -- Trap Exception
  ON EXCEPTION SET sqlErr, isamErr
      CALL reportErr(currentDay,tableName,mode, s_b3iid, sqlErr,isamErr);
  END EXCEPTION WITH RESUME;

  SET LOCK MODE TO WAIT 60;

  LET currentDay = today;
  LET tableName  = 'B3';
  LET mode = 'I';
  LET s_b3iid = NULL;

  FOREACH WITH HOLD
     SELECT  b3iid, liiclientno, liiaccountno, liibrchno, liirefno, acctsecurno, b3type,
     cargcntrlno, carriercode, createdate, custoff, k84date, modetransp,
     portunlading, reldate, status, totb3duty, totb3exctax, totb3gst,
     totb3sima, totb3vfd, transno, weight, purchaseorder1, purchaseorder2,
     shipvia, locationofgoods, containerno, vendorname, vendorstate, vendorzip,
     freight, usportexit, billoflading, cargcntrlqty, approveddate
     INTO s_b3iid, s_liiclientno, s_liiaccountno, s_liibrchno, s_liirefno, s_acctsecurno,
     s_b3type, s_cargcntrlno, s_carriercode, s_createdate, s_custoff, s_k84date,
     s_modetransp, s_portunlading, s_reldate, s_status, s_totb3duty,
     s_totb3exctax, s_totb3gst, s_totb3sima, s_totb3vfd, s_transno, s_weight,
     s_purchaseorder1, s_purchaseorder2, s_shipvia, s_locationofgoods, s_containerno,
     s_vendorname, s_vendorstate, s_vendorzip, s_freight, s_usportexit,
     s_billoflading, s_cargcntrlqty, s_approveddate
     FROM ip_0p@ip1:b3
     WHERE approveddate >= startdate and approveddate < enddate


     BEGIN

		-- Trap Exception
		  ON EXCEPTION SET sqlErr, isamErr
		    	CALL reportErr(currentDay,tableName,mode, s_b3iid, sqlErr,isamErr);
		  END EXCEPTION WITH RESUME;

          insert into b3
          values(s_b3iid, s_liiclientno, s_liiaccountno, s_liibrchno, s_liirefno, s_acctsecurno,
          s_b3type, s_cargcntrlno, s_carriercode, s_createdate, s_custoff, s_k84date,
          s_modetransp, s_portunlading, s_reldate, s_status, s_totb3duty,
          s_totb3exctax, s_totb3gst, s_totb3sima, s_totb3vfd, s_transno, s_weight,
          s_purchaseorder1, s_purchaseorder2, s_shipvia, s_locationofgoods, s_containerno,
          s_vendorname, s_vendorstate, s_vendorzip, s_freight, s_usportexit,
          s_billoflading, s_cargcntrlqty, s_approveddate);

     END

   END FOREACH;

END PROCEDURE;

create procedure "informix".sp_pagelock()
begin work;
delete from b3 where b3iid = 7141693;
-- update b3 set vendorname = "bchong testing" where b3iid = 7141693;
system 'sleep 120';
rollback work;
-- commit work;
end procedure;

CREATE PROCEDURE "informix".deleteb3_1()

  -- Declare working variables
  DEFINE startdate         CHAR(20) ;
  DEFINE enddate           CHAR(20) ;
  DEFINE s_b3iid           INT;

  DEFINE tableName         CHAR(25);
  DEFINE currentDay        DATE;
  DEFINE mode              CHAR(1);
  DEFINE sqlErr            INT;
  DEFINE isamErr           INT;

  -- Trap Exception
  ON EXCEPTION SET sqlErr, isamErr
      CALL reportErr(currentDay,tableName,mode, s_b3iid, sqlErr,isamErr);
  END EXCEPTION WITH RESUME;

  --Define working variables
  LET startdate = EXTEND(current, YEAR TO MONTH) - INTERVAL(1) YEAR TO YEAR - INTERVAL(6) MONTH TO MONTH;
  LET enddate   = EXTEND(current, YEAR TO MONTH) - INTERVAL(1) YEAR TO YEAR - INTERVAL(5) MONTH TO MONTH;
  LET s_b3iid   = 0;

  LET tableName  = 'B3';
  LET currentDay = today;
  LET mode = 'D';
  LET sqlErr = 0;
  LET isamErr = 0;

  SET DEBUG FILE TO './deleteb3_1.trc' ;
  TRACE ON ;
  TRACE "startdate value=" || startdate || "endate value=" || enddate ;

  FOREACH WITH HOLD
     SELECT  b3iid
     INTO s_b3iid
     FROM b3
     WHERE approveddate >= startdate and approveddate < enddate   

	  BEGIN
	   -- Trap Exception
	   ON EXCEPTION SET sqlErr, isamErr
	     CALL reportErr(currentDay,tableName,mode, s_b3iid, sqlErr,isamErr);
	   END EXCEPTION WITH RESUME;

           TRACE "s_b3iid value=" || s_b3iid ;
           DELETE FROM b3 WHERE b3iid = s_b3iid ;
         END
  END FOREACH;

END PROCEDURE;

CREATE PROCEDURE "informix".cleanb3(startdate char(20), enddate char(20))

 -- Declare working variables
 -- DEFINE startdate         CHAR(20) ;
 -- DEFINE enddate           CHAR(20) ;
  DEFINE s_b3iid           INT;

  DEFINE tableName         CHAR(25);
  DEFINE currentDay        DATE;
  DEFINE mode              CHAR(1);
  DEFINE sqlErr            INT;
  DEFINE isamErr           INT;

  -- Trap Exception
  ON EXCEPTION SET sqlErr, isamErr
      CALL reportErr(currentDay,tableName,mode, s_b3iid, sqlErr,isamErr);
  END EXCEPTION WITH RESUME;

  --Define working variables
 -- LET startdate = EXTEND(current, YEAR TO MONTH) - INTERVAL(1) YEAR TO YEAR - INTERVAL(6) MONTH TO MONTH;
 -- LET enddate   = EXTEND(current, YEAR TO MONTH) - INTERVAL(1) YEAR TO YEAR - INTERVAL(5) MONTH TO MONTH;


  LET s_b3iid   = 0;

  LET tableName  = 'B3';
  LET currentDay = today;
  LET mode = 'D';
  LET sqlErr = 0;
  LET isamErr = 0;

  SET DEBUG FILE TO './cleanb3.trc' ;
  TRACE ON ;
  TRACE "startdate value=" || startdate || "endate value=" || enddate ;

  FOREACH WITH HOLD
     SELECT  b3iid
     INTO s_b3iid
     FROM b3
     WHERE approveddate >= startdate and approveddate <= enddate   

	  BEGIN
	   -- Trap Exception
	   ON EXCEPTION SET sqlErr, isamErr
	     CALL reportErr(currentDay,tableName,mode, s_b3iid, sqlErr,isamErr);
	   END EXCEPTION WITH RESUME;

           TRACE "s_b3iid value=" || s_b3iid ;
           DELETE FROM b3 WHERE b3iid = s_b3iid ;
         END
  END FOREACH;

END PROCEDURE;

CREATE PROCEDURE "informix".invoice_purge()

  -- Declare working variables
  DEFINE enddate           CHAR(20) ;
  DEFINE s_liiclientno     INT;
  DEFINE s_liiaccountno    INT;
  DEFINE s_liirefno        INT;
  DEFINE s_liibrchno       INT;
  DEFINE s_liireftext      CHAR(3);

  LET enddate   = EXTEND(current, YEAR TO MONTH) - INTERVAL(1) YEAR TO YEAR - INTERVAL(6) MONTH TO MONTH;
  LET s_liiclientno   = 0;
  LET s_liiaccountno  = 0;
  LET s_liibrchno   = 0;
  LET s_liirefno   = 0;

  SET DEBUG FILE TO './invoice_purge.trc' ;
  TRACE ON ;
  TRACE "endate value=" || enddate ;

  FOREACH WITH HOLD
     SELECT liiclientno,liiaccountno,liibrchno,liirefno,liireftext
     INTO s_liiclientno,s_liiaccountno,s_liibrchno,s_liirefno,s_liireftext
     FROM client_invoice
     WHERE balance = 0
       AND itemdate < enddate

    BEGIN
    --    TRACE "liiclientno="||s_liiclientno||" and liiaccountno="||s_liiaccountno||" and liibrchno="||s_liibrchno||" and liirefno="||s_liirefno;

    DELETE FROM ip_0p@ipdb:client_invoice
    WHERE liiclientno = s_liiclientno
      AND liiaccountno = s_liiaccountno
      AND liibrchno = s_liibrchno
      AND liirefno = s_liirefno
      AND liireftext = s_liireftext ;
    END

  END FOREACH;

END PROCEDURE;

create procedure "informix".pd_b3(old_b3iid integer)
   define  errno    integer;
   define  errmsg   char(255);
   define  numrows  integer;

   --  Delete all children in "b3_subheader"
   delete from b3_subheader
   where  b3iid = old_b3iid;

   --  Delete all children in "b3b"
   delete from b3b
   where  b3iid = old_b3iid;

   --  Delete all children in "status_history"
   delete from status_history
   where  b3iid = old_b3iid;

   --  Delete all children in "containers"
   delete from containers
   where  b3iid = old_b3iid;
end procedure;

CREATE PROCEDURE "informix".hsdutyrate_purge()

  -- Declare working variables
  DEFINE enddate           CHAR(20) ;
  DEFINE s_hsno            CHAR(10);
  DEFINE s_hstarifftrtmnt  CHAR(2);
  DEFINE s_effdate         CHAR(20);

  LET enddate = EXTEND(current, YEAR TO MONTH) - INTERVAL(24) MONTH TO MONTH;
  LET s_hsno   = 0;
  LET s_hstarifftrtmnt  = 0;
  LET s_effdate   = 0;

  SET DEBUG FILE TO './hsdutyrate_purge.trc' ;
  TRACE ON ;
  TRACE "endate value=" || enddate ;

  FOREACH WITH HOLD
     SELECT hsno,hstarifftrtmnt,effdate
     INTO s_hsno,s_hstarifftrtmnt,s_effdate
     FROM hs_duty_rate
     WHERE exprydate < enddate

     DELETE FROM ip_0p@ipdb:hs_duty_rate
     WHERE hsno = s_hsno
       AND hstarifftrtmnt = s_hstarifftrtmnt
       AND effdate = s_effdate;

  END FOREACH;

END PROCEDURE;

CREATE PROCEDURE "informix".hsuom_purge()

  -- Declare working variables
  DEFINE enddate           CHAR(20) ;
  DEFINE s_hsno            CHAR(10);
  DEFINE s_effdate         CHAR(20);

  LET enddate = EXTEND(current, YEAR TO MONTH) - INTERVAL(24) MONTH TO MONTH;
  LET s_hsno   = 0;
  LET s_effdate   = 0;

  SET DEBUG FILE TO './hsuom_purge.trc' ;
  TRACE ON ;
  TRACE "endate value=" || enddate ;

  FOREACH WITH HOLD
     SELECT hsno,effdate
     INTO s_hsno,s_effdate
     FROM hs_uom
     WHERE exprydate < enddate

     DELETE FROM ip_0p@ipdb:hs_uom
     WHERE hsno = s_hsno
       AND effdate = s_effdate;

  END FOREACH;

END PROCEDURE;

create procedure "informix".keepalive()
  system "sleep 5";
end procedure
;


grant  execute on procedure "informix".pi_company_ins (char,char) to "public" as "informix";
grant  execute on function "informix".ps_nxtcompanyiid (integer) to "public" as "informix";
grant  execute on procedure "informix".pi_account_contact (integer,integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pi_as_accounted (integer) to "public" as "informix";
grant  execute on procedure "informix".pi_as_claimed (integer) to "public" as "informix";
grant  execute on procedure "informix".pi_b3 (integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pi_b3_line (integer) to "public" as "informix";
grant  execute on procedure "informix".pi_b3_line_comment (integer) to "public" as "informix";
grant  execute on procedure "informix".pi_b3_recap_detail (integer) to "public" as "informix";
grant  execute on procedure "informix".pi_b3_subheader (integer) to "public" as "informix";
grant  execute on procedure "informix".pi_b3b (integer) to "public" as "informix";
grant  execute on procedure "informix".pi_client_invoice (integer,integer,char) to "public" as "informix";
grant  execute on procedure "informix".pi_lii_account (integer) to "public" as "informix";
grant  execute on procedure "informix".pi_privilege (integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pi_search_criteria (integer) to "public" as "informix";
grant  execute on procedure "informix".pi_securuser (integer) to "public" as "informix";
grant  execute on procedure "informix".pi_status_history (integer) to "public" as "informix";
grant  execute on procedure "informix".pi_tariff (integer,char) to "public" as "informix";
grant  execute on procedure "informix".pi_user_locus_xref (integer,integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pi_usergroup (integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pu_account_contact (integer,integer,integer,integer,integer,integer,integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pu_as_accounted (integer,integer,integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pu_as_claimed (integer,integer,integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pu_b3 (integer,integer,integer,integer,integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pu_b3_line (integer,integer,integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pu_b3_line_comment (integer,integer,integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pu_b3_recap_detail (integer,integer,integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pu_b3_subheader (integer,integer,integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pu_b3b (integer,integer,integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pu_claim_log (integer,integer,char,integer,integer,char) to "public" as "informix";
grant  execute on procedure "informix".pu_client (integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pu_client_invoice (integer,integer,integer,integer,char,char,integer,integer,integer,integer,char,char) to "public" as "informix";
grant  execute on procedure "informix".pu_lii_account (integer,integer,integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pu_lii_client (integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pu_lii_contact (integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pu_privilege (integer,integer,integer,integer,integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pu_securuser (integer,integer,integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pu_status_history (integer,integer,integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pu_tariff (integer,char,char,integer,integer,char,char,integer) to "public" as "informix";
grant  execute on procedure "informix".pu_user_locus_xref (integer,integer,integer,integer,integer,integer,integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pd_b3_line (integer) to "public" as "informix";
grant  execute on procedure "informix".pd_b3_subheader (integer) to "public" as "informix";
grant  execute on procedure "informix".pd_claim_log (integer) to "public" as "informix";
grant  execute on procedure "informix".pd_client (integer) to "public" as "informix";
grant  execute on procedure "informix".pd_lii_contact (integer) to "public" as "informix";
grant  execute on procedure "informix".pd_securgroup (integer) to "public" as "informix";
grant  execute on procedure "informix".pd_securuser (integer) to "public" as "informix";
grant  execute on procedure "informix".pd_services (integer) to "public" as "informix";
grant  execute on procedure "informix".pi_ip_b3b (integer) to "public" as "informix";
grant  execute on procedure "informix".pu_ip_b3b (integer,integer,integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pu_ip_cci (integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pd_ip_cci (integer) to "public" as "informix";
grant  execute on procedure "informix".pi_ip_cci_line (integer) to "public" as "informix";
grant  execute on procedure "informix".pu_ip_cci_line (integer,integer,integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pu_ip_rmd (integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pd_ip_rmd (integer) to "public" as "informix";
grant  execute on procedure "informix".pi_srch_crit_batch (integer) to "public" as "informix";
grant  execute on procedure "informix".pu_srch_crit_batch (integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pi_claim_log (integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pi_claim_log_ins (char) to "public" as "informix";
grant  execute on function "informix".ps_nxtasacctiid (integer) to "public" as "informix";
grant  execute on function "informix".ps_nxtasclmiid (integer) to "public" as "informix";
grant  execute on procedure "informix".pd_lii_account (integer,integer) to "public" as "informix";
grant  execute on procedure "informix".pd_lii_client (integer) to "public" as "informix";
grant  execute on function "informix".sp1 (char) to "public" as "informix";
grant  execute on function "ipgown".hsno (char) to "public" as "ipgown";
grant  execute on procedure "informix".pd_rpt_b3 (integer) to "public" as "informix";
grant  execute on procedure "informix".pd_rpt_b3_sub (integer) to "public" as "informix";
grant  execute on function "informix".status_457 (integer,integer,char) to "public" as "informix";
grant  execute on procedure "informix".deleteb3 (char,char) to "public" as "informix";
grant  execute on function "informix".ps_nxtbatid () to "public" as "informix";
grant  execute on procedure "informix".reporterr (date,char,char,integer,integer,integer) to "public" as "informix";
grant  execute on function "informix".cleanupb3 (char,char) to "public" as "informix";
grant  execute on function "informix".insert_st (integer,integer,integer,char) to "public" as "informix";
grant  execute on function "informix".archiveandpurge () to "public" as "informix";
grant  execute on procedure "informix".insertarch (char,char) to "public" as "informix";
grant  execute on function "ipgown".p_invbrchno (integer) to "public" as "ipgown";
grant  execute on function "ipgown".p_invrefno (integer) to "public" as "ipgown";
grant  execute on procedure "informix".sp_pagelock () to "public" as "informix";
grant  execute on function "informix".deletetariff (integer) to "public" as "informix";
grant  execute on procedure "informix".deleteb3_1 () to "public" as "informix";
grant  execute on procedure "informix".cleanb3 (char,char) to "public" as "informix";
grant  execute on procedure "informix".invoice_purge () to "public" as "informix";
grant  execute on procedure "informix".pd_b3 (integer) to "public" as "informix";
grant  execute on function "informix".ps_nxtcontaineriid () to "public" as "informix";
grant  execute on function "informix".settrbnulldate (char) to "public" as "informix";
grant  execute on procedure "informix".hsdutyrate_purge () to "public" as "informix";
grant  execute on procedure "informix".hsuom_purge () to "public" as "informix";
grant  execute on function "informix".datetimeformat (datetime) to "public" as "informix";
grant  execute on function "informix".dateformat (date) to "public" as "informix";
grant  execute on function "informix".datetimeparse (char) to "public" as "informix";
grant  execute on function "informix".dateparse (char) to "public" as "informix";
grant  execute on function "informix".timepart (char) to "public" as "informix";
grant  execute on procedure "informix".keepalive () to "public" as "informix";

revoke usage on language SPL from public ;

grant usage on language SPL to public ;


create view "informix".vw_item_type (itemtypecode,description) as 
  select x0.strcode ,x0.description from "informix".stringtable 
    x0 where (x0.strtype = 'ITM' ) ;                          
          
create view "informix".vw_tarifftrtmnt (tarifftrtmnt,description) as 
  select x0.strcode ,x0.description from "informix".stringtable 
    x0 where (x0.strtype = 'TRB' ) ;                          
       
create view "informix".vw_search_criteria (useriid,liiclientno) as 
  select x0.useriid ,x0.liiclientno from "informix".search_criteria 
    x0 group by x0.useriid ,x0.liiclientno ;                 
      
create view "informix".vw_claim_type (claimcode,description) as 
  select x0.strcode ,x0.description from "informix".stringtable 
    x0 where (x0.strtype = 'PET' ) ;                          
            
create view "informix".vw_user_cltacct (liiclientno,liiaccountno,clientname,accountname,userlocusxrefiid,useriid) as 
  select x0.liiclientno ,x0.liiaccountno ,x2.name ,x1.name ,x0.userlocusxrefiid 
    ,x0.useriid from "informix".user_locus_xref x0 ,"informix".lii_account 
    x1 ,"informix".lii_client x2 where ((x0.liiclientno = x2.liiclientno 
    ) AND ((x0.liiclientno = x1.liiclientno ) AND (x0.liiaccountno 
    = x1.liiaccountno ) ) ) ;                         
create view "ipgown".trk_srhsuom (data,hsno,effdate) as 
  select ((x0.unitmeas || x1.ch ) || x0.effdate ) ,x0.hsno ,x0.effdate 
    from "informix".hs_uom x0 ,"ipgown".delimiter x1 where ((DATE 
    (((((x0.effdate [6,7] || x0.effdate [5,5] ) || x0.effdate 
    [9,10] ) || x0.effdate [5,5] ) || x0.effdate [1,4] ) ) <= 
    TODAY ) AND (DATE (((((x0.exprydate [6,7] || x0.exprydate 
    [5,5] ) || x0.exprydate [9,10] ) || x0.exprydate [5,5] ) 
    || x0.exprydate [1,4] ) ) > TODAY ) ) ;                  
                                         
create view "ipgown".v1 (data,liibrchno,liirefno) as 
  select ((x0.acctsecurno || x5.ch ) || x0.vendorname ) ,x0.liibrchno 
    ,x0.liirefno from "informix".b3 x0 ,"informix".carrier x1 ,
    "informix".usport_exit x2 ,"informix".canct_off x3 ,"informix"
    .transp_mode x4 ,"ipgown".delimiter x5 where ((((x0.carriercode 
    = x1.carriercode ) AND (x0.usportexit = x2.portexit ) ) AND 
    (x0.custoff = x3.canctoffcode ) ) AND (x0.modetransp = x4.transpmode 
    ) ) ;        
create view "ipgown".trk_srb3sub (data,b3iid,b3subiid) as 
  select (((((((((((((((((((((('B3ENTRY2' || x4.ch [1,1] ) || x3.b3subno 
    ) || x4.ch [1,1] ) || x3.vendorname ) || x4.ch [1,1] ) || 
    x3.vendorstate ) || x4.ch [1,1] ) || x3.vendorzip ) || x4.ch 
    [1,1] ) || x1.description ) || x4.ch [1,1] ) || x2.description 
    ) || x4.ch [1,1] ) || x0.description ) || x4.ch [1,1] ) || 
    x3.timelim ) || x4.ch [1,1] ) || x3.timelimunit ) || x4.ch 
    [1,1] ) || x3.currcode ) || x4.ch [1,1] ) || x3.shipdate 
    ) ,x3.b3iid ,x3.b3subiid from "informix".vw_tarifftrtmnt x0 
    ,"informix".ctry_code x1 ,"informix".ctry_code x2 ,"informix"
    .b3_subheader x3 ,"ipgown".delimiter x4 where (((x3.tarifftrtmnt 
    = x0.tarifftrtmnt ) AND (x3.placeexp = x1.ctrycode ) ) AND 
    (x3.ctryorigin = x2.ctrycode ) ) ;   
create view "ipgown".trk_srb3_7 (data,liibrchno,liirefno) as 
  select ((((((((((((((((((((((((((((((((((((x0.acctsecurno || 
    x5.ch [1,1] ) || x0.transno ) || x5.ch [1,1] ) || x0.vendorname 
    ) || x5.ch [1,1] ) || x0.vendorstate ) || x5.ch [1,1] ) || 
    x0.vendorzip ) || x5.ch [1,1] ) || x2.description ) || x5.ch 
    [1,1] ) || x0.purchaseorder1 ) || x5.ch [1,1] ) || x0.purchaseorder2 
    ) || x5.ch [1,1] ) || x3.description ) || x5.ch [1,1] ) || 
    x0.billoflading ) || x5.ch [1,1] ) || round(x0.weight , 2 
    ) ) || x5.ch [1,1] ) || x0.cargcntrlno ) || x5.ch [1,1] ) 
    || round(x0.cargcntrlqty , 2 ) ) || x5.ch [1,1] ) || x0.containerno 
    ) || x5.ch [1,1] ) || x1.description ) || x5.ch [1,1] ) || 
    x4.description ) || x5.ch [1,1] ) || x0.shipvia ) || x5.ch 
    [1,1] ) || x0.status ) || x5.ch [1,1] ) || x0.reldate ) ,
    x0.liibrchno ,x0.liirefno from "informix".b3 x0 ,"informix"
    .carrier x1 ,"informix".usport_exit x2 ,"informix".canct_off 
    x3 ,"informix".transp_mode x4 ,"ipgown".delimiter x5 where 
    ((((x0.carriercode = x1.carriercode ) AND (x0.usportexit 
    = x2.portexit ) ) AND (x0.custoff = x3.canctoffcode ) ) AND 
    (x0.modetransp = x4.transpmode ) ) ;                     
          
create view "informix".vw_as_accounted (asacctiid,claimlogiid,b3description) as 
  select x0.asacctiid ,x0.claimlogiid ,x0.b3description from "informix"
    .as_accounted x0 ;                         
create view "ipgown".trk_srb3_4 (data,b3iid,liibrchno,liirefno) as 
  select ((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((
    'B3ENTRY1' || x0.liiclientno ) || x5.ch [1,1] ) || x0.liiaccountno 
    ) || x5.ch [1,1] ) || x0.acctsecurno ) || x5.ch [1,1] ) || 
    x0.transno ) || x5.ch [1,1] ) || x0.b3type ) || x5.ch [1,
    1] ) || x0.purchaseorder1 ) || x5.ch [1,1] ) || x0.purchaseorder2 
    ) || x5.ch [1,1] ) || x0.vendorname ) || x5.ch [1,1] ) || 
    x0.vendorstate ) || x5.ch [1,1] ) || x0.vendorzip ) || x5.ch 
    [1,1] ) || x1.description ) || x5.ch [1,1] ) || x0.cargcntrlno 
    ) || x5.ch [1,1] ) || round(x0.freight , 2 ) ) || x5.ch [1,
    1] ) || x3.description ) || x5.ch [1,1] ) || round(x0.weight 
    , 2 ) ) || x5.ch [1,1] ) || round(x0.cargcntrlqty , 2 ) ) 
    || x5.ch [1,1] ) || x0.locationofgoods ) || x5.ch [1,1] ) 
    || x4.description ) || x5.ch [1,1] ) || x0.shipvia ) || x5.ch 
    [1,1] ) || x0.containerno ) || x5.ch [1,1] ) || x0.billoflading 
    ) || x5.ch [1,1] ) || x2.description ) || x5.ch [1,1] ) || 
    round(x0.totb3vfd , 2 ) ) || x5.ch [1,1] ) || round(x0.totb3duty 
    , 2 ) ) || x5.ch [1,1] ) || round(x0.totb3sima , 2 ) ) || 
    x5.ch [1,1] ) || round(x0.totb3exctax , 2 ) ) || x5.ch [1,
    1] ) || round(x0.totb3gst , 2 ) ) || x5.ch [1,1] ) || x0.approveddate 
    [1,10] ) || x5.ch [1,1] ) || x0.reldate [1,10] ) || x5.ch 
    [1,1] ) || "ipgown".p_invbrchno(x0.liibrchno )) || "ipgown"
    .p_invrefno(x0.liirefno )) || x5.ch [1,1] ) || x0.sbrnno 
    ) || x5.ch [1,1] ) || x0.ccnqty ) || x5.ch [1,1] ) || x0.ccinumlines 
    ) || x5.ch [1,1] ) || x0.invoiceqty ) || x5.ch [1,1] ) || 
    x0.warehousenum ) || x5.ch [1,1] ) || x0.entname ) || x5.ch 
    [1,1] ) || x0.entaddr1 ) || x5.ch [1,1] ) || x0.entaddr2 
    ) || x5.ch [1,1] ) || x0.entaddr3 ) || x5.ch [1,1] ) || x0.entaddr4 
    ) || x5.ch [1,1] ) || x0.entpostcd ) ,x0.b3iid ,x0.liibrchno 
    ,x0.liirefno from "informix".b3 x0 ,"informix".canct_off x1 
    ,"informix".canct_off x2 ,"informix".usport_exit x3 ,"informix"
    .transp_mode x4 ,"ipgown".delimiter x5 where ((((x0.usportexit 
    = x3.portexit ) AND (x0.modetransp = x4.transpmode ) ) AND 
    (x0.custoff = x1.canctoffcode ) ) AND (x0.portunlading = 
    x2.canctoffcode ) ) ;                                    
               
create view "ipgown".trk_srb3line (data,b3lineiid,b3subiid) as 
  select (((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((
    'B3ENTRY3' || x1.ch [1,1] ) || x0.b3lineno ) || x1.ch [1,1] 
    ) || x0.partdesc ) || x1.ch [1,1] ) || x0.hsno ) || x1.ch 
    [1,1] ) || x0.tariffcode ) || x1.ch [1,1] ) || x0.vfdcode 
    ) || x1.ch [1,1] ) || x0.exctaxexmptcode ) || x1.ch [1,1] 
    ) || x0.simacode ) || x1.ch [1,1] ) || x0.gstexemptcode ) 
    || x1.ch [1,1] ) || x0.oicspecialaut ) || x1.ch [1,1] ) || 
    round(x0.convtoqty1 , 2 ) ) || x1.ch [1,1] ) || x0.advaldutyrateumeas 
    ) || x1.ch [1,1] ) || round(x0.convtoqty2 , 2 ) ) || x1.ch 
    [1,1] ) || x0.spcdutyrateumeas ) || x1.ch [1,1] ) || round(x0.convtoqty3 
    , 2 ) ) || x1.ch [1,1] ) || x0.excdutyrateumeas ) || x1.ch 
    [1,1] ) || round(x0.exchgrate , 6 ) ) || x1.ch [1,1] ) || 
    round(x0.advalrate1 , 2 ) ) || x1.ch [1,1] ) || round(x0.spcrate 
    , 2 ) ) || x1.ch [1,1] ) || round(x0.excdutyrate , 6 ) ) 
    || x1.ch [1,1] ) || round(x0.exctaxrate , 2 ) ) || x1.ch 
    [1,1] ) || round(x0.gstrate , 2 ) ) || x1.ch [1,1] ) || round(x0.vfcc 
    , 2 ) ) || x1.ch [1,1] ) || round(x0.vfd , 2 ) ) || x1.ch 
    [1,1] ) || round(x0.advalduty , 2 ) ) || x1.ch [1,1] ) || 
    round(x0.spcduty , 2 ) ) || x1.ch [1,1] ) || round(x0.excduty 
    , 2 ) ) || x1.ch [1,1] ) || round(x0.exctax , 2 ) ) || x1.ch 
    [1,1] ) || round(x0.simaval , 2 ) ) || x1.ch [1,1] ) || round(x0.vft 
    , 2 ) ) || x1.ch [1,1] ) || round(x0.gst , 2 ) ) || x1.ch 
    [1,1] ) || x0.linecomment ) || x1.ch [1,1] ) || x0.rulingnumber 
    ) || x1.ch [1,1] ) || x0.trqno ) || x1.ch [1,1] ) || x0.prevtransno 
    ) || x1.ch [1,1] ) || x0.prevlineno ) || x1.ch [1,1] ) ,x0.b3lineiid 
    ,x0.b3subiid from "informix".b3_line x0 ,"ipgown".delimiter 
    x1 ;                                     
create view "ipgown".trk_srb3recap (data,b3lineiid) as 
  select (((((((((((((((((('B3ENTRY4' || x0.ccipageno ) || x1.ch 
    [1,1] ) || x0.ccilineno ) || x1.ch [1,1] ) || x0.uom ) || 
    x1.ch [1,1] ) || round(x0.quantity , 2 ) ) || x1.ch [1,1] 
    ) || round(x0.amount , 2 ) ) || x1.ch [1,1] ) || x0.proddesc 
    ) || x1.ch [1,1] ) || round(x0.percentsplit , 2 ) ) || x1.ch 
    [1,1] ) || x0.detailponumber ) || x1.ch [1,1] ) || round(x0.unitprice 
    , 2 ) ) || x1.ch [1,1] ) ,x0.b3lineiid from "informix".b3_recap_details 
    x0 ,"ipgown".delimiter x1 ;                               
                        
create view "ipgown".trk_tariff (liiclientno,vendorname,productkeyword,productsufx,data1,data2,data3) as 
  select x0.liiclientno ,x0.vendorname ,x0.productkeyword ,x0.productsufx 
    ,(((((((((((((((((((((x0.liiclientno || x2.ch ) || x0.vendorname 
    ) || x2.ch ) || x1.description ) || x2.ch ) || x0.productkeyword 
    ) || x2.ch ) || x0.hsno ) || x2.ch ) || x0.tariffcode ) || 
    x2.ch ) || x0.vfdcode ) || x2.ch ) || x0.productsufx ) || 
    x2.ch ) || x0.b3description ) || x2.ch ) || x0.remarks ) 
    || x2.ch ) || x0.tarifftrtmnt ) || x2.ch ) ,((((((((((((((((((((x2.ch 
    || round(x0.exctaxamt , 6 ) ) || x2.ch ) || round(x0.exctaxdeduct 
    , 2 ) ) || x2.ch ) || x0.exctaxdeductunit ) || x2.ch ) || 
    round(x0.exctaxrate , 2 ) ) || x2.ch ) || x0.exctaxunit ) 
    || x2.ch ) || x0.exctaxlicind ) || x2.ch ) || x0.exctaxexmptcode 
    ) || x2.ch ) || x0.gstexemptcode ) || x2.ch ) || x0.gstratecode 
    ) || x2.ch ) || x3.gstrate ) || x2.ch ) ,((((((((((((((((((((((((((((((((((((((((((((((((((x0.cooindicator 
    || x2.ch ) || x0.cooexprydate ) || x2.ch ) || x0.remissno 
    ) || x2.ch ) || x0.remissexprydate ) || x2.ch ) || x0.rulingno 
    ) || x2.ch ) || x0.rulingexprydate ) || x2.ch ) || x0.oic 
    ) || x2.ch ) || x0.oicexprydate ) || x2.ch ) || round(x0.percentsplit 
    , 2 ) ) || x2.ch ) || x0.createdate ) || x2.ch ) || x0.moddate 
    ) || x2.ch ) || x0.lastuseddate ) || x2.ch ) || x0.moduser 
    ) || x2.ch ) || x0.b3refbrch ) || x2.ch ) || x0.b3refno ) 
    || x2.ch ) || x0.specialinstruct ) || x2.ch ) || x0.projectcode 
    ) || x2.ch ) || x0.businessunitcode ) || x2.ch ) || x0.materialclasscode 
    ) || x2.ch ) || x0.countryorigin ) || x2.ch ) || x0.requirementid 
    ) || x2.ch ) || x0.version ) || x2.ch ) || x0.ogdextension 
    ) || x2.ch ) || x0.enduse ) || x2.ch ) || x0.miscellaneous 
    ) || x2.ch ) || x0.regtype01 ) from "informix".tariff x0 ,
    "informix".ctry_code x1 ,"ipgown".delimiter x2 ,"informix".gst_rate_code 
    x3 where ((x1.ctrycode = x0.placeexp ) AND (x0.gstratecode 
    = x3.ratecode ) ) ;                                      
                      
create view "ipgown".trk_srhsduty (data,hsno,hstarifftrtmnt,effdate) as 
  select ((((((((((((((x1.ch || round(x0.advalrate , 2 ) ) || 
    x1.ch ) || round(x0.specrate , 6 ) ) || x1.ch ) || x0.specunitmeas 
    ) || x1.ch ) || round(x0.excrate , 2 ) ) || x1.ch ) || x0.excunitmeas 
    ) || x1.ch ) || round(x0.minamt , 6 ) ) || x1.ch ) || round(x0.maxamt 
    , 6 ) ) || x1.ch ) ,x0.hsno ,x0.hstarifftrtmnt ,x0.effdate 
    from "informix".hs_duty_rate x0 ,"ipgown".delimiter x1 where 
    ((DATE (((((x0.effdate [6,7] || x0.effdate [5,5] ) || x0.effdate 
    [9,10] ) || x0.effdate [5,5] ) || x0.effdate [1,4] ) ) <= 
    TODAY ) AND (DATE (((((x0.exprydate [6,7] || x0.exprydate 
    [5,5] ) || x0.exprydate [9,10] ) || x0.exprydate [5,5] ) 
    || x0.exprydate [1,4] ) ) > TODAY ) ) ;                  
                  

create index "informix".client_invoice_rk1 on "informix".client_invoice 
    (itemtypecode) using btree  in indxdbs1;
create index "informix".client_invoice_rk2 on "informix".client_invoice 
    (balance) using btree  in indxdbs2;
create index "informix".client_invoice_rk3 on "informix".client_invoice 
    (itemstatus) using btree  in indxdbs3;
create index "informix".client_invoice_rk4 on "informix".client_invoice 
    (itemdate) using btree  in indxdbs1;
create index "informix".client_invoice_rk5 on "informix".client_invoice 
    (totduty) using btree  in indxdbs2;
create unique index "informix".claim_log_rk1 on "informix".claim_log 
    (b3acctsecurno,b3transno,b3transseqno) using btree  in indxdbs1;
    
create index "informix".claim_log_rk2 on "informix".claim_log 
    (b2brchno,b2refno) using btree  in indxdbs2;
create index "informix".claim_log_rk3 on "informix".claim_log 
    (liiclientno) using btree  in indxdbs3;
create index "informix".claim_log_rk4 on "informix".claim_log 
    (claimstatus) using btree  in indxdbs1;
create index "informix".claim_log_rk5 on "informix".claim_log 
    (claimcode) using btree  in indxdbs2;
create index "informix".claim_log_rk6 on "informix".claim_log 
    (claimvendorname) using btree  in indxdbs3;
create index "informix".claim_log_rk7 on "informix".claim_log 
    (b3acctsecurno) using btree  in indxdbs1;
create index "informix".claim_log_rk8 on "informix".claim_log 
    (b3transno) using btree  in indxdbs2;
create index "informix".claim_log_rk9 on "informix".claim_log 
    (claimrefno) using btree  in indxdbs3;
create index "informix".as_accounted_rk1 on "informix".as_accounted 
    (claimlogiid,b2subhdrno,b3lineno,b2lineno) using btree  in 
    indxdbs3;
create index "informix".as_claimed_rk1 on "informix".as_claimed 
    (claimlogiid,b2subhdrno,b3lineno,b2lineno) using btree  in 
    indxdbs1;
create index "informix".user_loc_xref_rk1 on "informix".user_locus_xref 
    (useriid,liiclientno,liiaccountno) using btree  in indxdbs1;
    
create unique index "informix".ip_cci_rk1 on "informix".ip_cci 
    (fromsiteid,refno) using btree  in indxdbs2;
create index "informix".lii_contact_rk1 on "informix".lii_contact 
    (contactcode) using btree  in indxdbs1;
create index "informix".lii_contact_rk2 on "informix".lii_contact 
    (inactiveflag) using btree  in indxdbs2;
create unique index "informix".ip_rmd_rk1 on "informix".ip_rmd 
    (liibrchno,liirefno) using btree  in indxdbs1;
create index "informix".securuser_rk1 on "informix".securuser 
    (username) using btree  in indxdbs3;
create unique index "informix".account_cont_rk1 on "informix".account_contact 
    (liiclientno,liiaccountno,employeeno) using btree  in indxdbs3;
    
create index "informix".account_cont_rk2 on "informix".account_contact 
    (liiaccountno) using btree  in indxdbs1;
create index "informix".b3b_rk1 on "informix".b3b (cargcntrlno) 
    using btree  in indxdbs1;
create unique index "informix".product_used_rk1 on "informix".product_used 
    (liiclientno,productcode) using btree  in indxdbs1;
create unique index "informix".privilege_rk1 on "informix".privilege 
    (securgroupiid desc,serviceiid desc) using btree  in indxdbs2;
    
create unique index "informix".securgroup_rk1 on "informix".securgroup 
    (securgroupiid desc) using btree  in indxdbs2;
create unique index "informix".securgroup_rk2 on "informix".securgroup 
    (groupname desc) using btree  in indxdbs3;
create unique index "informix".usergroup_rk1 on "informix".usergroup 
    (useriid desc,securgroupiid desc) using btree  in indxdbs2;
    
create index "informix".ip_ccn_rk1 on "informix".ip_ccn (dociid) 
    using btree  in indxdbs3;
create index "informix".srch_crit_bat_rk1 on "informix".srch_crit_batch 
    (useriid,tablename) using btree  in indxdbs1;
create index "informix".srch_crit_bat_rk2 on "informix".srch_crit_batch 
    (liiclientno,liiaccountno) using btree  in indxdbs2;
create unique index "informix".company_rk1 on "informix".company 
    (liiclientno,companyname) using btree  in indxdbs3;
create index "informix".company_rk2 on "informix".company (companyname) 
    using btree  in indxdbs1;
create unique index "informix".rpt_b3_rk1 on "informix".rpt_b3 
    (useriid,b3iid) using btree  in indxdbs3;
create index "informix".rpt_b3_rk2 on "informix".rpt_b3 (rriid) 
    using btree  in indxdbs1;
create unique index "informix".rpt_b3_sub_rk1 on "informix".rpt_b3_subheader 
    (useriid,b3subiid) using btree  in indxdbs1;
create index "informix".rpt_b3_sub_rk2 on "informix".rpt_b3_subheader 
    (rriid) using btree  in indxdbs2;
create index "informix".rpt_b3_sub_rk3 on "informix".rpt_b3_subheader 
    (b3iid) using btree  in indxdbs3;
create unique index "informix".rpt_b3_line_rk1 on "informix".rpt_b3_line 
    (useriid,sortfield,b3lineiid) using btree  in indxdbs1;
create index "informix".rpt_b3_line_rk2 on "informix".rpt_b3_line 
    (rriid) using btree  in indxdbs2;
create index "informix".rpt_b3_line_rk3 on "informix".rpt_b3_line 
    (b3subiid) using btree  in indxdbs3;
create unique index "informix".bat_id_rk1 on "informix".bat_id 
    (tablename) using btree  in indxdbs2;
create unique index "informix".bat_id_rk2 on "informix".bat_id 
    (last_id) using btree  in indxdbs3;
create unique index "informix".bat_info_rk1 on "informix".bat_info 
    (bat_id) using btree  in indxdbs1;
create unique index "informix".b3_rk1 on "informix".b3 (liibrchno,
    liirefno) using btree  in indxdbs1;
create index "informix".b3_rk10 on "informix".b3 (modetransp) 
    using btree  in indxdbs1;
create index "informix".b3_rk11 on "informix".b3 (status) using 
    btree  in indxdbs2;
create index "informix".b3_rk12 on "informix".b3 (transno) using 
    btree  in indxdbs3;
create index "informix".b3_rk13 on "informix".b3 (k84date) using 
    btree  in indxdbs1;
create index "informix".b3_rk14 on "informix".b3 (containerno) 
    using btree  in indxdbs2;
create index "informix".b3_rk2 on "informix".b3 (liiclientno,liiaccountno) 
    using btree  in indxdbs2;
create index "informix".b3_rk3 on "informix".b3 (approveddate) 
    using btree  in indxdbs3;
create index "informix".b3_rk4 on "informix".b3 (createdate) using 
    btree  in indxdbs1;
create index "informix".b3_rk5 on "informix".b3 (cargcntrlno) 
    using btree  in indxdbs2;
create index "informix".b3_rk6 on "informix".b3 (reldate) using 
    btree  in indxdbs3;
create index "informix".b3_rk7 on "informix".b3 (custoff) using 
    btree  in indxdbs1;
create index "informix".b3_rk8 on "informix".b3 (usportexit) using 
    btree  in indxdbs2;
create index "informix".b3_rk9 on "informix".b3 (carriercode) 
    using btree  in indxdbs3;
create index "informix".b3_subheader_rk1 on "informix".b3_subheader 
    (b3iid) using btree  in indxdbs3;
create index "informix".b3_subheader_rk2 on "informix".b3_subheader 
    (shipdate) using btree  in indxdbs3;
create index "informix".b3_line_rk1 on "informix".b3_line (hsno) 
    using btree  in indxdbs2;
create index "informix".b3_line_rk2 on "informix".b3_line (partdesc) 
    using btree  in indxdbs1;
create index "informix".b3_recap_rk1 on "informix".b3_recap_details 
    (proddesc) using btree  in indxdbs1;
create index "informix".b3_recap_rk2 on "informix".b3_recap_details 
    (detailponumber) using btree  in indxdbs2;
create unique index "informix".insight_pdq_rk1 on "informix".insight_pdq 
    (pdq_id) using btree  in indxdbs2;
create unique index "informix".insight_pdq_rk2 on "informix".insight_pdq 
    (query_type) using btree  in indxdbs3;
create index "informix".tariff_rk1 on "informix".tariff (liiclientno,
    createdate) using btree  in indxdbs1;
create index "informix".tariff_rk10 on "informix".tariff (countryorigin) 
    using btree  in indxdbs2;
create index "informix".tariff_rk2 on "informix".tariff (liiclientno,
    moddate) using btree  in indxdbs2;
create index "informix".tariff_rk3 on "informix".tariff (liiclientno,
    lastuseddate) using btree  in indxdbs3;
create index "informix".tariff_rk4 on "informix".tariff (tariffcode) 
    using btree  in indxdbs1;
create index "informix".tariff_rk5 on "informix".tariff (hsno) 
    using btree  in indxdbs2;
create index "informix".tariff_rk6 on "informix".tariff (liiclientno,
    tarifftrtmnt) using btree  in indxdbs3;
create index "informix".tariff_rk7 on "informix".tariff (b3description) 
    using btree  in indxdbs1;
create index "informix".tariff_rk8 on "informix".tariff (remarks) 
    using btree  in indxdbs2;
create index "informix".tariff_rk9 on "informix".tariff (productkeyword) 
    using btree  in indxdbs3;
create index "informix".containers_rk1 on "informix".containers 
    (containerno) using btree  in indxdbs3;


alter table "informix".securuser add constraint (foreign key 
    (clientiid) references "informix".client );
alter table "informix".lii_account add constraint (foreign key 
    (liiclientno) references "informix".lii_client );
alter table "informix".account_contact add constraint (foreign 
    key (employeeno) references "informix".lii_contact );
alter table "informix".product_used add constraint (foreign key 
    (productcode) references "informix".product );
alter table "informix".ip_b3b add constraint (foreign key (iprmdiid) 
    references "informix".ip_rmd );
alter table "informix".ip_cci_line add constraint (foreign key 
    (cciiid) references "informix".ip_cci );
alter table "informix".search_criteria add constraint (foreign 
    key (useriid) references "informix".securuser );
alter table "informix".srch_crit_batch add constraint (foreign 
    key (useriid) references "informix".securuser );
alter table "informix".status_history add constraint (foreign 
    key (b3iid) references "informix".b3 );
alter table "informix".b3b add constraint (foreign key (b3iid) 
    references "informix".b3 );
alter table "informix".b3_line add constraint (foreign key (b3subiid) 
    references "informix".b3_subheader );
alter table "informix".b3_recap_details add constraint (foreign 
    key (b3lineiid) references "informix".b3_line );
alter table "informix".b3_line_comment add constraint (foreign 
    key (b3lineiid) references "informix".b3_line );
alter table "informix".user_locus_xref add constraint (foreign 
    key (liiclientno,liiaccountno) references "informix".lii_account 
    );
alter table "informix".user_locus_xref add constraint (foreign 
    key (useriid) references "informix".securuser );
alter table "informix".tariff add constraint (foreign key (liiclientno) 
    references "informix".lii_client );
alter table "informix".containers add constraint (foreign key 
    (b3iid) references "informix".b3 );


create trigger "informix".ti_client_invoice insert on "informix"
    .client_invoice referencing new as new_ins
    for each row
        (
        execute procedure "informix".pi_client_invoice(new_ins.liiclientno 
    ,new_ins.liiaccountno ,new_ins.itemtypecode ));

create trigger "informix".tu_client_invoice update on "informix"
    .client_invoice referencing old as old_upd new as new_upd
    
    for each row
        (
        execute procedure "informix".pu_client_invoice(old_upd.liiclientno 
    ,old_upd.liiaccountno ,old_upd.liibrchno ,old_upd.liirefno ,old_upd.liireftext 
    ,old_upd.itemtypecode ,new_upd.liiclientno ,new_upd.liiaccountno 
    ,new_upd.liibrchno ,new_upd.liirefno ,new_upd.liireftext ,new_upd.itemtypecode 
    ));

create trigger "informix".td_claim_log delete on "informix".claim_log 
    referencing old as old_del
    for each row
        (
        execute procedure "informix".pd_claim_log(old_del.claimlogiid 
    ));

create trigger "informix".tu_claim_log update on "informix".claim_log 
    referencing old as old_upd new as new_upd
    for each row
        (
        execute procedure "informix".pu_claim_log(old_upd.claimlogiid 
    ,old_upd.liiclientno ,old_upd.claimcode ,new_upd.claimlogiid ,new_upd.liiclientno 
    ,new_upd.claimcode ));

create trigger "informix".ti_claim_log insert on "informix".claim_log 
    referencing new as new_ins
    for each row
        (
        execute procedure "informix".pi_claim_log(new_ins.liiclientno 
    ,new_ins.claimlogiid ));

create trigger "informix".ti_as_accounted insert on "informix"
    .as_accounted referencing new as new_ins
    for each row
        (
        execute procedure "informix".pi_as_accounted(new_ins.claimlogiid 
    ));

create trigger "informix".tu_as_accounted update on "informix"
    .as_accounted referencing old as old_upd new as new_upd
    for each row
        (
        execute procedure "informix".pu_as_accounted(old_upd.asacctiid 
    ,old_upd.claimlogiid ,new_upd.asacctiid ,new_upd.claimlogiid ));

create trigger "informix".ti_as_claimed insert on "informix".as_claimed 
    referencing new as new_ins
    for each row
        (
        execute procedure "informix".pi_as_claimed(new_ins.claimlogiid 
    ));

create trigger "informix".tu_as_claimed update on "informix".as_claimed 
    referencing old as old_upd new as new_upd
    for each row
        (
        execute procedure "informix".pu_as_claimed(old_upd.asclaimediid 
    ,old_upd.claimlogiid ,new_upd.asclaimediid ,new_upd.claimlogiid ));
    

create trigger "informix".ti_status_history insert on "informix"
    .status_history referencing new as new_ins
    for each row
        (
        execute procedure "informix".pi_status_history(new_ins.b3iid 
    ));

create trigger "informix".tu_status_history update on "informix"
    .status_history referencing old as old_upd new as new_upd
    
    for each row
        (
        execute procedure "informix".pu_status_history(old_upd.b3iid 
    ,old_upd.status ,new_upd.b3iid ,new_upd.status ));

create trigger "informix".ti_user_locus_xref insert on "informix"
    .user_locus_xref referencing new as new_ins
    for each row
        (
        execute procedure "informix".pi_user_locus_xref(new_ins.liiaccountno 
    ,new_ins.liiclientno ,new_ins.useriid ));

create trigger "informix".tu_user_locus_xref update on "informix"
    .user_locus_xref referencing old as old_upd new as new_upd
    
    for each row
        (
        execute procedure "informix".pu_user_locus_xref(old_upd.userlocusxrefiid 
    ,old_upd.liiaccountno ,old_upd.liiclientno ,old_upd.useriid ,new_upd.userlocusxrefiid 
    ,new_upd.liiaccountno ,new_upd.liiclientno ,new_upd.useriid ));

create trigger "informix".tu_client update on "informix".client 
    referencing old as old_upd new as new_upd
    for each row
        (
        execute procedure "informix".pu_client(old_upd.clientiid 
    ,new_upd.clientiid ));

create trigger "informix".td_client delete on "informix".client 
    referencing old as old_del
    for each row
        (
        execute procedure "informix".pd_client(old_del.clientiid 
    ));

create trigger "informix".tu_ip_cci update on "informix".ip_cci 
    referencing old as old_upd new as new_upd
    for each row
        (
        execute procedure "informix".pu_ip_cci(old_upd.cciiid 
    ,new_upd.cciiid ));

create trigger "informix".td_ip_cci delete on "informix".ip_cci 
    referencing old as old_del
    for each row
        (
        execute procedure "informix".pd_ip_cci(old_del.cciiid 
    ));

create trigger "informix".tu_lii_contact update on "informix".lii_contact 
    referencing old as old_upd new as new_upd
    for each row
        (
        execute procedure "informix".pu_lii_contact(old_upd.employeeno 
    ,new_upd.employeeno ));

create trigger "informix".td_lii_contact delete on "informix".lii_contact 
    referencing old as old_del
    for each row
        (
        execute procedure "informix".pd_lii_contact(old_del.employeeno 
    ));

create trigger "informix".tu_lii_client update on "informix".lii_client 
    referencing old as old_upd new as new_upd
    for each row
        (
        execute procedure "informix".pu_lii_client(old_upd.liiclientno 
    ,new_upd.liiclientno ));

create trigger "informix".td_lii_client delete on "informix".lii_client 
    referencing old as old_del
    for each row
        (
        execute procedure "informix".pd_lii_client(old_del.liiclientno 
    ));

create trigger "informix".tu_ip_rmd update on "informix".ip_rmd 
    referencing old as old_upd new as new_upd
    for each row
        (
        execute procedure "informix".pu_ip_rmd(old_upd.iprmdiid 
    ,new_upd.iprmdiid ));

create trigger "informix".td_ip_rmd delete on "informix".ip_rmd 
    referencing old as old_del
    for each row
        (
        execute procedure "informix".pd_ip_rmd(old_del.iprmdiid 
    ));

create trigger "informix".ti_securuser insert on "informix".securuser 
    referencing new as new_ins
    for each row
        (
        execute procedure "informix".pi_securuser(new_ins.clientiid 
    ));

create trigger "informix".tu_securuser update on "informix".securuser 
    referencing old as old_upd new as new_upd
    for each row
        (
        execute procedure "informix".pu_securuser(old_upd.useriid 
    ,old_upd.clientiid ,new_upd.useriid ,new_upd.clientiid ));

create trigger "informix".td_securuser delete on "informix".securuser 
    referencing old as old_del
    for each row
        (
        execute procedure "informix".pd_securuser(old_del.useriid 
    ));

create trigger "informix".ti_lii_account insert on "informix".lii_account 
    referencing new as new_ins
    for each row
        (
        execute procedure "informix".pi_lii_account(new_ins.liiclientno 
    ));

create trigger "informix".tu_lii_account update on "informix".lii_account 
    referencing old as old_upd new as new_upd
    for each row
        (
        execute procedure "informix".pu_lii_account(old_upd.liiclientno 
    ,old_upd.liiaccountno ,new_upd.liiclientno ,new_upd.liiaccountno 
    ));

create trigger "informix".td_lii_account delete on "informix".lii_account 
    referencing old as old_del
    for each row
        (
        execute procedure "informix".pd_lii_account(old_del.liiclientno 
    ,old_del.liiaccountno ));

create trigger "informix".ti_account_contact insert on "informix"
    .account_contact referencing new as new_ins
    for each row
        (
        execute procedure "informix".pi_account_contact(new_ins.employeeno 
    ,new_ins.liiclientno ,new_ins.liiaccountno ));

create trigger "informix".tu_account_contact update on "informix"
    .account_contact referencing old as old_upd new as new_upd
    
    for each row
        (
        execute procedure "informix".pu_account_contact(old_upd.acctcontiid 
    ,old_upd.employeeno ,old_upd.liiclientno ,old_upd.liiaccountno ,new_upd.acctcontiid 
    ,new_upd.employeeno ,new_upd.liiclientno ,new_upd.liiaccountno ));
    

create trigger "informix".ti_b3b insert on "informix".b3b referencing 
    new as new_ins
    for each row
        (
        execute procedure "informix".pi_b3b(new_ins.b3iid ));
    

create trigger "informix".tu_b3b update on "informix".b3b referencing 
    old as old_upd new as new_upd
    for each row
        (
        execute procedure "informix".pu_b3b(old_upd.b3biid ,old_upd.b3iid 
    ,new_upd.b3biid ,new_upd.b3iid ));

create trigger "informix".ti_ip_cci_line insert on "informix".ip_cci_line 
    referencing new as new_ins
    for each row
        (
        execute procedure "informix".pi_ip_cci_line(new_ins.cciiid 
    ));

create trigger "informix".tu_ip_cci_line update on "informix".ip_cci_line 
    referencing old as old_upd new as new_upd
    for each row
        (
        execute procedure "informix".pu_ip_cci_line(old_upd.ccilineiid 
    ,old_upd.cciiid ,new_upd.ccilineiid ,new_upd.cciiid ));

create trigger "informix".ti_search_criteria insert on "informix"
    .search_criteria referencing new as new_ins
    for each row
        (
        execute procedure "informix".pi_search_criteria(new_ins.useriid 
    ));

create trigger "informix".ti_b3_line_comment insert on "informix"
    .b3_line_comment referencing new as new_ins
    for each row
        (
        execute procedure "informix".pi_b3_line_comment(new_ins.b3lineiid 
    ));

create trigger "informix".tu_b3_line_comment update on "informix"
    .b3_line_comment referencing old as old_upd new as new_upd
    
    for each row
        (
        execute procedure "informix".pu_b3_line_comment(old_upd.b3linecommentiid 
    ,old_upd.b3lineiid ,new_upd.b3linecommentiid ,new_upd.b3lineiid ));
    

create trigger "informix".ti_ip_b3b insert on "informix".ip_b3b 
    referencing new as new_ins
    for each row
        (
        execute procedure "informix".pi_ip_b3b(new_ins.iprmdiid 
    ));

create trigger "informix".tu_ip_b3b update on "informix".ip_b3b 
    referencing old as old_upd new as new_upd
    for each row
        (
        execute procedure "informix".pu_ip_b3b(old_upd.ipb3biid 
    ,old_upd.iprmdiid ,new_upd.ipb3biid ,new_upd.iprmdiid ));

create trigger "informix".ti_privilege insert on "informix".privilege 
    referencing new as new_ins
    for each row
        (
        execute procedure "informix".pi_privilege(new_ins.serviceiid 
    ,new_ins.securgroupiid ));

create trigger "informix".tu_privilege update on "informix".privilege 
    referencing old as old_upd new as new_upd
    for each row
        (
        execute procedure "informix".pu_privilege(old_upd.privilegeiid 
    ,old_upd.serviceiid ,old_upd.securgroupiid ,new_upd.privilegeiid 
    ,new_upd.serviceiid ,new_upd.securgroupiid ));

create trigger "informix".td_securgroup delete on "informix".securgroup 
    referencing old as old_del
    for each row
        (
        execute procedure "informix".pd_securgroup(old_del.securgroupiid 
    ));

create trigger "informix".td_services delete on "informix".services 
    referencing old as old_del
    for each row
        (
        execute procedure "informix".pd_services(old_del.serviceiid 
    ));

create trigger "informix".ti_usergroup insert on "informix".usergroup 
    referencing new as new_ins
    for each row
        (
        execute procedure "informix".pi_usergroup(new_ins.securgroupiid 
    ,new_ins.useriid ));

create trigger "informix".ti_srch_crit_batch insert on "informix"
    .srch_crit_batch referencing new as new_ins
    for each row
        (
        execute procedure "informix".pi_srch_crit_batch(new_ins.useriid 
    ));

create trigger "informix".tu_srch_crit_batch update on "informix"
    .srch_crit_batch referencing old as old_upd new as new_upd
    
    for each row
        (
        execute procedure "informix".pu_srch_crit_batch(old_upd.useriid 
    ,new_upd.useriid ));

create trigger "informix".td_rpt_b3 delete on "informix".rpt_b3 
    referencing old as old_del
    for each row
        (
        execute procedure "informix".pd_rpt_b3(old_del.b3iid 
    ));

create trigger "informix".td_rpt_b3_sub delete on "informix".rpt_b3_subheader 
    referencing old as old_del
    for each row
        (
        execute procedure "informix".pd_rpt_b3_sub(old_del.b3subiid 
    ));

create trigger "informix".td_b3 delete on "informix".b3 referencing 
    old as old_del
    for each row
        (
        execute procedure "informix".pd_b3(old_del.b3iid ));

create trigger "informix".tu_b3_subheader update on "informix"
    .b3_subheader referencing old as old_upd new as new_upd
    for each row
        (
        execute procedure "informix".pu_b3_subheader(old_upd.b3subiid 
    ,old_upd.b3iid ,new_upd.b3subiid ,new_upd.b3iid ));

create trigger "informix".td_b3_subheader delete on "informix"
    .b3_subheader referencing old as old_del
    for each row
        (
        execute procedure "informix".pd_b3_subheader(old_del.b3subiid 
    ));

create trigger "informix".ti_b3_line insert on "informix".b3_line 
    referencing new as new_ins
    for each row
        (
        execute procedure "informix".pi_b3_line(new_ins.b3subiid 
    ));

create trigger "informix".tu_b3_line update on "informix".b3_line 
    referencing old as old_upd new as new_upd
    for each row
        (
        execute procedure "informix".pu_b3_line(old_upd.b3lineiid 
    ,old_upd.b3subiid ,new_upd.b3lineiid ,new_upd.b3subiid ));

create trigger "informix".td_b3_line delete on "informix".b3_line 
    referencing old as old_del
    for each row
        (
        execute procedure "informix".pd_b3_line(old_del.b3lineiid 
    ));

create trigger "informix".ti_b3_recap_detail insert on "informix"
    .b3_recap_details referencing new as new_ins
    for each row
        (
        execute procedure "informix".pi_b3_recap_detail(new_ins.b3lineiid 
    ));

create trigger "informix".tu_b3_recap_detail update on "informix"
    .b3_recap_details referencing old as old_upd new as new_upd
    
    for each row
        (
        execute procedure "informix".pu_b3_recap_detail(old_upd.b3recapiid 
    ,old_upd.b3lineiid ,new_upd.b3recapiid ,new_upd.b3lineiid ));

create trigger "informix".ti_tariff insert on "informix".tariff 
    referencing new as new_ins
    for each row
        (
        execute procedure "informix".pi_tariff(new_ins.liiclientno 
    ,new_ins.vendorname ));

create trigger "informix".tu_tariff update on "informix".tariff 
    referencing old as old_upd new as new_upd
    for each row
        (
        execute procedure "informix".pu_tariff(old_upd.liiclientno 
    ,old_upd.vendorname ,old_upd.productkeyword ,old_upd.productsufx 
    ,new_upd.liiclientno ,new_upd.vendorname ,new_upd.productkeyword 
    ,new_upd.productsufx ));

grant select on "informix".vw_item_type to "public" as "informix";
grant update on "informix".vw_item_type to "public" as "informix";
grant insert on "informix".vw_item_type to "public" as "informix";
grant delete on "informix".vw_item_type to "public" as "informix";
grant select on "informix".vw_tarifftrtmnt to "public" as "informix";
grant update on "informix".vw_tarifftrtmnt to "public" as "informix";
grant insert on "informix".vw_tarifftrtmnt to "public" as "informix";
grant delete on "informix".vw_tarifftrtmnt to "public" as "informix";
grant select on "informix".vw_search_criteria to "public" as "informix";
grant select on "informix".vw_claim_type to "public" as "informix";
grant update on "informix".vw_claim_type to "public" as "informix";
grant insert on "informix".vw_claim_type to "public" as "informix";
grant delete on "informix".vw_claim_type to "public" as "informix";
grant select on "informix".vw_user_cltacct to "public" as "informix";
grant select on "informix".vw_as_accounted to "public" as "informix";
