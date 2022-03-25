#!/usr/bin/env python3

import random

approved_list = []
def random_amount():
    return str(random.randint(10, 500))

def random_city():
    cities = ["Москва", "Зеленоград", "Балашиха", "Мытищи", "Липецк"]
    return cities[random.randint(0, len(cities)-1)]

#def random_personal():
#    pers = ["Врач", "Охраник", "Уборщица", "Повар"]
#    return pers[random.randint(0, len(pers)-1)]

def random_first_name(gender):
    male_values = ["Владимир", "Сергей", "Евгений", "Григорий", "Алексей", "Иван"]
    female_values = ["Полина", "Клава", "Ксения", "Людмила", "Нина", "Галина"]
    
    if (gender == "male"):
        return male_values[random.randint(0, len(male_values)-1)]
    else:
        return female_values[random.randint(0, len(female_values)-1)]

def random_last_name(gender):
    male_values = ["Максименко", "Павлов", "Клюев", "Ришатов", "Дунаев", "Седько"]
    female_values = ["Волошина", "Миклуш", "Суворина", "Пешкина", "Логвина", "Фукина"]
    
    if (gender == "male"):
        return male_values[random.randint(0, len(male_values)-1)]
    else:
        return female_values[random.randint(0, len(female_values)-1)]

def random_middle_name(gender):
    male_values = ["Алексеевич", "Максимович", "Александрович", "Сергеевич", "Владимирович"]
    female_values = ["Алексеевна", "Максимовна", "Александровна", "Сергеевна", "Владимировна"]
    
    if (gender == "male"):
        return male_values[random.randint(0, len(male_values)-1)]
    else:
        return female_values[random.randint(0, len(female_values)-1)]

def random_date():
    #TODO: нормальная генерация даты
    return str(random.randint(1960, 2000)) + '-' + str(random.randint(1, 12)) + '-' + str(random.randint(1, 28))

def random_count():
    return str(random.randint(1000, 3000))

def random_square():
    return str(random.randint(5000, 10000))

def random_doctor(school_index):
	if approved_list[school_index] == 'True':
		return str(random.randint(8, 15))
	else:
		return str(random.randint(1, 3))

def random_security():
    return str(random.randint(1, 10))

def random_cooker():
    return str(random.randint(1, 10))

def random_bool():
    return str(bool(random.randint(0, 1)))

def random_gender():
    genders = ["male", "female"]
    return genders[random.randint(0, len(genders)-1)]

def random_position():
    positions = ["teacher", "head_teacher"]
    return positions[random.randint(0, len(positions)-1)]

establishments_index = 1
establishments_count = 1000
f = open('./csv/establishments.csv', 'w', encoding='utf-8')
f.write("address;creation_date;is_vaccination_point;square;people_count\n")
while (establishments_index <= establishments_count):
    f.write("\"" + random_city() + "\";\"" + random_date() + "\";" + random_bool() + ";" + random_square() + ";" + random_count() + "\n")
    establishments_index += 1
f.close()
print("-> establishments.csv generated") # branch

employee_index = 1
employee_count = 1000
f = open('./csv/employee.csv', 'w', encoding='utf-8')
f.write("first_name;last_name;middle_name;birth_date;position\n")
while (employee_index <= employee_count):
    gender = random_gender()
    f.write("\"" + random_first_name(gender) + "\";\"" + random_last_name(gender) + "\";\"" + random_middle_name(gender) + "\";\"" + random_date() + "\";\"" + random_position() +"\"\n")
    employee_index += 1
f.close()
print("-> employee.csv generated") # employee

pupils_index = 1
pupils_count = 1000
f = open('./csv/pupils.csv', 'w', encoding='utf-8')
f.write("first_name;last_name;middle_name;birth_date;gender;is_vaccinated\n")
while (pupils_index <= pupils_count):
    gender = random_gender()
    approved = random_bool()
    approved_list.append(approved)    	
    f.write("\"" + random_first_name(gender) + "\";\"" + random_last_name(gender) + "\";\"" + random_middle_name(gender) + "\";\"" + random_date() + "\";\"" + random_gender() +"\";" + str(approved) + "\n")
    pupils_index += 1
f.close()
print("-> pupils.csv generated") # customer

school_index = 1
school_count = 1000
f = open('./csv/school.csv', 'w', encoding='utf-8')
f.write("establishment_id;employee_id;pupil_id;infected_amount;is_necessarily\n")
while (school_index <= school_count):
    f.write(str(random.randint(1, establishments_count)) + ";" + str(random.randint(1, employee_count)) + ";" + str(school_index) + ";" + random_amount() + ";" + str(approved_list[school_index - 1]) + "\n")
    school_index += 1
f.close()
print("-> school.csv generated") # credit_limit

# атриб персонал кол-во, если есть пункт то врачей больше