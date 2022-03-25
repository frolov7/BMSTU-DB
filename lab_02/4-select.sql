--Защита
--вывести название школы и кол-во в ней вакцинированных мальчиков и девочек. Школ 10. Как то выбрать
select count(pupils.id), establishments.address, pupils.gender 
from study.school 
join study.pupils on school.pupils_id = pupils.id 
join study.establishments on school.establishments_id = establishments.id 
where study.pupils.is_vaccinated = true group by (establishments.address, study.pupils.gender) 
limit 10

-- 1. Инструкция SELECT, использующая предикат сравнения
-- Возвращает все уч. заведения, кроме Балашиха
select * from study.establishments
where study.establishments.address <> 'Балашиха';

-- 2. Инструкция SELECT, использующая предикат BETWEEN.
-- Возвращает всех учеников, родившихся в заданных период времени
select * from study.pupils
where study.pupils.birth_date between '1988-02-04' and '1998-02-04';

-- 3. Инструкция SELECT, использующая предикат LIKE.
-- Возвращает всех учеников, имя которых начинается на "Е"
select * from study.pupils
where study.pupils.first_name LIKE 'Е%';

-- 4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом.
-- Возвращает школы, где есть пункт вакцинации
select * from study.school
where school.establishments_id in (select id from study.establishments where is_vaccination_point = true);

-- 5. Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом.
-- возвращает ученика под угрозой, у которых в школе вакцинация обязательна и кол-во зараженных больше 350
select * from study.pupils as cus
where exists(
    select * from study.school
    where cus.id = school.pupils_id
    and school.is_necessarily = true
    and school.infected_amount > 350);

-- 6 Инструкция SELECT, использующая предикат сравнения с квантором
-- Возвращает учеников, которые старше всех сотрудников
select * from study.pupils
where pupils.birth_date < all (select birth_date from study.employee);

-- 7 Инструкция SELECT, использующая агрегатные функции в выражениях столбцов
-- Возвращает максимальное кол-во зараженных, минимальное кол-во зараженных и сумму всех случай заражения
select max(infected_amount), min(infected_amount), sum(infected_amount) from study.school
where school.is_necessarily = true;

-- 8. Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов
-- Возвращает список учеников и максимальное кол-во заражений в его школе
select establishments_id,
       infected_amount,
       (select max(infected_amount) from study.school as i where i.pupils_id = o.pupils_id and i.is_necessarily = true)
from study.school as o;

-- 9. Инструкция SELECT, использующая простое выражение CASE
-- CASE Возвращает "обязательно" и "не обязательно" в зависимости от параметра обязательности вакцинации в школе
select establishments_id,
       infected_amount,
        is_necessarily,
       case when is_necessarily = true then 'обязательно' else 'не обязательно' end
from study.school;

-- 10. Инструкция SELECT, использующая поисковое выражение CASE
-- Возвращает "красная зона" или "зеленая зон" в зависимости от кол-ва заражений
select
       establishments_id,
       infected_amount,
       case when (infected_amount > 350) then 'красная зона' else 'зеленая зона' end
from study.school
where is_necessarily = true;

-- 11. Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT
select * from establishmentses_with_electronic_queue;
drop table establishmentses_with_electronic_queue;
----
select *
into temp establishmentses_with_electronic_queue
from study.establishments
where establishments.is_vaccination_point = true;

-- 12. Инструкция SELECT, использующая вложенные коррелированные подзапросы в качестве производных таблиц в предложении FROM.
-- Возвращает учеников и сколько в его школе зараженных
select id, first_name, last_name, middle_name, limits.total_infected_amount
from study.pupils as pupilss
join (select pupils_id, sum(infected_amount) as total_infected_amount from study.school
      group by pupils_id) as limits on pupilss.id = limits.pupils_id;

-- 13. Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3.
-- Возвращает ученика, у которого в школе больше всего зараженных
select *
from study.pupils
where id = (select pupils_id
            from study.school
            where infected_amount = (select max(infected_amount)
                                  from study.school
                                  where is_necessarily = true));

-- 14. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING.
-- Возвращает количество учеников мужского и женского пола
select gender, count(*)
from study.pupils
group by (gender);

-- 15. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY и предложения HAVING.
-- Возвращает города, в которых квадратура школ больше чем 1000000
select address, sum(square) from study.establishments
group by address
having sum(square) > 1000000;

-- 16. Однострочная инструкция INSERT, выполняющая вставку в таблицу одной строки значений.
-- Выполняет вставку нового заведения
insert into study.establishments (address, creation_date, is_vaccination_point, square, people_count)
values ('Новосибирск', '1990-04-11', true, 5500, 10);
-- Проверка
select * from study.establishments where id = (select max(id) from study.establishments);


-- 17. Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса.
-- Выполняет вставку нового учебного заведения
insert into study.establishments (address, creation_date, is_vaccination_point, square, people_count)
values (
           (

-- Выполняется вставка названия города, в котором больше всего зараженных
-- (в 22 задании данный запрос переписан с помощью with)
select t.address from (select establishments.address, sum(cl.infected_amount) as sum from study.establishments
                       join study.school cl on establishments.id = cl.establishments_id
                       group by (study.establishments.address)) as t
where t.sum = (select max(t.sum) from (select establishments.address, sum(cl.infected_amount) as sum from study.establishments
                       join study.school cl on establishments.id = cl.establishments_id
                       group by (study.establishments.address)) as t)),

'1990-04-11',
true,
5500,
10);
-- Проверка
select * from study.establishments where id = (select max(id) from study.establishments);

-- 18. Простая инструкция UPDATE
-- Меняет
update study.establishments
set is_vaccination_point = true
where study.establishments.id = 1;
-- Проверка
select * from study.establishments where establishments.id = 1;

-- 19. Инструкция UPDATE со скалярным подзапросом в предложении SET
-- Меняет is_vaccination_point на обратную
update study.establishments
set is_vaccination_point = (select not is_vaccination_point from study.establishments where id = 1)
where study.establishments.id = 1;
-- Проверка
select * from study.establishments where establishments.id = 1;

-- 20. Простая инструкция DELETE
-- Подготовка данных
insert into study.establishments (address, creation_date, is_vaccination_point, square, people_count)
values ('Крым', '1990-04-11', true, 4000, 1200);
-- Проверка
select * from study.establishments where address = 'Крым';
-- Удаление
delete from study.establishments where address = 'Лалаленд';

-- 21. Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE
-- Подготовка данных
insert into study.establishments (address, creation_date, is_vaccination_point, square, people_count)
values ('Global, Америка', '1990-04-11', true, 5400, 1025);
insert into study.establishments (address, creation_date, is_vaccination_point, square, people_count)
values ('Global, Европа', '1990-04-11', true, 5004, 1200);
insert into study.establishments (address, creation_date, is_vaccination_point, square, people_count)
values ('Global, Австралия', '1990-04-11', true, 5040, 1300);
-- Проверка
select * from study.establishments where address like 'Global%';
-- Удаление
delete from study.establishments
where id in (select id from study.establishments where address like 'Global%');

-- 22. Инструкция SELECT, использующая простое обобщенное табличное выражение
-- Поиск названия города, в котором больше всего зараженных
-- cts: город и кол-во зараженных
with cts(address, sum) as (
    select t.address, t.sum
    from (select establishments.address, sum(cl.infected_amount) as sum
          from study.establishments
                   join study.school cl on establishments.id = cl.establishments_id
          group by (study.establishments.address)) as t
)
select * from cts where sum = (select max(sum) from cts);

-- 23. Возвращает ученика и кол-во зараженных в его школе
select school.pupils_id,
       school.infected_amount,
       school.is_necessarily,
       max(infected_amount) over (partition by pupils_id) as max_request
from study.school;

-- 23. Оконные фнкции для устранения дублей

-- Создание дублей
insert into study.school values (1, 1, 1, 100, true);
insert into study.school values (1, 1, 1, 100, true);
insert into study.school values (1, 1, 1, 100, true);

-- Посмотреть дубли
select *, row_number() over (partition by establishments_id, employee_id, pupils_id, infected_amount, is_necessarily) as row_number from study.school
order by row_number desc;

-- Удаление дублей
delete
from study.school
where (establishments_id, employee_id, pupils_id, infected_amount, is_necessarily) in
      (
          select establishments_id, establishments_id, employee_id, pupils_id, infected_amount, is_necessarily
          from (select *,
                       row_number()
                       over (partition by establishments_id, employee_id, pupils_id, infected_amount, is_necessarily) as row_number
                from study.school) as t
          where t.row_number > 1
      );
     

