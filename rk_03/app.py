import os
import psycopg2
from dotenv import load_dotenv
from tabulate import tabulate
from py_linq import Enumerable

connection = psycopg2.connect(
	user = "postgres", 
	password = "qwert", 
	host = "localhost", 
	port = "5432", 
	database = "postgres"
)

# Найти все отделы, в которых работает более 10 сотрудников (SQL)
def task_1_sql():
	cursor = connection.cursor()
	try:
		cursor.execute('''
			select department from rk_03.employee
			group by department
			having count(id) > 10;
		''')
		headers = [desc[0] for desc in cursor.description]
		print(tabulate(cursor.fetchall(), headers = headers))
		connection.commit()
		cursor.close()
	except:
		connection.rollback()

# Найти все отделы, в которых работает более 10 сотрудников (LINQ)
def task_1_python():
	cursor = connection.cursor()
	try:
		cursor.execute('''
			select * from rk_03.employee;
		''')

		emp = Enumerable(cursor.fetchall())
		connection.commit()
		cursor.close()

		res = (
			emp.group_by(key_names=['department'], key = lambda g: g[3])
		).select(
			lambda a: {'department': a.key.department, 'count':a.count()}
		).where(
			lambda b: b['count'] > 10
		).to_list()

		print(res)
	except:
		connection.rollback()


# Найти сотрудников, которые не выходят с рабочего места в течение всего рабочего дня (SQL)
def task_2_sql():
	cursor = connection.cursor()
	try:
		cursor.execute('''
			select id from rk_03.employee
			where id not in(
				select id_employee
				from (select id_employee, sdate, stype, count(*)
						from rk_03.shedule
						group by id_employee, sdate, stype
						having count(*) > 1 and stype=2
				) as tmp
			);
		''')
		headers = [desc[0] for desc in cursor.description]
		print(tabulate(cursor.fetchall(), headers = headers))
		connection.commit()
		cursor.close()
	except:
		connection.rollback()

# Найти все отделы, в которых есть сотрудники, опоздавшие в определенную дату
def task_3_sql():
	cursor = connection.cursor()
	date = input('Input date > ')
	try:
		query = '''
			select distinct department 
			from rk_03.employee
			where id in 
			(
				select id_employee
				from
				(
					select id_employee, min(stime)
					from rk_03.shedule
					where stype = 1 and sdate = date (%s)
					group by id_employee
					having min(stime) > '09:00'
				) as tmp
			);
		'''
		cursor.execute(query, (date, ))
		headers = [desc[0] for desc in cursor.description]
		print(tabulate(cursor.fetchall(), headers = headers))
		
		connection.commit()
		cursor.close()
	except:
		connection.rollback()

def print_menu():
	print("\n\
1.  Найти все отделы, в которых работает более 10 сотрудников (SQL) \n\
2.  Найти все отделы, в которых работает более 10 сотрудников (Python) \n\
3.  Найти сотрудников, которые не выходят с рабочего места в течение всего рабочего дня (SQL) \n\
4.  Найти все отделы, в которых есть сотрудники, опоздавшие в определенную дату (SQL) \n\
5. Завершить работу\n"
	)

execute = [
	'__empty__',

	task_1_sql, task_1_python,
	task_2_sql,
	task_3_sql,
	
	lambda: print('Bye!'),
]

if __name__ == '__main__':
	choice = -1
	while choice != 5:
		print_menu()
		choice = int(input('> '))
		execute[choice]()