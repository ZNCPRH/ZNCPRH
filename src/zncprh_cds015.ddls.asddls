@AbapCatalog.sqlViewName: 'ZNCPRH_DDL015'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Time Zone Fonks.'
define view zncprh_cds015 as select from 
    demo_expressions 
    { 
      tstmp_current_utctimestamp() as tstmp, 
      tstmp_to_dats( tstmp_current_utctimestamp(), 
                     abap_system_timezone( $session.client,'NULL' ), 
                     $session.client, 
                     'NULL' )      as dat, 
      tstmp_to_tims( tstmp_current_utctimestamp(), 
                     abap_system_timezone( $session.client,'NULL' ), 
                     $session.client, 
                     'NULL' )      as tim, 
      dats_tims_to_tstmp( dats1, 
                          tims1, 
                          abap_system_timezone( $session.client,'NULL' ), 
                          $session.client, 
                         'NULL' )  as dat_tim , 
                         
      dats_tims_to_tstmp( tstmp_to_dats( tstmp_current_utctimestamp(), 
                     abap_system_timezone( $session.client,'NULL' ), 
                     $session.client, 
                     'NULL' )      ,
                            tstmp_to_tims( tstmp_current_utctimestamp(), 
                     abap_system_timezone( $session.client,'NULL' ), 
                     $session.client, 
                     'NULL' ), 
                          abap_system_timezone( $session.client,'NULL' ), 
                          $session.client, 
                         'NULL' )  as dat_tim_last                     
     
     
     }    where id = 'X'
     
     
     
//TSTMP_TO_DATS(tstmp,tzone,clnt,on_error):   TSTMP_TO_DATS  fonksiyonu tstmp argumanını bir tarih biçimine çevirir.
//tstmp parametresi, 15 veri uzunluğuna sahip ve ondalık basamak içermeyen DEC veri tipine sahip olmalı ve YYYYMMDDHHMMSS formatında geçerli bir time stamp içermelidir. 
//tzone, uzunluğu 6 olan ve geçerli bir zaman dilimi içeren CHAR türünde gerçek bir parametre bekler.
//
//On_error parametresi hata işlemeyi kontrol eder. Önceden tanımlanmış CHAR(10) veri tipine sahip olmalı ve aşağıdaki değerlerden birine sahip olmalıdır:
//
//"FAIL" (bir hata döndürür)
//"NULL" (bir hata null değerini döndürür)
//"INITIAL" (bir hata initial değerini döndürür).


//


//TSTMP_TO_TIMS(tstmp,tzone,clnt,on_error) :  TSTMP_TO_TIMS fonksiyonu, fonksiyonu tstmp argumanını bir tims  biçimine çevirir.
//Parametrelerin tanımları TSTMP_TO_DATS fonksiyonu ile aynıdır.


//


//DATS_TIMS_TO_TSTMP(date,time,tzone,clnt,on_error):  DATS_TIMS_TO_TSTMP fonksiyonu bir tarih biçimini tstmp biçimine dönüştürür.
//Parametrelerin tanımları TSTMP_TO_DATS fonksiyonu ile aynıdır.
     
     
     
     
     
     
     
     
