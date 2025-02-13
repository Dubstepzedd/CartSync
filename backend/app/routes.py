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

@main_blueprint.route('/delete_user_from_cart/<int:cart_id>', methods=['DELETE'])
@jwt_required()
@cross_origin()
def delete_cart(cart_id: int):
    email = get_jwt_identity()
    user = User.query.filter_by(username=email).first()

    if not user:
        return jsonify({"type": ResponseType.UNAUTHORIZED.value, "msg": "User not found"}), 401

    cart = Cart.query.get(cart_id)

    if cart is None:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "Cart not found"}), 404

    if user not in cart.users:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "User is not in the cart"}), 400

    cart.users.remove(user)
    db.session.commit()

    return jsonify({"type": ResponseType.SUCCESS.value, "msg": "User removed from cart successfully"}), 200


@main_blueprint.route('/search_user', methods=['POST'])
@jwt_required()
@cross_origin()
def search_user():
    data = request.get_json()
    username = data["username"]
    current_user = User.query.filter_by(username=get_jwt_identity()).first()
    users = User.query.filter(User.username.startswith(username)).all()

    if current_user in users:
        users.remove(current_user)

    if users is None:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "User not found"}), 404

    return jsonify({"type": ResponseType.RESOURCE_FOUND.value, "msg": "User found", "data": [user.to_map() for user in users]}), 200


@main_blueprint.route('/add_friend', methods=['POST'])
@jwt_required()
@cross_origin()
def add_friend():
    data = request.get_json()
    friend_username = data["username"]
    friend = User.query.filter_by(username=friend_username).first()
    current_user = User.query.filter_by(username=get_jwt_identity()).first()

    if friend is None:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "Friend not found"}), 404
    
    if friend in current_user.friends or current_user in friend.friends:
        return jsonify({"type": ResponseType.RESOURCE_ALREADY_EXISTS.value, "msg": "Friend already added"}), 409
    
    current_user.friends.append(friend)
    friend.friends.append(current_user)
    db.session.commit()

    return jsonify({"type": ResponseType.SUCCESS.value, "msg": "Friend added successfully"}), 201


@main_blueprint.route('/remove_friend/<string:username>', methods=['DELETE'])
@jwt_required()
@cross_origin()
def remove_friend(username: str):
    friend = User.query.filter_by(username=username).first()
    current_user = User.query.filter_by(username=get_jwt_identity()).first()

    if friend is None:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "Friend not found"}), 404
    
    if friend not in current_user.friends or current_user not in friend.friends:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "Friend not found"}), 404
    
    current_user.friends.remove(friend)
    friend.friends.remove(current_user)
    db.session.commit()

    return jsonify({"type": ResponseType.SUCCESS.value, "msg": "Friend removed successfully"}), 200