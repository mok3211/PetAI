from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from jose import jwt
import secrets
from ....schemas.auth import LoginRequest
from ....schemas.token import Token
from ....schemas.user import UserCreate
from ....schemas.oauth import OAuthGoogleRequest, OAuthFacebookRequest, OAuthWeChatRequest
from ....models.user import User
from ....deps import get_db
from ....core.security import verify_password, get_password_hash, create_access_token
from ....core.config import settings

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

@router.post("/oauth/google", response_model=Token)
def oauth_google(payload: OAuthGoogleRequest, db: Session = Depends(get_db)):
    sub = None
    email = None
    if settings.OAUTH_DEV_ALLOW and payload.id_token == "dev":
        sub = "google_dev_user"
        email = "google_dev_user@example.com"
    else:
        try:
            claims = jwt.get_unverified_claims(payload.id_token)
            sub = claims.get("sub")
            email = claims.get("email")
        except Exception:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid Google token")
    if not sub:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid Google token")
    synthetic_email = email or f"google_{sub}@local"
    user = db.query(User).filter((User.provider_id == sub) | (User.email == synthetic_email)).first()
    if not user:
        user = User(email=synthetic_email, hashed_password=get_password_hash(secrets.token_hex(16)), provider="google", provider_id=sub)
        db.add(user)
        db.commit()
        db.refresh(user)
    token = create_access_token(subject=user.email)
    return Token(access_token=token)

@router.post("/oauth/facebook", response_model=Token)
def oauth_facebook(payload: OAuthFacebookRequest, db: Session = Depends(get_db)):
    fid = None
    email = None
    if settings.OAUTH_DEV_ALLOW and payload.access_token == "dev":
        fid = "facebook_dev_user"
        email = "facebook_dev_user@example.com"
    else:
        fid = None
    if not fid:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid Facebook token")
    synthetic_email = email or f"facebook_{fid}@local"
    user = db.query(User).filter((User.provider_id == fid) | (User.email == synthetic_email)).first()
    if not user:
        user = User(email=synthetic_email, hashed_password=get_password_hash(secrets.token_hex(16)), provider="facebook", provider_id=fid)
        db.add(user)
        db.commit()
        db.refresh(user)
    token = create_access_token(subject=user.email)
    return Token(access_token=token)

@router.post("/oauth/wechat", response_model=Token)
def oauth_wechat(payload: OAuthWeChatRequest, db: Session = Depends(get_db)):
    wid = None
    if settings.OAUTH_DEV_ALLOW and payload.code == "dev":
        wid = "wechat_dev_user"
    else:
        wid = None
    if not wid:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid WeChat code")
    synthetic_email = f"wechat_{wid}@local"
    user = db.query(User).filter((User.provider_id == wid) | (User.email == synthetic_email)).first()
    if not user:
        user = User(email=synthetic_email, hashed_password=get_password_hash(secrets.token_hex(16)), provider="wechat", provider_id=wid)
        db.add(user)
        db.commit()
        db.refresh(user)
    token = create_access_token(subject=user.email)
    return Token(access_token=token)
