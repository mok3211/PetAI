from pydantic import BaseModel
from datetime import datetime

class CommentCreate(BaseModel):
  memory_id: int
  content: str

class CommentRead(BaseModel):
  id: int
  memory_id: int
  user_id: int
  content: str
  created_at: datetime | None = None

  class Config:
    from_attributes = True

