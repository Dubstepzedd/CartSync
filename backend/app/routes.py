from app.models import Cart, User, JwtBlocklist
from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required
from flask_cors import cross_origin
from app.codes import *
from extensions import db

main_blueprint = Blueprint('main', __name__)

@main_blueprint.route('/get_carts', methods=['GET'])
@jwt_required()
@cross_origin()
def get_carts():
    return jsonify({"id": 1, 'carts': [{"name": "Inköpslista", "description": "För att handla", "count": 15} for i in range(5)]}), 200

@main_blueprint.route('/cart/<string:cart_id>', methods=['GET'])
@jwt_required()
@cross_origin()
def get_cart(name: str):
    cart = Cart.query.filter_by(name=name).first()

    if cart is None:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "Cart not found"}), 404
    
    return jsonify({"type": ResponseType.RESOURCE_FOUND.value, "msg": "Cart found", "data": {"name": cart.name, "description": cart.description}}), 200



@main_blueprint.route('/cart/<int:cart_id>', methods=['POST'])
@jwt_required()
@cross_origin()
def add_cart():
    try: 
        data = request.get_json()
        name = data["name"]
        description = data["description"]
    except KeyError:
        return jsonify({"type": ResponseType.WRONG_PAYLOAD.value, "msg": "Missing name"}), 400
    
    
    cart = Cart.query.filter_by(name=name).first()

    if cart is not None:
        return jsonify({"type": ResponseType.RESOURCE_ALREADY_EXISTS.value, "msg": "Cart already exists with that name"}), 400
    
    cart = Cart(name=name, description=description)
    db.session.add(cart)
    db.session.commit()

    return jsonify({"type": ResponseType.RESOURCE_CREATED.value, "msg": "Cart added successfully"}), 201

