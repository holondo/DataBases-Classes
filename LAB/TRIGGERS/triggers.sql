CREATE OR REPLACE FUNCTION VerificaAeroporto() RETURNS TRIGGER AS $$
	BEGIN
		PERFORM * FROM GEOCITIES15K WHERE NEW.CITY = GEOCITIES1K.NAME;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'Cidade não encontrada! Operação cancelada.';
			RETURN NULL;
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER TR_Airports
BEFORE INSERT OR UPDATE ON AIRPORTS
FOR EACH ROW EXECUTE procedure VerificaAeroporto();

-- 2
CREATE TABLE Results_Status (
StatusID INTEGER PRIMARY KEY ,
contagem INTEGER ,
FOREIGN KEY ( StatusID ) REFERENCES Status ( StatusID )
);

INSERT INTO Results_Status
	SELECT S . StatusId , COUNT (*)
	FROM Status S
	JOIN Results R ON R . StatusID = S . StatusID
	GROUP BY S . StatusId , S . Status ;
	
CREATE OR REPLACE FUNCTION AtualizaContagem() RETURNS TRIGGER AS $$
	DECLARE
		amnt INTEGER;
		stsID INTEGER;
	BEGIN
		IF TG_OP = 'DELETE' or TG_OP = 'UPDATE' THEN
			UPDATE RESULTS_STATUS SET CONTAGEM = (CONTAGEM-1) WHERE STATUSID = OLD.STATUSID;
			SELECT contagem, statusID from results_status where STATUSID = OLD.STATUSID INTO amnt, stsID;
			RAISE NOTICE 'StatusID: %, Contagem: %', stsID, amnt;
		END IF;
		IF TG_OP = 'INSERT' or TG_OP = 'UPDATE' THEN
			UPDATE RESULTS_STATUS SET CONTAGEM = (CONTAGEM+1) WHERE STATUSID = NEW.STATUSID;
			SELECT contagem, statusID from results_status where STATUSID =  NEW.STATUSID INTO amnt, stsID;
			RAISE NOTICE 'StatusID: %, Contagem: %', stsID, amnt;
			RETURN NEW;
		END IF;
		RETURN OLD;
	END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER TR_ResultsStatus
BEFORE INSERT or UPDATE or DELETE ON RESULTS
FOR EACH ROW EXECUTE PROCEDURE AtualizaContagem();
-- D
CREATE OR REPLACE FUNCTION VerificaStatus() RETURNS TRIGGER AS $$
	BEGIN
		IF NEW.StatusID < 0 THEN
			RAISE EXCEPTION 'StatusID Negativo! Operação cancelada.';
			
			IF TG_OP = 'INSERT' THEN
				RETURN NULL;
			END IF;
			RETURN OLD;
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER TR_Results
BEFORE INSERT OR UPDATE ON RESULTS
FOR EACH ROW EXECUTE PROCEDURE VerificaStatus();