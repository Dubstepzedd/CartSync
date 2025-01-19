import os

# Base configuration
debug_flag = True  # Debug mode enabled
port = int(os.environ.get("PORT", 5000))  # Default port for the application

# SQLite database configuration
db_path = os.path.join(os.path.dirname(__file__), 'app.db')
SQLALCHEMY_DATABASE_URI = f'sqlite:///{db_path}'

# SQLAlchemy configurations
SQLALCHEMY_TRACK_MODIFICATIONS = False
