from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "<h1 style='color:red'>Лабораторна робота 6-7</h1><p>виконана успішно</p><p>Студентка: Гульчак Дар'я МІТ-31</p>"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)