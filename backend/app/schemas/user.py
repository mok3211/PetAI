from typing import Optional
from pydantic import BaseModel, EmailStr

class UserCreate(BaseModel):
    email: EmailStr
    password: str

class UserRead(BaseModel):
    id: int
    email: EmailStr
    nickname: Optional[str] = None
    avatar_url: Optional[str] = None
    is_admin: bool = False

    class Config:
        from_attributes = True

class UserUpdate(BaseModel):
    nickname: Optional[str] = None
    avatar_url: Optional[str] = None

class UserAdminUpdate(BaseModel):
    is_admin: bool
