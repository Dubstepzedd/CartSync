# main.py or wherever you define the routes and JWT logic

from flask import Blueprint, jsonify, request
from flask_jwt_extended import create_access_token, get_jwt, jwt_required
from app.models import User, JwtBlocklist
from extensions import db
from extensions import jwt

# Create a blueprint for the main routes
main_blueprint = Blueprint('main', __name__)

# Blocklist - checking if the token is in the database blocklist
@jwt.token_in_blocklist_loader
def check_if_token_is_revoked(jwt_header, jwt_payload: dict):
    jti = jwt_payload["jti"]
    token_in_db = JwtBlocklist.query.filter_by(jti=jti).first()
    return token_in_db is not None

# Routes

@main_blueprint.route('/cart/<int:cart_id>', methods=['GET'])
@jwt_required()
def get_cart(cart_id: int):
    return jsonify({"id": cart_id, 'recipe': ["Example" for i in range(5)]}), 200

@main_blueprint.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    username = data.get("username")
    password = data.get("password")

    if not isinstance(username, str) or not isinstance(password, str):
        return jsonify({"message": "Invalid payload"}), 400
    
    user = User.query.filter_by(username=username).first()
    
    if user is None:
        return "User not found", 404
    
    if user.check_password(password):
        access_token = create_access_token(identity=username)
        return jsonify(access_token=access_token), 200
    else:
        return "Invalid credentials", 400

    
@main_blueprint.route("/register", methods=["POST"])
def register():
    data = request.get_json()
    username = data.get("username")
    password = data.get("password")

    if not isinstance(username, str) or not isinstance(password, str):
        return jsonify({"message": "Invalid payload"}), 400
    
    user = User.query.filter_by(username=username).first()
    
    if user is None:
        user = User(username, password)
        db.session.add(user)
        db.session.commit()
        access_token = create_access_token(identity=username)
        return jsonify(access_token=access_token), 200
    else:
        return jsonify({"message": "User already exists"}), 400

@main_blueprint.route("/logout", methods=["DELETE"])
@jwt_required()
def logout():

    # I wanted to use Redis to handle the JWT tokens, but I had to set up a Redis server and I didn't want to spend too much time on it. 
    # So I used the database to store the tokens, which is not optimal as the blocklist is going to grow indefinitely as of now, but it works.
    
    jti = get_jwt()["jti"]
    
    # Store the revoked token in the database
    revoked_token = JwtBlocklist(jti=jti)
    db.session.add(revoked_token)
    db.session.commit()
    
    return jsonify(msg="Access token revoked")
