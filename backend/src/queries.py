from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from src.models import User, Cart, CartItem, JwtBlocklist


async def get_user(db: AsyncSession, username: str) -> User | None:
    return await db.scalar(
        select(User)
        .where(User.username == username)
        .options(
            selectinload(User.friends),
            selectinload(User.received_requests),
            selectinload(User.sent_requests),
        )
        .execution_options(populate_existing=True)
    )


async def get_users(db: AsyncSession, usernames: list[str]) -> list[User]:
    if not usernames:
        return []
    return (await db.scalars(
        select(User)
        .where(User.username.in_(usernames))
        .options(
            selectinload(User.friends),
            selectinload(User.carts),
            selectinload(User.sent_requests),
            selectinload(User.received_requests),
        )
        .execution_options(populate_existing=True)
    )).all()


async def get_cart(db: AsyncSession, cart_id: int) -> Cart | None:
    return await db.scalar(
        select(Cart)
        .where(Cart.id == cart_id)
        .options(
            selectinload(Cart.items),
            selectinload(Cart.users),
        )
        .execution_options(populate_existing=True)
    )


async def get_item(db: AsyncSession, item_id: int) -> CartItem | None:
    return await db.scalar(
        select(CartItem)
        .where(CartItem.id == item_id)
        .options(selectinload(CartItem.cart))
        .execution_options(populate_existing=True)
    )


async def get_user_carts(db: AsyncSession, username: str) -> list[Cart]:
    return (await db.scalars(
        select(Cart)
        .where(Cart.users.any(User.username == username))
        .options(
            selectinload(Cart.items),
            selectinload(Cart.users),
        )
        .execution_options(populate_existing=True)
    )).all()


async def search_users(db: AsyncSession, prefix: str) -> list[User]:
    return (await db.scalars(
        select(User)
        .where(User.username.startswith(prefix))
        .options(
            selectinload(User.friends),
            selectinload(User.carts),
            selectinload(User.sent_requests),
            selectinload(User.received_requests),
        )
        .execution_options(populate_existing=True)
    )).all()


async def is_token_revoked(db: AsyncSession, jti: str) -> bool:
    return await db.scalar(select(JwtBlocklist).where(JwtBlocklist.jti == jti)) is not None
