@AbapCatalog.sqlViewName: 'ZNCPRH_DDL004'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'min-max with group by'
define view zncprh_cds004 as select from bseg 
{
belnr,
min(bseg.wrbtr) as min_deger,
max(bseg.wrbtr) as max_deger

} group by belnr
//her belnr nin en b -k alır


//define view zncprh_cds004 as select from bseg{
//min(bseg.wrbtr) as min_deger, // en kucuk değer
//max(bseg.wrbtr) as max_deger // en buyuk değer
//}
// "tek deger doner


//define view ZP1388_CDS006 as select min(wrbtr) as min_alias from bseg

//define view ZP1388_CDS006 as select max(wrbtr) as max_alias from bseg
