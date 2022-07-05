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
            # if logged_user.type == 'administrador':
            #     logged_user.full_name == 'Admin'
            # elif logged_user.type == 'Escuderia':
            #     logged_user.full_name = 
           
            return logged_user
        
        raise ValueError('Wrong login or password')

    
    def get_dataframe(self, query:str) -> pd.DataFrame:
        table = pd.read_sql(query, self.connection)
        return table

if __name__ == '__main__':
    f1 = Formula1(config.DB_USER, config.DB_PWD, config.DB_DATABASE)
    f1.perform_login('admin', 'admin')
    f1.get_dataframe('select * from races limit 10;')
