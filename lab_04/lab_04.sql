-- 1) Определяемая пользователем скалярная функция CLR
-- Выводится разница между площадью школы и средним значением площади всех школ где пункт вакцинации = false
create or replace function study.square_diff(x int) returns int as
$body$
	select x -
	(
		select avg(establishments.square)
		from study.establishments
	)
$body$ language sql;

select study.square_diff(establishments.square) as difference
from study.establishments
where establishments.is_vaccination_point is false;

-- 2) Пользовательская агрегатная функция CLR
-- Выводится сумма зараженных людей
create or replace aggregate study.sum(numeric)
(
	sfunc = numeric_add,
	stype = numeric,
	initcond = '0'
);

select sum(school.infected_amount) from study.school;

-- 3) Определяемая пользователем табличная функция CLR
-- Выводятся значения кол-ва людей, площадь и кол-во зараженных в школе
create or replace function study.fulltable() returns table(people_count int, square int, infected_amount numeric) as
$body$
	select people_count, square, infected_amount
	from study.establishments as t join study.school as tt on t.id = tt.establishments_id
$body$ language sql;

select * from study.fulltable();

-- 4) Хранимая процедура CLR
-- Процедура для добавления данных в таблицу
delete from study.establishments where establishments.id = 5000;

create or replace procedure study.insert_establishments_data(id int, address varchar(50), creation_date date, is_vaccination_point bool, square int, people_count int) as
$body$ begin
	insert into study.establishments (id, address, creation_date, is_vaccination_point, square, people_count) values (id, address, creation_date, is_vaccination_point, square, people_count);
end 
$body$ language plpgsql;

call study.insert_establishments_data(5000, 'Красноярск', '2021-11-25', True, 20000, 5000);

select * from study.establishments where establishments.id = 5000;

-- 5) Триггер CLR
drop table temp_fare;

create temp table temp_fare
(
	people_count int not null,
	workers_count int not null,
	half_vaccinated bool not null,
	num_vaccinated int not null
);

create or replace function study.inc_num() returns trigger as
$body$ begin
	update temp_fare
	set num_vaccinated = num_vaccinated + 1;
	return new;
end 
$body$ language plpgsql;

create trigger trigger_after_insert
after insert on temp_fare for each row
execute function study.inc_num();

insert into temp_fare values (30, 15, true, 20);
insert into temp_fare values (10, 4, true, 8);
insert into temp_fare values (70, 30, false, 10);
insert into temp_fare values (44, 10, true, 50);
insert into temp_fare values (15, 5, false, 3);

select * from temp_fare order by num_vaccinated;

-- 6) Определяемый пользователем тип данных CLR. 
-- Вывод строки данных пользовательского типа
drop type study.pupils_info cascade;

create type study.pupils_info as
(
	id int,
	name varchar(50)
);

create or replace function study.get_pupils_info() returns study.pupils_info as
$body$
		select id, first_name from study.pupils;
$body$ language sql;

select * from study.get_pupils_info();