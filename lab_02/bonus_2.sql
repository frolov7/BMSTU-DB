drop table Table1;
drop table Table2;

CREATE SCHEMA bonus2;

create table bonus2.Table1 
(
	id int,
	var1 char,
	valid_from_dttm date,
	valid_to_dttm date
);

create table bonus2.Table2 
(
	id int,
	var2 char,
	valid_from_dttm date,
	valid_to_dttm date
);

insert into bonus2.Table1 (id, var1, valid_from_dttm, valid_to_dttm) values (1, 'A', '20180901', '20180915');
insert into bonus2.Table1 (id, var1, valid_from_dttm, valid_to_dttm) values (1, 'B', '20180916', '59991231');
insert into bonus2.Table1 (id, var1, valid_from_dttm, valid_to_dttm) values (2, 'A', '20180916', '59991231');
insert into bonus2.Table1 (id, var1, valid_from_dttm, valid_to_dttm) values (3, 'A', '20180901', '20180920');
insert into bonus2.Table1 (id, var1, valid_from_dttm, valid_to_dttm) values (3, 'B', '20180921', '20180925');
insert into bonus2.Table1 (id, var1, valid_from_dttm, valid_to_dttm) values (3, 'C', '20180926', '59991231');

insert into bonus2.Table2 (id, var2, valid_from_dttm, valid_to_dttm) values (1, 'A', '20180901', '20180918');
insert into bonus2.Table2 (id, var2, valid_from_dttm, valid_to_dttm) values (1, 'B', '20180919', '59991231');
insert into bonus2.Table2 (id, var2, valid_from_dttm, valid_to_dttm) values (3, 'A', '20180901', '20180924');
insert into bonus2.Table2 (id, var2, valid_from_dttm, valid_to_dttm) values (3, 'B', '20180925', '59991231');

SELECT bonus2.Table1.id, bonus2.Table1.var1, bonus2.Table2.var2, 
	CASE WHEN bonus2.Table1.valid_from_dttm <= bonus2.Table2.valid_from_dttm THEN bonus2.Table2.valid_from_dttm
		ELSE bonus2.Table1.valid_from_dttm
	END valid_from_dttm, 
	
	CASE WHEN bonus2.Table1.valid_to_dttm >= bonus2.Table2.valid_to_dttm THEN bonus2.Table2.valid_to_dttm
		ELSE bonus2.Table1.valid_to_dttm
	END valid_to_dttm
	
FROM bonus2.Table1 FULL OUTER JOIN bonus2.Table2 ON bonus2.Table1.id = bonus2.Table2.id
AND bonus2.Table1.valid_from_dttm <= bonus2.Table2.valid_to_dttm
AND bonus2.Table2.valid_from_dttm <= bonus2.Table1.valid_to_dttm
ORDER by id, valid_from_dttm