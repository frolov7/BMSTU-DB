CREATE SCHEMA rk_2;

drop table if exists rk_2.employee cascade;
drop table if exists rk_2.medicament cascade;
drop table if exists rk_2.department cascade;
drop table if exists rk_2.employee_medicament cascade;

-- Задание 1
-- Создать базу данных RK2. Создать в ней структуру, соответствующую
-- указанной на ER-диаграмме. Заполнить таблицы тестовыми значениями (не
-- менее 10 в каждой таблице).

create table rk_2.employee (
	id serial primary key,
	department varchar(20),
	position varchar(20),
	FIO varchar(20),
	salary int,
	department_id int
);

insert into rk_2.employee(department, position, FIO, salary, department_id)
values ('A', 'Главврач', 'Кириллов А.У', 500, 1);

insert into rk_2.employee(department, position, FIO, salary, department_id)
values ('B', 'Хирург', 'Савин Л.Д', 540, 2);

insert into rk_2.employee(department, position, FIO, salary, department_id)
values ('C', 'Ишин В.Л', 'Урин А.А.', 1000, 3);

insert into rk_2.employee(department, position, FIO, salary, department_id)
values ('D', 'Иванова Д.А', 'Калин А.А', 1500, 4);

insert into rk_2.employee(department, position, FIO, salary, department_id)
values ('E', 'Иванов Д.Л', 'Возова В.Д',800, 1);

insert into rk_2.employee(department, position, FIO, salary, department_id)
values ('F', 'Водитель', 'Селина Р.А', 400, 1);

insert into rk_2.employee(department, position, FIO, salary, department_id)
values ('G', 'Терапевт', 'Ганина А.Д',490, 5);

insert into rk_2.employee(department, position, FIO, salary, department_id)
values ('H', 'Уборщик', 'Клюева Р.Г',560, 6);

insert into rk_2.employee(department, position, FIO, salary, department_id)
values ('I', 'Хирург', 'Славина А.А',1200, 1);

insert into rk_2.employee(department, position, FIO, salary, department_id)
values ('J', 'Охраник', 'Маркова Д.А',200, 3);

select * from rk_2.employee;

create table rk_2.medicament(
	id serial primary key,
	name varchar(15),
	instruction varchar(60),
	cost int
);

insert into rk_2.medicament(name, instruction, cost)
values('Парацетомол', 'Два раза в день', 1500);

insert into rk_2.medicament(name, instruction, cost)
values('Ацетаминофен', 'После еды', 1000);

insert into rk_2.medicament(name, instruction, cost)
values('Метил', 'Три раза в день', 200);

insert into rk_2.medicament(name, instruction, cost)
values('Аспирин','До еды', 800);

insert into rk_2.medicament(name, instruction, cost)
values('Конкор', 'Утром', 700);

insert into rk_2.medicament(name, instruction, cost)
values('Кардура', 'Перед сном', 2000);

insert into rk_2.medicament(name, instruction, cost)
values('Дульколакс', 'Два раза в день', 1800);

insert into rk_2.medicament(name, instruction, cost)
values('Имудон', 'Два раза в день', 1000);

insert into rk_2.medicament(name, instruction, cost)
values('Карадуба', 'До еды', 3000);

insert into rk_2.medicament(name, instruction, cost)
values('Нифкурил', 'Утром', 3400);

select * from rk_2.medicament;

create table rk_2.department(
	id serial primary key,
	name varchar(30),
	telephone int,
	manager varchar(15)
);

insert into rk_2.department(name, telephone, manager)
values ('AA', 666, 'Балгин А.Д');

insert into rk_2.department(name, telephone, manager)
values ('BB', 078, 'Ерин А.В');

insert into rk_2.department(name, telephone, manager)
values ('CC', 387, 'Варов Е.Е');

insert into rk_2.department(name, telephone, manager)
values ('DD', 690, 'Салин К.К');

insert into rk_2.department(name, telephone, manager)
values ('EE', 322, 'Угин К.Е');

insert into rk_2.department(name, telephone, manager)
values ('FF', 412, 'Царин В.В');

insert into rk_2.department(name, telephone, manager)
values ('GG', 123, 'Зорин Д.Д');

insert into rk_2.department(name, telephone, manager)
values ('HH', 567, 'Залин Л.О');

select * from rk_2.department;

create table rk_2.employee_medicament(
	id serial primary key,
	employee_id int,
	medicament_id int
);

-- Задание 2.1. Инструкцию SELECT, использующую простое выражение CASE 
-- Классификация медикаментов по цене
select t.id, t.name, case when t.cost > 1500 then 'дорого'
when t.cost < 1500 then 'дешево'
else 'неопределённо'
end
from rk_2.medicament T;

-- Задание 2.2. Инструкцию, использующую оконную функцию
-- Выбрать сотрудников, которые работают в отделе с названием AA
select E.id, E.FIO
from rk_2.employee E join rk_2.department D on E.department_id = D.id
group by E.id, E.FIO, D.name
having D.name = 'AA';

-- Задание 2.3. Инструкцию SELECT, консолидирующую данные с помощью
-- предложения GROUP BY и предложения HAVING
-- Сколько сотрудников в каждом отделе
Select distinct d.id, d.name , count(e.id ) over (partition by d.id)
From rk_2.employee E join rk_2.Department D
On d.id = e.department_id;


-- Задание 3
-- Создать хранимую процедуру с двумя входными параметрами – имя базы
-- данных и имя таблицы, которая выводит сведения об индексах указанной
-- таблицы в указанной базе данных. 
create or replace procedure rk_2.get_indexes(table_name_in varchar, schema_name_in varchar)
as $$
declare
	rec record;
	cur cursor for
		select * from pg_indexes pind
		where pind.schemaname = schema_name_in and pind.tablename = table_name_in
		order by pind.indexname;
	begin
		raise info 'table: % ', table_name_in;
		open cur;
		fetch cur into rec;
		raise info 'index: %', rec.indexname;
		raise info 'index definition: %', rec.indexdef;
		close cur;
	end
$$ language plpgsql;

call rk_2.get_indexes('medicament', 'rk_2');
