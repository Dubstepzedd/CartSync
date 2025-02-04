from datetime import timedelta
import os
from dotenv import load_dotenv

load_dotenv()  # Load the .env file

# Base configuration class with common settings
class BaseConfig:
    DEBUG = False
    PORT = int(os.environ.get("PORT", 5000))
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JWT_SECRET_KEY = os.environ.get("JWT_SECRET")
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=1)  # Default expiration time for JWTs
    JWT_REFRESH_TOKEN_EXPIRES = timedelta(days=30)  # Default expiration time refresh JWTs

# Development configuration class that inherits from BaseConfig
class DevelopmentConfig(BaseConfig):
    DEBUG = True
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=1) 
    SQLALCHEMY_DATABASE_URI = f'sqlite:///{os.path.join(os.path.dirname(__file__), "dev.db")}'  # Use a dev-specific database

# Testing configuration class that inherits from BaseConfig
class TestingConfig(BaseConfig):
    DEBUG = True
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(seconds=5)  
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'  # Use an in-memory database for testing

config_dict = {
    'development': DevelopmentConfig,
    'testing': TestingConfig
}
