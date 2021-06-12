@AbapCatalog.sqlViewName: 'ZNCPRH_DDL001'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Personel Genel Bilgileri'
define view ZNCPRH_CD001 as select distinct from pa0000 as p0
    inner join             pa0001 as p1 on(
      p0.pernr     =  p1.pernr
      and p1.endda >= $session.system_date
      and p0.massn <> '10'
      and p0.endda >= $session.system_date
    )
    left outer to one join t001   as t1 on(
      t1.bukrs = p1.bukrs
    )
    left outer to one join t503t  as t2 on ( t2.sprsl = 'T' and t2.persk = p1.persk )
    left outer to one join pa0002 as p2 on ( p2.pernr = p0.pernr and p2.endda >= $session.system_date )
    left outer to one join pa0770 as p3 on ( p3.pernr = p0.pernr and p3.ictyp = '01' and p3.endda >= $session.system_date )
    {

  key p1.pernr,
      p1.bukrs,
      p1.ename,
      t1.butxt,
      p2.vorna ,
      p2.nachn ,
      p1.persk ,
      t2.ptext ,
      p3.merni
      }
