from email import message
from flask import Flask, flash, render_template, url_for, redirect, request, session
import psycopg2

from model import Formula1, User 
import config

app = Flask(__name__, template_folder='templates')
app.secret_key = 'f1'

# connection = psycopg2.connect(host='localhost',
#     database=config.DB_DATABASE,
#     user=config.DB_USER,
#     password=config.DB_PWD)

# cursor = connection.cursor()
model = Formula1(config.DB_USER, config.DB_PWD, config.DB_DATABASE)

@app.get('/')
def home():
    if 'user' not in session:
        return redirect(url_for('login'))
    else:
        user:User = User(**session['user'])

        # if user['type'] == :
        
        if user.type == 'Escuderia':
            overview = model.get_tabelas_escuderia(user)
            return render_template('overview-scuderia.html', user=session['user'], tabelas=overview)

        if user.type == 'Piloto':
            overview = model.get_tabelas_piloto(user)
            return render_template('overview-driver.html', user=session['user'], tabelas=overview)

        if user.type == 'Administrador':
            dataAdmin = model.get_admin_data()
            return render_template('overview-admin.html', user=session['user'], data=dataAdmin)


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        try:
            session['user'] = \
                model.perform_login(
                    request.form['username'], request.form['password']
                )
            return redirect(url_for('home'))

        except ValueError as e:
            return render_template('login.html', message=str(e))
    else:
        if 'user' in session:
            return redirect(url_for('home'))
            
        else:
            return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

@app.route('/cadastrarpiloto', methods=['GET', 'POST'])
def cadastrarPiloto():
    return render_template('cadastrar-piloto.html', user=session['user'], data=model.get_admin_data())

if __name__ == '__main__':
    app.run(debug=True)