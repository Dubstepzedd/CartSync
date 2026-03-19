import os
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from src.codes import ResponseType, make_response
from src.config import config_dict
from src import extensions
from src.models import Base
from src.routes import auth_router, main_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    config_name = os.getenv("FASTAPI_ENV")
    if not config_name:
        raise RuntimeError("'FASTAPI_ENV' is not set. Please add it to the environment.")
    config = config_dict[config_name]
    engine = extensions.get_engine(config.DATABASE_URL)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    await engine.dispose()


def create_app() -> FastAPI:
    app = FastAPI(lifespan=lifespan)

    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_methods=["*"],
        allow_headers=["*"],
    )

    @app.exception_handler(HTTPException)
    async def http_exception_handler(request: Request, exc: HTTPException):
        return make_response(ResponseType.UNKNOWN, exc.detail, exc.status_code)

    app.include_router(auth_router)
    app.include_router(main_router)

    return app
