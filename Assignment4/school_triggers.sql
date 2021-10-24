--1
CREATE OR REPLACE FUNCTION student_capacity() RETURNS TRIGGER AS $student_capacity$
DECLARE
	total_credits integer;
	discipline_credits integer;
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
	
