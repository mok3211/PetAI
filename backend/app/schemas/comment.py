from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class CommentCreate(BaseModel):
  memory_id: int
  content: str

class CommentRead(BaseModel):
  id: int
  memory_id: int
  user_id: int
  content: str
  created_at: Optional[datetime] = None

  class Config:
    from_attributes = True
