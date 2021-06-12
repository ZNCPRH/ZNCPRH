@AbapCatalog.sqlViewName: 'ZNCPRH_DDL017'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Currency Convers.'

define view zncprh_cds017 
//with parameters p_to_curr : abap.cuky( 5 ),
//                p_conv_date : abap.dats
as select distinct from sflight as s {

key s.carrid,
key s.connid,
key s.fldate,
    s.price,
    s.currency,
    
    currency_conversion( amount => s.price,
                         source_currency => s.currency, 
                         target_currency => cast( 'USD' as abap.cuky( 5 ) ), 
                         exchange_rate_date => cast( $session.system_date as abap.dats ) ) as convprice
    
} 
