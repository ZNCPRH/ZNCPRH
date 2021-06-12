@AbapCatalog.sqlViewName: 'ZNCPRH_DDL002'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'String Fonksiyonları'
define view zncprh_cds002 as select from adrc{
    addrnumber,
    
    length(addrnumber)   as r_length, //Karakterin boyutu
    
    instr( name1,'tay')  as r_instr, // Karakterin pozisyonu
    
    
    concat(name1, city1) as r_concat, // Alan Birleştirme
    concat_with_space(name1, city1,10) as r_concat_with_space,
        // Alan Birleştirme 10 karakter boşluk bırakarak
        
        
    left(name1,3)  as r_left, //soldan üç karakterden sonrasını al
    right(name1,3) as r_right, // sağdan 3 karakter sonrasını al
    
    
    lpad(name1, 10,'x') as r_lpad,// alan 10 karakter olana kadara sol tarafına X ekle
    rpad(name1, 10,'y') as r_rpad, // alan 10 karakter olana kadara sağ tarafına Y ekle
    
    
    ltrim(name1, 'D') as r_ltrim, // soldan boslukları ve verilen karakteri kaldır
    rtrim(name1, 't') as r_rtrim, // sağdan boslukları ve verilen karakteri kaldır
    
    
    replace(name1, 'Or', 'Xx' ) as r_replace, // var olan karakteri verilen ile değiştirme.
    
    substring(name1, 1, 3 ) as r_substring , //belirtilen karakter kadar al
    
    
    upper (name1 ) as buyuk, //Alanları buyuk harfle yazar
    lower(name1) as kucuk //Alanları kucuk harfle yazar
    
    
}
