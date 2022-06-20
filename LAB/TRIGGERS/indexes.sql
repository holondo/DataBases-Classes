CREATE OR REPLACE FUNCTION mede_tempo ( q TEXT )
RETURNS TABLE ( LAT DOUBLE precision, LONG DOUBLE precision, population INTEGER) AS $$

	DECLARE
	tini TIME ;
	tfim TIME ;
	i DOUBLE PRECISION ;
	diff BIGINT ;

	BEGIN

		-- Registra o tempo inicial
		tini = CLOCK_TIMESTAMP () ;
		FOR i IN 0..1000 LOOP
			EXECUTE q ;
		END LOOP ;
		-- Registra o tempo final
		tfim = CLOCK_TIMESTAMP () ;
		-- Calcula a diferenca em milisegundos
		diff = ROUND (( EXTRACT ( EPOCH FROM tfim ) -
		EXTRACT ( EPOCH FROM tini ) ) * 1000) ;
		RAISE NOTICE '% - % = % ' , tfim , tini , diff ;
		-- Retorna o resultado da consulta recebida
		RETURN QUERY EXECUTE q ;
	END ;
$$ LANGUAGE plpgsql ;
drop function mede_tempo;

-- 1
EXPLAIN SELECT forename::TEXT, nationality::TEXT from driver where forename = 'Tim';
select mede_tempo('SELECT forename::TEXT, nationality::TEXT from driver where forename = ''Tim'';');

CREATE INDEX IdxForenameNationality on driver (forename) include (nationality);
--drop INDEX IdxForenameNationality;

select mede_tempo('SELECT forename::TEXT, nationality::TEXT from driver where forename = ''Tim'';');

-- 2
EXPLAIN SELECT name, LAT, LONG, population from geocities15k where country = 'BR' and name like 'Curitiba%';
select mede_tempo('SELECT LAT, LONG, population from geocities15k where name like ''Curitiba%'' and country = ''BR'';');
CREATE INDEX IdxCityName on geocities15k (Name) where country = 'BR';
-- drop index IdxCityName;
select mede_tempo('SELECT LAT, LONG, population from geocities15k where name like ''Curitiba%'' and country = ''BR'';');

-- 3
/* 	Não, B-Trees Não conseguem indexar consultas do tipo LIKE '%valor%', pois a estrutura necessita de um prefixo para
	indexar texto.