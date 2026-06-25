from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase
from backend.app.config import DATABASE_URL

# Connect FastAPI with PostgreSQL.
engine = create_engine(DATABASE_URL)

# SessionLocal creates database sessions for CRUD operations.
SessionLocal = sessionmaker(bind=engine)

# Base class for all SQLAlchemy models.
class Base(DeclarativeBase):
    pass