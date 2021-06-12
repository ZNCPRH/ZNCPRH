@AbapCatalog.sqlViewName: 'ZNCPRH_DDL012'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Tarih Fonksiyonlari'
define view zncprh_cds012 with parameters p_add_days  : abap.int4,  
                 p_add_months: abap.int4,
                 @Environment.systemField: #SYSTEM_DATE
                 p_curr_date : abap.dats 
 as select from sflight as a {
     key a.carrid as FlgId,
     key a.connid as FlgConnId,
     key a.fldate as FlgDate,
     dats_add_days     (a.fldate, :p_add_days  , 'INITIAL') as Added_DT,
     dats_add_months   (a.fldate, :p_add_months, 'NULL'   ) as Added_MT,
     dats_days_between (a.fldate, $parameters.p_curr_date ) as Days_BTW,
     dats_is_valid     (a.fldate)                           as Is_Valid                               
 }
