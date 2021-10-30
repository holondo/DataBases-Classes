select * from catalogo c
join fornecedores f on f.f_id = c.f_id
join pecas p on p.p_id = c.p_id;

--1
select distinct f.f_nome from catalogo c
join fornecedores f on f.f_id = c.f_id
join pecas p on p.p_id = c.p_id
where p.cor = 'vermelho';

--T1 <- Sigma(peca.cor = vermelho)(peca)
--T2 <- fornecedor * T1

--2
select distinct f.f_nome from catalogo c
join fornecedores f on f.f_id = c.f_id
join pecas p on p.p_id = c.p_id
where p.cor = 'vermelho' or f.endereco = 'Sao Carlos';

--3
(select f.f_nome from catalogo c
join fornecedores f on f.f_id = c.f_id
join pecas p on p.p_id = c.p_id 
where p.cor = 'verde')

INTERSECT

(select f.f_nome from catalogo c
join fornecedores f on f.f_id = c.f_id
join pecas p on p.p_id = c.p_id 
where p.cor = 'vermelho');

--T1 <- PI(f_nome)Fornecedores * Catalogo *(Sigma(cor = vermelho)(pecas))
--T2 <- 
--
--T1 <- Sigma(cor = verde)(pecas)
--T2 <- Fonecedores * Catalogo * T1

--4

select f1.f_id, c1.preco, f2.f_id, c2.preco, c2.p_id, c1.p_id
from fornecedores f1 join catalogo c1 on c1.f_id = f1.f_id, --join comes before next from
fornecedores f2 join catalogo c2 on c2.f_id = f2.f_id
where f1.f_id <> f2.f_id and c1.p_id = c2.p_id and c1.preco < c2.preco;

--5
select p_nome, cor, f_nome, preco 
from pecas 
NATURAL LEFT JOIN catalogo
NATURAL LEFT JOIN fornecedores order by p_nome, f_nome;

--6
select f_nome, p_id
from fornecedores, catalogo
where fornecedores.f_id = CATALOGo.f_id;
