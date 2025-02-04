from datetime import datetime
from extensions import db, bcrypt

class User(db.Model):
    __tablename__ = "users"
    username = db.Column(db.String(50), nullable=False, primary_key=True)
    password = db.Column(db.String(60), nullable=False)

    def __init__(self, username, password):
        self.username = username
        self.password = bcrypt.generate_password_hash(password).decode('utf-8')

    def check_password(self, password):
        # Check if the password matches the hashed password
        return bcrypt.check_password_hash(self.password, password)
    
    def __repr__(self):
        return f"User {self.username}"

class Cart(db.Model):
    __tablename__ = "carts"
    name = db.Column(db.String(50), primary_key=True)
    description = db.Column(db.String(255), nullable=False)
    items = db.relationship('CartItem', backref='cart', lazy=True)


    def __init__(self, name, description):
        self.name = name
        self.description = description

    def __repr__(self):
        return f"Cart {self.id}: {self.name}"

class Item(db.Model):
    __tablename__ = "items"
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(50), nullable=False)
    cart = db.relationship('CartItem', backref='items', lazy=True)

    def __init__(self, name, description, price):
        self.name = name
        self.description = description
        self.price = price

    def __repr__(self):
        return f"Item {self.id}: {self.name}"
class JwtBlocklist(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    jti = db.Column(db.String(255), unique=True, nullable=False)
    revoked_at = db.Column(db.DateTime, nullable=False, default=datetime.now())
