@AbapCatalog.sqlViewName: 'ZNCPRH_DDL009'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Distinct'
define view zncprh_cds009 as select distinct from mara
   inner join lips on mara.matnr = lips.matnr
     {
        mara.matnr as mara,
        lips.matnr as lips
     }
