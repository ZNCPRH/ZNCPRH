*&---------------------------------------------------------------------*
*& Report ZNCPRH_P251
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p251.

PARAMETERS : p_adday  TYPE int4,
             p_admnth TYPE int4,
             p_sydat  TYPE sy-datum DEFAULT sy-datum.

SELECT * FROM zncprh_cds012( p_add_days = 3 ,
                             p_add_months = 1 ,
                             p_curr_date = @sy-datum )
         INTO TABLE @DATA(lt_tab).

BREAK p1362.

*DATS_IS_VALID: DATS_IS_VALID fonksiyonu, tarihin (belirtilmişse) YYYYMMDD biçiminde geçerli bir tarih içerip içermediğini belirler. Gerçek parametrenin önceden tanımlanmış veri türü DATS olması gerekir. Sonuç INT4 veri tipine sahiptir. Geçerli bir tarih
*1 değerini verir ve diğer tüm giriş değerleri (boş değer dahil) 0 değerini verir.

*--------------------------------------------------------------------*


*DATS_DAYS_BETWEEN: DATS_DAYS_BETWEEN fonksiyonu, belirtilen tarihler ve tarih1 ile tarih2 arasındaki iki günü arasındaki farkı hesaplar. Parametreler önceden tanımlanmış veri türü DATS'a sahip olmalı ve YYYYMMDD biçiminde geçerli bir tarih içermelidir.
*Belirtilen geçersiz tarihler sıfırlanır veya hesaplamadan önce "00010101" değerine ayarlanır. Sonuç INT4 veri tipine sahiptir. Eğer tarih2, tarih1'den büyükse, sonuç pozitiftir. Ters durumda, negatif.

*--------------------------------------------------------------------*


*DATS_ADD_DAYS(date, days, on_error): DATS_ADD_DAYS fonksiyonu belirtilen gün tarihine gün günlerini ekler. Parametre DATE önceden tanımlanmış veri türü DATS'a sahip olmalı ve YYYYMMDD formatında geçerli bir tarih içermelidir. Belirtilen geçersiz tarih
*başlangıç durumuna getirilir veya hesaplamadan önce "00010101" değerine ayarlanır. Parametre DAYS, INT4 önceden tanımlanmış veri tipine sahip olmalıdır. On_error parametresi, char ve 10 karakter uzunluğuna sahip olmalı ve aşağıdaki değerlerden birine
*sahip olmalıdır:
*"FAIL" (bir hata yaratır)
*"NULL" (bir hata null değerini döndürür)
*"INITIAL" (bir hata başlangıç değerini döndürür)
*" UNCHANGED " (bir hata tarihin değiştirilmemiş değerini döndürür)
*Format b üyük / küçük harfe duyarlı değildir. Yanlış belirtilen herhangi bir değer Hata oluşturur.
*Sonuç DATS veri türündedir. DAYS pozitifse, gün sayısı tarihe eklenir. Diğer durumlarda, gün sayısı çıkarılır. Hesaplama geçersiz bir tarih veriyorsa, hata on_error'da belirtildiği şekilde ele alınır.
*

*--------------------------------------------------------------------*


*DATS_ ADD_MONTHS: DATS ADD_MONTHS fonksiyonu, belirtilen bir tarih tarihine aylar ay ekler. Parametre DATE önceden tanımlanmış veri türü DATS'a sahip olmalı ve YYYYMMDD formatında geçerli bir tarih içermelidir. Belirtilen geçersiz tarih başlangıç
*durumuna getirilir veya hesaplamadan önce "00010101" değerine ayarlanır. Parametre DAYS, INT4 önceden tanımlanmış veri tipine sahip olmalıdır. On_error parametresi, char ve 10 karakter uzunluğuna sahip olmalı ve aşağıdaki değerlerden birine sahip
*olmalıdır:
*"FAIL" (bir hata yaratır)
*"NULL" (bir hata null değerini döndürür)
*"INITIAL" (bir hata başlangıç değerini döndürür)
*" UNCHANGED " (bir hata tarihin değiştirilmemiş değerini döndürür).
