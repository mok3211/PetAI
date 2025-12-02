from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ....deps import get_db, get_current_user
from ....models.chat import ChatMessage
from ....schemas.chat import ChatRequest, ChatMessageRead

router = APIRouter()

@router.get("/history/pets/{pet_id}", response_model=List[ChatMessageRead])
def history(pet_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return (
        db.query(ChatMessage)
        .filter(ChatMessage.user_id == current_user.id, ChatMessage.pet_id == pet_id)
        .order_by(ChatMessage.id.asc())
        .limit(100)
        .all()
    )

@router.post("/chat", response_model=List[ChatMessageRead])
def chat(payload: ChatRequest, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    user_msg = ChatMessage(user_id=current_user.id, pet_id=payload.pet_id, role="user", content=payload.content)
    db.add(user_msg)
    db.commit()
    db.refresh(user_msg)
    reply = f"我在这里陪你。关于{payload.pet_id}号宠物，我会一直记着你的回忆：{payload.content}"
    ai_msg = ChatMessage(user_id=current_user.id, pet_id=payload.pet_id, role="assistant", content=reply)
    db.add(ai_msg)
    db.commit()
    db.refresh(ai_msg)
    return [user_msg, ai_msg]
