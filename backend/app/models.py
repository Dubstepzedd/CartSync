from datetime import datetime
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import Boolean, String, Integer, DateTime, ForeignKey, Table
from extensions import db, bcrypt

# The models below use the updated syntax in SQLAlchemy 2.0. 

users_to_carts = Table(
    "association_table",
    db.Model.metadata,
    db.Column("username", db.String(50), db.ForeignKey("users.username"), primary_key=True),
    db.Column("id", db.String(50), db.ForeignKey("carts.id"), primary_key=True)
)

users_to_users = Table(
    "following",
    db.Model.metadata,
    db.Column("user_id", db.String(50), db.ForeignKey("users.username"), primary_key=True),
    db.Column("follow_id", db.String(50), db.ForeignKey("users.username"), primary_key=True)
)

class User(db.Model):
    __tablename__ = "users"
    
    username: Mapped[str] = mapped_column(String(50), primary_key=True, nullable=False)
    password: Mapped[str] = mapped_column(String(60), nullable=False)
    following: Mapped[list["User"]] = relationship(
        "User",
        secondary=users_to_users,
        primaryjoin=username == users_to_users.c.user_id,
        secondaryjoin=username == users_to_users.c.follow_id,
        backref="friend_of",
        lazy=True
    )

    carts: Mapped[list["Cart"]] = relationship("Cart", secondary=users_to_carts, back_populates="users", lazy=True)

    def __init__(self, username: str, password: str):
        self.username = username
        self.password = bcrypt.generate_password_hash(password).decode("utf-8")

    def check_password(self, password: str) -> bool:
        return bcrypt.check_password_hash(self.password, password)
    
    def __repr__(self) -> str:
        return f"User {self.username}"
    
    def to_map(self) -> dict:
        return {"username": self.username, "carts": [cart.id for cart in self.carts], "following": [friend.username for friend in self.following]}

class Cart(db.Model):
    __tablename__ = "carts"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(50), nullable=False)
    description: Mapped[str] = mapped_column(String(255), nullable=False)
    items: Mapped[list["CartItem"]] = relationship("CartItem", back_populates="cart", lazy=True, cascade="all, delete-orphan")
    users: Mapped[list["User"]] = relationship("User", secondary=users_to_carts, back_populates="carts", lazy=True)

    def __init__(self, name: str, description: str):
        self.name = name
        self.description = description
    
    def __repr__(self) -> str:
        return f"Cart {self.name}: {self.description}"
    
    def to_map(self) -> dict:
        return {"id": self.id, "name": self.name, "description": self.description, "items": [item.to_map() for item in self.items], "users": [user.username for user in self.users]}

class CartItem(db.Model):
    __tablename__ = "cart_items"
    
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(50), nullable=False)
    description: Mapped[str] = mapped_column(String(255), nullable=False)
    is_checked: Mapped[bool] = mapped_column(Boolean, default=False)
    cart_id: Mapped[int] = mapped_column(Integer, ForeignKey("carts.id"), nullable=False)
    cart: Mapped["Cart"] = relationship("Cart", back_populates="items", lazy=True)

    def __init__(self, name: str, description: str, cart: str, is_checked: bool = False):
        self.name = name
        self.description = description
        self.cart = cart
        self.is_checked = is_checked

    def __repr__(self) -> str:
        return f"Item {self.id}: {self.name}, (Cart: {self.cart.name})"
    
    def to_map(self) -> dict:
        return {"id": self.id, "name": self.name, "description": self.description, "cart": self.cart.name, "is_checked": self.is_checked, "cart_id": self.cart_id}

class JwtBlocklist(db.Model):
    __tablename__ = "jwt_blocklist"
    
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    jti: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    revoked_at: Mapped[datetime] = mapped_column(DateTime, nullable=False, default=datetime.now)

    def __repr__(self) -> str:
        return f"JWT {self.jti} revoked at {self.revoked_at}"
