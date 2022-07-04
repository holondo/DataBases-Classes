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

insert into users values (0, 'admin', 'Admnistrador', null, 'admin');

select * from users;

CREATE OR REPLACE FUNCTION PerformLogin(Username VARCHAR(50), currPassword VARCHAR(50)) RETURNS BOOLEAN as $$
	DECLARE userPassword VARCHAR(50);
	BEGIN
		select password into userPassword from Users where Login = Username;
		IF md5(currPassword) = userPassword THEN
			RAISE NOTICE 'User logged';
			RETURN True;
		ELSE 
			RAISE NOTICE 'Wrong password';
			RETURN False;
		END IF;
	END;
$$ LANGUAGE PLPGSQL;

select PerformLogin('admin', 'admin4');