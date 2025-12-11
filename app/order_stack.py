class OrderStack:
    def __init__(self):
        self.stack = []

    def push(self, order_id, item_name, quantity=1):
        order = {"id": order_id, "item": item_name, "quantity": quantity}
        self.stack.append(order)

    def pop(self):
        if not self.is_empty():
            return self.stack.pop()
        return None

    def peek(self):
        if not self.is_empty():
            return self.stack[-1]
        raise IndexError

    def is_empty(self):
        return len(self.stack) == 0

    def display(self):
        if not self.is_empty():
            return list(reversed(self.stack))
        return []