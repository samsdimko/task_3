--Вывести количество фильмов в каждой категории, отсортировать по убыванию.
select category.name, count(*) from film_category
inner join category on film_category.category_id = category.category_id 
group by category.name
order by category.name desc;

--Вывести 10 актеров, чьи фильмы большего всего арендовали, отсортировать по убыванию.
select a.first_name, a.last_name, count(*) as count_rents from actor a 
inner join film_actor fa ON a.actor_id = fa.actor_id
inner join film f on f.film_id = fa.film_id 
inner join inventory i on i.film_id = f.film_id 
inner join rental r on r.inventory_id = i.inventory_id
group by a.first_name, a.last_name
order by count_rents desc 
limit 10;

--Вывести категорию фильмов, на которую потратили больше всего денег.
select c."name", sum(replacement_cost) from category c 
inner join film_category fc on c.category_id = fc.category_id 
inner join film f on f.film_id = fc.film_id
group by c."name"
order by sum(replacement_cost) desc limit 1; 

--Вывести названия фильмов, которых нет в inventory. Написать запрос без использования оператора IN.
select f.title from film f left join inventory i on f.film_id = i.film_id
where i.film_id is null;

--Вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”. Если у нескольких актеров одинаковое кол-во фильмов, вывести всех.
select first_name, last_name, count_in_film
from 
(
select a.first_name, a.last_name, count(*) as count_in_film,
dense_rank() over (order by count(*) desc) as dr
from actor a 
inner join film_actor fa on fa.actor_id = a.actor_id 
inner join film f on f.film_id = fa.film_id 
inner join film_category fc on f.film_id = fc.film_id 
inner join category c on fc.category_id = c.category_id 
where c."name" = 'Children' 
group by a.first_name, a.last_name
) as inn
where inn.dr < 4;

--Вывести города с количеством активных и неактивных клиентов (активный — customer.active = 1). Отсортировать по количеству неактивных клиентов по убыванию.
select c2.city, sum(c.active) as active, count(*)-sum(c.active) as disactive from customer c 
inner join address a on c.address_id = a.address_id 
inner join city c2 on c2.city_id = a.city_id 
group by c2.city
order by disactive desc;

--Вывести категорию фильмов, у которой самое большое кол-во часов суммарной аренды в городах (customer.address_id в этом city),
--и которые начинаются на букву “a”. То же самое сделать для городов в которых есть символ “-”. Написать все в одном запросе.
with popular_category as(
select city, name,
dense_rank() over (partition by c3.city order by sum(r.return_date - r.rental_date) desc) as dr
from category c
inner join film_category fc on fc.category_id = c.category_id 
inner join film f on f.film_id = fc.film_id 
inner join inventory i on f.film_id = i.film_id
inner join customer c2 on c2.store_id = i.store_id 
inner join rental r on r.customer_id = c2.customer_id 
inner join address a on a.address_id = c2.address_id 
inner join city c3 on c3.city_id = a.city_id 
where c."name" like 'A%' and city like '%-%'
group by city, name
)
select city, name 
from popular_category 
where dr = 1;
