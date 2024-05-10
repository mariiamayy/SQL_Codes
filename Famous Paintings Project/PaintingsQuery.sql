/* Using SQL queries to analyze and answer questions about 
famous paintings and artists dataset. 

Skills mostly used: 
-Joins
-Subqueries
-Window Functions 
- Aggregate Functions
-CTEs

*/

Select * from artist --421
Select * from canvas_size --200
Select * from image_link --14,775
Select * from museum --57
Select * from museum_hours --351
Select * from product_size --131,894
Select * from subject --6,771
Select * from work --14,776


-- 1) Which paintings are not displayed in any museum?
select * from work where museum_id is null

-- 2) Are there any museums without any paintings?
select * from museum m
	where not exists (select * from work w
					 where w.museum_id=m.museum_id)

-- 3) How many paintings have a sale price more than their regular price?
Select * from product_size where sale_price > regular_price

-- 4) Which paintings have a sale price that is less than 50% of its regular price?
Select * from product_size p where sale_price < (regular_price*0.5)

select work_id, name  from work w where exists
(Select * from product_size p where sale_price < (regular_price*0.5)
and w.work_id=p.work_id) 

--OR
SELECT w.work_id, w.name, p.sale_price, regular_price
FROM work w 
JOIN product_size p ON w.work_id = p.work_id 
WHERE p.sale_price < (p.regular_price * 0.5)

--5) Which canvas size costs the most?
select cs.label as canva, ps.sale_price
	from (select *
		  , rank() over(order by sale_price desc) as rnk 
		  from product_size) ps
	join canvas_size cs on cs.size_id=ps.size_id
	where ps.rnk=1

-- 6) Identify the museums with invalid city information in the given dataset
select * from museum 
	where city like '[0-9]%'

-- 7) What are the top 10 most famous painting subjects? 
select * 
	from (
		select s.subject, count(1) as no_of_paintings
		,rank() over(order by count(1) desc) as ranking
		from work w
		join subject s on s.work_id=w.work_id
		group by s.subject ) x
	where ranking <= 10

-- 8) Which  museums are open on both Friday and Saturday?	
select distinct m.name as museum_name, m.city, m.state,m.country
from museum m
join museum_hours h on m.museum_id=h.museum_id
where day='Friday'
and exists (select 1 from museum_hours h2 
where h2.museum_id=h.museum_id 
and h2.day='Saturday')

-- 9) How many museums are open everyday?
SELECT COUNT(1)
FROM (
    SELECT museum_id, COUNT(1) AS count
    FROM museum_hours
    GROUP BY museum_id
    HAVING COUNT(1) = 7
) X

--10) Which museum is open for the longest hours during the day? 
--(museum's name, state, hours open and day)
select museum_name,state,day,open_time, close_time, duration
from (select m.name as museum_name, m.state, day, open_time, close_time
, DATEDIFF (hour,open_time,close_time) as duration
, rank() over (order by (DATEDIFF (hour,open_time,close_time)) desc) as rnk
from museum_hours mh
join museum m on m.museum_id=mh.museum_id) x
where x.rnk=1

-- 11) How many museums are present in each country and city?
select country, city, count(museum_id) as number_of_museums from museum 
group by country, city 
order by count(museum_id) desc

-- 12) Which are the top 5 most popular museum? (Most number of paintings)select m.name as museum,x.num_of_painintgs
from (select m.museum_id, count(work_id) as num_of_painintgs,
rank() over(order by count(work_id) desc) as rnk
from work w
join museum m on m.museum_id=w.museum_id
group by m.museum_id) x
join museum m on m.museum_id=x.museum_id
where x.rnk<=5

-- 13) Who are the top 5 most popular artist? (Most number of paintings done by an artist)select a.full_name as artist, x.number_of_paintingsfrom ( select a.artist_id, count(w.work_id)as number_of_paintings, rank () over (order by count(w.work_id) desc ) as rnk from work wjoin artist a on a.artist_id=w.artist_idgroup by a.artist_id) xjoin artist a on a.artist_id=x.artist_idwhere rnk<=5-- 14) What are the 3 least popular canvas sizes?select label,ranking,no_of_paintings
from (
select cs.size_id,cs.label,count(1) as no_of_paintings, 
dense_rank() over(order by count(1) ) as ranking
from work w
join product_size ps on ps.work_id=w.work_id
join canvas_size cs on cs.size_id= ps.size_id
group by cs.size_id,cs.label) x
where x.ranking<=3

-- 15) Which museum has the most number of most popular painting styles?with pop_style as 
(select style
,rank() over(order by count(1) desc) as rnk
from work
group by style),
cte as
(select w.museum_id,m.name as museum_name,ps.style, count(1) as num_of_paintings
,rank() over(order by count(1) desc) as rnk
from work w
join museum m on m.museum_id=w.museum_id
join pop_style ps on ps.style = w.style
where w.museum_id is not null
and ps.rnk=1
group by w.museum_id, m.name,ps.style)
select museum_name,style,num_of_paintings
from cte 
where rnk=1

-- 16) Which artists have paintings displayed in multiple countries?
with cte as
(select distinct a.full_name as artist
,m.country
from work w
join artist a on a.artist_id=w.artist_id
join museum m on m.museum_id=w.museum_id)

select artist,count(1) as num_of_countries
from cte
group by artist
having count(1)>1
order by num_of_countries desc

-- 17) Which country has the 5th highest number of paintings?
with cte as 
(select m.country, count(1) as num_of_Paintings, rank() over(order by count(1) desc) as rnk
from work w
join museum m on m.museum_id=w.museum_id
group by m.country)
select country, num_of_Paintings
from cte 
where rnk=5

-- 18) What are the 3 most popular and 3 least popular painting styles?
with cte as 
(select style, count(1) as cnt, rank() over(order by count(1) desc) rnk, count(1) over() as num_of_records
from work
where style is not null
group by style)
select style, case when rnk <=3 then 'Most Popular' else 'Least Popular' end as remarks 
from cte
where rnk <=3
or rnk > num_of_records - 3

-- 19) Which artist has the most number of Portraits paintings outside USA?
-- (Artist name,  number of paintings and the artist's nationality)
select full_name as artist_name, nationality, num_of_paintings
from (select a.full_name, a.nationality, 
count(1) as num_of_paintings, rank() over(order by count(1) desc) as rnk
from work w
join artist a on a.artist_id=w.artist_id
join subject s on s.work_id=w.work_id
join museum m on m.museum_id=w.museum_id
where s.subject='Portraits'
and m.country != 'USA'
group by a.full_name, a.nationality) x
where rnk=1;	
