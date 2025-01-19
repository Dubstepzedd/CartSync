from flask_jwt_extended import JWTManager
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt

# To avoid circular imports, we will create the SQLAlchemy object here and import it when needed
db = SQLAlchemy()
jwt = JWTManager()
bcrypt = Bcrypt()