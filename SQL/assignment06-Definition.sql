CREATE TABLE Fornecedores (
 f_id INTEGER NOT NULL,
 f_nome VARCHAR(100),
 endereco VARCHAR(200),

 CONSTRAINT Forn_pk PRIMARY KEY(f_id)
);

CREATE TABLE Pecas (
 p_id INTEGER NOT NULL,
 p_nome VARCHAR(100),
 cor VARCHAR(100),

 CONSTRAINT Pecas_PK PRIMARY KEY(p_id)
);

CREATE TABLE Catalogo (
 f_id INTEGER NOT NULL,
 p_id INTEGER NOT NULL,
 preco NUMERIC(5,2),

 CONSTRAINT Cat_pk PRIMARY KEY(f_id, p_id),
 CONSTRAINT Cat_fk1 FOREIGN KEY(f_id) REFERENCES Fornecedores(f_id),
 CONSTRAINT Cat_fk2 FOREIGN KEY(p_id) REFERENCES Pecas(p_id)
);

insert into pecas values(100,'bobina','vermelho');
insert into pecas values(200,'vela','vermelho');
insert into pecas values(300,'platinado','vermelho');
insert into pecas values(400,'radiador','verde');
insert into pecas values(500,'bateria','verde');
insert into pecas values(600,'calota','verde');
insert into pecas values(700,'correia','verde');
insert into pecas values(800,'pistao','verde');
insert into pecas values(900,'valvula','verde');
insert into pecas values(1000,'rele','verde');




INSERT INTO FORNECEDORES VALUES(10,'Acme','Sao Carlos');
INSERT INTO FORNECEDORES VALUES(20,'Freitas','Sao Carlos');
INSERT INTO FORNECEDORES VALUES(30,'SaoCarlosPecas','Sao Carlos');
INSERT INTO FORNECEDORES VALUES(40,'Rodobens','Sao Paulo');
INSERT INTO FORNECEDORES VALUES(50,'Escania','Sao Paulo');
INSERT INTO FORNECEDORES VALUES(60,'Ford','Sao Paulo');
INSERT INTO FORNECEDORES VALUES(70,'Fiat','Sao Caetano');
INSERT INTO FORNECEDORES VALUES(80,'Kia','Sao Caetano');
INSERT INTO FORNECEDORES VALUES(90,'Honda','Sao Caetano');

INSERT INTO Catalogo VALUES(10,100,25);
INSERT INTO Catalogo VALUES(10,300,79);
INSERT INTO Catalogo VALUES(10,500,100);
INSERT INTO Catalogo VALUES(20,200,14);
INSERT INTO Catalogo VALUES(20,400,800);
INSERT INTO Catalogo VALUES(20,600,945);
INSERT INTO Catalogo VALUES(30,100,26);
INSERT INTO Catalogo VALUES(30,200,13);
INSERT INTO Catalogo VALUES(30,300,78);
INSERT INTO Catalogo VALUES(40,400,900);
INSERT INTO Catalogo VALUES(40,500,110);
INSERT INTO Catalogo VALUES(40,600,867);
INSERT INTO Catalogo VALUES(50,100,24);
INSERT INTO Catalogo VALUES(50,200,12);
INSERT INTO Catalogo VALUES(50,600,753);
INSERT INTO Catalogo VALUES(60,100,25);
INSERT INTO Catalogo VALUES(60,500,150);
INSERT INTO Catalogo VALUES(60,600,999);
INSERT INTO Catalogo VALUES(70,200,11);
INSERT INTO Catalogo VALUES(70,300,77);
INSERT INTO Catalogo VALUES(70,500,160);
INSERT INTO Catalogo VALUES(80,200,10);
INSERT INTO Catalogo VALUES(80,300,70);
INSERT INTO Catalogo VALUES(80,400,700);
INSERT INTO Catalogo VALUES(90,100,28);
INSERT INTO Catalogo VALUES(90,400,600);
INSERT INTO Catalogo VALUES(90,600,800);
INSERT INTO Catalogo VALUES(90,900,650);
INSERT INTO Catalogo VALUES(90,1000,340);
