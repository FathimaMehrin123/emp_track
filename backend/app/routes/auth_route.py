from fastapi import APIRouter, Depends, HTTPException, status
from backend.app.database.database import SessionLocal
from backend.app.models.user_model import User
from backend.app.schemas.auth_schema import RegisterData
from backend.app.utils.auth_util import pwd_context, create_access_token, get_current_user
from fastapi.security import OAuth2PasswordRequestForm
router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/register", status_code=status.HTTP_201_CREATED)
def register(data: RegisterData):
    db = SessionLocal()

    try:
        if data.name.strip() == "" or data.email.strip() == "" or data.password.strip() == "":
            raise HTTPException(
                status_code=400,
                detail="All fields are required"
            )

        if len(data.password) < 6:
            raise HTTPException(
                status_code=400,
                detail="Password must contain at least 6 characters"
            )

        if len(data.password.encode("utf-8")) > 72:
            raise HTTPException(
                status_code=400,
                detail="Password cannot be longer than 72 bytes"
            )

        existing_email = db.query(User).filter(
            User.email == data.email
        ).first()

        if existing_email:
            raise HTTPException(
                status_code=409,
                detail="Email already registered"
            )

        hashed_password = pwd_context.hash(data.password)

        new_user = User(
            name=data.name,
            email=data.email,
            hashed_password=hashed_password,
            role=data.role
        )

        db.add(new_user)
        db.commit()

        return {
            "message": "User registered successfully"
        }

    except HTTPException:
        raise

    except Exception as e:
        db.rollback()
        print(e)

        raise HTTPException(
            status_code=500,
            detail="Something went wrong while registering."
        )

    finally:
        db.close()
        
@router.post("/login")
def login(data: OAuth2PasswordRequestForm = Depends()):
    # data: LoginData
    # OAuth2PasswordRequestForm reads login credentials as form data
    # (username and password) instead of JSON.
    # Here, the username field contains the user's email.
    # LoginData (Pydantic): Expects JSON -> {"email": "...", "password": "..."}
    # OAuth2PasswordRequestForm: Expects form data -> username=...&password=...
    # In this project, the username field is used to store the user's email.
    db = SessionLocal()
    try:
        user = db.query(User).filter(
            User.email == data.username
        ).first()

        if user is None:
            raise HTTPException(
                status_code=401,
                detail="Invalid email or password"
            )

        if not pwd_context.verify(
            data.password,
            user.hashed_password
        ):
            raise HTTPException(
                status_code=401,
                detail="Invalid email or password"
            )

        access_token = create_access_token(
            data={
                "user_id": str(user.id),
                "email": user.email,
                "role": user.role
            }
        )

        return {
            "access_token": access_token,
            "token_type": "bearer",
            "role": user.role
        }

    except HTTPException:
        raise

    except Exception as e:
        print(e)

        raise HTTPException(
            status_code=500,
            detail="Login failed."
        )

    finally:
        db.close()
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