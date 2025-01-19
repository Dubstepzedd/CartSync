from flask import Blueprint, jsonify, request
from app.models import User
from extensions import db

# Create a blueprint for the main routes
main_blueprint = Blueprint('main', __name__)

@main_blueprint.route('/cart/<int:cart_id>', methods=['GET'])
def get_recipes(cart_id: int):
    return jsonify({"id": cart_id, 'recipe': ["Example" for i in range(5)]}), 200

@main_blueprint.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    username = data.get("username")
    password = data.get("password")
    user = User.query.filter_by(username=username).first()
    if user is None:
        user = User(username, password)
        db.session.add(user)
        db.session.commit()
        return "User created", 201
    else:
        return "User already exists", 400

@main_blueprint.route("/register", methods=["POST"])
def register():
    return jsonify({"message": "Register"}), 200

@main_blueprint.route("/logout", methods=["POST"])
def logout():
    return jsonify({"message": "Logout"}), 200
