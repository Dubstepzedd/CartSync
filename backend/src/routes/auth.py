from fastapi import APIRouter, Depends, Request
from fastapi.security import HTTPAuthorizationCredentials
from jose import JWTError, jwt
from sqlalchemy.ext.asyncio import AsyncSession

from src.models import User, JwtBlocklist
from src.codes import ResponseType, make_response
from src.extensions import get_db, hash_password
from src.config import get_config
from src.security import bearer_scheme, get_token_payload, create_access_token, create_refresh_token
from src.queries import get_user

auth_router = APIRouter()


@auth_router.post("/login")
async def login(request: Request, db: AsyncSession = Depends(get_db)):
    try:
        data = await request.json()
    except Exception:
        return make_response(ResponseType.WRONG_PAYLOAD, "Invalid or missing JSON payload", 400)

    if data is None:
        return make_response(ResponseType.WRONG_PAYLOAD, "Invalid or missing JSON payload", 400)

    username = data.get("username")
    password = data.get("password")

    if not isinstance(username, str) or not isinstance(password, str):
        return make_response(ResponseType.WRONG_PAYLOAD, "Invalid payload", 400)

    user = await get_user(db, username)
    if user is None:
        return make_response(ResponseType.RESOURCE_NOT_FOUND, "User not found", 404)

    if user.check_password(password):
        access_token = create_access_token(username)
        refresh_token = create_refresh_token(username)
        return make_response(
            ResponseType.SUCCESS,
            "Successfully logged in",
            200,
            data={"access_token": access_token, "refresh_token": refresh_token},
        )

    return make_response(ResponseType.WRONG_PAYLOAD, "Invalid credentials", 400)


@auth_router.post("/register")
async def register(request: Request, db: AsyncSession = Depends(get_db)):
    try:
        data = await request.json()
    except Exception:
        return make_response(ResponseType.WRONG_PAYLOAD, "Invalid or missing JSON payload", 400)

    if data is None:
        return make_response(ResponseType.WRONG_PAYLOAD, "Invalid or missing JSON payload", 400)

    username = data.get("username")
    password = data.get("password")

    if not isinstance(username, str) or not isinstance(password, str):
        return make_response(ResponseType.WRONG_PAYLOAD, "Invalid payload", 400)

    existing = await get_user(db, username)
    if existing is not None:
        return make_response(ResponseType.RESOURCE_ALREADY_EXISTS, "User already exists", 409)

    hashed_password = hash_password(password)
    user = User(username=username, password=hashed_password)
    db.add(user)
    await db.commit()
    return make_response(ResponseType.RESOURCE_CREATED, "Successfully registered user", 201)


@auth_router.delete("/logout")
async def logout(
    payload: dict = Depends(get_token_payload),
    db: AsyncSession = Depends(get_db),
):
    jti = payload.get("jti")
    revoked_token = JwtBlocklist(jti=jti)
    db.add(revoked_token)
    await db.commit()
    return make_response(ResponseType.SUCCESS, "Access token revoked", 200)


@auth_router.post("/refresh")
async def refresh(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
):
    config = get_config()
    try:
        payload = jwt.decode(
            credentials.credentials,
            config.JWT_SECRET_KEY,
            algorithms=[config.JWT_ALGORITHM],
        )
        if payload.get("type") != "refresh":
            return make_response(ResponseType.UNAUTHORIZED, "Not a refresh token", 401)
        username = payload.get("sub")
    except JWTError:
        return make_response(ResponseType.UNAUTHORIZED, "Invalid token", 401)

    new_access_token = create_access_token(username)
    return make_response(
        ResponseType.RESOURCE_CREATED,
        "Successfully refreshed access token",
        201,
        data={"access_token": new_access_token},
    )
