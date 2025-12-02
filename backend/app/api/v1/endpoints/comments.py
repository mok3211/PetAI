from typing import List
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from ....deps import get_db, get_current_user
from ....models.comment import Comment
from ....schemas.comment import CommentCreate, CommentRead

router = APIRouter()

@router.get("/memories/{memory_id}", response_model=List[CommentRead])
def list_comments(memory_id: int, db: Session = Depends(get_db)):
    return db.query(Comment).filter(Comment.memory_id == memory_id).order_by(Comment.id.desc()).all()

@router.post("/", response_model=CommentRead, status_code=status.HTTP_201_CREATED)
def create_comment(payload: CommentCreate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    c = Comment(memory_id=payload.memory_id, user_id=current_user.id, content=payload.content)
    db.add(c)
    db.commit()
    db.refresh(c)
    return c
