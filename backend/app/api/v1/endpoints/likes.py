from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ....deps import get_db, get_current_user
from ....models.like import Like
from ....schemas.like import LikeRead

router = APIRouter()

@router.get("/memories/{memory_id}/count")
def count_likes(memory_id: int, db: Session = Depends(get_db)):
    count = db.query(Like).filter(Like.memory_id == memory_id).count()
    return {"count": count}

@router.post("/memories/{memory_id}/toggle")
def toggle_like(memory_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    like = db.query(Like).filter(Like.memory_id == memory_id, Like.user_id == current_user.id).first()
    if like:
        db.delete(like)
        db.commit()
        liked = False
    else:
        like = Like(memory_id=memory_id, user_id=current_user.id)
        db.add(like)
        db.commit()
        liked = True
    count = db.query(Like).filter(Like.memory_id == memory_id).count()
    return {"liked": liked, "count": count}

@router.get("/memories/{memory_id}", response_model=list[LikeRead])
def list_likes(memory_id: int, db: Session = Depends(get_db)):
    return db.query(Like).filter(Like.memory_id == memory_id).order_by(Like.id.desc()).limit(10).all()
