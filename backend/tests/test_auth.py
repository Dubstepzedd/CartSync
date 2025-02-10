import os
import time
import pytest
import sys

# Add the parent directory to sys.path to access the 'app' module
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app import create_app
from config import TestingConfig
from extensions import db

@pytest.fixture(scope='module')
def test_client():
    os.environ['FLASK_ENV'] = 'testing'
    app = create_app()

    # Access the config value and confirm it's set correctly (otherwise the tests won't work for token expiration)
    with app.app_context():
        jwt_expire_time = app.config['JWT_ACCESS_TOKEN_EXPIRES']
        expected_expire_time = TestingConfig.JWT_ACCESS_TOKEN_EXPIRES
        assert jwt_expire_time == expected_expire_time, \
            f"Expected JWT expiration time to be {expected_expire_time}, but got {jwt_expire_time}"

    # Setup the database (creating the tables)
    with app.app_context():
        db.create_all()

    yield app.test_client()

    # Cleanup the database
    with app.app_context():
        db.drop_all()

@pytest.fixture

def register_user(test_client):
    # Register a new user to use in other tests
    data = {
        "username": "testuser",
        "password": "password123"
    }
    response = test_client.post("/register", json=data)
    assert response.status_code == 201
    
def test_register_new_user(test_client):
    data = {
        "username": "user",
        "password": "password123"
    }

    response = test_client.post("/register", json=data)
    assert response.status_code == 201
    assert response.json["type"] == "RESOURCE_CREATED"

def test_register_existing_user(test_client):
    data = {
        "username": "user",  # This user is already registered in the fixture
        "password": "password123"
    }
    
    response = test_client.post("/register", json=data)
    assert response.status_code == 409
    assert response.json["msg"] == "User already exists"
    assert response.json["type"] == "RESOURCE_ALREADY_EXISTS"

# Login

def test_login_valid_user(test_client):
    data = {
        "username": "user",
        "password": "password123"
    }

    response = test_client.post("/login", json=data)
    assert response.status_code == 200
    assert 'access_token' in response.json

def test_login_invalid_user(test_client):
    data = {
        "username": "nonexistentuser",
        "password": "password123"
    }

    response = test_client.post("/login", json=data)
    assert response.status_code == 404
    assert response.json["msg"] == "User not found"

def test_login_invalid_password(test_client):
    data = {
        "username": "user",
        "password": "wrongpassword"
    }

    response = test_client.post("/login", json=data)
    assert response.status_code == 400
    assert response.json["msg"] == "Invalid credentials"


# Logout test
def test_logout(test_client):
    # First, log in to get the token
    data = {
        "username": "user",
        "password": "password123"
    }
    response = test_client.post("/login", json=data)
    token = response.json['access_token']

    # Send a request to log out
    response = test_client.delete("/logout", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    assert response.json["msg"] == "Access token revoked"

    # Try to use the token after logout
    response = test_client.get('/cart/1', headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 401  # Unauthorized because the token was revoked
    assert response.json["msg"] == "Token has been revoked"


# Token Expiration test
def test_token_expiration(test_client):
    # Create a token that expires immediately
    data = {
        "username": "user",
        "password": "password123"
    }

    response = test_client.post("/login", json=data)
    token = response.json['access_token']

    # Simulate waiting for the token to expire
    time.sleep(TestingConfig.JWT_ACCESS_TOKEN_EXPIRES.total_seconds() + 1)

    # Send a request with the expired token
    response = test_client.get('/get_carts', headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 401  # Unauthorized due to expired token
    assert response.json["msg"] == "Token has expired"


# Test invalid input 

def test_invalid_payload_reg(test_client):
    data = {
        "username": 123,  # Invalid type
        "password": "password123"
    }

    response = test_client.post("/register", json=data)
    assert response.status_code == 400
    assert response.json["type"] ==  "WRONG_PAYLOAD"

def test_invalid_payload_reg2(test_client):
    data = {
        "username": None,  # Invalid type
        "password": None
    }

    response = test_client.post("/register", json=data)
    assert response.status_code == 400
    assert response.json["type"] ==  "WRONG_PAYLOAD"


def test_invalid_payload_login(test_client):
    data = {
        "username": 123,  # Invalid type
        "password": "password123"
    }

    response = test_client.post("/login", json=data)
    assert response.status_code == 400
    assert response.json["type"] ==  "WRONG_PAYLOAD"

def test_invalid_payload_login2(test_client):
    data = {
        "username": None,  # Invalid type
        "password": None
    }

    response = test_client.post("/login", json=data)
    assert response.status_code == 400
    assert response.json["type"] ==  "WRONG_PAYLOAD"