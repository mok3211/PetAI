from pydantic import BaseModel
from datetime import datetime

class LikeRead(BaseModel):
    id: int
    memory_id: int
    user_id: int
    created_at: datetime | None = None

    class Config:
        from_attributes = True

