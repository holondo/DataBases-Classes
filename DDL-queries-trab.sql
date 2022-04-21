insert into federacao(nome) values ('Brasil');

insert into estado(nome, uf) values ('São Paulo', 'SP');
insert into estado(nome, uf) values ('Rio de Janeiro', 'RJ');
insert into estado(nome, uf) values ('Minas Gerais', 'MG');
insert into estado(nome, uf) values ('Paraná', 'PR');

insert into cidade(nome, uf) values ('Barueri', 'SP');
insert into cidade(nome, uf) values ('São Paulo', 'SP');

insert into cidade(nome, uf) values ('Rio de Janeiro', 'RJ');
insert into cidade(nome, uf) values ('Niterói', 'RJ');

insert into cidade(nome, uf) values ('Belo Horizonte', 'MG');
insert into cidade(nome, uf) values ('Varginha', 'MG');

insert into cidade(nome, uf) values ('Foz do Iguaçu', 'PR');
insert into cidade(nome, uf) values ('Curitiba', 'PR');


select * from localidade;
select * from federacao;

select l.id, l.tipo, 
case 
	when l.tipo = 'cidade' then c.nome
	when l.tipo = 'estado' then e.nome
	when l.tipo = 'federacao' then f.nome
end as nome,
case
	when l.tipo = 'cidade' then c.uf
	when l.tipo = 'estado' then e.uf
	else 'Federacao'
end as UF
from localidade l
left join federacao f on l.id = f.id
left join estado e on l.id = e.id
left join cidade c on c.id = l.id;
