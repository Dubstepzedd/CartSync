from flask_sqlalchemy import SQLAlchemy

# To avoid circular imports, we will create the SQLAlchemy object here and import it when needed
db = SQLAlchemy()
