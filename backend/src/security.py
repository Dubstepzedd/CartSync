from datetime import datetime, timezone
from uuid import uuid4

from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt
from sqlalchemy.ext.asyncio import AsyncSession

from src.models import User
from src.extensions import get_db
from src.config import get_config
from src.queries import get_user, is_token_revoked

bearer_scheme = HTTPBearer()

def create_access_token(subject: str) -> str:
    config = get_config()
    expire = datetime.now(timezone.utc) + config.JWT_ACCESS_TOKEN_EXPIRES
    payload = {"sub": subject, "exp": expire, "jti": str(uuid4()), "type": "access"}
    return jwt.encode(payload, config.JWT_SECRET_KEY, algorithm=config.JWT_ALGORITHM)


def create_refresh_token(subject: str) -> str:
    config = get_config()
    expire = datetime.now(timezone.utc) + config.JWT_REFRESH_TOKEN_EXPIRES
    payload = {"sub": subject, "exp": expire, "jti": str(uuid4()), "type": "refresh"}
    return jwt.encode(payload, config.JWT_SECRET_KEY, algorithm=config.JWT_ALGORITHM)


async def get_token_payload(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
    db: AsyncSession = Depends(get_db),
) -> dict:
    config = get_config()
    try:
        payload = jwt.decode(
            credentials.credentials,
            config.JWT_SECRET_KEY,
            algorithms=[config.JWT_ALGORITHM],
        )
        if payload.get("type") != "access":
            raise HTTPException(status_code=401, detail="Could not validate credentials")
    except JWTError as e:
        if "expired" in str(e).lower():
            raise HTTPException(status_code=401, detail="Token has expired")
        raise HTTPException(status_code=401, detail="Could not validate credentials")

    jti = payload.get("jti")
    if await is_token_revoked(db, jti):
        raise HTTPException(status_code=401, detail="Token has been revoked")

    return payload


async def get_current_user(
    payload: dict = Depends(get_token_payload),
    db: AsyncSession = Depends(get_db),
) -> User:
    username = payload.get("sub")
    user = await get_user(db, username)
    if user is None:
        raise HTTPException(status_code=401, detail="Could not validate credentials")
    return user
