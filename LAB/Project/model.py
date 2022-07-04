import psycopg2
import config

class Formula1:
    def __init__(self, username:str, password:str, database:str) -> None:
        self.connection = psycopg2.connect(
            host='localhost',
            database=database,
            user=username,
            password=password
        )
        self.cursor = self.connection.cursor()

    def perform_login(self, username:str, password:str):
        '''
        Returns:
            * tuple: (User id, Username, tipo)
        '''
        self.cursor.execute(f"select PerformLogin('{username}', '{password}');")
        response = self.cursor.fetchone()

        if True in response:
            self.cursor.execute(f"select userid, tipo from users where login = '{username}';")
            infos = self.cursor.fetchone()
            user_id = infos[0]
            tipo = infos[1]
            return (user_id, username, tipo)
        
        raise ValueError('Wrong login or password')


if __name__ == '__main__':
    f1 = Formula1(config.DB_USER, config.DB_PWD, config.DB_DATABASE)
    f1.perform_login('admin', 'admin')