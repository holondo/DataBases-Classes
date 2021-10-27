--1
CREATE OR REPLACE FUNCTION student_capacity() RETURNS TRIGGER AS $student_capacity$
DECLARE
	total_credits integer default 0;
	discipline_credits integer default 0;
BEGIN
	SELECT DISCIPLINA.ncred from disciplina into discipline_credits where disciplina.sigla = new.sigla;
	
	select sum(disciplina.ncred) from disciplina into total_credits 
	join matricula on disciplina.sigla = matricula.sigla
	join aluno al on al.nusp = matricula.aluno
	where al.nusp = NEW.aluno
	AND matricula.ano = NEW.ano;
	
	raise notice 'Sigla= %, before credits= %, Total credits: %', NEW.sigla, total_credits, (total_credits + discipline_credits);
	if (total_credits + discipline_credits) > 20 THEN
		RAISE EXCEPTION 'Um aluno nao pode se inscrever em mais de 20 creditos no mesmo ano.';
		Return NULL;
	END IF;
	RETURN NEW;
END;
$student_capacity$ LANGUAGE plpgsql;
--DROP TRIGGER check_student_enrollment on matricula;
CREATE TRIGGER check_student_enrollment
BEFORE INSERT on matricula
for each row execute function student_capacity();

--2
CREATE OR REPLACE FUNCTION check_professor_promotion() RETURNS TRIGGER AS $check_professor_promotion$
BEGIN
	raise notice 'Titulacao anterior: %, Titulacao nova: %', old.titulacao, new.titulacao;
	IF LOWER(OLD.TITULACAO) = LOWER('doutor') or LOWER(OLD.titulacao) = LOWER('doutorado') then
		if LOWER(NEW.TITULACAO) = 'mestre' or lower(NEW.TITULACAO) = 'mestrado' then
			RAISE EXCEPTION 'A titulação do professor nao pode ser atualizada para um status anterior!';
			RETURN NULL;
		end if;

	ELSIF LOWER(OLD.TITULACAO) = 'livre-docente' then
		IF LOWER(NEW.TITULACAO) = ANY(ARRAY['mestre', 'mestrado', 'doutor', 'doutorado']) THEN
			RAISE EXCEPTION 'A titulação do professor nao pode ser atualizada para um status anterior!';
			RETURN NULL;
		end if;

	ELSIF LOWER(OLD.TITULACAO) = 'titular' then
		IF LOWER(NEW.TITULACAO) = ANY(ARRAY['mestre', 'mestrado', 'doutor', 'doutorado', 'livre-docente']) THEN
			RAISE EXCEPTION 'A titulação do professor nao pode ser atualizada para um status anterior!';
			RETURN NULL;
		end if;
	END IF;
	
	RETURN NEW;
END;
$check_professor_promotion$ LANGUAGE plpgsql;
CREATE TRIGGER professor_promotion 
BEFORE UPDATE ON PROFESSOR
FOR EACH ROW EXECUTE PROCEDURE check_professor_promotion();

--3
CREATE OR REPLACE FUNCTION update_subject_mean() RETURNS TRIGGER AS $subject_mean$--PESQUISAR $
DECLARE
	mean NUMERIC(4,2);
	cur_sigla VARCHAR;
BEGIN
	
	IF TG_OP = 'DELETE' THEN
		SELECT matricula.sigla INTO cur_sigla from matricula
		where matricula.sigla = OLD.sigla;
	ELSE
		SELECT matricula.sigla INTO cur_sigla from matricula
		where matricula.sigla = NEW.sigla;
	END IF;
	
	select (sum(nota)/count(nota)) from matricula into mean
	where sigla = cur_sigla;
	
	update disciplina set nota_media = mean 
	where sigla = cur_sigla;
	
	RETURN NULL;
END;
$subject_mean$ LANGUAGE plpgsql;

CREATE TRIGGER subject_mean 
AFTER DELETE OR INSERT OR UPDATE ON matricula
FOR EACH ROW EXECUTE PROCEDURE update_subject_mean();

--4
CREATE OR REPLACE FUNCTION derived_age() RETURNS TRIGGER AS $update_student_age$
DECLARE
	student_age integer;
BEGIN
	SELECT date_part('year', age(new.DATANASC)) FROM ALUNO INTO new.idade;
	
	return NEW;
END;
$update_student_age$ LANGUAGE plpgsql;

CREATE TRIGGER devive_student_age
BEFORE UPDATE ON aluno
FOR EACH ROW EXECUTE PROCEDURE derived_age();

--5
CREATE OR REPLACE FUNCTION check_terceirizado_fc() RETURNS trigger AS
$check_terceirizado_fc$
BEGIN
	PERFORM * FROM l11_terceirizado WHERE TCPF = NEW.PECPF;
	IF FOUND THEN
		RAISE EXCEPTION 'Este funcionário já se encontra na tabela de terceirizados, e não deve ser inserido na tabela de permanentes';
	END IF;
	RETURN NEW;
END;
$check_terceirizado_fc$ LANGUAGE plpgsql;

CREATE TRIGGER check_terceirizado
BEFORE UPDATE OR INSERT ON l10_permanente
FOR EACH ROW EXECUTE PROCEDURE check_terceirizado_fc();

--6
CREATE OR REPLACE FUNCTION check_sala_cinema() RETURNS trigger AS
$check_sala_cinema$
BEGIN

	IF NEW.cinema_onde_ocorre = NEW.id_cinema THEN
		PERFORM * FROM sala WHERE nr_sala = NEW.nr_sala AND id_cinema = NEW.id_cinema;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'Esta sessão deve ocorrer apenas em uma sala que pertença ao seu cinema';
		END IF
	ELSE
		RAISE EXCEPTION 'Sala e local de sessão nao correspondem ';
	END IF;
	
	RETURN NEW;
END
$check_sala_cinema$

CREATE TRIGGER check_sala_cinema
BEFORE UPDATE OR INSERT ON sessao
FOR EACH ROW EXECUTE PROCEDURE check_sala_cinema();

--7
CREATE OR REPLACE FUNCTION matricula_reports() RETURNS TRIGGER AS $matricula_reports$
DECLARE
	CNT INTEGER;
BEGIN
	SELECT COUNT(*) FROM MATRICULA INTO CNT;
	
	if(TG_OP = 'DELETE') then
		raise notice 'Operacao de %: % registros', TG_OP, CNT;
		return OLD;
	END IF;
	
	raise notice 'Operacao de %: % registros', TG_OP, CNT;
	return NEW;
END;
$matricula_reports$ LANGUAGE plpgsql;

CREATE TRIGGER report_matricula_BEFORE
BEFORE UPDATE OR INSERT OR DELETE ON MATRICULA
EXECUTE PROCEDURE matricula_reports();

CREATE TRIGGER report_matricula_AFTER
AFTER UPDATE OR INSERT OR DELETE ON MATRICULA
EXECUTE PROCEDURE matricula_reports();

--8
ALTER TABLE Matricula
ADD aprovacao boolean DEFAULT false;
--
CREATE OR REPLACE FUNCTION matricula_aproval() RETURNS TRIGGER AS $matricula_aproval$
BEGIN
  NEW.aprovacao = (NEW.Nota>=5);
  Return NEW;
END;
$matricula_aproval$ LANGUAGE plpgsql;
--9
CREATE TRIGGER matricula_aproval
BEFORE INSERT OR UPDATE ON matricula
FOR EACH ROW EXECUTE PROCEDURE matricula_aproval();

--10

CREATE OR REPLACE FUNCTION aluno_idade_atualiza() RETURNS void AS $aluno_idade_atualiza$
BEGIN
	UPDATE Aluno SET Idade = date_part('year', age(aluno.DATANASC));
END;
$aluno_idade_atualiza$ LANGUAGE plpgsql;
select aluno_idade_atualiza()

