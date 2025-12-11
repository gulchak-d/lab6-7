from flask import Flask, render_template, request, redirect, url_for
from order_stack import OrderStack

app = Flask(__name__)

stack_manager = OrderStack()
order_id_counter = 1 

@app.route('/')
def index():
    current_orders = stack_manager.display()
    return render_template('index.html', orders=current_orders)

@app.route('/add', methods=['POST'])
def add_order():
    global order_id_counter
    
    item = request.form['item']
    try:
        quantity = int(request.form['quantity'])
    except ValueError:
        quantity = 1
    
    stack_manager.push(order_id_counter, item, quantity)
    order_id_counter += 1
    
    return redirect(url_for('index'))

@app.route('/pop', methods=['POST'])
def pop_order():
    stack_manager.pop()
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)