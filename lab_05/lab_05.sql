CREATE SCHEMA lab_05;
-- 1)Из таблиц базы данных, созданной в первой лабораторной работе, извлечь
-- данные в XML (MSSQL) или JSON(Oracle, Postgres). 

copy (select to_json(study.establishments.*) from study.establishments)
to 'C:/123/establishments.json';

copy(select array_to_json(array_agg(row_to_json(t))) as "establishments"
    from study.establishments as t)
  to 'C:/123/establishments.json';

-- 2)Выполнить загрузку и сохранение XML или JSON файла в таблицу.
-- Созданная таблица после всех манипуляций должна соответствовать таблице
-- базы данных, созданной в первой лабораторной работе.
create temporary table json_import (values text);
copy json_import from 'C:/123/establishments.json';

create table lab_05.establishments_json(
    address varchar(20), 
    square integer CHECK(square >= 5000),
    id integer CHECK(id > 0) PRIMARY KEY
);

insert into lab_05.establishments_json("address", "square", "id")
select  j->>'address' as address,
CAST(j->>'square' as integer) as square,
CAST(j->>'id' as integer) as id
from   (
           select json_array_elements(replace(values,'\','\\')::json) as j 
           from   json_import
       ) a where j->'address' is not null;
      
select * from lab_05.establishments_json;


-- 3) Создать таблицу, в которой будет атрибут(-ы) с типом XML или JSON, или
-- добавить атрибут с типом XML или JSON к уже существующей таблице.
-- Заполнить атрибут правдоподобными данными с помощью команд INSERT
-- или UPDATE. 

drop table lab_05.json_table;
create table lab_05.json_table(
    establishments_id serial primary key,
    address varchar(40) not null,
    json_column json
);

insert into lab_05.json_table(address, json_column) values 
    ('Рим', '{"age": 52, "name": "Шурьянов Р.А."}'::json),
    ('Кёльн', '{"age": 65, "name": "Мулыгин О.В."}'::json),
    ('Астана', '{"age": 48, "name": "Савин В.В."}'::json);

select * from lab_05.json_table;

-- 4. Выполнить следующие действия:
-- 1. Извлечь XML/JSON фрагмент из XML/JSON документа
-- 2. Извлечь значения конкретных узлов или атрибутов XML/JSON документа
-- 3. Выполнить проверку существования узла или атрибута
-- 4. Изменить XML/JSON документ
-- 5. Разделить XML/JSON документ на несколько строк по узлам

-- 1. Извлечь XML/JSON фрагмент из XML/JSON документа
--Извлекаю всех игроков, чьё имя начинается на A
drop table lab_05.json_import;
drop table lab_05.establishments_json_frg;

create temporary table json_import(values text);
copy json_import from 'C:/123/establishments.json';

create table lab_05.establishments_json_frg(
    address varchar(20), 
    square integer CHECK(square >= 5000),
    id integer CHECK(id > 0) PRIMARY KEY
);

insert into lab_05.establishments_json_frg("address", "square", "id")
select  j->>'address' as address,
CAST(j->>'square' as integer) as square,
CAST(j->>'id' as integer) as id
from(
           select json_array_elements(replace(values,'\','\\')::json) as j 
           from   json_import
    )      a where j->'address' is not null and j->>'address' like 'М%';
      
select * from lab_05.establishments_json_frg;

-- 2. Извлечь значения конкретных узлов или атрибутов XML/JSON документа
-- 3. Выполнить проверку существования узла или атрибута
--проверяет на null 
-- данные о заведении c id 8
drop table lab_05.establishments_json_frg;
create table lab_05.establishments_json_frg(
    address varchar(20), 
    square integer CHECK(square >= 5000),
    id integer CHECK(id > 0) PRIMARY KEY
);

insert into lab_05.establishments_json_frg("address", "square", "id")
select  j->>'address' as address,
CAST(j->>'square' as integer) as square,
CAST(j->>'id' as integer) as id
from(
           select json_array_elements(replace(values,'\','\\')::json) as j 
           from   json_import
       ) a where j->'address' is not null and j->>'id' = '8';
      
select * from lab_05.establishments_json_frg;


-- 4. Изменить XML/JSON документ

drop table json_import;
drop table lab_05.establishments_json_frg;

create temporary table json_import(values text);
copy json_import from 'C:/123/establishments.json';

create table lab_05.establishments_json_frg(
    address varchar(20), 
    square integer CHECK(square >= 5000),
    id integer CHECK(id > 0) PRIMARY KEY
);

insert into lab_05.establishments_json_frg("address", "square", "id")
select  j->>'address' as address,
CAST(j->>'square' as integer) as square,
CAST(j->>'id' as integer) as id
from   (
           select json_array_elements(replace(values,'\','\\')::json) as j 
           from   json_import
       ) a where j->'address' is not null;
select * from lab_05.establishments_json_frg;
update lab_05.establishments_json_frg
set address = 'new_address'
where id = 1;

select * from lab_05.establishments_json_frg;
select * from lab_05.establishments_json_frg where id = 1;

copy(select array_to_json(array_agg(row_to_json(t))) as "establishments"
    from lab_05.establishments_json_frg as t)
  to 'C:/123/establishments.json';

-- 5. Разделить XML/JSON документ на несколько строк по узлам
drop table lab_05.json_table;
drop table lab_05.parsed;

create table lab_05.json_table(
    establishments_id serial primary key,
    address varchar(40) not null,
    json_column json
);

create table lab_05.parsed(
    establishments_id serial primary key,
    address varchar(40) not null,
    age int,
    test json
);

insert into lab_05.json_table(address, json_column) values 
    ('Рим', '[{"age": 52, "name": "Шурьянов Р.А."}]'::json),
    ('Кёльн', '[{"age": 65, "name": "Мулыгин О.В."}]'::json),
    ('Астана', '[{"age": 48, "name": "Савин В.В."}]'::json);
   
select * from lab_05.json_table;


insert into lab_05.parsed (address, age, test)
select address, (j.items->>'age')::integer, items #- '{age}'
from lab_05.json_table, jsonb_array_elements(json_column::jsonb) j(items);
select * from lab_05.parsed;