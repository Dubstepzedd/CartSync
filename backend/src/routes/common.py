from fastapi import APIRouter, Depends, Request
from sqlalchemy.ext.asyncio import AsyncSession

from src.models import Cart, CartItem, FriendRequest, User
from src.codes import ResponseType, make_response
from src.extensions import get_db
from src.security import get_current_user
from src.queries import get_user, get_users, get_cart, get_item, get_user_carts, search_users
from src.helpers import find_request

main_router = APIRouter()


@main_router.get("/carts")
async def get_carts(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    carts = await get_user_carts(db, current_user.username)
    return make_response(ResponseType.RESOURCE_FOUND, "Carts found", 200, data=[cart.to_map() for cart in carts])


@main_router.get("/cart/{cart_id}")
async def get_cart_route(
    cart_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    cart = await get_cart(db, cart_id)
    if cart is None:
        return make_response(ResponseType.RESOURCE_NOT_FOUND, "Cart not found", 404)
    return make_response(ResponseType.RESOURCE_FOUND, "Cart found", 200, data=cart.to_map())


@main_router.post("/cart/create")
async def add_cart(
    request: Request,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    try:
        data = await request.json()
        name = data["name"]
        description = data["description"]
    except Exception:
        return make_response(ResponseType.WRONG_PAYLOAD, "Missing required fields: name, description", 400)

    cart = Cart(name=name, description=description, owner_id=current_user.username)
    cart.users.append(current_user)
    db.add(cart)
    await db.commit()
    return make_response(ResponseType.RESOURCE_CREATED, "Cart added successfully", 201)


@main_router.delete("/cart/remove/{cart_id}")
async def delete_cart(
    cart_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    cart = await get_cart(db, cart_id)
    if cart is None:
        return make_response(ResponseType.RESOURCE_NOT_FOUND, "Cart not found", 404)

    if current_user not in cart.users:
        return make_response(ResponseType.RESOURCE_NOT_FOUND, "User is not in the cart", 400)

    cart.users.remove(current_user)
    await db.commit()
    return make_response(ResponseType.SUCCESS, "User removed from cart successfully", 200)


@main_router.post("/user/search")
async def search_user(
    request: Request,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    data = await request.json()
    username = data.get("username", None)
    if not username:
        return make_response(ResponseType.WRONG_PAYLOAD, "'username' not found in the payload.", 400)

    users = [u for u in await search_users(db, username) if u != current_user]
    return make_response(ResponseType.RESOURCE_FOUND, "User found", 200, data=[user.to_map() for user in users])


@main_router.get("/user/friends")
async def get_friends(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    friends = await get_users(db, [f.username for f in current_user.friends])
    return make_response(
        ResponseType.RESOURCE_FOUND, "Friends found", 200, data=[f.to_map() for f in friends]
    )


@main_router.get("/user/requests")
async def get_friend_requests(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    senders = await get_users(db, [req.sender_id for req in current_user.received_requests])
    return make_response(
        ResponseType.RESOURCE_FOUND,
        "Requests found",
        200,
        data=[s.to_map() for s in senders],
    )


@main_router.post("/user/request")
async def send_friend_request(
    request: Request,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    data = await request.json()
    target_username = data.get("username", None)

    if not target_username:
        return make_response(ResponseType.WRONG_PAYLOAD, "Target username missing.", 400)

    if target_username == current_user.username:
        return make_response(ResponseType.WRONG_PAYLOAD, "You cannot send a friend request to yourself.", 400)

    target_user = await get_user(db, target_username)
    if not target_user:
        return make_response(ResponseType.RESOURCE_NOT_FOUND, "User not found.", 404)

    if target_user in current_user.friends:
        return make_response(ResponseType.RESOURCE_ALREADY_EXISTS, "You are already friends.", 409)

    if find_request(current_user.sent_requests, receiver_id=target_username) is not None:
        return make_response(ResponseType.RESOURCE_ALREADY_EXISTS, "Friend request already sent.", 409)

    new_request = FriendRequest(sender_id=current_user.username, receiver_id=target_username)
    db.add(new_request)
    await db.commit()
    return make_response(ResponseType.RESOURCE_CREATED, "Friend request sent.", 201)


@main_router.post("/user/accept")
async def accept_friend_request(
    request: Request,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    data = await request.json()
    sender_username = data.get("username", None)

    if not sender_username:
        return make_response(ResponseType.WRONG_PAYLOAD, "Sender username missing.", 400)

    sender_user = await get_user(db, sender_username)
    if not sender_user:
        return make_response(ResponseType.RESOURCE_NOT_FOUND, "User not found.", 404)

    incoming_req = find_request(current_user.received_requests, sender_id=sender_username)
    if not incoming_req:
        return make_response(ResponseType.RESOURCE_NOT_FOUND, "No incoming friend request from this user.", 404)

    current_user.friends.append(sender_user)
    sender_user.friends.append(current_user)
    await db.delete(incoming_req)
    await db.commit()
    return make_response(ResponseType.SUCCESS, "Friend request accepted.", 200)


@main_router.delete("/user/remove/request/{target_username}")
async def remove_friend_request(
    target_username: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    out_req = find_request(current_user.sent_requests, receiver_id=target_username)
    if out_req:
        await db.delete(out_req)
        await db.commit()
        return make_response(ResponseType.SUCCESS, "Friend request canceled.", 200)

    in_req = find_request(current_user.received_requests, sender_id=target_username)
    if in_req:
        await db.delete(in_req)
        await db.commit()
        return make_response(ResponseType.SUCCESS, "Friend request declined.", 200)

    return make_response(ResponseType.RESOURCE_NOT_FOUND, "No pending request found with this user.", 404)


@main_router.delete("/user/remove/friend/{target_username}")
async def remove_friend(
    target_username: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    target_user = await get_user(db, target_username)
    if not target_user:
        return make_response(ResponseType.RESOURCE_NOT_FOUND, "User not found.", 404)

    if target_user not in current_user.friends:
        return make_response(ResponseType.RESOURCE_NOT_FOUND, "You are not friends with this user.", 404)

    current_user.friends.remove(target_user)
    if current_user in target_user.friends:
        target_user.friends.remove(current_user)
    await db.commit()
    return make_response(ResponseType.SUCCESS, "Friend removed.", 200)


@main_router.post("/cart/share")
async def share_cart(
    request: Request,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    data = await request.json()
    cart_id = data.get("cart_id")
    target_username = data.get("username")

    if not cart_id or not target_username:
        return make_response(ResponseType.WRONG_PAYLOAD, "cart_id and username are required.", 400)

    target_user = await get_user(db, target_username)
    if not target_user:
        return make_response(ResponseType.RESOURCE_NOT_FOUND, "User not found.", 404)

    if target_user not in current_user.friends:
        return make_response(ResponseType.UNAUTHORIZED, "You can only share carts with friends.", 403)

    cart = await get_cart(db, cart_id)
    if not cart:
        return make_response(ResponseType.RESOURCE_NOT_FOUND, "Cart not found.", 404)

    if cart.owner_id != current_user.username:
        return make_response(ResponseType.UNAUTHORIZED, "Only the cart owner can share it.", 403)

    if target_user in cart.users:
        return make_response(ResponseType.RESOURCE_ALREADY_EXISTS, "User is already in this cart.", 409)

    cart.users.append(target_user)
    await db.commit()
    return make_response(ResponseType.SUCCESS, f"Cart shared with {target_username}.", 200)


@main_router.post("/cart/item/add")
async def add_item(
    request: Request,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    data = await request.json()
    cart_id = data["cart_id"]
    name = data["item_name"]

    cart = await get_cart(db, cart_id)
    if cart is None:
        return make_response(ResponseType.RESOURCE_NOT_FOUND, "Cart not found", 404)

    item = CartItem(name=name, cart_id=cart_id)
    db.add(item)
    await db.commit()
    item = await get_item(db, item.id)
    return make_response(ResponseType.RESOURCE_CREATED, "Item added successfully", 201, data=item.to_map())


@main_router.post("/cart/item/toggle")
async def toggle_item(
    request: Request,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    data = await request.json()
    item_id = data["item_id"]

    item = await get_item(db, item_id)
    if item is None:
        return make_response(ResponseType.RESOURCE_NOT_FOUND, "Item not found", 404)

    item.is_checked = not item.is_checked
    await db.commit()
    return make_response(ResponseType.SUCCESS, "Item modified successfully", 200, data=item.to_map())


@main_router.delete("/cart/item/remove/{item_id}")
async def delete_item(
    item_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    item = await get_item(db, item_id)
    if item is None:
        return make_response(ResponseType.RESOURCE_NOT_FOUND, "Item not found", 404)

    await db.delete(item)
    await db.commit()
    return make_response(ResponseType.SUCCESS, "Item deleted successfully", 200)
