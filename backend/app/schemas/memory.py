from typing import Optional
from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class MemoryCreate(BaseModel):
    pet_id: int
    title: str
    content: Optional[str] = None
    media_url: Optional[str] = None
    is_public: bool = False

class MemoryUpdate(BaseModel):
    title: Optional[str] = None
    content: Optional[str] = None
    media_url: Optional[str] = None
    is_public: Optional[bool] = None

class MemoryRead(BaseModel):
    id: int
    pet_id: int
    title: str
    content: Optional[str]
    media_url: Optional[str]
    created_at: Optional[datetime] = None
    is_public: bool = False

    class Config:
        from_attributes = True
