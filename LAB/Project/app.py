from email import message
from flask import Flask, flash, render_template, url_for, redirect, request, session
import psycopg2

from model import Formula1, User 
import config

app = Flask(__name__, template_folder='templates')
app.secret_key = 'f1'

model = Formula1(config.DB_USER, config.DB_PWD, config.DB_DATABASE)

@app.get('/')
def home():
    if 'user' not in session:
        return redirect(url_for('login'))
    else:
        user:User = User(**session['user'])
        print(user)
        
        if user.type == 'Escuderia':
            overview = model.get_tabelas_escuderia(user)
            return render_template('overview-scuderia.html', user=session['user'], tabelas=overview)

        if user.type == 'Piloto':
            overview = model.get_tabelas_piloto(user)
            return render_template('overview-driver.html', user=session['user'], tabelas=overview)

        if user.type == 'Administrador':
            dataAdmin = model.get_admin_data()
            tables = model.get_tabelas_admin(user)
            return render_template('overview-admin.html', user=session['user'], data=dataAdmin, tabelas=tables)


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
    if session['user']['type'] == 'Administrador':
        if request.method == 'POST':
            driverref = request.form['txt-driverref']
            numero = request.form['txt-numero']
            codigo = request.form['txt-codigo']
            forename = request.form['txt-forename']
            surname = request.form['txt-surname']
            date = request.form['txt-date']
            nationality = request.form['txt-nationality']

            model.cadastrar_piloto(driverref, numero, codigo, forename, surname, date, nationality)

            return redirect(url_for('home'))
            
        else:
            return render_template('cadastrar-piloto.html', user=session['user'], data=model.get_admin_data())


@app.route('/cadastrarescuderia', methods=['GET', 'POST'])
def cadastrarEscuderia():
    if session['user']['type'] == 'Administrador':
        if request.method == 'POST':
            escuderiaref = request.form['txt-escuderiaref']
            nome = request.form['txt-nome']
            nacionalidade = request.form['txt-nacionalidade']
            url = request.form['txt-url']
            model.cadastrar_escuderia(escuderiaref, nome, nacionalidade, url)

            return redirect(url_for('home'))
        else:
            return render_template('cadastrar-escuderia.html', user=session['user'], data=model.get_admin_data())

@app.route('/consultarpiloto', methods=['GET', 'POST'])
def consultarPiloto():
    if session['user']['type'] == 'Escuderia':
        user:User = User(**session['user'])
        # user.id_original = 3
        if request.method == 'GET':
             return render_template('consultar-pilotos.html', user=session['user'],data=model.get_admin_data(), tabelas=model.get_tabelas_escuderia(user), tabelas_busca=None)
        
        elif request.method == 'POST':
            busca = request.form['txt-query']
            tabela_busca = model.get_pilotos_escuderia(busca, user)
            return render_template('consultar-pilotos.html', user=user, data=model.get_admin_data(), tabelas=model.get_tabelas_escuderia(user), tabelas_busca=[tabela_busca])


if __name__ == '__main__':
    app.run(debug=True)