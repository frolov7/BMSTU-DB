-- Защита
-- Задание: Процедура в которой выдаем номер школы, она будет вакцинировать студента. 
-- Если число вакцинированных меньше среднего

select * from study.pupils where pupils.id = 4;

call study.do_vacination(212);

create or replace procedure study.do_vacination(ARG_ID int) as
$body$
    begin
        update study.pupils set is_vaccinated = true 
        where study.pupils.id in (select study.pupils.id from study.establishments 
        join study.school on study.school.establishments_id = study.establishments.id 
        join study.pupils on study.school.pupils_id = study.pupils.id 
        where study.establishments.id = ARG_ID)
        and (select count(*) from study.establishments 
       join study.school on study.school.establishments_id = study.establishments.id 
      join study.pupils on study.school.pupils_id = study.pupils.id 
     where study.establishments.id = ARG_ID) < ((select people_count from study.establishments where study.establishments.id = ARG_ID) / 2);
    end;
$body$ language plpgsql;

DROP PROCEDURE study.do_vacination(integer);



-- 1. Скалярная функция
-- Форматирование ФИО
create or replace function study.fullName(first_name varchar(255), last_name varchar(255), middle_name varchar(255))
returns varchar(255) as
$$
    begin
        return upper(last_name) || ' ' || upper(first_name) || ' ' || upper(middle_name);
    end
$$ language plpgsql;

select study.pupils.id, study.fullName(study.pupils.first_name, study.pupils.last_name, study.pupils.middle_name) from study.pupils;


-- 2. Подставляемая табличная функция
-- Возвращает количество зараженных
drop function study.totalInfected();

create or replace function study.totalInfected()
returns table (id int, Infected bigint) as
$body$
    (select pupils.id, sum(school.infected_amount) from study.pupils
        join study.school on pupils.id = school.pupils_id
        where school.is_necessarily = true
        group by pupils.id);
$body$ language sql;

select * from study.totalInfected();

-- 3. Многооператорная табличная функция
-- Возвращает студента, у которого больше всего зараженных
drop function study.maxInfected();

create or replace function study.maxInfected()
returns table (id int, last_name varchar(255), first_name varchar(255), middle_name varchar(255)) as
$body$
    declare
        max integer;
    begin
    select pupils_id into max from study.school where infected_amount = (select max(infected_amount) from study.school where is_necessarily = true);

    return query (select pupils.id, pupils.last_name, pupils.first_name, pupils.middle_name from study.pupils where pupils.id = max);

    end;
$body$ language plpgsql;

select * from study.maxInfected();

-- 4. Функция с рекурсивным ОТВ
-- Возвращает ветку в структуре школы от заданной ноды
call study.create_workers();
drop function study.structure; 
drop table study.workers;

select * from study.workers;

create or replace function study.structure(s_id int)
returns table (id int, p_id int, t varchar(255)) as
$body$
    begin
    return query (with recursive cts(workers_id, parent_id, title) as (
    select workers_id, parent_id, title
    from study.workers
    where workers.workers_id = s_id
    union all
    select workers.workers_id, workers.parent_id, workers.title
    from study.workers
             join cts rec ON workers.parent_id = rec.workers_id
        )
    select * from cts);

    end;
$body$ language plpgsql;

select * from study.structure(4);

-- 5. Хранимая процедура без параметров
-- Создает таблицу с работниками
call study.create_workers();

create procedure study.create_workers() as
$$
    begin
        create table study.workers (workers_id int primary key , parent_id int, title varchar(50));

		insert into study.workers (workers_id, parent_id, title)
		VALUES (0, null, 'Director');
		insert into study.workers (workers_id, parent_id, title)
		VALUES (1, 0, 'Chef');
		insert into study.workers (workers_id, parent_id, title)
		VALUES (2, 1, 'Cook');
		insert into study.workers (workers_id, parent_id, title)
		VALUES (3, 2, 'Dishwasher');
		insert into study.workers (workers_id, parent_id, title)
		VALUES (4, 0, 'Head teacher');
		insert into study.workers (workers_id, parent_id, title)
		VALUES (5, 4, 'Physicist');
		insert into study.workers (workers_id, parent_id, title)
		VALUES (6, 5, 'Laboratory assistant');
end;
$$ language plpgsql;

drop procedure study.create_workers();
-- 6. Рекурсивная хранимая процедура или хранимая процедура с рекурсивным ОТВ
-- Создает таблицу из ветки в структуре школы от заданной ноды создает новую таблицу и сохраняет результат
drop procedure study.create_workers_structure;

create procedure study.create_workers_structure(i int) as
$$
    begin
        drop table if exists study.tmp_workers_tree;
        create table study.tmp_workers_tree(workers_id int primary key , parent_id int, title varchar(50));
        insert into study.tmp_workers_tree (select * from study.structure(i));
    end;
$$ language plpgsql;

call study.create_workers_structure(1);

select * from study.tmp_workers_tree;

-- 7-8. Хранимая процедура с курсором + Хранимая процедура доступа к метаданным
-- Удаляет временные таблицы (начинаются с tmp)
drop procedure study.drop_tmp_tables;

create procedure study.drop_tmp_tables() as
$$
declare
    tables CURSOR FOR
        SELECT tablename FROM tmp_tables
        WHERE tablename LIKE 'tmp%'
        and schemaname = 'study'
        ORDER BY tablename;
    tablename varchar(100);
begin
    FOR tablename IN tables LOOP
        EXECUTE 'drop table study.' || tablename.tablename;
    END LOOP;
end;
$$ language plpgsql;

call study.drop_tmp_tables();

SELECT tablename FROM pg_tables WHERE tablename LIKE 'tmp%' ORDER BY tablename;

-- 9. Триггер AFTER
drop function study.update_workers_structure;

create function study.update_workers_structure() returns trigger as
$$
    begin
        call study.create_workers_structure(1);
        return null;
    end;
$$ language plpgsql;

drop trigger myTrigger on study.workers;

create trigger myTrigger
    after insert on study.workers
    execute procedure study.update_workers_structure();

-- 10. Триггер INSTEAD OF
create view study.workers_view as
    select * from study.workers;

drop function study.do_nothing;

create function study.do_nothing() returns trigger as
$$
    begin
        return null;
    end;
$$ language plpgsql;

drop trigger workersInsert on study.workers_view;

create trigger workersInsert
    instead of insert on study.workers_view
    for row
    execute procedure study.do_nothing();

select * from study.workers;
select * from study.workers_view;

insert into study.workers_view (workers_id, parent_id, title)
        VALUES (7, 3, 'new');

delete from study.workers_view where workers_id in (7);
