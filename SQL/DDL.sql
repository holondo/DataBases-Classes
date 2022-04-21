CREATE TABLE individuo
(
	nome VARCHAR(100) NOT NULL,
	CPF VARCHAR(11),
	status_ficha bool,
	
	CONSTRAINT pk_individuo PRIMARY KEY(CPF) 
);

CREATE TABLE processo_judicial
(
	num_processo SERIAL,
	CPF VARCHAR(11),
	status_procedente BOOL,
	data_julgamento DATE,
	
	CONSTRAINT pk_processo_judicial PRIMARY KEY(num_processo),
	CONSTRAINT fk_individuo_processo FOREIGN KEY(CPF) REFERENCES individuo(CPF)
);

CREATE TABLE partido
(
	cod_partido SERIAL,
	nome VARCHAR(100) NOT NULL,
	
	CONSTRAINT pk_partido PRIMARY KEY(cod_partido)
);

CREATE TABLE candidato
(
	CPF VARCHAR(11),
	partido integer,
	
	CONSTRAINT pk_candidato PRIMARY KEY(CPF),
	CONSTRAINT fk_individuo_candidato FOREIGN KEY (CPF) REFERENCES individuo(CPF),
	CONSTRAINT fk_candidato_partido FOREIGN KEY (partido) REFERENCES partido(cod_partido)
	
);

CREATE TABLE programa_partido
(
	cod_partido integer,
	descricao VARCHAR(500),
	
	CONSTRAINT pk_programa PRIMARY KEY(cod_partido),
	CONSTRAINT fk_programa_partido FOREIGN KEY(cod_partido) REFERENCES partido(cod_partido)
);

CREATE TABLE individuo_juridico
(
	CNPJ VARCHAR(14),
	nome VARCHAR(100) NOT NULL,
	
	CONSTRAINT pk_juridico PRIMARY KEY(CNPJ)
);

CREATE TABLE doador_campanha
(
	cod_doador serial,
	CPF VARCHAR(11),
	CNPJ VARCHAR(14),
	tipo BOOL,
	
	CHECK((CPF != NULL and CNPJ = NULL and tipo = FALSE) or (CPF = NULL and CNPJ != NULL and tipo = TRUE)),
	CONSTRAINT pk_doador PRIMARY KEY(cod_doador),
	CONSTRAINT fk_doador_fisico FOREIGN KEY(CPF) REFERENCES individuo(CPF),
	CONSTRAINT fk_doador_juridico FOREIGN KEY(CNPJ) REFERENCES individuo_juridico(CNPJ)
);

CREATE DOMAIN tipo_localidade
as VARCHAR(9)
CHECK(VALUE in ('cidade', 'estado', 'federacao'));

CREATE TABLE localidade
(
	id serial,
	tipo tipo_localidade NOT NULL,
	num_habitantes integer,
	
	CONSTRAINT pk_localidade PRIMARY KEY(id)
);

CREATE TABLE federacao
(
	id integer,
	nome VARCHAR(100) NOT NULL,
	
	CONSTRAINT pk_federacao PRIMARY KEY(id),
	CONSTRAINT fk_federacao FOREIGN KEY(id) REFERENCES localidade(id),
	CONSTRAINT un_federacao UNIQUE(nome)
);

CREATE DOMAIN UnidadeFederativa AS VARCHAR(2)
CHECK (VALUE IN ('RJ','SP','ES','MG','PR','SC','RS','MS','GO','AC','AL','AP','AM','BA','CE','DF','MA','MT','PA','PB','PE','PI','RN','RO','RR','SE','TO'));

CREATE TABLE estado
(
	id integer,
	UF UnidadeFederativa,
	nome varchar(100),
	
	CONSTRAINT pk_estado PRIMARY KEY(id),
	CONSTRAINT fk_estado FOREIGN KEY(id) REFERENCES localidade(id),
	CONSTRAINT un_UF UNIQUE(UF)
);

CREATE TABLE cidade
(
	id integer,
	nome VARCHAR(100),
	UF unidadefederativa,
	
	CONSTRAINT pk_cidade PRIMARY KEY(id),
	CONSTRAINT fk_id_cidade FOREIGN KEY(id) REFERENCES localidade(id),
	CONSTRAINT fk_uf_cidade FOREIGN KEY(UF) REFERENCES estado(UF),
	CONSTRAINT un_cidade_uf UNIQUE(nome, UF)
);

CREATE TABLE cargo
(
	nome VARCHAR(100),
	localidade integer,
	quant_eleitos integer DEFAULT 0,
	
	CONSTRAINT pk_cargo PRIMARY KEY(nome, localidade),
	CONSTRAINT fk_localidade_cargo FOREIGN KEY(localidade) references localidade(id)
);

--------------------------CANDIDATURA------------------
CREATE TABLE CANDIDATURA
(
	cod_candidatura serial,
	nome_cargo varchar(100),
	localidade integer,
	CPF_candidato varchar(11),
	ano INTEGER NOT NULL,
	vice varchar(11),
	
	CONSTRAINT pk_candidatura PRIMARY KEY(cod_candidatura),
	CONSTRAINT un_cadidato_ano UNIQUE(CPF_candidato, ano),
	--vice?
	CONSTRAINT fk_candidatura_cargo FOREIGN KEY(nome_cargo, localidade) REFERENCES cargo(nome, localidade),
	CONSTRAINT fk_candidatura_vice FOREIGN KEY(vice) REFERENCES candidato(CPF)
);

