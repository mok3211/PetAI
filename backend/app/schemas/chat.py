from pydantic import BaseModel
from datetime import datetime

class ChatRequest(BaseModel):
    pet_id: int
    content: str

class ChatMessageRead(BaseModel):
    id: int
    pet_id: int
    role: str
    content: str
    created_at: datetime | None = None

    class Config:
        from_attributes = True

