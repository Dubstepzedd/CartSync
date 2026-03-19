from datetime import timedelta
import os
from dotenv import load_dotenv

load_dotenv()

class BaseConfig:
    PORT: int = int(os.environ.get("PORT", 8000))
    DATABASE_URL: str = f'sqlite+aiosqlite:///{os.path.join(os.path.dirname(__file__), "..", "dev.db")}'
    JWT_SECRET_KEY: str = os.environ["JWT_SECRET"]
    JWT_ALGORITHM: str = "HS256"
    JWT_ACCESS_TOKEN_EXPIRES: timedelta = timedelta(hours=1)
    JWT_REFRESH_TOKEN_EXPIRES: timedelta = timedelta(days=30)

class DevelopmentConfig(BaseConfig):
    DEBUG: bool = True

class TestingConfig(BaseConfig):
    DEBUG: bool = True
    DATABASE_URL: str = "sqlite+aiosqlite:///:memory:"
    JWT_ACCESS_TOKEN_EXPIRES: timedelta = timedelta(seconds=5)

config_dict = {
    "development": DevelopmentConfig,
    "testing": TestingConfig,
}


def get_config() -> BaseConfig:
    config_name = os.getenv("FASTAPI_ENV")
    if not config_name:
        raise RuntimeError("'FASTAPI_ENV' is not set. Please add it to the environment.")
    return config_dict[config_name]
