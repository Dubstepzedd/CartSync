from extensions import db

class User(db.Model):
    __tablename__ = "users"
    username = db.Column(db.String(50), nullable=False, primary_key=True)
    password = db.Column(db.String(60), nullable=False)

    def __init__(self, username, password):
        self.username = username
        self.password = password
