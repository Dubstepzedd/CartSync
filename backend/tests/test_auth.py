import os
import time
import pytest
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

os.environ["FASTAPI_ENV"] = "testing"

from fastapi.testclient import TestClient
from src import create_app
from src.config import TestingConfig


@pytest.fixture(scope="module")
def test_client():
    app = create_app()
    with TestClient(app) as client:
        yield client


@pytest.fixture
def register_user(test_client):
    data = {"username": "testuser", "password": "password123"}
    response = test_client.post("/register", json=data)
    assert response.status_code == 201


def test_register_new_user(test_client):
    data = {"username": "user", "password": "password123"}
    response = test_client.post("/register", json=data)
    assert response.status_code == 201
    assert response.json()["type"] == "RESOURCE_CREATED"


def test_register_existing_user(test_client):
    data = {"username": "user", "password": "password123"}
    response = test_client.post("/register", json=data)
    assert response.status_code == 409
    assert response.json()["msg"] == "User already exists"
    assert response.json()["type"] == "RESOURCE_ALREADY_EXISTS"


# Login

def test_login_valid_user(test_client):
    data = {"username": "user", "password": "password123"}
    response = test_client.post("/login", json=data)
    assert response.status_code == 200
    assert "access_token" in response.json()["data"]


def test_login_invalid_user(test_client):
    data = {"username": "nonexistentuser", "password": "password123"}
    response = test_client.post("/login", json=data)
    assert response.status_code == 404
    assert response.json()["msg"] == "User not found"


def test_login_invalid_password(test_client):
    data = {"username": "user", "password": "wrongpassword"}
    response = test_client.post("/login", json=data)
    assert response.status_code == 400
    assert response.json()["msg"] == "Invalid credentials"


# Logout

def test_logout(test_client):
    data = {"username": "user", "password": "password123"}
    response = test_client.post("/login", json=data)
    token = response.json()["data"]["access_token"]

    response = test_client.delete("/logout", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    assert response.json()["msg"] == "Access token revoked"

    response = test_client.get("/cart/1", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 401
    assert response.json()["msg"] == "Token has been revoked"


# Token Expiration

def test_token_expiration(test_client):
    data = {"username": "user", "password": "password123"}
    response = test_client.post("/login", json=data)
    token = response.json()["data"]["access_token"]

    time.sleep(TestingConfig.JWT_ACCESS_TOKEN_EXPIRES.total_seconds() + 1)

    response = test_client.get("/carts", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 401
    assert response.json()["msg"] == "Token has expired"


# Invalid input

def test_invalid_payload_reg(test_client):
    data = {"username": 123, "password": "password123"}
    response = test_client.post("/register", json=data)
    assert response.status_code == 400
    assert response.json()["type"] == "WRONG_PAYLOAD"


def test_invalid_payload_reg2(test_client):
    data = {"username": None, "password": None}
    response = test_client.post("/register", json=data)
    assert response.status_code == 400
    assert response.json()["type"] == "WRONG_PAYLOAD"


def test_invalid_payload_login(test_client):
    data = {"username": 123, "password": "password123"}
    response = test_client.post("/login", json=data)
    assert response.status_code == 400
    assert response.json()["type"] == "WRONG_PAYLOAD"


def test_invalid_payload_login2(test_client):
    data = {"username": None, "password": None}
    response = test_client.post("/login", json=data)
    assert response.status_code == 400
    assert response.json()["type"] == "WRONG_PAYLOAD"
