from fastapi import APIRouter, Depends, status
from backend.app.database.database import SessionLocal
from backend.app.models.user import User
from backend.app.schemas.auth_schema import RegisterData, LoginData
from backend.app.utils.auth_util import pwd_context, create_access_token, get_current_user

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register", status_code=status.HTTP_201_CREATED)
def register(data: RegisterData):
    db = SessionLocal()

    if data.name.strip() == "" or data.email.strip() == "" or data.password.strip() == "":
        db.close()
        return {"error": "All fields are required"}

    if len(data.password) < 6:
        db.close()
        return {"error": "Password must contain at least 6 characters"}

    if len(data.password.encode("utf-8")) > 72:
        db.close()
        return {"error": "Password cannot be longer than 72 bytes"}

    existing_email = db.query(User).filter(User.email == data.email).first()

    if existing_email:
        db.close()
        return {"error": "Email already registered"}

    hashed_password = pwd_context.hash(data.password)

    new_user = User(
        name=data.name,
        email=data.email,
        hashed_password=hashed_password,
        role=data.role
    )

    db.add(new_user)
    db.commit()
    db.close()

    return {"message": "User registered successfully"}


@router.post("/login")
def login(data: LoginData):
    db = SessionLocal()

    user = db.query(User).filter(User.email == data.email).first()

    if user is None:
        db.close()
        return {"error": "Invalid email or password"}

    password_correct = pwd_context.verify(
        data.password,
        user.hashed_password
    )

    if not password_correct:
        db.close()
        return {"error": "Invalid email or password"}

    access_token = create_access_token(
        data={
            "user_id": str(user.id),
            "email": user.email,
            "role": user.role
        }
    )

    db.close()

    return {
        "token": access_token,
        "role": user.role
    }


# @router.get("/profile")
# def profile(current_user=Depends(get_current_user)):
#     if isinstance(current_user, dict) and "error" in current_user:
#         return current_user

#     db = SessionLocal()

#     user = db.query(User).filter(User.id == current_user["user_id"]).first()

#     db.close()

#     if user is None:
#         return {"error": "User not found"}

#     return {
#         "id": str(user.id),
#         "name": user.name,
#         "email": user.email,
#         "role": user.role
#     }