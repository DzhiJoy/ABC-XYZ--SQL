-- MAU, DAU, WAU
-- sticky factor

select *
from userentry u 

--DAU

with a as (
	select 
		to_char(entry_at, 'YYYY-MM-DD') as ymd,--сначала уберём время из первой колонки
		count(distinct user_id) as cnt
	from userentry u 
	where to_char(entry_at, 'YYYY-MM-DD') >= '2021-11-20'
	group by ymd
	limit 90 -- запоследние 90 дней
)
select avg(cnt) as dau --посчитаем DAU
from a

--WAU

with a as (
	select 
		to_char(entry_at, 'YYYY-WW') as yw,--WW-это номер недели в году-такой модификатор
		count(distinct user_id) as cnt
	from userentry u 
	group by yw
	having count(distinct to_char(entry_at, 'YYYY-MM-DD')) >= 6 --чтобы учитывались все дни недели, а не попался просто один какой-то
)--метрика сразу возрасла на 50%
select avg(cnt) as wau --посчитаем WAU
from a

--MAU

with a as (
	select 
		to_char(entry_at, 'YYYY-MM') as ym,
		count(distinct user_id) as cnt
	from userentry u 
	group by ym
	having count(distinct to_char(entry_at, 'YYYY-MM-DD')) >= 25
)
select avg(cnt) as mau --посчитаем MAU
from a

--sticky factor-коэффициент липучести,обычно рассчитывается как отношение DAU к MAU

with at as (
	select 
		to_char(entry_at, 'YYYY-MM-DD') as ymd,
		count(distinct user_id) as cnt_dau
	from userentry u 
	where to_char(entry_at, 'YYYY-MM-DD') >= '2021-11-20'
	group by ymd
),
bt as (
	select 
		to_char(entry_at, 'YYYY-MM') as ym,
		count(distinct user_id) as cnt_mau
	from userentry u 
	group by ym
	having count(distinct to_char(entry_at, 'YYYY-MM-DD')) >= 25
)
select round(avg(cnt_dau) *100.00 / avg(cnt_mau), 2) as sticky_factor
from at, bt




