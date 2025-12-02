from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ....schemas.auth import LoginRequest
from ....schemas.token import Token
from ....schemas.user import UserCreate
from ....models.user import User
from ....deps import get_db
from ....core.security import verify_password, get_password_hash, create_access_token

router = APIRouter()

@router.post("/login", response_model=Token)
def login(payload: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email).first()
    if not user or not verify_password(payload.password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    token = create_access_token(subject=user.email)
    return Token(access_token=token)

@router.post("/register")
def register(payload: UserCreate, db: Session = Depends(get_db)):
    exists = db.query(User).filter(User.email == payload.email).first()
    if exists:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered")
    first_user = db.query(User).count() == 0
    user = User(email=payload.email, hashed_password=get_password_hash(payload.password), is_admin=first_user)
    db.add(user)
    db.commit()
    db.refresh(user)
    return {"id": user.id}
