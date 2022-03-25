import psycopg2
from psycopg2 import OperationalError

text = '''
1)Выполнить скалярный запрос
2)Выполнить запрос с несколькими join
3)Выполнить запрос с ОТВ и оконными функциями
4)Выполнить запрос к метаданным
5)Вызвать скалярную функцию(написанную в третьей л.р.)
6)Вызвать многооператорную или табличную функцию(написанную в 3 л.р.)
7)Вызвать хранимую процедуру(написанную 3 л.р.)
8)Вызвать системную функцию или процедуру
9)Создать таблицу в базе данных, соответствующую теме бд
10)Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT или COPY
11)Задать номер школы и выписать в JSON список невакцинированных учащихся.
12)Удалить данные.
'''

# Получение студента с id = 70
scalarRequest = '''
    select first_name, last_name, middle_name, id from study.pupils where id = 70;
'''

# Получить адреса школ, количество зараженных где прививка обязательна, 
# количество зараженных больше 110, но все ученики привиты
multJoinRequest = '''
    select establishments.address, school.is_necessarily, school.infected_amount, pupils.is_vaccinated
    from study.establishments join study.school on establishments.id = school.establishments_id
    join study.pupils on pupils.id = school.pupils_id
    where school.is_necessarily = true and school.infected_amount > 110 and pupils.is_vaccinated = true;
'''

# Получить среднее количество студентов для каждого города
OTV = '''
WITH CTE(people_count, address) AS
(
    SELECT people_count, address
    from study.establishments
)
SELECT DISTINCT address, AVG(people_count) OVER(PARTITION by address)
from CTE;
'''

# Получить все данные из схемы study
metadataRequest = '''
    select * from pg_tables where schemaname = 'study';
'''

# Получить Форматирование ФИО
scalarFunc = '''
    select study.pupils.id, 
    study.fullName(study.pupils.first_name, study.pupils.last_name, study.pupils.middle_name) 
    from study.pupils;
'''

# Возвращает студента, у которого больше всего зараженных
tableFunc = '''
    select * from study.maxInfected();
'''

# Создает таблицу с работниками
storedProc = '''
    call study.create_workers();
    select * from study.workers;
'''

# Создать таблицу
tableCreation = '''
CREATE table if not EXISTS study.table_tmp (
    id serial, -- суррогатный ключ
    address varchar(255), -- адрес
    creation_date date, -- дата открытия
    is_vaccination_point boolean, -- наличие пункта вакцинации
    square integer, -- квадратура
    people_count integer -- количество людей
);
'''

# Вставить данные в таблицу
tableInsertion = '''
    COPY study.table_tmp(address, creation_date, is_vaccination_point, square, people_count)
    FROM 'C:/123/tmp.csv' DELIMITER ';' CSV HEADER;

    select * from study.table_tmp;
'''

# Вывести имя текущей базы данных
systemFunc = '''
    SELECT current_database();
'''

protection_add = '''
    copy (select first_name, last_name, middle_name, is_vaccinated
    from study.pupils, study.establishments 
    where establishments.id = 13 and is_vaccinated = false limit 10) TO 'C:/123/protect.csv' DELIMITER ';' CSV;

    create table if not exists study.json_table(
        first_name varchar(40),
        last_name varchar(40),
        middle_name varchar(40),
        is_vaccinated boolean
    );

    copy study.json_table(first_name, last_name, middle_name, is_vaccinated)
    from 'C:/123/protect.csv' DELIMITER ';' CSV HEADER;

    copy(select array_to_json(array_agg(row_to_json(t))) as "json_table"
    from study.json_table as t)
    to 'C:/123/protect.json';

    select * from study.json_table;
'''

protection_odd = '''
    truncate table study.json_table; 

    copy (select to_json(study.json_table.*) 
    from study.json_table)
    to 'C:/123/protect.json';

    select * from study.json_table;
'''
def output(cur, func):
    if func == 1:
        answer = cur.fetchall()
        print("\nВывести студента с id = 70 : \n")
        print("Результат :\n")
        print("first_name", "     last_name", "      middle_name\t", "       id")
        print("---------------------------------------------------------------")
        print('\t\t'.join(map(str, answer[0])))

    elif func == 2:
        answer = cur.fetchall()

        print("\nПолучить адреса школ, количество зараженных где прививка обязательна, \nколичество зараженных больше 110, но все ученики привиты: \n")
        print("Результат :")
        print("address  is_necessarily  infected_amount  is_vaccinated")
        for i in range(len(answer)):
            print(answer[i][0], answer[i][1], answer[i][2], answer[i][3])

    elif func == 3:
        answer = cur.fetchall()

        print("\nПолучить среднее количество студентов для каждого города: \n")
        print("Результат :")
        print("avg")
        for i in range(len(answer)):
            #print(answer[i][0], answer[i][1])
            print("{:.10s}     {:.2f}".format(answer[i][0], float(answer[i][1])))

    elif func == 4:
        answer = cur.fetchall()

        print("\nПолучить все данные из 'rk_2': \n")
        print("Результат :")
        print("shemaname | tablename | tableowner | tablespace | hasIndexes | hasrules | hastriggers")
        for i in range(len(answer)):
            print(answer[i][0], answer[i][1], answer[i][2], answer[i][3],  answer[i][4],  answer[i][5], answer[i][6])

    elif func == 5:
        answer = cur.fetchall()

        print("\nПолучить Форматирование ФИО: \n")
        print("Результат :")
        print("id          |      fullname")
        for i in range(len(answer)):
            print(answer[i][0], answer[i][1])

    elif func == 6:
        answer = cur.fetchall()

        print("\nВозвращает студента, у которого больше всего зараженных: \n")
        print("Результат :")
        print("id     |         last_name     |      first_name   |     middle_name")
        print("--------------------------------------------------------------------")
        print('\t\t'.join(map(str, answer[0])))

    elif func == 7:
        answer = cur.fetchall()

        print("\n Создает таблицу с работниками: \n")
        print("Результат :")
        print("workers_id, parent_id, title")
        for i in range (len(answer)):
            print(answer[i][0], answer[i][1], answer[i][2])

    elif func == 8:
        answer = cur.fetchall()

        print("\n Вывести имя текущей базы данных: \n")
        print("Результат :")
        print("current catalog is", answer[0][0])

    elif func == 9:
        print("\n Создать таблицу: \n")
        print("Результат :")
        print("Table created")

    elif func == 10:
        answer = cur.fetchall()

        print("\n Вставить данные в таблицу: \n")
        print("Результат :")
        print("address, creation_date, is_vaccination_point, square, people_count")
        for i in range (len(answer)):
            print(answer[i][0], answer[i][1], answer[i][2], answer[i][3], answer[i][4])

    elif func == 11:
        answer = cur.fetchall()
        print("\nСоздать таблицу с данными и файл json\n")
        print("Результат :")
        for i in range (len(answer)):
            print(answer[i][0], answer[i][1], answer[i][2], answer[i][3])

    elif func == 12:
        answer = cur.fetchall()
        print("\nУдалить данные из файла\n")
        print("Результат :")
        print("Таблица пуста")
        for i in range (len(answer)):
            print(answer[i][0], answer[i][1], answer[i][2], answer[i][3])        

def requestPgQuery(connection, query, func):
    cursor = connection.cursor()
    cursor.execute(query)
    # COMMIT фиксирует текущую транзакцию. Все изменения, произведённые транзакцией, становятся видимыми для других и гарантированно сохранятся в случае сбоя.
    connection.commit()
    output(cursor, func)
    cursor.close()

def connect():
    connection = None
    try:
        connection = psycopg2.connect(
            user = "postgres", 
            password = "qwert", 
            host = "localhost", 
            port = "5432", 
            database = "postgres")

        print("Connection to PostgreSQL DB successful")

    except OperationalError as e:
        print(f"The error '{e}' occurred")
    return connection


def menu(connection):
    print(text)
    print("Выберите действие:")
    choice = int(input())
    while(choice):
        if (choice == 1):
            requestPgQuery(connection, scalarRequest, 1)
        elif choice == 2:
            requestPgQuery(connection, multJoinRequest, 2)
        elif choice == 3:
            requestPgQuery(connection, OTV, 3)
        elif choice == 4:
            requestPgQuery(connection, metadataRequest, 4)
        elif choice == 5:
            requestPgQuery(connection, scalarFunc, 5)
        elif choice == 6:
            requestPgQuery(connection, tableFunc, 6)
        elif choice == 7:
            requestPgQuery(connection, storedProc, 7)
        elif choice == 8:
            requestPgQuery(connection, systemFunc, 8)
        elif choice == 9:
            requestPgQuery(connection, tableCreation, 9)
        elif choice == 10:
            requestPgQuery(connection, tableInsertion, 10)
        elif choice == 11:
            #id_i = int(input("id: "))
            requestPgQuery(connection, protection_add, 11)
        elif choice == 12:
            #id_i = int(input("id: "))
            requestPgQuery(connection, protection_odd, 12)              
        print("\nВыберите действие:")
        choice = int(input())


if __name__ == '__main__':
    connection = connect()
    menu(connection)
    connection.close()