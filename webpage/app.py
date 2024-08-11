from flask import Flask, request, render_template, redirect, url_for, flash
from flask_mail import Mail, Message

app = Flask(__name__)

@app.route('/')
def home():
    return render_template('home.html')

@app.route('/about')
def about():
    return render_template('about.html')

@app.route('/contact')
def contact():
    return render_template('contact.html')

if __name__ == '__main__':
    app.secret_key = 'supersecretkey'
    app.run(debug=True)
