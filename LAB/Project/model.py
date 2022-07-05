from dataclasses import dataclass
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
                        when tipo = 'administrador' then 'Admin'
                        when tipo = 'escuderia' then 
                            (select name from constructors where constructorid = idoriginal limit 1)
                        else
                            FullName(userid)
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
    
    def create_piloto(self, username:str, password:str) -> str:
        self.cursor.execute(query ="")
        return 'OK'

    
    def get_tabelas_escuderia(self, user:User):
        if not user.type == 'Escuderia':
            raise ValueError('Usuário não é uma escuderia.')

        vitorias = self.get_dataframe(f"select count(*) from results where constructorid = {user.id_original} and position = '1';")
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
        
        overview = pd.DataFrame(data=[vitorias, pilotos_amnt, ano_inicio, ano_fim], index=['Vitórias', 'Quantidade de pilotos', 'Ano de início', 'Ultima competição'])
        overview = overview.T

        drivers_report = self.get_dataframe(f"select * from GetDriversReport_Scuderia({user.id_original});")
        status_report = self.get_dataframe(f"select * from GetStatusReport_Scuderia({user.id_original});")

        print(overview)

        return overview, drivers_report, status_report

    def get_tabelas_piloto(self, user:User):
        if not user.type == 'Piloto':
            raise ValueError('Usuário não é um Piloto.')

        vitorias = self.get_dataframe(f"select count(*) from results where driverid = {user.id_original} and position = '1';")
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
        
        overview = pd.DataFrame(data=[vitorias, ano_inicio, ano_fim], index=['Vitórias', 'Ano de início', 'Ultima competição'])
        overview = overview.T

        victory_report = self.get_dataframe(f"select * from GetVictoryReport_Driver({user.id_original});")
        status_report = self.get_dataframe(f"select * from GetStatusReport_Driver({user.id_original});")
        return overview, victory_report, status_report


if __name__ == '__main__':
    f1 = Formula1(config.DB_USER, config.DB_PWD, config.DB_DATABASE)
    f1.perform_login('admin', 'admin')
    f1.get_dataframe('select * from races limit 10;').itertuples
