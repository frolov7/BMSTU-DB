import decimal
import json

from prettytable import PrettyTable
from sqlalchemy import MetaData, create_engine, text
from sqlalchemy.orm import Session, mapper

engine = create_engine('postgresql+psycopg2://postgres:pgadminkoro@localhost/postgres')
meta = MetaData()
meta.reflect(bind = engine, schema = 'public')

class fare(object):
	def __init__(self, root_numer, price, start_id, stop_id, day_time):
		self.root_number = root_numer
		self.price = price
		self.start_id = start_id
		self.stop_id = stop_id
		self.day_time = day_time

	@staticmethod
	def get_header_array():
		return ['root_numer', 'price', 'start_id', 'stop_id', 'day_time']

class timetable(object):
	def __init__(self, timing, transport_stop_id, root, weekends, max_price):
		self.timing = timing
		self.transport_stop_id = transport_stop_id
		self.root = root
		self.weekends = weekends
		self.max_price = max_price

	@staticmethod
	def get_header_array():
		return ['timing', 'transport_stop_id', 'root', 'weekends', 'max_price']

class transport(object):
	def __init__(self, root_number, start_id, stop_id, transport_type, entry_date):
		self.root_number = root_number
		self.start_id = start_id
		self.stop_id = stop_id
		self.transport_type = transport_type
		self.entry_date = entry_date

	@staticmethod
	def get_header_array():
		return ['root_number', 'start_id', 'stop_id', 'transport_type', 'entry_date']

	def get_header_tuple(self):
		return (self.root_number, self.start_id, self.stop_id, self.transport_type, self.entry_date)

class transport_stop(object):
	def __init__(self, id, name, address, request_stop, install_year, electricity, rails):
		self.id = id
		self.name = name
		self.address = address
		self.request_stop = request_stop
		self.install_year = install_year
		self.electricity = electricity
		self.rails = rails

	@staticmethod
	def get_header_array():
		return ['id', 'name', 'address', 'request_stop', 'install_year', 'electricity', 'rails']

	def get_header_tuple(self):
		return (self.id, self.name, self.address, self.request_stop, self.install_year, self.electricity, self.rails)

class DecimalEncoder(json.JSONEncoder):
	def default(self, o):
		if isinstance(o, decimal.Decimal):
			return {'__Decimal__': str(o)}

		return json.JSONEncoder.default(self, o)

mapper(fare, meta.tables['public.fare'])
mapper(timetable, meta.tables['public.timetable'])
mapper(transport, meta.tables['public.transport'])
mapper(transport_stop, meta.tables['public.transport_stop'])

def install_years_between():
	connection = Session(bind = engine)
	query = text(
		'select distinct name, address ' \
		'from transport_stop ' \
		'where install_year between \'1997-01-01\' and \'1997-03-31\';'
	)
	result = connection.execute(query).fetchall()
	connection.close()

	table = PrettyTable(['Название', 'Адрес'])
	table.add_rows(result)
	print(table, '\n')

def day_time_like():
	connection = Session(bind = engine)
	query = text(
		'select distinct root_number, start_id, stop_id ' \
		'from fare ' \
		'where day_time like \'с 9%\';'
	)
	result = connection.execute(query).fetchall()
	connection.close()

	table = PrettyTable(['Номер маршрута', 'Первая остановка', 'Конечная остановка'])
	table.add_rows(result)
	print(table, '\n')

def root_number_in():
	connection = Session(bind = engine)
	query = text(
		'select distinct root_number, start_id, stop_id ' \
		'from fare ' \
		'where root_number in ' \
		'(\
			select root_number \
			from transport \
			where transport_type = \'автобус\' \
		) and price > 50;'
	)
	result = connection.execute(query).fetchall()
	connection.close()

	table = PrettyTable(['Номер маршрута', 'Первая остановка', 'Конечная остановка'])
	table.add_rows(result)
	print(table, '\n')

def exists_query():
	connection = Session(bind = engine)
	query = text(
		'select root, timing ' \
		'from timetable ' \
		'where exists ' \
		'(\
			select * \
			from transport_stop \
			where install_year > \'1992-02-23\' \
		);'
	)
	result = connection.execute(query).fetchall()
	connection.close()

	table = PrettyTable(['Номер маршрута', 'Время прибытия'])
	table.add_rows(result)
	print(table, '\n')

def max_price_all():
	connection = Session(bind = engine)
	query = text(
		'select root, max_price ' \
		'from timetable ' \
		'where max_price > all' \
		'(\
			select max_price \
			from fare \
			where start_id = 123 \
		);'
	)
	result = connection.execute(query).fetchall()
	connection.close()

	table = PrettyTable(['Номер маршрута', 'Максимальная цена'])
	table.add_rows(result)
	print(table, '\n')

def transport_by_types():
	connection = Session(bind = engine)
	transport_type = input('Тип транспорта (автобус, троллейбус, трамвай): ')
	types = connection.query(transport).filter(text('transport_type = :transport_type')).params(transport_type = transport_type).all()[:10]
	connection.close()

	data = []
	for elem in types:
		data.append(elem.get_header_tuple())

	table = PrettyTable(transport.get_header_array())
	table.add_rows(data)
	print(table, '\n')

def transport_by_start_id():
	connection = Session(bind = engine)
	start_id = input('Иден-ор остановки: ')
	stops = connection.query(transport_stop, transport).filter(
		transport_stop.id == transport.start_id
	).filter(text('start_id = :start_id')).params(start_id = start_id).all()[:10]
	connection.close()

	data = []
	for elem in stops:
		r = list(map(lambda c: c.get_header_tuple(), elem))
		data.append(r[0] + (r[1]))

	table = PrettyTable(transport_stop.get_header_array() + transport.get_header_array())
	table.add_rows(data)
	print(table, '\n')

def add_timetable():
	connection = Session(bind = engine)
	tmng = input('timing: ')
	trnsprt_stop_id = input('transport_stop_id: ')
	root = int(input('root: '))
	weekends = bool(input('weekends: '))
	max_price = float(input('max_price: '))

	connection.add(timetable(tmng, trnsprt_stop_id, root, weekends, max_price))
	connection.commit()
	connection.close()

def upd_timetable_by_timing():
	connection = Session(bind = engine)
	old_tmng = input('Старый столбец timing: ')
	new_tmng = input('Новый столбец timing: ')

	const = connection.query(timetable).filter(timetable.timing == old_tmng).first()
	if const:
		timetable.timing = new_tmng

	connection.commit()
	connection.close()

def del_timetable_by_timing():
	connection = Session(bind = engine)
	old_tmng = input('timing для удаления: ')

	const = connection.query(timetable).filter(timetable.timing == old_tmng).first()
	if const:
		const.delete(timetable)

	connection.commit()
	connection.close()

def exists_row_timetable():
	connection = Session(bind = engine)
	old_tmng = input('timing для проверки: ')

	const = connection.query(timetable).filter(timetable.timing == old_tmng).first()

	connection.close()
	if const:
		print('Запись существует.')
	else:
		print('Запись не существует.')

def to_json():
	connection = Session(bind = engine)
	query = text(
		'select distinct t.root_number, t.transport_type '\
		'from transport as t join transport as t2 on t.transport_type = t2.transport_type '\
		'where t2.start_id != t.start_id and t.entry_date = \'1982-08-24\' '\
		'order by t.root_number, t.transport_type;'
	)
	result = connection.execute(query).fetchall()
	connection.close()

	j = [dict(elem) for elem in result]
	print('JSON:', json.dumps(j, indent = 4, cls = DecimalEncoder))

	for elem in j:
		if elem['transport_type'] == 'автобус':
			elem['transport_type'] == 'троллейбус'

	print('Изменённый JSON: ', json.dumps(j, indent = 4, cls = DecimalEncoder))

	j.append({'root_number': 9000, 'transport_type': 'троллейбус'})
	print('JSON после добавления: ', json.dumps(j, indent = 4, cls = DecimalEncoder))

def defen():
	connection = Session(bind = engine)
	query = text(
		'select distinct t.root_number, t.transport_type '\
		'from transport as t join transport as t2 on t.transport_type = t2.transport_type '\
		'where t2.start_id != t.start_id and t.entry_date = \'1982-08-24\' '\
		'order by t.root_number, t.transport_type;'
	)
	result = connection.execute(query).fetchall()
	connection.close()

	j = [dict(elem) for elem in result]

	for elem in j:
		if elem['transport_type'] == 'автобус':
			elem['transport_type'] == 'троллейбус'

	print('Изменённый JSON: ', json.dumps(j, indent = 4, cls = DecimalEncoder))

	j.append({'root_number': 9000, 'transport_type': 'троллейбус'})
	print('JSON после добавления: ', json.dumps(j, indent = 4, cls = DecimalEncoder))

def menu():
	print(
		'0. Выход;\n' \
		'1. Названия и адреса остановок, год установки которых между 1 января и 31 марта 1997;\n'
		'2. Номер, первая и последняя остановки маршрутов, которые начинают ходить с 9 утра;\n'
		'3. Номер, первая и последняя остановки маршрутов автобусов, цена которых больше 50\n'
		'4. Номер маршрута и время его прибытия на остановки, установленные после 23 февраля 1992;\n'
		'5. Номер маршрута, у которого иден-ор начальной остановки равен 123, и максимальная цена, установленная за него;\n'
		'6. Вывод транспорта по типу (однотабличный);\n'
		'7. Вывод всего проходящего через остановку транспорта по её иден-ору (многотабличный);\n'
		'8. Добавить расписание;\n'
		'9. Обновить время прибытия в расписании;\n'
		'10. Удалить строку расписания по времени прибытия;\n'
		'11. Найти строку в расписании;\n'
		'12. JSON;\n'
		'13. Защита.'
	)

functions = [exit, install_years_between, day_time_like, root_number_in, exists_query, max_price_all, transport_by_types, transport_by_start_id, add_timetable, upd_timetable_by_timing, del_timetable_by_timing, exists_row_timetable, to_json, defen]
while 1:
	menu()
	choice = int(input('Введите пункт меню: '))
	functions[choice]()
