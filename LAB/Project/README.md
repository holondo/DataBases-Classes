# Projeto Final

O projeto foi desenvolvido em python por meio do framework flask.
Algumas bibliotecas foram utilizadas para otimizar a obtenção dos dados como o psycopg2, o sqlalchemy e o pandas.

## Rodando

Para rodar o programa, siga estas etapas:

- Extraia o zip `pfinalf1.zip` ;
- Entre na pasta `pfinalf1` e rode o comando `pip install -r requirements.txt`, certifique-se de que o pip está instalado na sua máquina;

### Configurando o Banco de Dados
- Rode o servidor do banco de dados localmente;
- Acesse o arquivo config.py e altere as seguintes variáveis de acordo com o seu usuário, senha e nome de banco:
```
DB_USER = 'postgres'
DB_PWD = 'password'
DB_DATABASE = 'f1'
```

### Execução
- Certifique-se de que você tenha o python3 na sua máquina;
- Rode o comando `python app.py` na pasta raiz do projeto.
