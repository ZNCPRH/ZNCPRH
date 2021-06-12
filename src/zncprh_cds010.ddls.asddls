@AbapCatalog.sqlViewName: 'ZNCPRH_DDL010'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Case-When'
define view zncprh_cds010 as select from adrc {
        addrnumber,
        sort1,
        mc_name1,
        city1,
        mc_city1,
        case when sort1 = '' and mc_name1 != '' then mc_name1
          when sort1!= '' and mc_name1 = '' then sort1
          else sort1 end as adres,
        case when city1 = '' and mc_city1 != '' then mc_name1
          when city1 != '' and mc_city1 = '' then city1
          else city1 end as sehir
            }
