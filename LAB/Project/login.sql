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

select PerformLogin('admin', 'admin');
SELECT * FROM log_table;