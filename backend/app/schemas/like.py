from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class LikeRead(BaseModel):
    id: int
    memory_id: int
    user_id: int
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True
