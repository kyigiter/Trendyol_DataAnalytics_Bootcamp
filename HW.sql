--Soru 1 : Promosyon çıkılmış fakat hiç satılmamış ürünleri tespit edebilir miyiz?

with notsold as(
select a.v2ProductName
from `data-to-insights.ecommerce.web_analytics` wa 
    inner join (select distinct visitId, v2ProductName from `data-to-insights.ecommerce.all_sessions` where eCommerceAction_type != '6') a on a.visitId=wa.visitId 
    cross join unnest(wa.hits) h 
    cross join unnest(h.promotion) p
where p.promoName is not null),

sold as(
select a.v2ProductName
from `data-to-insights.ecommerce.web_analytics` wa 
    inner join (select distinct visitId, v2ProductName from `data-to-insights.ecommerce.all_sessions` where eCommerceAction_type = '6') a on a.visitId=wa.visitId 
    cross join unnest(wa.hits) h 
    cross join unnest(h.promotion) p
where p.promoName is not null)

select v2ProductName as notsold from notsold except distinct select v2ProductName from sold

--Soru 2: Mart, nisan, mayıs aylarında ziyaretçilerin en çok görüntülediği fakat satın alınmamış ürünlere ihtiyacımız var. Her ayın top 10 ürününü gösterebilir misiniz? (Tarih yıl - ay olarak gösterilmeli.)Mart, nisan, mayıs aylarında ziyaretçilerin en çok görüntülediği fakat satın alınmamış ürünlere ihtiyacımız var. Her ayın top 10 ürününü gösterebilir misiniz? (Tarih yıl - ay olarak gösterilmeli.)

select * from 

(with notsold as (SELECT EXTRACT(year from PARSE_DATE('%Y%m%d',a.date)) as year, EXTRACT(month from PARSE_DATE('%Y%m%d',a.date)) as month, count(pageviews) as pw, v2ProductName 
from `data-to-insights.ecommerce.all_sessions` as a 
where EXTRACT(month from PARSE_DATE('%Y%m%d',a.date)) in (3,4,5) and eCommerceAction_type != '6'
group by 1, 2, 4),

sold as (SELECT EXTRACT(year from PARSE_DATE('%Y%m%d',a.date)) as year, EXTRACT(month from PARSE_DATE('%Y%m%d',a.date)) as month, count(pageviews) as pw, v2ProductName 
from `data-to-insights.ecommerce.all_sessions` as a 
where EXTRACT(month from PARSE_DATE('%Y%m%d',a.date)) in (3,4,5) and eCommerceAction_type = '6'
group by 1, 2, 4)

select ns.year, ns.month, ns.pw as pageview, row_number() over(partition by ns.month order by ns.pw desc) as top, ns.v2ProductName as notsoldproductname 
from notsold ns left outer join sold s on ns.v2ProductName = s.v2ProductName
where s.v2ProductName is null
group by 1, 2, 3, 5 
order by 1, 2 desc, 3 desc)

where top < 11 
order by 1, 2, 3 desc,4 

--Soru 3: E ticaret sitemiz için günün bölümlerinde, en fazla ilgi gören kategorileri öğrenmek istiyoruz.

select * from
(select  DayPart, Category, Pageviews, row_number() over(partition by DayPart order by Pageviews desc) as Top from 

(with x as (select a.v2ProductCategory as Category, 
count(a.pageviews) as Pageviews, h.hour as Hour
from `data-to-insights.ecommerce.web_analytics` wa 
    inner join (select visitId, v2ProductCategory, pageviews from `data-to-insights.ecommerce.all_sessions`) a on a.visitId=wa.visitId 
    cross join unnest(wa.hits) h 
    group by 1,3
    order by 2 desc)
select *, case 
    when Hour between 0 and 8 then 'daypart1' 
    when Hour  between 8 and 18 then 'daypart2'
    when Hour between 18 and 23 then 'daypart3'
    end as DayPart
from x where Category !='(not set)'))

where top < 31
group by 1,2, 3,4
order by 1,3 desc,4
