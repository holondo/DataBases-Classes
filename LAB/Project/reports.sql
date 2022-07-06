-- admin

--1
select s.status, rs.contagem from status s
natural left join results_status rs
order by rs.contagem desc nulls last;

select s.status, count(re.*) from status s
right join results re
	on re.statusid = s.statusid
group by s.status
order by 2 desc nulls last;


-- Escuderia
--3
CREATE OR REPLACE FUNCTION FullName(CurrDriverId INTEGER) RETURNS VARCHAR(100) AS $$
	DECLARE fname VARCHAR(100);
	BEGIN
		select concat(forename, ' ', surname) into fname from driver where driverid = CurrDriverId;
		if fname is null then
			fname = 'Admin';
		end if;
		return fname;
	END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION GetDriversReport_Scuderia(CurrConstructorId INTEGER) RETURNS TABLE(Nome VARCHAR(100), Vitorias INTEGER) AS $$
	BEGIN
		return query(
			select FullName(res.driverid) as Nome, 
				(select count(position) from results where driverid = res.driverid and constructorid = CurrConstructorId and position = '1')::INTEGER as vitorias
			from results res
			where constructorid = CurrConstructorId
			group by res.driverid
			order by vitorias desc
		);
	END;
$$ LANGUAGE PLPGSQL;
			
CREATE INDEX idx_3 ON RESULTS (constructorid) include (driverid); 


-- 4
CREATE OR REPLACE FUNCTION GetStatusReport_Scuderia(CurrConstructorId INTEGER) RETURNS TABLE(Status VARCHAR(100), Quantidade INTEGER) AS $$
	BEGIN
		return query(
			select s.status, count(s.status)::INTEGER as Quantidade from status s
			left join results res
				on s.statusid = res.statusid
			where res.constructorid = CurrConstructorId
			group by s.status		
			order by Quantidade desc
		);
	END;
$$ LANGUAGE PLPGSQL;

-- Driver
-- 5
CREATE OR REPLACE FUNCTION GetVictoryReport_Driver(CurrDriverId INTEGER) RETURNS TABLE(Ano VARCHAR(100), Corrida VARCHAR(100), Vitorias INTEGER) AS $$
	BEGIN
		return query(
			select ra.year, ra.name, count(re.position)::INTEGER 
			from results re
			left join races ra
				on re.raceid = ra.raceid
			where
				re.driverid = CurrDriverId
				and re.position = '1'
			group by ROLLUP(ra.year, ra.name)
		);
	END;
$$ LANGUAGE PLPGSQL;

-- 6
CREATE OR REPLACE FUNCTION GetStatusReport_Driver(CurrDriverId INTEGER) RETURNS TABLE(Status VARCHAR(100), Quantidade INTEGER) AS $$
	BEGIN
		return query(
			select s.status, count(s.status)::INTEGER as Quantidade from status s
			left join results res
				on s.statusid = res.statusid
			where res.driverid = CurrDriverId
			group by s.status		
			order by Quantidade desc
		);
	END;
$$ LANGUAGE PLPGSQL;

/*
select 
	case
		when (ra.year not null) then '* Todos * '
		else
			ra.year
	end as Ano,
	case
		when (ra.name not null) then '* Todas *'
		else
			ra.name
	end as Corrida,
	count(re.position) 
from results re
left join races ra
	on re.raceid = ra.raceid
where
	re.driverid = 1
	and re.position = '1'
group by ROLLUP(1, 2);

select count(distinct driverid) from results where constructorid = 4;
select max(ra.year) from results re
left join races ra
on re.raceid = ra.raceid;
select max(year) from races;

update Users set tipo = 'Administrador' where tipo = 'Admnistrador';
update Users set password = 'admin' where userid = 0;
delete *
from Users;
select performlogin('admin', 'admin');

select fullname(dr.driverid), dr.dateofbirth, dr.nationality
            from driver dr
            right join
                (select distinct driverid from results where constructorid = 3) as res
                    on res.driverid = dr.driverid
            where dr.forename like '%%';*/


