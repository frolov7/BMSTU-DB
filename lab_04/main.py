import psycopg2
from psycopg2 import Error

def scalar_function(cursor):
	cursor.execute(
		'''
		create or replace function study.square_diff(x int) returns int language sql as
			$$
				select x -
				(
					select avg(establishments.square)
					from study.establishments
				)
			$$;
		'''
	)
	# Получить результат
	connection.commit()
	print('Скалярная функция успешно создана.')

	cursor.execute(
		'''
			select study.square_diff(establishments.square) as difference
			from study.establishments
			where establishments.is_vaccination_point is false;
		'''
	)
	print('  difference   |\n---------------+')
	result = cursor.fetchall()
	for i in range(200):
		print("     {:4g}   ".format(result[i][0]))

def aggregate(cursor):
	cursor.execute(
		'''
			create or replace aggregate study.sum(numeric)
			(
				sfunc = numeric_add,
				stype = numeric,
				initcond = '0'
			);
		'''
	)
	connection.commit()
	print('Агрегатная функция успешно создана.')

	cursor.execute(
		'''
			select sum(school.infected_amount)
			from study.school;
		'''
	)
	print('  sum   |\n--------+')
	result = cursor.fetchone()
	print(result[0])

def table_function(cursor):
	cursor.execute(
		'''
			create or replace function study.fulltable() returns table(people_count int, square int, infected_amount numeric) language sql as
			$$
				select people_count, square, infected_amount
				from study.establishments as t join study.school as tt on t.id = tt.establishments_id
			$$;
		'''
	)
	connection.commit()
	print('Табличная функция успешно создана.')

	cursor.execute(
		'''
			select *
			from study.fulltable();
		'''
	)
	result = cursor.fetchall()
	print('|people_count |square      |infected_amount          \n+------------+-------------+----------+')
	for i in range(200):
		print("{:4d}             {:4d}             {:4}             ".format(result[i][0], result[i][1], result[i][2]))

def procedure(cursor):
	cursor.execute(
	'''
		delete from study.establishments where establishments.id = 5000;
	'''
	)
	cursor.execute(
	'''
			create or replace procedure study.insert_establishments_data(id int, address varchar(50), creation_date date, is_vaccination_point bool, square int, people_count int) language plpgsql as
			$$ begin
				insert into study.establishments (id, address, creation_date, is_vaccination_point, square, people_count) values (id, address, creation_date, is_vaccination_point, square, people_count);
			end $$;
	'''
	)
	connection.commit()
	print('Хранимая процедура успешно создана.')

	cursor.execute(
	'''	
			call study.insert_establishments_data(5000, 'Красноярск', '2021-11-25', True, 20000, 5000);
	'''	
	)
	cursor.execute(
		'''
			select * from study.establishments where establishments.id = 5000;
		'''
	)
	result = cursor.fetchone()
	for i in range(6):
		print(result[i], end = " ")

def trigger(cursor):
	cursor.execute(
		'''
			create temp table temp_fare
			(
				people_count int not null,
				workers_count int not null,
				half_vaccinated bool not null,
				num_vaccinated int not null
			);
		'''
	)
	connection.commit()
	print('\n\nВременная таблица успешно создана.')

	cursor.execute(
		'''
			create or replace function study.inc_num() returns trigger language plpgsql as
			$$ begin
				update temp_fare
				set num_vaccinated = num_vaccinated + 1;
				return new;
			end $$;
		'''
	)
	connection.commit()
	print('Функция для триггера успешно создана.')

	cursor.execute(
		'''
			create trigger trigger_after_insert
			after insert on temp_fare for each row
			execute function study.inc_num();
		'''
	)
	connection.commit()
	print('Триггер успешно создан.')
	cursor.execute(
		'''
			insert into temp_fare values (30, 15, true, 20);
		'''
	)
	connection.commit()
	cursor.execute(
		'''
			insert into temp_fare values (10, 4, true, 8);
		'''
	)
	connection.commit()
	cursor.execute(
		'''
			insert into temp_fare values (70, 30, false, 10);
		'''
	)
	connection.commit()
	cursor.execute(
		'''
			insert into temp_fare values (44, 10, true, 50);
		'''
	)
	connection.commit()
	cursor.execute(
		'''
			insert into temp_fare values (15, 5, false, 3);
		'''
	)
	connection.commit()
	cursor.execute(
		'''
			select * from temp_fare order by num_vaccinated;
		'''
	)

	result = cursor.fetchall()
	print('people_count |workers_count|half_vaccinated|num_vaccinated|\n-------------+-------------+-------------+---------------+')
	for i in range(5):
		print("{:4d}             {:4d}             {:4}             {:4d}".format(result[i][0], result[i][1], result[i][2], result[i][3]))

def user_type(cursor):
	cursor.execute(
		'''
		drop type study.pupils_info cascade;
		create type study.pupils_info as
		(
			id int,
			name varchar(50)
		);
		'''
	)
	connection.commit()
	cursor.execute(
		'''
			create or replace function study.get_pupils_info() returns study.pupils_info language sql as
			$$
					select id, first_name
					from study.pupils;
			$$;
		'''
	)
	print('Функция для вывода данных успешно создана.')
	connection.commit();
	cursor.execute(
		'''
			select *
			from study.get_pupils_info();
		'''
	)

	result = cursor.fetchall()
	print(result)
try:
	# Подключение к существующей базе данных
	connection = psycopg2.connect(user = "postgres", password = "qwert", host = "localhost", port = "5432", database = "postgres")

	# Курсор для выполнения операций с базой данных
	cursor = connection.cursor()
	# Выполнение SQL-запроса
	scalar_function(cursor)
	print()
	aggregate(cursor)
	print()
	table_function(cursor)
	print()
	procedure(cursor)
	print()
	trigger(cursor)
	print()
	user_type(cursor)
except (Exception, Error) as error:
	print("Ошибка при работе с PostgreSQL", error)
finally:
	if connection:
		cursor.close()
		connection.close()
		print("Соединение с PostgreSQL закрыто")