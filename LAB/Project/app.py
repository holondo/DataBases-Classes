from email import message
from flask import Flask, flash, render_template, url_for, redirect, request, session
import psycopg2

from model import Formula1
import config

app = Flask(__name__, template_folder='templates')

# connection = psycopg2.connect(host='localhost',
#     database=config.DB_DATABASE,
#     user=config.DB_USER,
#     password=config.DB_PWD)

# cursor = connection.cursor()
model = Formula1(config.DB_USER, config.DB_PWD, config.DB_DATABASE)

@app.get('/')
def home():
    if 'userid' not in session:
        return redirect(url_for('login'))
    else:
        return render_template('home.html')

@app.route('/login')
def login():
    if request.method == 'POST':
        try:
            session['userid'], session['username'] = model.perform_login(
                request.form['username'], request.form['password']
            )
            return redirect(url_for('/'))
        except ValueError as e:
            return render_template('login.html', message=str(e))
    else:
        if 'userid' in session:
            return redirect(url_for('/'))
            
        else:
            return render_template('login.html')

if __name__ == '__main__':
    app.run()