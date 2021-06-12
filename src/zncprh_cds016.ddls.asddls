@AbapCatalog.sqlViewName: 'ZNCPRH_DDL016'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Unit Conversion Fonks.'
define view zncprh_cds016 as select distinct from mara as a {
        key a.matnr as material,
            a.brgew as MatQuantity,
            a.meins as SourceUnit,
//            a.geewi as 
            unit_conversion( quantity => brgew, source_unit => meins, 
                             target_unit =>cast( 'LB'  as gewei  ) )
            as result1 
} where matnr = '000000000000000073'
