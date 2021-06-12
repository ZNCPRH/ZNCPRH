@AbapCatalog.sqlViewName: 'ZNCPRH_DDL005'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'count-avg-sum'

//define view zncprh_cds005 as select count(*) as alias_cout from bseg
//define view zncprh_cds005 as select avg(wrbtr as abap.dec(24,2) ) as alias_avg from bseg
//define view zncprh_cds005 as select sum(wrbtr) as alias_sum from bseg

//define view zncprh_cds005 as select from bseg{
//
//belnr as belge,
////buzei,
//count(*) as sayisi
//} group by belnr

//define view zncprh_cds005 as select from bseg
//{
//belnr as belge,
//avg(wrbtr as abap.dec(24,2)) as avg_kayit
//} group by belnr


define view zncprh_cds005 as select from bseg
{
belnr as belge,
sum(wrbtr) as sum_kayit
} group by belnr
