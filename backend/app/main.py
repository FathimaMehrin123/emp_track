from fastapi import FastAPI

from backend.app.database.database import Base, engine
from backend.app.routes.auth_route import router as auth_router
from backend.app.models import user

app = FastAPI()

Base.metadata.create_all(bind=engine)

app.include_router(auth_router)