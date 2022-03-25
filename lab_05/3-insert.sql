COPY study.establishments(address, creation_date, is_vaccination_point, square, people_count)
FROM 'C:/123/establishments.csv' DELIMITER ';' CSV HEADER;

COPY study.employee(first_name, last_name, middle_name, birth_date, position)
FROM 'C:/123/employee.csv' DELIMITER ';' CSV HEADER;

COPY study.pupils(first_name, last_name, middle_name, birth_date, gender, is_vaccinated)
FROM 'C:/123/pupils.csv' DELIMITER ';' CSV HEADER;

COPY study.school(establishments_id, employee_id, pupils_id, infected_amount, is_necessarily)
FROM 'C:/123/school.csv' DELIMITER ';' CSV HEADER;