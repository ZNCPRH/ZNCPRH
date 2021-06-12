@AbapCatalog.sqlViewName: 'ZNCPRH_DDL003'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Numeric Fonks.'
define view zncprh_cds003 as select from  bseg
{
    bukrs,
    belnr,
    gjahr,
    buzei,
    

    abs (wrbtr) as r_abs,// INT1, INT2, INT4, INT8, DEC, CURR, QUAN, FLTP
    // mutlak değer alır.
    
    
    ceil (wrbtr) as r_ceil,// INT1, INT2, INT4, INT8, DEC, CURR, QUAN, FLTP
    // değerden yukarı yuvarlar
    
    
    floor(wrbtr) as r_floor, // INT1, INT2, INT4, INT8, DEC, CURR, QUAN
    //değerden aşagı yuvarlar
    
    
    div (wrbtr,3) as r_div, // INT1, INT2, INT4, INT8, DEC, CURR, QUAN
    // tam sayı kısmı.
    // VERİLEN DEGER TAM SAYI SEKLINDE BOLUM YAPAR.
    
    
    division(wrbtr,5,3) as r_division,// INT1, INT2, INT4, INT8, DEC, CURR, QUAN
    // ilk deger bolme ikinci deger virgulden sonraki degeri ifade eder
    
    
    round(wrbtr,1) as r_round // INT1, INT2, INT4, INT8, DEC, CURR, QUAN
    // - ve + deger alabılır.
    // virgülden sonrakı deger kadara yuvarlama yapar round( wrbtr, -1) as r_round // eğer deger negatifse virgulden onceki degeri yuvarlar
}
