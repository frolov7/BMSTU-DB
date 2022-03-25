CREATE SCHEMA study;

-- родительская таблица "учебные заведения"
CREATE TABLE study.establishments (
    id serial, -- суррогатный ключ
    address varchar(255), -- адрес
    creation_date date, -- дата открытия
    is_vaccination_point boolean, -- наличие пункта вакцинации
    square integer, -- квадратура
    people_count integer -- количество людей
);

-- родительская таблица "учителя"
CREATE TABLE study.employee (
    id serial, -- суррогатный ключ
    first_name varchar (255),
    last_name varchar (255),
    middle_name varchar (255),
    birth_date date, -- дата рождения
    position varchar (255) -- должность
);

-- родительская таблица "ученики"
CREATE TABLE study.pupils (
    id serial, -- суррогатный ключ
    first_name varchar (255),
    last_name varchar (255),
    middle_name varchar (255),
    birth_date date, -- дата рождения
    gender varchar (255), -- пол
    is_vaccinated boolean -- признак, есть ли прививка
);

-- дочерняя таблица "школа"
CREATE TABLE study.school (
    establishments_id integer,
    employee_id integer,
    pupils_id integer,
    infected_amount numeric, -- кол-во зараженных
    is_necessarily boolean -- признак, обязательна ли вакцинация
);
