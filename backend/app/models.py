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
    
    
class JwtBlocklist(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    jti = db.Column(db.String(255), unique=True, nullable=False)
    revoked_at = db.Column(db.DateTime, nullable=False, default=datetime.now())