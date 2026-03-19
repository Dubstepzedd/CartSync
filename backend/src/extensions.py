import os
from functools import cache
from typing import AsyncGenerator

from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession, AsyncEngine
from sqlalchemy.pool import StaticPool
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError, VerificationError

from src.config import config_dict

_hasher = PasswordHasher()


def hash_password(password: str) -> str:
    return _hasher.hash(password)


def verify_password(password: str, hashed: str) -> bool:
    try:
        return _hasher.verify(hashed, password)
    except (VerifyMismatchError, VerificationError):
        return False


@cache
def get_engine(database_url: str) -> AsyncEngine:
    kwargs = {}
    if ":memory:" in database_url:
        kwargs["poolclass"] = StaticPool
        kwargs["connect_args"] = {"check_same_thread": False}
    return create_async_engine(database_url, **kwargs)


@cache
def get_session_factory(database_url: str):
    return async_sessionmaker(get_engine(database_url), expire_on_commit=False)


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    config_name = os.getenv("FASTAPI_ENV")
    if not config_name:
        raise RuntimeError("'FASTAPI_ENV' is not set. Please add it to the environment.")
    config = config_dict[config_name]
    async with get_session_factory(config.DATABASE_URL)() as session:
        yield session
