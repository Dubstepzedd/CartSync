from app.models import Cart, CartItem, FriendRequest, User
from flask import Blueprint, jsonify, request
from flask_jwt_extended import get_jwt_identity, jwt_required
from flask_cors import cross_origin
from app.codes import ResponseType
from extensions import db

main_blueprint = Blueprint('main', __name__)

@main_blueprint.route('/carts', methods=['GET'])
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


@main_blueprint.route('/cart/create', methods=['POST'])
@jwt_required()
@cross_origin()
def add_cart():
    try:
        data = request.get_json()
        name = data["name"]
        description = data["description"]
    except KeyError:
        return jsonify({"type": ResponseType.WRONG_PAYLOAD.value, "msg": "Missing name"}), 400

    username = get_jwt_identity()
    user = User.query.filter_by(username=username).first()
    if user is None:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "Logged in user not found"}), 404

    cart = Cart(name=name, description=description, owner_id=username)
    cart.users.append(user)
    db.session.add(cart)
    db.session.commit()

    return jsonify({"type": ResponseType.RESOURCE_CREATED.value, "msg": "Cart added successfully"}), 201


@main_blueprint.route('/cart/remove/<int:cart_id>', methods=['DELETE'])
@jwt_required()
@cross_origin()
def delete_cart(cart_id: int):
    email = get_jwt_identity()
    user = User.query.filter_by(username=email).first()

    if not user:
        return jsonify({"type": ResponseType.UNAUTHORIZED.value, "msg": "User not found"}), 401

    cart: Cart = Cart.query.get(cart_id)

    if cart is None:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "Cart not found"}), 404

    if user not in cart.users:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "User is not in the cart"}), 400

    cart.users.remove(user)
    db.session.commit()

    return jsonify({"type": ResponseType.SUCCESS.value, "msg": "User removed from cart successfully"}), 200


@main_blueprint.route('/user/search', methods=['POST'])
@jwt_required()
@cross_origin()
def search_user():
    data = request.get_json()
    username = data.get("username", None)
    if not username:
        return jsonify({"type": ResponseType.WRONG_PAYLOAD.value, "msg": "'username' not found in the payload."}), 400
    current_user: User = User.query.filter_by(username=get_jwt_identity()).first()
    users = User.query.filter(User.username.startswith(username)).all()

    if not current_user:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "The JWT's mapped username does not correlate to a database entry."}), 400

    if current_user in users:
        users.remove(current_user)

    if users is None:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "User not found"}), 404

    return jsonify({"type": ResponseType.RESOURCE_FOUND.value, "msg": "User found", "data": [user.to_map() for user in users]}), 200


@main_blueprint.route('/user/friends', methods=['GET'])
@jwt_required()
@cross_origin()
def get_friends():
    user: User = User.query.filter_by(username=get_jwt_identity()).first()

    if not user:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "User not found."}), 404

    return jsonify({
        "type": ResponseType.RESOURCE_FOUND.value,
        "msg": "Friends found",
        "data": [friend.to_map() for friend in user.friends]
    }), 200


@main_blueprint.route('/user/requests', methods=['GET'])
@jwt_required()
@cross_origin()
def get_friend_requests():
    user: User = User.query.filter_by(username=get_jwt_identity()).first()

    if not user:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "User not found."}), 404

    return jsonify({
        "type": ResponseType.RESOURCE_FOUND.value,
        "msg": "Requests found",
        "data": [req.sender.to_map() for req in user.received_requests]
    }), 200

@main_blueprint.route('/user/request', methods=['POST'])
@jwt_required()
@cross_origin()
def send_friend_request():
    data = request.get_json()
    target_username = data.get("username", None)
    current_username = get_jwt_identity()

    if not target_username:
        return jsonify({"type": ResponseType.WRONG_PAYLOAD.value, "msg": "Target username missing."}), 400

    if target_username == current_username:
        return jsonify({"type": ResponseType.WRONG_PAYLOAD.value, "msg": "You cannot send a friend request to yourself."}), 400

    current_user: User = User.query.filter_by(username=current_username).first()
    target_user: User = User.query.filter_by(username=target_username).first()

    if not target_user or not current_user:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "User not found."}), 404

    if target_user in current_user.friends:
        return jsonify({"type": ResponseType.RESOURCE_ALREADY_EXISTS.value, "msg": "You are already friends."}), 409

    existing_req = FriendRequest.query.filter_by(
        sender_id=current_username,
        receiver_id=target_username
    ).first()

    if existing_req:
        return jsonify({"type": ResponseType.RESOURCE_ALREADY_EXISTS.value, "msg": "Friend request already sent."}), 409

    new_request = FriendRequest(sender=current_user, receiver=target_user)
    db.session.add(new_request)
    db.session.commit()

    return jsonify({"type": ResponseType.RESOURCE_CREATED.value, "msg": "Friend request sent."}), 201


@main_blueprint.route('/user/accept', methods=['POST'])
@jwt_required()
@cross_origin()
def accept_friend_request():
    data = request.get_json()
    sender_username = data.get("username", None)
    current_username = get_jwt_identity()

    if not sender_username:
        return jsonify({"type": ResponseType.WRONG_PAYLOAD.value, "msg": "Sender username missing."}), 400

    current_user: User = User.query.filter_by(username=current_username).first()
    sender_user: User = User.query.filter_by(username=sender_username).first()

    if not current_user or not sender_user:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "User not found."}), 404

    incoming_req = FriendRequest.query.filter_by(
        sender_id=sender_username,
        receiver_id=current_username
    ).first()

    if not incoming_req:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "No incoming friend request from this user."}), 404

    current_user.friends.append(sender_user)
    sender_user.friends.append(current_user)
    db.session.delete(incoming_req)
    db.session.commit()

    return jsonify({"type": ResponseType.SUCCESS.value, "msg": "Friend request accepted."}), 200


@main_blueprint.route('/user/remove/request/<string:target_username>', methods=['DELETE'])
@jwt_required()
@cross_origin()
def remove_friend_request(target_username: str):
    current_username = get_jwt_identity()

    # Cancel an outgoing request
    out_req = FriendRequest.query.filter_by(
        sender_id=current_username,
        receiver_id=target_username
    ).first()

    if out_req:
        db.session.delete(out_req)
        db.session.commit()
        return jsonify({"type": ResponseType.SUCCESS.value, "msg": "Friend request canceled."}), 200

    # Decline an incoming request
    in_req = FriendRequest.query.filter_by(
        sender_id=target_username,
        receiver_id=current_username
    ).first()

    if in_req:
        db.session.delete(in_req)
        db.session.commit()
        return jsonify({"type": ResponseType.SUCCESS.value, "msg": "Friend request declined."}), 200

    return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "No pending request found with this user."}), 404


@main_blueprint.route('/user/remove/friend/<string:target_username>', methods=['DELETE'])
@jwt_required()
@cross_origin()
def remove_friend(target_username: str):
    current_username = get_jwt_identity()
    current_user: User = User.query.filter_by(username=current_username).first()
    target_user: User = User.query.filter_by(username=target_username).first()

    if not current_user or not target_user:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "User not found."}), 404

    if target_user not in current_user.friends:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "You are not friends with this user."}), 404

    current_user.friends.remove(target_user)
    if current_user in target_user.friends:
        target_user.friends.remove(current_user)
    db.session.commit()

    return jsonify({"type": ResponseType.SUCCESS.value, "msg": "Friend removed."}), 200

@main_blueprint.route('/cart/share', methods=['POST'])
@jwt_required()
@cross_origin()
def share_cart():
    data = request.get_json()
    cart_id = data.get("cart_id")
    target_username = data.get("username")

    if not cart_id or not target_username:
        return jsonify({"type": ResponseType.WRONG_PAYLOAD.value, "msg": "cart_id and username are required."}), 400

    current_username = get_jwt_identity()
    current_user: User = User.query.filter_by(username=current_username).first()
    target_user: User = User.query.filter_by(username=target_username).first()

    if not current_user or not target_user:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "User not found."}), 404

    if target_user not in current_user.friends:
        return jsonify({"type": ResponseType.UNAUTHORIZED.value, "msg": "You can only share carts with friends."}), 403

    cart: Cart = Cart.query.get(cart_id)

    if not cart:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "Cart not found."}), 404

    if cart.owner_id != current_username:
        return jsonify({"type": ResponseType.UNAUTHORIZED.value, "msg": "Only the cart owner can share it."}), 403

    if target_user in cart.users:
        return jsonify({"type": ResponseType.RESOURCE_ALREADY_EXISTS.value, "msg": "User is already in this cart."}), 409

    cart.users.append(target_user)
    db.session.commit()

    return jsonify({"type": ResponseType.SUCCESS.value, "msg": f"Cart shared with {target_username}."}), 200


@main_blueprint.route('/cart/item/add', methods=['POST'])
@jwt_required()
@cross_origin()
def add_item():
    data = request.get_json()
    cart_id = data["cart_id"]
    name = data["item_name"]

    cart = Cart.query.get(cart_id)

    if cart is None:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "Cart not found"}), 404

    item = CartItem(name=name, cart=cart)
    db.session.add(item)
    db.session.commit()

    return jsonify({"type": ResponseType.RESOURCE_CREATED.value, "msg": "Item added successfully", "data": item.to_map()}), 201

@main_blueprint.route('/cart/item/toggle', methods=['POST'])
@jwt_required()
@cross_origin()
def toggle_item():
    data = request.get_json()
    item_id = data["item_id"]

    item: CartItem = CartItem.query.get(item_id)

    if item is None:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "Item not found"}), 404

    item.is_checked = not item.is_checked
    db.session.commit()
    return jsonify({"type": ResponseType.SUCCESS.value, "msg": "Item modified successfully", "data": item.to_map()}), 200


@main_blueprint.route('/cart/item/remove/<int:item_id>', methods=['DELETE'])
@jwt_required()
@cross_origin()
def delete_item(item_id : int):
    item = CartItem.query.get(item_id)

    if item is None:
        return jsonify({"type": ResponseType.RESOURCE_NOT_FOUND.value, "msg": "Item not found"}), 404

    db.session.delete(item)
    db.session.commit()

    return jsonify({"type": ResponseType.SUCCESS.value, "msg": "Item deleted successfully"}), 200