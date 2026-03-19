from datetime import datetime, timezone
from typing import List
from sqlalchemy.orm import Mapped, declarative_base, mapped_column, relationship
from sqlalchemy import Boolean, String, Integer, DateTime, ForeignKey, Table, Column
from src.extensions import verify_password


Base = declarative_base()

users_to_carts = Table(
    "association_table",
    Base.metadata,
    Column("username", String(50), ForeignKey("users.username"), primary_key=True),
    Column("id", Integer, ForeignKey("carts.id"), primary_key=True),
)

users_to_users = Table(
    "friends",
    Base.metadata,
    Column("user_id", String(50), ForeignKey("users.username"), primary_key=True),
    Column("friend_id", String(50), ForeignKey("users.username"), primary_key=True),
)


class FriendRequest(Base):
    __tablename__ = "friend_requests"

    id: Mapped[int] = mapped_column(primary_key=True)
    sender_id: Mapped[str] = mapped_column(String(50), ForeignKey("users.username"), nullable=False)
    receiver_id: Mapped[str] = mapped_column(String(50), ForeignKey("users.username"), nullable=False)

    sender: Mapped["User"] = relationship("User", foreign_keys=[sender_id], back_populates="sent_requests")
    receiver: Mapped["User"] = relationship("User", foreign_keys=[receiver_id], back_populates="received_requests")


class User(Base):
    __tablename__ = "users"

    username: Mapped[str] = mapped_column(String(50), primary_key=True, nullable=False)
    password: Mapped[str] = mapped_column(String(128), nullable=False)

    friends: Mapped[List["User"]] = relationship(
        "User",
        secondary=users_to_users,
        primaryjoin=lambda: User.username == users_to_users.c.user_id,
        secondaryjoin=lambda: User.username == users_to_users.c.friend_id,
        back_populates="friends",
    )

    carts: Mapped[List["Cart"]] = relationship(
        "Cart", secondary=users_to_carts, back_populates="users"
    )

    sent_requests: Mapped[List["FriendRequest"]] = relationship(
        "FriendRequest",
        foreign_keys=[FriendRequest.sender_id],
        back_populates="sender",
    )

    received_requests: Mapped[List["FriendRequest"]] = relationship(
        "FriendRequest",
        foreign_keys=[FriendRequest.receiver_id],
        back_populates="receiver",
    )

    def check_password(self, password: str) -> bool:
        return verify_password(password, self.password)

    def __repr__(self) -> str:
        return f"User {self.username}"

    def to_map(self) -> dict:
        return {
            "username": self.username,
            "friends": [f.username for f in self.friends],
            "carts": [cart.id for cart in self.carts],
            "sent_friend_requests": [req.receiver_id for req in self.sent_requests],
            "received_friend_requests": [req.sender_id for req in self.received_requests],
        }


class Cart(Base):
    __tablename__ = "carts"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(50), nullable=False)
    description: Mapped[str] = mapped_column(String(255), nullable=False)
    owner_id: Mapped[str] = mapped_column(String(50), ForeignKey("users.username"), nullable=False)
    items: Mapped[list["CartItem"]] = relationship(
        "CartItem", back_populates="cart", cascade="all, delete-orphan"
    )
    users: Mapped[list["User"]] = relationship(
        "User", secondary=users_to_carts, back_populates="carts"
    )

    def __repr__(self) -> str:
        return f"Cart {self.name}: {self.description}"

    def to_map(self) -> dict:
        return {
            "id": self.id,
            "name": self.name,
            "description": self.description,
            "owner": self.owner_id,
            "items": [item.to_map() for item in self.items],
            "users": [user.username for user in self.users],
        }


class CartItem(Base):
    __tablename__ = "cart_items"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(50), nullable=False)
    is_checked: Mapped[bool] = mapped_column(Boolean, default=False)
    cart_id: Mapped[int] = mapped_column(Integer, ForeignKey("carts.id"), nullable=False)
    cart: Mapped["Cart"] = relationship("Cart", back_populates="items")

    def __repr__(self) -> str:
        return f"Item {self.id}: {self.name}"

    def to_map(self) -> dict:
        return {
            "id": self.id,
            "name": self.name,
            "cart": self.cart.name,
            "is_checked": self.is_checked,
            "cart_id": self.cart_id,
        }


class JwtBlocklist(Base):
    __tablename__ = "jwt_blocklist"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    jti: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    revoked_at: Mapped[datetime] = mapped_column(DateTime, nullable=False, default=lambda: datetime.now(timezone.utc))

    def __repr__(self) -> str:
        return f"JWT {self.jti} revoked at {self.revoked_at}"
