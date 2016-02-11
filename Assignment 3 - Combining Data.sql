#----Part One: Load tb file in SQL

DROP TABLE IF EXISTS tb;

CREATE TABLE tb 
( country varchar(100) NOT NULL,
  year int NOT NULL,
  sex varchar(6) NOT NULL,
  child int NULL,
  adult int NULL,
  elderly int NULL
);

SELECT * FROM tb;

LOAD DATA INFILE 'tb.csv'
INTO TABLE tb
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(country, year, sex, @child, @adult, @elderly)
SET
child = nullif(@child,-1),
adult = nullif(@adult,-1),
elderly = nullif(@elderly,-1)
;



#----Part Two: Create tb_cases table from tb table
DROP TABLE IF EXISTS tb_cases;

CREATE TABLE tb_cases AS
	SELECT country, year, sex, child+adult+elderly AS cases
FROM tb;

SELECT * FROM tb_cases;



#---Part Three: Load population table in SQL
DROP TABLE IF EXISTS population;

CREATE TABLE population
( country varchar(100) NOT NULL,
  year int NOT NULL,
  population int NOT NULL
);

LOAD DATA INFILE 'population.csv'
INTO TABLE population
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(country, year, population)
;

SELECT * FROM population;



#---Part Four: Join tables
DROP TABLE IF EXISTS tb_population;

CREATE TABLE tb_population AS
	SELECT tbc.country, tbc.year, SUM(tbc.cases) as 'No. Cases', p.population, SUM(tbc.cases)/p.population AS rate
    FROM tb_cases tbc
    LEFT JOIN population p ON p.country = tbc.country AND tbc.year = p.year
    WHERE tbc.cases > 0
    GROUP BY tbc.country, tbc.year
    ORDER BY tbc.country, tbc.year;

SELECT * FROM tb_population;


#---Part Five: Test SELECT statement for request
SELECT country, year, rate FROM tb_population;


#---Part Six: Export/Save as new file:
SELECT country, year, rate
	INTO OUTFILE '/Users/Public/tb_population.csv'
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '\n'
FROM tb_population