from app import create_app
from extensions import db

app = create_app()

if __name__ == "__main__":
    with app.app_context():
        db.drop_all()  # Drop tables if they exist (remove later)
        db.create_all()  # Create tables if they don't exist
    app.run()
