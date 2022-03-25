CREATE SCHEMA rk_03;

-- Задание 1. Создать в БД таблицы и соответствующие связи:
create table rk_03.employee (
	id serial not null primary key,
	name varchar(20),
	birthdate date, 
	department varchar(20)
);

create table rk_03.shedule(
	id_employee int references rk_03.employee(id) not null,
	sdate date,
	day text,
	stime time,
	stype int
);

insert into rk_03.employee(name, birthdate, department) values
	('Rty Eva W', '22-08-1990', 'Backend'),	
	('Qwer Anna N', '23-04-1995', 'Manager'),
	('Qwer Artem Q', '13-05-1998', 'Frontend'),
	('Qaz Inna A', '20-02-1993', 'Manager'),
	('Qwer Anton Z', '13-07-1996', 'Backend'),
	('Tyui Oleg M', '12-04-1992', 'Backend');

insert into rk_03.shedule(id_employee, sdate, day, stime, stype) values
	(1, '14-12-2020', 'Понедельник', '09:01', 1),
	(1, '14-12-2020', 'Понедельник', '09:11', 2),
	(1, '14-12-2020', 'Понедельник', '09:40', 1),
	(1, '14-12-2020', 'Понедельник', '20:02', 2),

	(1, '14-12-2020', 'Понедельник', '09:01', 1),
	(1, '14-12-2020', 'Понедельник', '09:11', 2),
	(1, '14-12-2020', 'Понедельник', '09:40', 1),
	(1, '14-12-2020', 'Понедельник', '20:02', 2),

	(3, '14-12-2020', 'Понедельник', '08:53', 1),
	(3, '14-12-2020', 'Понедельник', '20:32', 2),

	(4, '14-12-2020', 'Понедельник', '09:53', 1),
	(4, '14-12-2020', 'Понедельник', '20:32', 2),

	(2, '16-12-2020', 'Среда', '09:01', 1),
	(2, '16-12-2020', 'Среда', '09:11', 2),
	(2, '16-12-2020', 'Среда', '09:40', 1),
	(2, '16-12-2020', 'Среда', '20:02', 2),

	(3, '16-12-2020', 'Среда', '09:01', 1),
	(3, '16-12-2020', 'Среда', '09:11', 2),
	(3, '16-12-2020', 'Среда', '09:50', 1),
	(3, '16-12-2020', 'Среда', '20:02', 2),

	(5, '17-12-2020', 'Четверг', '08:41', 1),
	(5, '17-12-2020', 'Четверг','20:31', 2),

	(6, '17-12-2020', 'Четверг', '09:51', 1),
	(6, '17-12-2020', 'Четверг', '20:31', 2);


-- Написать скалярную функцию, возвращающую количество сотрудников в возрасте от 18 до
-- 40, выходивших более 3х раз.
create or replace function rk_03.latters_count(late_date date) returns int as $$
	BEGIN
	RETURN(
		select count(*)
		from(select distinct id
				from rk_03.employee
				where extract(year from CURRENT_DATE) - extract(year from birthdate) between 18 and 40 and id in(
					select id_employee from(
						select id_employee, sdate, stype, count(*) from rk_03.shedule
							where sdate = late_date
							group by id_employee, sdate, stype
							having stype = 2 and count(*) > 3
						) as tmp0
					)
				) as tmp1
			);
	END;
$$ language plpgsql;

select * from rk_03.latters_count('14-12-2020')

-- Задание 2.1 Найти все отделы, в которых работает более 10 сотрудников
select department from rk_03.employee
group by department
having count(id) > 10;

-- Задание 2.2 Найти сотрудников, которые не выходят с рабочего места в течение всего рабочего дня
select id from rk_03.employee
where id not in(
	select id_employee
	from (select id_employee, sdate, stype, count(*)
			from rk_03.shedule
			group by id_employee, sdate, stype
			having count(*) > 1 and stype=2
	) as tmp
);

-- 2.3 Найти все отделы, в которых есть сотрудники, опоздавшие в определенную дату. 
-- Дату передавать с клавиатуры
select distinct department 
from rk_03.employee
where id in 
(
	select id_employee
	from
	(
		select id_employee, min(stime)
		from rk_03.shedule
		where stype = 1 and sdate = '14-12-2020'
		group by id_employee
		having min(stime) > '09:00'
	) as tmp
);
