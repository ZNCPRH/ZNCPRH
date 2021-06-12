@AbapCatalog.sqlViewName: 'ZNCPRH_DDL014'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Timestamp Fonks.'
@ObjectModel.semanticKey :['ID']
@AbapCatalog.preserveKey: true
define view zncprh_cds014 as select from 
demo_expressions 
{ 
   key id  as id, 
    timestamp1 as timestamp1, 
    tstmp_is_valid(timestamp1) as valid1, 
    tstmp_seconds_between( 
    tstmp_current_utctimestamp(), 
    tstmp_add_seconds( 
    timestamp1, 
    cast( num1 as abap.dec(15,0) ), 
          'FAIL'), 
          'FAIL') as difference ,
     num1
}       where id = '0'


//TSTMP_IS_VALID: TSTMP_IS_VALID fonksiyonu, tstmp'nin (belirtilmişse) YYYYMMDDHHMMSS biçiminde geçerli bir time stamp içerip içermediğini belirler.
//Parametrenin dahili veri tipi DEC, uzunluğu 15 ve ondalık basamak içermemelidir. 
//Sonuç INT4 veri tipine sahiptir. 
//Geçerli bir time stamp 1 değerini verir ve diğer tüm giriş değerleri (boş değer de dahil olmak üzere) 0 değerini üretir.

//

//TSTMP_CURRENT_UTCTIMESTAMP: TSTMP_CURRENT_UTCTIMESTAMP fonksiyonu POSIX standardına uygun bir UTC timestamp döndürür.
//Sonuç, DEC veri tipinde, uzunluğu 15 ve ondalık basamaksızdır.
//UTC timestamp, veritabanı sunucusundaki saatten oluşturulur.
//ABAP'taki time stamp GET_TIME_STAMP 

//

//TSTMP_SECONDS_BETWEEN(tstmp1,tstmp2,on_error):  TSTMP_SECONDS_BETWEEN fonksiyonu, belirtilen iki time stamp, tstmp1 ve tstmp2 arasındaki farkı saniye cinsinden hesaplar.
//Parametrenin veri türü DEC 15 uzunluğunda ve ondalık basamak içermemeli ve YYYYMMDDHHMMSS biçiminde geçerli time stamp içermelidir. 
//Eğer tstmp2, tstmp1'den büyükse, sonuç pozitiftir. Ters durumda, negatif.

//

//TSTMP_ADD_SECONDS(tstmp,seconds,on_error):  TSTMP_ADD_SECONDS fonksiyonu, tstmp time stamp saniye saniye ekler.
// Parametre tstmp, 15 uzunluklu ve ondalık basamak içermeyen  veri tipi DEC'ye sahip olmalı ve YYYYMMDDHHMMSS biçiminde geçerli bir time stamp içermelidir. 
// Parametre Seconds ayrıca veri türü DEC, uzunluğu 15 ve ondalık basamak içermemelidir.
// Negatif değerler çıkartılır. Sonuç geçersizse, bir hata oluşur.
