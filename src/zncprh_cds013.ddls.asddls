@AbapCatalog.sqlViewName: 'ZNCPRH_DDL013'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Zaman-saat Fonks.'
define view zncprh_cds013 as select from 
demo_expressions 
{ 
id, 
tims1 as time1, 
tims_is_valid(tims1) as valid1 
}
//
//TIMS_IS_VALID:  TIMS_IS_VALID fonksiyonu, 
//   zamanın (belirtilmişse) HHMMSS biçiminde geçerli bir zaman içerip içermediğini belirler. 
//Parametre, önceden tanımlanmış TIMS veri tipine sahip olmalıdır.
//Sonuç INT4 veri tipine sahiptir. Geçerli bir Time 1 değerini verir ve
//   diğer tüm giriş değerleri (boş değer dahil) 0 değerini verir.
