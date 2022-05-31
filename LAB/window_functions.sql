-- 1
select lt.Raceid, lt.lap, r.year, lt.milliseconds, d.forename, d.surname,
	min(lt.milliseconds) OVER(partition by lt.raceid, lt.lap order by lt.milliseconds),
	max(lt.milliseconds) OVER(partition by lt.raceid, lt.lap )
from laptimes lt
left join driver d 
	on d.driverid = lt.driverid
left join races r
	on r.raceid = lt.raceid;

-- 2
SELECT c.name, c.nationality, c.constructorid, count(r.position) as VITORIAS FROM constructors c 
left join results r
	on r.constructorid = c.constructorid
where r.position = '1'
group by c.name, c.constructorid, c.nationality;

SELECT distinct c.name, c.nationality, c.constructorid,
	count(*) OVER(partition by c.constructorid) as vitorias_scuderia,
	count(*) OVER(Partition by c.nationality) as vitorias_nacionalidade
FROM constructors c
left join results r
	on r.constructorid = c.constructorid
where r.position = '1'
order by vitorias_nacionalidade DESC;

SELECT distinct c.name, c.nationality, c.constructorid,
	count(*) OVER(partition by c.constructorid) as vitorias_scuderia,
	count(*) OVER(Partition by c.nationality) as vitorias_nacionalidade,
	DENSE_RANK() OVER(partition by c.nationality order by 
		(select count(*) from results where results.position = '1' and results.constructorid = c.constructorid) DESC)
FROM constructors c
left join results r
	on r.constructorid = c.constructorid
where r.position = '1'
order by vitorias_nacionalidade DESC;

SELECT distinct c.name, c.nationality, c.constructorid,
	count(*) OVER(partition by c.constructorid) as vitorias_scuderia,
	count(*) OVER(Partition by c.nationality) as vitorias_nacionalidade,
	DENSE_RANK() OVER(partition by c.nationality order by 
		(select count(*) from results where results.position = '1' and results.constructorid = c.constructorid) DESC)
FROM constructors c
left join results r
	on r.constructorid = c.constructorid
where r.position = '1'
order by vitorias_scuderia;

-- 3
/* Para cada corrida e piloto, apresente o tempo médio dos pitstops, ranqueando-os por
sua duração em ordem crescente. Apresente o nome e o ano das corridas, o nome
completo dos pilotos, o tempo médio do piloto em pitstops na corrida e seu rank. */
SELECT
  RACES.NAME,
  RACES.YEAR,
  DRIVER.FORENAME,
  DRIVER.SURNAME,
  RACES.RACEID,
  AVG(PITSTOPS.MILLISECONDS) as TEMPO_MEDIO,
  DENSE_RANK() OVER(PARTITION BY RACES.RACEID ORDER BY AVG(PITSTOPS.MILLISECONDS))
FROM PITSTOPS
JOIN DRIVER ON PITSTOPS.DRIVERID = DRIVER.DRIVERID
JOIN RACES ON PITSTOPS.RACEID = RACES.RACEID
GROUP BY RACES.RACEID, DRIVER.DRIVERID;

--4
SELECT DISTINCT NATIONALITY, ARRAY_AGG(NAME) OVER(PARTITION BY NATIONALITY) FROM CONSTRUCTORS;


--5
SELECT R.RACEID, R.NAME, R.YEAR, D.FORENAME, D.SURNAME, RES.MILLISECONDS,
	RES.MILLISECONDS - LAG(RES.MILLISECONDS) OVER(PARTITION BY R.RACEID ORDER BY RES.MILLISECONDS) as DESVANTAGEM
FROM RESULTS RES
LEFT JOIN DRIVER D
	ON D.DRIVERID = RES.DRIVERID
LEFT JOIN RACES R
	ON R.RACEID = RES.RACEID;
