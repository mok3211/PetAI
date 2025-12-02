from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ....deps import get_db, get_current_user
from ....schemas.user import UserRead, UserUpdate, UserAdminUpdate
from ....models.user import User

router = APIRouter()

@router.get("/me", response_model=UserRead)
def read_me(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return current_user

@router.get("/{user_id}", response_model=UserRead)
def read_user(user_id: int, db: Session = Depends(get_db)):
    return db.query(User).filter(User.id == user_id).first()

@router.put("/me", response_model=UserRead)
def update_me(payload: UserUpdate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    for k, v in payload.model_dump(exclude_unset=True).items():
        setattr(current_user, k, v)
    db.add(current_user)
    db.commit()
    db.refresh(current_user)
    return current_user

@router.get("/", response_model=list[UserRead])
def list_users(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    if not getattr(current_user, "is_admin", False):
        return []
    return db.query(User).order_by(User.id.desc()).all()

@router.put("/{user_id}/admin", response_model=UserRead)
def set_admin(user_id: int, payload: UserAdminUpdate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    if not getattr(current_user, "is_admin", False):
        return current_user
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        return current_user
    user.is_admin = payload.is_admin
    db.add(user)
    db.commit()
    db.refresh(user)
    return user
