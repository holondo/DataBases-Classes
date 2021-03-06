CREATE TABLE USERS(
	UserId integer,
	Login VARCHAR(50),
	Tipo VARCHAR(50),
	IdOriginal integer,
	Password varchar(50),
	CONSTRAINT pk_users PRIMARY KEY(UserID)
);

CREATE OR REPLACE FUNCTION EncryptPassword() RETURNS TRIGGER AS $$
	BEGIN
		NEW.Password = md5(NEW.Password);
		RETURN NEW;
	END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER tr_encrypt 
BEFORE INSERT OR UPDATE ON Users
FOR EACH ROW EXECUTE PROCEDURE EncryptPassword();

insert into users values (0, 'admin', 'Administrador', null, 'admin');

CREATE TABLE log_table(
	UserID integer,
	Access TIMESTAMP,
	constraint pk_log PRIMARY KEY(UserID, Access),
	constraint fk_log_user FOREIGN KEY(UserID) references Users(UserId)
);

CREATE OR REPLACE FUNCTION PerformLogin(Username VARCHAR(50), currPassword VARCHAR(50)) RETURNS BOOLEAN as $$
	DECLARE userPassword VARCHAR(50);
	DECLARE ID INTEGER;
	BEGIN
		select password, UserID into userPassword, ID from Users where Login = Username;
		IF md5(currPassword) = userPassword THEN
			RAISE NOTICE 'User logged';
			insert into log_table values (ID, CURRENT_TIMESTAMP);
			RETURN True;
		ELSE 
			RAISE NOTICE 'Wrong password';
			RETURN False;
		END IF;
	END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION InsertUsers() RETURNS TRIGGER AS $$
	DECLARE max_id INTEGER;
	DECLARE type VARCHAR(50);
	DECLARE suffix VARCHAR(50);
	DECLARE ref VARCHAR(100);
	DECLARE idorig INTEGER;
	BEGIN
		select max(userid) into max_id from users;
		if TG_TABLE_NAME = 'constructors' then
			type = 'Escuderia';
			suffix = '_c';
			ref = NEW.constructorref;
			idorig = NEW.constructorid;
		else
			type = 'Piloto';
			suffix = '_d';
			ref = NEW.driverref;
			idorig = NEW.driverid;
		end if;
		
		perform * from users where login = concat(ref, suffix);
		IF FOUND THEN
			raise notice 'Usuário ja cadastrado';
			return NULL;
		END IF;
		insert into USERS values(max_id + 1, concat(ref, suffix), type, idorig, ref);
		return NEW;			
	END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER tr_insert_driver
BEFORE INSERT on driver
FOR EACH ROW EXECUTE PROCEDURE InsertUsers();

CREATE TRIGGER tr_insert_scuderia
BEFORE INSERT on constructors
FOR EACH ROW EXECUTE PROCEDURE InsertUsers();

-- LOGIN
CREATE OR REPLACE FUNCTION InsertUser() RETURNS TRIGGER AS $$
	BEGIN
		NEW.userid = (select max(userid)+1 from users);
		RETURN NEW;
	END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER tr_insert
BEFORE INSERT ON Users
FOR EACH ROW EXECUTE PROCEDURE InsertUser();


insert into users
	(select 
	 	null,
		concat(con.constructorref, '_c'),
	 	'Escuderia',
	 	con.constructorid,
	 	con.constructorref
	 from constructors con
	 where con.constructorid < (select max(constructorid) from constructors)
);

insert into users
	(select 
	 	null,
		concat(driverref, '_d'),
	 	'Piloto',
	 	driverid,
	 	driverref
	 from driver
	 where driverid < (select max(driverid) from driver)
);
	
	