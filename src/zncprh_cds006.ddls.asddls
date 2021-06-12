@AbapCatalog.sqlViewName: 'ZNCPRH_DDL006'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'group by - having'
//define view zncprh_cds006 as select from bseg
//{
//count(*) as count_kayit
//}
//group by belnr
//having count (*) > 4
//Sql de bir fonksiyondan dönen değere göre koşul ifadesi yazılmak istenirse
//WHERE kullanımı hata verecektir. Bu tür koşul ifadeleri için HAVING kullanılmalıdır.
//HAVING ifadesi eğer kullanılıyorsa GROUP BY ifadesinden sonra yazılmalıdır.
//HAVING ifadesinden sonra WHERE kullanımında olduğu gibi koşul yazılmalıdır



define view zncprh_cds006 as select from mara
inner join lips on mara.matnr = lips.matnr
{
mara.matnr as mara,
lips.matnr as lips
}
group by mara.matnr,lips.matnr
