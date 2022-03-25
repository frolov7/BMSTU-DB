ALTER TABLE study.establishments
  ADD PRIMARY KEY (id);

ALTER TABLE study.establishments
  ALTER COLUMN address SET NOT NULL;

ALTER TABLE study.establishments
  ALTER COLUMN creation_date SET NOT NULL;

ALTER TABLE study.establishments -- проверка что дата больше 50го года и до сегодня
   ADD CONSTRAINT creation_date_check check (study.establishments.creation_date >= '1950-01-01' and study.establishments.creation_date <= now());

ALTER TABLE study.establishments
  ALTER COLUMN is_vaccination_point SET NOT NULL;

ALTER TABLE study.establishments
  ALTER COLUMN square SET NOT NULL;

ALTER TABLE study.establishments
   ADD CONSTRAINT square_non_negative check (study.establishments.square >= 0); -- площадь больше нуля

ALTER TABLE study.establishments
  ALTER COLUMN people_count SET NOT NULL;

ALTER TABLE study.establishments
   ADD CONSTRAINT people_count_non_negative check (study.establishments.people_count >= 0);
 
ALTER TABLE study.employee
  ADD PRIMARY KEY (id);

ALTER TABLE study.employee
  ALTER COLUMN first_name SET NOT NULL;

ALTER TABLE study.employee
  ALTER COLUMN last_name SET NOT NULL;

ALTER TABLE study.employee
  ALTER COLUMN middle_name SET NOT NULL;

ALTER TABLE study.employee
  ALTER COLUMN birth_date SET NOT NULL;

ALTER TABLE study.employee
   ADD CONSTRAINT birth_date_check check (date_part('year', age(study.employee.birth_date)) >= 18 and study.employee.birth_date <= now());

ALTER TABLE study.employee
  ALTER COLUMN position SET NOT NULL;

ALTER TABLE study.employee
  ADD CONSTRAINT position_check check (study.employee.position = 'teacher' or study.employee.position = 'head_teacher');

ALTER TABLE study.pupils
  ADD PRIMARY KEY (id);

ALTER TABLE study.pupils
  ALTER COLUMN first_name SET NOT NULL;

ALTER TABLE study.pupils
  ALTER COLUMN last_name SET NOT NULL;

ALTER TABLE study.pupils
  ALTER COLUMN middle_name SET NOT NULL;

ALTER TABLE study.pupils
  ALTER COLUMN birth_date SET NOT NULL;

ALTER TABLE study.pupils
   ADD CONSTRAINT birth_date_check check (date_part('year', age(study.pupils.birth_date)) >= 18 and study.pupils.birth_date <= now());

ALTER TABLE study.pupils
  ALTER COLUMN gender SET NOT NULL;

ALTER TABLE study.pupils
  ADD CONSTRAINT gender_check check (study.pupils.gender = 'male' or study.pupils.gender = 'female');

ALTER TABLE study.school 
    ADD CONSTRAINT "FK_establishments_id" FOREIGN KEY ("establishments_id") REFERENCES study.establishments ("id");

ALTER TABLE study.school
    ADD CONSTRAINT "FK_employee_id" FOREIGN KEY ("employee_id") REFERENCES study.employee ("id");

ALTER TABLE study.school
    ADD CONSTRAINT "FK_pupils_id" FOREIGN KEY ("pupils_id") REFERENCES study.pupils ("id");

ALTER TABLE study.school
  ALTER COLUMN infected_amount SET NOT NULL;
 
ALTER TABLE study.school
   ADD CONSTRAINT infected_amount_non_negative check (study.school.infected_amount >= 0);

ALTER TABLE study.school
  ALTER COLUMN is_necessarily SET NOT NULL;

--  ALTER TABLE study.school
--  ALTER COLUMN doctor SET NOT NULL;
 
--ALTER TABLE study.school
--  ALTER COLUMN securit SET NOT NULL;
 
--ALTER TABLE study.school
--  ALTER COLUMN cooker SET NOT NULL;