@AbapCatalog.sqlViewName: 'ZNCPRH_DDL008'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'COALESCE null kontrolü'
define view zncprh_cds008 as select from bseg
left outer join bsec on bseg.belnr = bsec.belnr
{
bseg.belnr as ilk,
bseg.bewar,
bseg.bdiff,
//bsec.belnr
coalesce(bsec.belnr,'null') as sonuc
}

//define view zncprh_cds008 as select coalesce(bsec.belnr,'null') as sonuc from bseg
//left outer join bsec on bseg.belnr = bsec.belnr
