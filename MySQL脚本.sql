#====================================================表创建复制索引================================================

CREATE TABLE t_1(
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	NAME VARCHAR(32)
);

#查看表
SHOW TABLES;

#查看表结构
DESC t_1;

#表复制
CREATE TABLE t_3 LIKE t_2;
INSERT INTO t_3 SELECT * FROM t_1
SELECT * FROM t_3

SELECT * FROM t_1;
#添加列
ALTER TABLE t_1 ADD COLUMN pwd VARCHAR(32) ;

#删除列
ALTER TABLE t_1 DROP COLUMN pwd;

#修改列
ALTER TABLE t_1 MODIFY pwd VARCHAR(64)


INSERT INTO t_1(NAME,pwd) VALUES("u2222","123"),("u3333","123"); 

INSERT INTO t_1(NAME,pwd) VALUES("u4","123"),("u5","123"); 


CREATE TABLE t_2 LIKE t_1

#创建索引================
CREATE INDEX index_name ON t_1(NAME);

#查看索引
SHOW INDEX FROM t_1;

DROP INDEX index_name ON t_1(NAME)
#表结构
DESC t_1;

#删除主键索引（如果自增则删除不了）
ALTER TABLE t_1 DROP PRIMARY KEY

#去自增
ALTER TABLE t_1 MODIFY id INT UNSIGNED NOT NULL;

#加自增
ALTER TABLE t_1 MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY;


#普通索引允许被索引的数据列包含重复的值，唯一索引则不然

ALTER TABLE t_1 ADD UNIQUE(NAME)
SHOW INDEX FROM t_1;

ALTER TABLE t_1 DROP INDEX NAME

#创建视图================

CREATE VIEW view_t1_1 AS SELECT * FROM t_1 WHERE id>3;

SELECT * FROM view_t1_1;

#删除视图
DROP VIEW view_t1;

#删除了视图依赖的表，视图也将无法查询


#====================================================内置函数================================================

#字符串连接
SELECT CONCAT("hello","world");

SELECT CONCAT(NAME,pwd) FROM t_1;

SELECT LCASE("Hello") l,UCASE("hello") u;

#随机数(0到1)
SELECT RAND();
#时间
SELECT NOW();

#====================================================预处理语句================================================

#预处理语句---------------
PREPARE stmt1 FROM 'select * from t_1 where id>?';

#设置一个变量
SET @i=1;

EXECUTE stmt1 USING @i;

DROP PREPARE stmt1;

#====================================================事务处理================================================

#关闭自动提交
SET autocommit=0;

SELECT * FROM t_1;

DELETE FROM t_1 WHERE id=1;

#记录一个还原点
SAVEPOINT p1;

DELETE FROM t_1 WHERE id=2;
#记录一个还原点
SAVEPOINT p2;

ROLLBACK TO p1;

#还原到原始点
ROLLBACK;

#查看autocommit值
SELECT @@autocommit;

#====================================================存储过程================================================
SHOW PROCEDURE STATUS;

SELECT * FROM t_2;

#DELIMITER是分割符的意思，因为MySQL默认以”;”为分隔 符，
#如果我们没有声明分割符，那么编译器会把存储过程当成SQL语句进行处理，
#则存储过程的编译过程会报错
DELIMITER // 

#
DELIMITER //
  CREATE PROCEDURE myselect(OUT s INT)
    BEGIN
      SELECT COUNT(*) INTO s FROM t_2;
    END
    //
DELIMITER ;

#
DELIMITER //
CREATE PROCEDURE p2()
BEGIN
SET @i=3;
WHILE @i<=100 DO
INSERT INTO t_2(NAME) VALUES(CONCAT("user",@i));
SET @i=@i+1;
END WHILE;
END//
DELIMITER ;

#查看存储过程
SHOW CREATE PROCEDURE p2;

SELECT * FROM t_2;
#执行存储过程
CALL p2();

#====================================================触发器================================================

#delete 是一行一行的删除
DELETE FROM t_1;

#删除所有数据
TRUNCATE t_2;

SELECT * FROM t_1;
SELECT * FROM t_2;


#触发器，新增
DELIMITER //
CREATE TRIGGER tg1 BEFORE INSERT ON t_1 FOR EACH ROW
BEGIN
INSERT INTO t_2(NAME) VALUES(new.name);
END//
DELIMITER ;


INSERT INTO t_1(NAME) VALUES(CONCAT("user",1));

#查看触发器
SHOW TRIGGERS;

#插入多条数据
INSERT INTO t_1(NAME) VALUES(1),(2),(3)


#触发器，删除
DELIMITER //
CREATE TRIGGER tg2 BEFORE DELETE ON t_1 FOR EACH ROW
BEGIN
DELETE FROM  t_2 WHERE id=old.id;
END//
DELIMITER ;


DELETE FROM t_1 WHERE id=7

#====================================================重排auto_increment================================================
#清空表时，不能用delete
DELETE FROM t_1;

#而是要用truncate，这样auto_increment就恢复成1了
TRUNCATE t_1;
TRUNCATE t_2;

#或者清空内容后用alter
ALTER TABLE t_1 AUTO_INCREMENT=1;



#====================================================常见技巧================================================

#正则表达式
SELECT "Mysql is very good!" REGEXP "^Mysql";

SELECT id,NAME FROM t_1 WHERE NAME REGEXP "^1" ;


#随机数
SELECT RAND()*100;

#随机拿记录
SELECT * FROM t_1 ORDER BY RAND();

CALL p2();

SELECT * FROM t_2 WHERE id<10 ORDER BY RAND();


#====================================================Group BY、WithRollUp================================================
SELECT * FROM t_2 GROUP BY NAME,id;

#使用with rollup关键字后，统计出更多的信息，但不可以和ordery by 同时使用
SELECT * FROM t_2 GROUP BY NAME,id WITH ROLLUP;


#===================================================MYSQL语句优化的一般步骤================================================
#通过show status 了解各种SQL的执行频率

#show [session|global] status ;session默认，表示当前连接；global表示自数据库启动至今 

SHOW SESSION STATUS;

SHOW STATUS LIKE 'Com_%';

SHOW STATUS LIKE 'Com_insert%';

SHOW STATUS LIKE 'Com_select%';

SHOW STATUS LIKE 'Com_update%';

SHOW STATUS LIKE 'Com_delete%';

#innodb引擎增删查改影响行数统计
SHOW STATUS LIKE 'innodb_rows%';


#连接数
SHOW STATUS LIKE 'connections'

#服务器已经工作的秒数
SHOW STATUS LIKE 'uptime';

#慢查询是否开启
SHOW VARIABLES LIKE 'slow_queries';

SHOW VARIABLES LIKE '%long%';


SHOW STATUS LIKE 'uptime';


#定位执行效率较低的语句
EXPLAIN SELECT * FROM t_2;

DESC SELECT * FROM t_2;

#重点看影响行数rows  select_type possible_keys
#select_type simple 单表查询；Primary 主查询；Union
#type :system-表仅一行；const-只一行匹配；all-全表扫描得到
#

SELECT * FROM t_2 WHERE NAME='user1';

#未加索引，全表扫描
DESC SELECT * FROM t_2 WHERE NAME='user1';

#范围查询
DESC SELECT * FROM t_2 WHERE id>3;

#加上索引
ALTER TABLE t_2 ADD INDEX index_name(NAME);
#加上索引后，影响行数为1


#===================================================索引问题================================================
#MyISAM存储引擎表数据和索引是自动分开存储，InnoDB是存储在同一个表空间里面


DESC SELECT * FROM t_2 WHERE NAME='user1';


SHOW INDEX FROM t_2;

#索引用于快速查找出某个列中有一特定值的行。对盯关列使用索引是提高select操作性能的最佳途径

#使用like的查询，后面如果是常量并且只有%不在第一个字符，索引才可能会被使用

#没用到索引
DESC SELECT * FROM t_2 WHERE NAME LIKE '%u';

#用到了索引
DESC SELECT * FROM t_2 WHERE NAME LIKE 'u%';

#用到了索引
DESC SELECT * FROM t_2 WHERE NAME IS NULL;


#存在索引但不使用索引=================================
#如果mysql估计使用索引比全表扫描更慢，则不使用索引
#例如列key_part1均匀分布 在1到100之间，查询时使用索引就不是很好
#查询时，where or之间和之后的条件都要加索引，否则失效（and可以用到索引）

#测试
#删除索引
ALTER TABLE t_2 DROP INDEX index_name;

SHOW INDEX FROM t_2;
SELECT * FROM t_2;
#其中一列没加索引，则and可以用到索引
DESC SELECT * FROM t_2 WHERE id=4 AND NAME='user3';
#其中一列没加索引，则or用不到索引 key列=null
DESC SELECT * FROM t_2 WHERE id=4 OR NAME='user3';


ALTER TABLE t_2 ADD INDEX index_name(NAME);

DESC t_2;
#name字段为varchar，数据类型不一致，用整型时，索引失效
DESC SELECT * FROM t_2 WHERE NAME=1;

#如果索引正在工作，Hander_read_key的值将很高
#这个值代表一个行被索引值读的次数

#Hander_read_rnd_nnex的值意味着查询运行低效，并且应该建索引补救


SHOW STATUS LIKE 'Handler_read%';

#===================================================表检测================================================
CREATE VIEW v_t2 AS SELECT * FROM t_2 WHERE id>2 AND id<100;

SELECT * FROM v_t2;

CHECK TABLES t_2;
#对空间碎片进行整合，优化
OPTIMIZE TABLE t_2;



#导出表 cd mysql/bin
mysqldump -uroot -p123 test>/temp.text.sql;

#导入表
mysql -uroot -p123 test </temp/test.sql

SELECT * FROM t_2 INTO OUTFILE  'test.sql'

#===================================================表检测================================================
#bin log日志
SHOW VARIABLES LIKE '%bin%';

SHOW VARIABLES LIKE '%slow%';

#vi /etc/my.cnf
log_slow_queries=slow.log
long_query_time=5


