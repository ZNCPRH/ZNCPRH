@AbapCatalog.sqlViewName: 'ZNCPRH_DDL007'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'where-between'
define view zncprh_cds007 as select from mara
{
matnr ,
aenam
} where matnr between '000000000000000001' and '000000000000000055'
