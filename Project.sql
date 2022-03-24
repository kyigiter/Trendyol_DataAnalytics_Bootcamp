--Soru 1: Tarih 1 Haziran 2020, Covid-19 yükselişte ve eve sipariş pazarının büyüyeceğini düşünüyorsun. 
--Trendyol olarak yerel market teslimat pazarına girmeyi planlıyorsun. Pazara giriş için hangi District_ID'yi plot seçerdin?

select t.SHIPMENT_DISTRICT_ID as district_id, count(t.order_parent_id) as total_order, 
sum(t.total_amount) as total_amount, avg(t.total_amount) as average_amount
from `bootcamp-342318.trendyoldata.final_case_transaction` t
where t.Platform = 'Core' and t.order_date < '2020-06-01'
group by 1
order by 2 desc      

--Soru 2: Tarih 1 Eylül 2020, Trendyol "Trendyol Go" adı ile yerel market teslimat işine girdi. 
--Trendyol Go'nun büyümesini takip etmek istiyorsun. Hangi metriklere bakarsın? Var olan datayla bir rapor hazırlar mısın?

--“Trendyol Go” teslimat işine girdiğinden itibaren haftalık olarak yeni kazanılan Grocery alışverişi yapmış müşteriler:
select extract(week from u.create_date) as week,
count(u.user_id) as total_new_user
from `bootcamp-342318.trendyoldata.final_case_users` u 
inner join  `bootcamp-342318.trendyoldata.final_case_transaction` t 
on t.user_id=u.user_id
where platform = 'Grocery' and u.create_date 
between '2020-06-01' and '2020-09-01' 
group by 1
order by 1

--Eskiden Core platformunda alışveriş yapmış müşteriler arasında Grocery’de alışveriş yapan müşteri sayısı: 
with Core_U as (select distinct user_id as core_user, order_date
from `bootcamp-342318.trendyoldata.final_case_transaction` t 
where order_date < '2020-06-01' and Platform = 'Core'),

Grocery_U as (select distinct user_id as grocery_user, order_date
from `bootcamp-342318.trendyoldata.final_case_transaction` t 
where t.order_date between '2020-06-01' and '2020-09-01' and Platform = 'Grocery')

select count(distinct core_user) as core_user,extract(week from g.order_date) as week
from Core_U as c
right join Grocery_U as g on g.grocery_user=c.core_user
where c.core_user is not null
group by 2
order by 2

--Kullanıcı başına ortalama sipariş tutarının haftalık değişimi:
select sum(total_amount) / count (distinct user_id) as average_order, extract(week from order_date) as week
from `bootcamp-342318.trendyoldata.final_case_transaction` t 
where order_date between '2020-06-01' and '2020-09-01' and platform = 'Grocery'
group by 2
order by 2

--Uzun süredir inaktif olan ancak Trendyol Go ile birlikte geri kazanılan kullanıcı sayısı:
with inactive as (select distinct user_id 
as inactive_user
from (select distinct user_id, max(t.order_date) 
as last_order_date 
from `bootcamp-342318.trendyoldata.final_case_transaction` t
group by 1)
where last_order_date < '2020-01-01'),

activated as (select distinct user_id as activated_user,
from `bootcamp-342318.trendyoldata.final_case_transaction` t 
where order_date between '2020-06-01' and '2020-09-01' 
and Platform = 'Grocery')

select count(distinct inactive_user) as activated_user 
from inactive as i
left join activated as a on i.inactive_user=a.activated_user
where i.inactive_user is not null

--Soru 3 : Tarih 1 Temmuz 2021, Trendyol Go 1 yılı geride bıraktı. 2.000 yeni kullanıcı edinme hedefin için 50.000 TL bütçen var. 
--Kullanıcı başına 25 TL'lik kampanya yapmayı planlıyorsun. Geçmiş kampanya verileri kampanya kullanım oranının %10 olduğunu gösteriyor. 
--Trendyol Core müşterilerinden hangilerini hedeflerdin?

with Core_U as (select distinct user_id as core_user,
business_unit_name, total_amount
from `bootcamp-342318.trendyoldata.final_case_transaction` t
where order_date between '2021-04-01' and '2021-07-01' and Platform = 'Core'),

Grocery_U as (select distinct user_id as grocery_user,
business_unit_name, total_amount
from `bootcamp-342318.trendyoldata.final_case_transaction` t
where order_date between '2020-01-01' and '2021-07-01' and Platform = 'Grocery')

select distinct core_user as core_user, 
c.business_unit_name as category, sum(c.total_amount) as total_amount from Core_U as c
left join Grocery_U as g on g.grocery_user=c.core_user
where g.grocery_user is null and c.business_unit_name in
('Gıda ve İçecek', 'Ev Bakım ve Temizlik', 'Bebek Bezi & Mendil')
group by 1,2
order by 3 desc

--Soru 4 :Trendyol GO’da “2 al 1 öde” kampanyası için ürünleri belirleyebilir miyiz?

select order_parent_id, product_content_id, count(product_content_id) as count
from `bootcamp-342318.trendyoldata.final_case_transaction` t
where order_date between '2021-06-01' and '2021-07-01' and platform = 'Grocery'
group by 1,2
having count(product_content_id)=2



