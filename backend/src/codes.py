from enum import Enum
from typing import Any
from fastapi.responses import JSONResponse


class ResponseType(Enum):
    RESOURCE_ALREADY_EXISTS = "RESOURCE_ALREADY_EXISTS"
    RESOURCE_CREATED = "RESOURCE_CREATED"
    RESOURCE_FOUND = "RESOURCE_FOUND"
    RESOURCE_NOT_FOUND = "RESOURCE_NOT_FOUND"
    WRONG_PAYLOAD = "WRONG_PAYLOAD"
    SUCCESS = "SUCCESS"
    UNAUTHORIZED = "UNAUTHORIZED"
    UNKNOWN = "UNKNOWN"


def make_response(response_type: ResponseType, msg: str, status_code: int, data: Any = None) -> JSONResponse:
    body = {"type": response_type.value, "msg": msg}
    if data is not None:
        body["data"] = data
        
    return JSONResponse(body, status_code=status_code)
