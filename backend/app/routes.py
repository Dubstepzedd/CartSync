from app.models import Cart, User, JwtBlocklist
from flask import Blueprint, jsonify, request
from flask_jwt_extended import get_jwt_identity, jwt_required
from flask_cors import cross_origin
from app.codes import *
from extensions import db

main_blueprint = Blueprint('main', __name__)

@main_blueprint.route('/get_carts', methods=['GET'])
@jwt_required()
@cross_origin()
def get_carts():
    username = get_jwt_identity()
    carts = Cart.query.filter(Cart.users.any(username=username)).all()
    return jsonify({"type": ResponseType.RESOURCE_FOUND.value, "msg": "Carts found", "data": [cart.to_map() for cart in carts]}), 200

@main_blueprint.route('/cart/<string:cart_id>', methods=['GET'])
@jwt_required()
@cross_origin()
def get_cart(name: str):
    cart = Cart.query.filter_by(name=name).first()

    if cart is None:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "Cart not found"}), 404
    
    return jsonify({"type": ResponseType.RESOURCE_FOUND.value, "msg": "Cart found", "data": cart.to_map()}), 200


@main_blueprint.route('/add_cart', methods=['POST'])
@jwt_required()
@cross_origin()
def add_cart():
    try: 
        data = request.get_json()
        name = data["name"]
        description = data["description"]
    except KeyError:
        return jsonify({"type": ResponseType.WRONG_PAYLOAD.value, "msg": "Missing name"}), 400
    
    cart = Cart(name=name, description=description)

    user = User.query.filter_by(username=get_jwt_identity()).first()
    if user is None:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "Logged in user not found"}), 404
    
    cart.users.append(user)
    db.session.add(cart)
    db.session.commit()

    return jsonify({"type": ResponseType.RESOURCE_CREATED.value, "msg": "Cart added successfully"}), 201

