--TABELAO
select * from catalogo c
join fornecedores f on f.f_id = c.f_id
join pecas p on p.p_id = c.p_id;

--a
select distinct f.f_nome from catalogo c
join fornecedores f on f.f_id = c.f_id
join pecas p on p.p_id = c.p_id
where p.cor = 'vermelho';

--T1 <- Sigma(peca.cor = vermelho)(peca)
--T2 <- (CATALOGO * T1) * fornecedores
--T3 <- pi(f_nome)(fornecedores)

--b
select distinct f.f_nome from catalogo c
join fornecedores f on f.f_id = c.f_id
join pecas p on p.p_id = c.p_id
where p.cor = 'vermelho' or f.endereco = 'Sao Carlos';

--T1 <- pecas * catalogo
--T2 <-- fornecedores * T1
--T3 <- sigma(cor == vermelho or endereco == Sao Carlos)
--T4 <- pi(f_nome)T3

--c
(select f.f_nome from catalogo c
join fornecedores f on f.f_id = c.f_id
join pecas p on p.p_id = c.p_id 
where p.cor = 'verde')

INTERSECT

(select f.f_nome from catalogo c
join fornecedores f on f.f_id = c.f_id
join pecas p on p.p_id = c.p_id 
where p.cor = 'vermelho');

--T1 <- PI(f_nome)(Fornecedores * Catalogo *(Sigma(cor = vermelho)(pecas)))
--T2 <- PI(f_nome)(Fornecedores * Catalogo *(Sigma(cor = verde)(pecas)))
--T3 <- T1 INTERSECT T2

--d
select f1.f_id, c1.preco, f2.f_id, c2.preco, c2.p_id, c1.p_id
from fornecedores f1 join catalogo c1 on c1.f_id = f1.f_id, --join comes before next from
	fornecedores f2 join catalogo c2 on c2.f_id = f2.f_id
where f1.f_id <> f2.f_id and c1.p_id = c2.p_id and c1.preco < c2.preco;

--T1 <- aliasF1(f_id, f_nome, endereco)(fornecedores) * aliasC1(f_id, p_id, preco)
--T2 <- aliasF2(f_id, f_nome, endereco)(fornecedores) * aliasC2(f_id, p_id, preco)
--T3 <- T1 theta-join(f1.f_id <> f2.f_id and c1.p_id = c2.p_id and c1.preco < c2.preco) T2
--T4 <- PI(f1.f_id, c1.preco, f2.f_id, c2.preco, c2.p_id, c1.p_id)T3

--e
select p_nome, cor, f_nome, preco 
from pecas 
NATURAL LEFT JOIN catalogo
NATURAL LEFT JOIN fornecedores order by p_nome, f_nome;

--T1 <- pecas natural-left-join catalogo
--T2 <- T1 natural-left-join fornecedores
--T3 <- PI(p_nome, cor, f_nome, preco)(T2)

--f
--T1 <- fornecedores * catalogo
--T2 <- pecas
--T3 <- pi(f_nome, endereco)(T1 / T2)

--g
--T1 <- sigma(cor = vermelho)(pecas)
--T2 <- sigma(cor = verde)(pecas)
--T3 <- PECAS * (FORNECEDOR * CATALOGO)
--T4 <- PI(f_id)((T3  T1) UNION (T3 / T2))

--h 
--T1 <- pecas natural-right-join (fonecedores natural-left-join catalogo)
--T2 <- PI(f_nome, f_id, p_nome, preco)

--i
select p_id, count(f_id) from catalogo
group by p_id
having count(f_id) > 1;

--j
select count(distinct c.p_id) from catalogo c
join fornecedores f on f.f_id = c.f_id
join pecas p on p.p_id = c.p_id
where f.f_nome = 'Joao';

--k
select max(c.preco), min(c.preco), round(avg(c.preco),2) from catalogo c
join fornecedores f on f.f_id = c.f_id
join pecas p on p.p_id = c.p_id
where p.cor = 'verde';

--l
select f.f_nome, count(*) from catalogo c
join fornecedores f on f.f_id = c.f_id
join pecas p on p.p_id = c.p_id
group by f_nome;

--Descreva o resultado das seguintes consultas:
--a
--A consulta resulta em uma coluna de tuplas com o nome dos fornecedores que vendem peças vermelhas com preço menor que 100. O nome pode se repetir, mas referem-se a pessoas diferentes (!=f_id).

--b
--A consulta resulta em um conjunto vazio, uma vez que é feita uma projeção da coluna f_nome logo após da projeção de uma coluna diferente f_id.

--c
--A consulta resulta em uma lista de nomes de fornecedores que vendem ao mesmo tempo, peças vermelhas e verdes, ambas com preço inferior a 100. 
--Todavia, neste caso a consulta não respeita o f_id, assim fornecedores diferentes, com mesmo nome, são considerados equivalentes, podendo comprometer a consulta. 

--d
--A consulta resulta em uma lista de IDs de fornecedores (f_id) que vendem ao mesmo tempo, peças vermelhas e verdes, ambas com preço inferior a 100.

--e
--A consulta resulta em uma lista de nomes de fornecedores (f_nome), os quais estão atrelados a um id unico, oculto a consulta, e que vendem ao mesmo tempo peças vermelhas e verdes, ambas com preço inferior a 100.