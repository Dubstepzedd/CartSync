# main.py or wherever you define the routes and JWT logic

from flask import Blueprint, jsonify, request
from flask_jwt_extended import create_access_token, create_refresh_token, get_jwt, jwt_required
from app.models import User, JwtBlocklist
from extensions import db
from extensions import jwt
from flask_cors import cross_origin
from app.codes import ResponseType

# Create a blueprint for the main routes
auth_blueprint = Blueprint('auth', __name__)

# Blocklist - checking if the token is in the database blocklist
@jwt.token_in_blocklist_loader
def check_if_token_is_revoked(jwt_header, jwt_payload: dict):
    jti = jwt_payload["jti"]
    token_in_db = JwtBlocklist.query.filter_by(jti=jti).first()
    return token_in_db is not None

# Routes

@auth_blueprint.route("/login", methods=["POST"])
@cross_origin()
def login():
    data = request.get_json()
    if data is None:
        return jsonify({"type": ResponseType.WRONG_PAYLOAD.value, "msg": "Invalid or missing JSON payload"}), 400

    username = data.get("username")
    password = data.get("password")

    if not isinstance(username, str) or not isinstance(password, str) :
        return jsonify({"type": ResponseType.WRONG_PAYLOAD.value, "msg": "Invalid payload"}), 400
    
    user = User.query.filter_by(username=username).first()
    
    if user is None:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "User not found"}), 404
    
    if user.check_password(password):
        access_token = create_access_token(identity=username)
        refresh_token = create_refresh_token(identity=username)
        return jsonify({"type": ResponseType.SUCCESS.value, "msg": "Successfully logged in", "access_token": access_token, "refresh_token": refresh_token}), 200
    else:
        return jsonify({"type": ResponseType.WRONG_PAYLOAD.value, "msg": "Invalid credentials"}), 400

    
@auth_blueprint.route("/register", methods=["POST"])
@cross_origin()
def register():
    data = request.get_json()

    if data is None:
        return jsonify({"type": ResponseType.WRONG_PAYLOAD.value, "msg": "Invalid or missing JSON payload"}), 400

    username = data.get("username")
    password = data.get("password")

    if not isinstance(username, str) or not isinstance(password, str):
        return jsonify({"type": ResponseType.WRONG_PAYLOAD.value, "msg": "Invalid payload"}), 400
    
    user = User.query.filter_by(username=username).first()
    
    if user is not None:
        return jsonify({"type": ResponseType.RESOURCE_ALREADY_EXISTS.value, "msg": "User already exists"}), 409
    
    user = User(username, password)
    db.session.add(user)
    db.session.commit()
    return jsonify({"type": ResponseType.RESOURCE_CREATED.value,"msg":"Successfully registered user"}), 201

@auth_blueprint.route("/logout", methods=["DELETE"])
@jwt_required()
@cross_origin()
def logout():
    # I wanted to use Redis to handle the JWT tokens, but I had to set up a Redis server and I didn't want to spend too much time on it. 
    # So I used the database to store the tokens, which is not optimal as the blocklist is going to grow indefinitely as of now, but it works.
    jti = get_jwt()["jti"]
    # Store the revoked token in the database
    revoked_token = JwtBlocklist(jti=jti)
    db.session.add(revoked_token)
    db.session.commit()
    
    return jsonify({"type": ResponseType.SUCCESS.value, "msg": "Access token revoked"}), 200

@auth_blueprint.route("/refresh", methods=["POST"])
@jwt_required(refresh=True)
@cross_origin()
def refresh():
    identity = get_jwt()["sub"]  # Extract the identity from the refresh token
    new_access_token = create_access_token(identity=identity)
    return jsonify({"type": ResponseType.RESOURCE_CREATED.value, "msg": "Successfully refreshed access token", "access_token": new_access_token}), 201