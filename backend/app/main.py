from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.app.database.database import Base, engine
from backend.app.routes.auth_route import router as auth_router
from backend.app.routes.attendance_route import router as attendance_router
from backend.app.routes.leave_route import router as leave_router
from backend.app.routes.admin_route import router as admin_router
from backend.app.routes.admin_route import router as employee_router


from backend.app.models import user_model
from backend.app.models import attendance_model 


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

Base.metadata.create_all(bind=engine)

app.include_router(auth_router)
app.include_router(attendance_router)
app.include_router(leave_router)
app.include_router(admin_router)
app.include_router(employee_router)