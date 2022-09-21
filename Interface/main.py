from flask import Flask, redirect, render_template, request, session, flash
import os
import web

app = Flask(__name__)
app.secret_key = os.urandom(69).hex()

@app.route('/')
def index():
    if session.get('user') == None:
        return render_template('base.html')
    return redirect('/')

# авторизация
@app.route('/auth', methods=['GET', 'POST'])
def auth():
    if session.get('user') == None:
        if request.method == 'POST':
            acc = request.form.get('acc')
            key = request.form.get('key')
            login = request.form.get('login')
            password = request.form.get('password')
            res = web.auth(acc, key, login, password)
            if type(res) == str:
                flash(res)
                return redirect('/auth')
            session['user'] = res
            return redirect('/lk')
        return render_template('auth.html')
    return redirect('/')

# регистрация
@app.route('/reg', methods=['GET', 'POST'])
def reg():
    if session.get('user') == None:
        if request.method == 'POST':
            acc = request.form.get('acc')
            key = request.form.get('key')
            FIO = request.form.get('FIO').split(",")
            login = request.form.get('login')
            password = request.form.get('password')
            res = web.reg(acc, key, FIO, login, password)
            if res[0] == False:
                return f"error {res[1]}"
            return redirect('/lk')
        return render_template('reg.html')
    return redirect('/')

# регистрация транспорта
@app.route('/reg_transport', methods=['GET', 'POST'])
def reg_t():
    if session.get('user') != None:
        if request.method == 'POST':
            acc = request.form.get('acc')
            key = request.form.get('key')
            acc = request.form.get('acc')
            acc = request.form.get('acc')
            res = web.reg_transpot(acc, key)
            if type(res[0]) == str:
                print(f"error {res[1]}")
                return
            return redirect('/lk')
        return render_template('reg_transport.html')
    return redirect('/')

# вызод из личного кабинета
@app.route('/exit')
def exit():
    if session.get('user') != None:
        session.pop('user', None)
    return redirect('/')

# помощь пользователю по сайту
@app.route('/help')
def help():
    if session.get('user') == None:
        return render_template('help.html')
    return redirect('/help')

# личный кабинет пользователя
@app.route('/lk')
def lk():
    if session.get('user') != None:
        return render_template('lk.html', res=session.get('user'))
    return redirect('/')

# # 
# @app.route('/profile', methods=['GET', 'POST'])
# def profile():
#     if session.get('user') == None:
#          return render_template('profile.html', res = session.get('user'))

#     return redirect('/profile')
   
if __name__ == '__main__':
    app.run(debug=True)
