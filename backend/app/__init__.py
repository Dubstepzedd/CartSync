import os
import subprocess
from flask import Flask
from extensions import db, jwt,bcrypt
from app.routes import main_blueprint
from config import config_dict
from flask_cors import CORS

def create_app():
    app = Flask(__name__)
    CORS(app, resources={r"/*"}, headers='Content-Type')
    config_name = os.getenv('FLASK_ENV', 'development')  # Default to 'development' if not set
    app.config.from_object(config_dict[config_name])  # Load the appropriate config
    
    # Initialize extensions
    db.init_app(app)
    jwt.init_app(app)
    bcrypt.init_app(app)
    
    # Register blueprints
    app.register_blueprint(main_blueprint)
    return app
