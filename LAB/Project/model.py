from dataclasses import dataclass
from datetime import datetime
import pandas as pd
import psycopg2
import config


# enum Type
@dataclass
class User():
    user_id:int
    username:str
    type:str
    id_original:int
    full_name:str
    

class Formula1:
    def __init__(self, username:str, password:str, database:str) -> None:
        self.connection = psycopg2.connect(
            host='localhost',
            database=database,
            user=username,
            password=password
        )
        self.cursor = self.connection.cursor()

    def perform_login(self, username:str, password:str) -> User:
        '''
        Returns:
            * User
        '''
        self.cursor.execute(f"select PerformLogin('{username}', '{password}');")
        response = self.cursor.fetchone()

        if True in response:
            self.cursor.execute(
                f"""select 
                    userid,
                    login, 
                    tipo, 
                    idoriginal, 
                    CASE 
                        when tipo = 'Administrador' then 'Admin'
                        when tipo = 'Escuderia' then 
                            (select name from constructors where constructorid = idoriginal limit 1)
                        else
                            FullName(idoriginal)
                    END
                    from users
                    where login = '{username}';"""
            )
            infos = self.cursor.fetchone()
            logged_user = User(infos[0], infos[1], infos[2], infos[3], infos[4])
        
            return logged_user
        
        raise ValueError('Wrong login or password')

    
    def get_dataframe(self, query:str) -> pd.DataFrame:
        table = pd.read_sql(query, self.connection)
        return table

    def dataframe_to_html_table(self, df:pd.DataFrame, width:str=None, remove_index:bool=False) -> str:
        df.style.format("{:.2f}")

        df_style = df.style

        if remove_index:
            df_style = df_style.hide_index()

        if width:
            df_style = df_style.set_table_attributes(f'width={width}')

        df_html = df_style.render(precision=2)

        return df_html
    
    def get_admin_data(self) -> dict[str, int]:
        dataAdmin = {"nroPilotos": 0, "nroEscuderias": 0, "nroCorridas": 0, "nroTemporadas": 0}
        self.cursor.execute(query='SELECT COUNT (*) from DRIVER;')
        dataAdmin['nroPilotos'] =  self.cursor.fetchone()[0]
        self.cursor.execute(query='SELECT COUNT(*) FROM CONSTRUCTORS;')
        dataAdmin['nroEscuderias'] =  self.cursor.fetchone()[0]
        self.cursor.execute(query='SELECT COUNT(*) FROM RACES;')
        dataAdmin['nroCorridas'] =  self.cursor.fetchone()[0]
        self.cursor.execute(query='SELECT COUNT(*) FROM SEASONS;')
        dataAdmin['nroTemporadas'] =  self.cursor.fetchone()[0]
        return dataAdmin
    
    # def create_piloto(self, username:str, password:str) -> str:
    #     self.cursor.execute(query ="")
    #     return 'OK'

    
    def get_tabelas_escuderia(self, user:User):
        if not user.type == 'Escuderia':
            raise ValueError('Usu??rio n??o ?? uma escuderia.')

        vitorias = self.get_dataframe(f"select count(*) from results where constructorid = {user.id_original} and position::VARCHAR(10) = '1';")
        pilotos_amnt = self.get_dataframe(f"select count(distinct driverid) from results where constructorid = {user.id_original};")
        ano_inicio = self.get_dataframe(f"""
            select min(ra.year) from results re
            left join races ra
            on re.raceid = ra.raceid
            where re.constructorid = '{user.id_original}';
        """)
        ano_fim = self.get_dataframe(f"""
            select max(ra.year) from results re
            left join races ra
            on re.raceid = ra.raceid
            where re.constructorid = '{user.id_original}';
        """)
        
        vitorias = vitorias.iloc[0, 0]
        pilotos_amnt = pilotos_amnt.iloc[0, 0]
        ano_inicio = ano_inicio.iloc[0, 0]
        ano_fim = ano_fim.iloc[0, 0]
        
        overview = pd.DataFrame(data=[vitorias, pilotos_amnt, ano_inicio, ano_fim], index=['Vit??rias', 'Quantidade de pilotos', 'Ano de in??cio', 'Ultima competi????o'])
        overview = overview.T
        overview.fillna('Nenhum', inplace=True)

        drivers_report = self.get_dataframe(f"select * from GetDriversReport_Scuderia({user.id_original});")
        status_report = self.get_dataframe(f"select * from GetStatusReport_Scuderia({user.id_original});")

        print(overview)

        return overview, drivers_report, status_report

    def get_tabelas_piloto(self, user:User):
        if not user.type == 'Piloto':
            raise ValueError('Usu??rio n??o ?? um Piloto.')

        vitorias = self.get_dataframe(f"select count(*) from results where driverid = {user.id_original} and position::VARCHAR(10) = '1';")
        ano_inicio = self.get_dataframe(f"""
            select min(ra.year) from results re
            left join races ra
            on re.raceid = ra.raceid
            where re.driverid = '{user.id_original}';
        """)
        ano_fim = self.get_dataframe(f"""
            select max(ra.year) from results re
            left join races ra
            on re.raceid = ra.raceid
            where re.driverid = '{user.id_original}';
        """)
        
        vitorias = vitorias.iloc[0, 0]
        ano_inicio = ano_inicio.iloc[0, 0]
        ano_fim = ano_fim.iloc[0, 0]
        
        overview = pd.DataFrame(data=[vitorias, ano_inicio, ano_fim], index=['Vit??rias', 'Ano de in??cio', 'Ultima competi????o'])
        overview = overview.T
        overview['Vit??rias'] = overview['Vit??rias'].astype('int32')
        overview.fillna('Nenhum', inplace=True)

        victory_report = self.get_dataframe(f"select * from GetVictoryReport_Driver({user.id_original});")
        victory_report.fillna('Todos', inplace=True)
        status_report = self.get_dataframe(f"select * from GetStatusReport_Driver({user.id_original});")
        return overview, victory_report, status_report

    def get_tabelas_admin(self, user:User):
        if not user.type == 'Administrador':
            raise ValueError('Usu??rio n??o ?? um Admin.')

        status_amnt = self.get_dataframe(
            f"""select s.status, count(re.*) as contagem from status s
                right join results re
                    on re.statusid = s.statusid
                group by s.status
                order by 2 desc nulls last;"""
        )
        status_amnt.fillna(0, inplace=True)
        status_amnt['contagem'] = status_amnt['contagem'].astype('int32')
        return (status_amnt,)


    def get_pilotos_escuderia(self, nome:str, user:User):
        if not user.type == 'Escuderia':
            raise ValueError('Usu??rio n??o ?? uma escuderia.')

        return self.get_dataframe(f"""
            select fullname(dr.driverid) as Nome, dr.dob as nascimento, dr.nationality as nacionalidade
            from driver dr
            right join
                (select distinct driverid from results where constructorid = {user.id_original}) as res
                    on res.driverid = dr.driverid
            where dr.forename like '%{nome}%';
        """)


    def cadastrar_escuderia(self, escuderiaref:str, nome:str, nacionalidade:str, url:str):
        self.cursor.execute(f"""
            insert into constructors values (
                (select max(constructorid) + 1 from constructors), 
                '{escuderiaref}',
                '{nome}',
                '{nacionalidade}',
                '{url}'
            );
        """)

        self.connection.commit()
        print('cadastrado com sucesso!')


    def cadastrar_piloto(self, driverref:str, numero:str, codigo:str, forename:str, surname:str, date:str, nationality:str):
        self.cursor.execute(f"""
            insert into driver values (
                (select max(driverid) + 1 from driver),
                '{driverref}',
                '{numero}',
                '{codigo}',
                '{forename}',
                '{surname}',
                '{datetime.strptime(date, '%d/%m/%Y')}',
                '{nationality}',
                ''
            );
        """)

        self.connection.commit()
        print('cadastrado com sucesso!')

if __name__ == '__main__':
    f1 = Formula1(config.DB_USER, config.DB_PWD, config.DB_DATABASE)
    f1.perform_login('admin', 'admin')
    f1.get_dataframe('select * from races limit 10;').itertuples
