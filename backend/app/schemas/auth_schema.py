from pydantic import BaseModel


class RegisterData(BaseModel):
    name: str
    email: str
    password: str
    role: str = "employee"


class LoginData(BaseModel):
    email: str
    password: str