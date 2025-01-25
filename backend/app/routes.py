# main.py or wherever you define the routes and JWT logic

from flask import Blueprint, jsonify, request
from flask_jwt_extended import create_access_token, create_refresh_token, get_jwt, jwt_required
from app.models import User, JwtBlocklist
from extensions import db
from extensions import jwt
from flask_cors import cross_origin

# Create a blueprint for the main routes
main_blueprint = Blueprint('main', __name__)

# Blocklist - checking if the token is in the database blocklist
@jwt.token_in_blocklist_loader
def check_if_token_is_revoked(jwt_header, jwt_payload: dict):
    jti = jwt_payload["jti"]
    token_in_db = JwtBlocklist.query.filter_by(jti=jti).first()
    return token_in_db is not None

# Routes

@main_blueprint.route('/get_carts', methods=['GET'])
@jwt_required()
@cross_origin()
def get_carts():
    return jsonify({"id": 1, 'carts': [{"name": "Inköpslista", "description": "För att handla", "count": 15} for i in range(5)]}), 200

@main_blueprint.route('/cart/<int:cart_id>', methods=['GET'])
@jwt_required()
@cross_origin()
def get_cart(cart_id: int):
    return jsonify({"id": cart_id, 'recipe': ["Example" for i in range(5)]}), 200

@main_blueprint.route("/login", methods=["POST"])
@cross_origin()
def login():
    data = request.get_json()
    if data is None:
        return jsonify({"success": False, "msg": "Invalid or missing JSON payload"}), 400

    username = data.get("username")
    password = data.get("password")

    if not isinstance(username, str) or not isinstance(password, str) :
        return jsonify({"success": False, "msg": "Invalid payload"}), 400
    
    user = User.query.filter_by(username=username).first()
    
    if user is None:
        return jsonify({"success": False, "msg": "User not found"}), 404
    
    if user.check_password(password):
        access_token = create_access_token(identity=username)
        refresh_token = create_refresh_token(identity=username)
        return jsonify({"success":True, "msg": "Successfully logged in", "access_token": access_token, "refresh_token": refresh_token}), 200
    else:
        return jsonify({"success": False, "msg": "Invalid credentials"}), 400

    
@main_blueprint.route("/register", methods=["POST"])
@cross_origin()
def register():
    data = request.get_json()

    if data is None:
        return jsonify({"success": False, "msg": "Invalid or missing JSON payload"}), 400

    username = data.get("username")
    password = data.get("password")

    if not isinstance(username, str) or not isinstance(password, str):
        return jsonify({"success": False, "msg": "Invalid type in payload"}), 400
    
    user = User.query.filter_by(username=username).first()
    
    if user is None:
        user = User(username, password)
        db.session.add(user)
        db.session.commit()
        return jsonify({"success": True,"msg":"Successfully registered user"}), 200
    else:
        return jsonify({"success": False, "msg": "User already exists"}), 409

@main_blueprint.route("/logout", methods=["DELETE"])
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
    
    return jsonify({"success": True, "msg": "Access token revoked"})

@main_blueprint.route("/refresh", methods=["POST"])
@jwt_required(refresh=True)
@cross_origin()
def refresh():
    identity = get_jwt()["sub"]  # Extract the identity from the refresh token
    new_access_token = create_access_token(identity=identity)
    return jsonify({"success": True, "msg": "Successfully refreshed access token", "access_token": new_access_token}), 200