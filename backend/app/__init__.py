from flask import Flask
from extensions import db
from app.routes import main_blueprint

def create_app():
    app = Flask(__name__)
    app.config.from_pyfile('../config.py')  # Load configurations from the config file

    # Initialize extensions
    db.init_app(app)

    # Register blueprints
    app.register_blueprint(main_blueprint)

    return app
