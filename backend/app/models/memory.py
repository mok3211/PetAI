from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey, func, Boolean
from .base import Base

class Memory(Base):
    __tablename__ = "memories"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), index=True, nullable=False)
    pet_id = Column(Integer, ForeignKey("pets.id"), index=True, nullable=False)
    title = Column(String, nullable=False)
    content = Column(Text, nullable=True)
    media_url = Column(String, nullable=True)
    created_at = Column(DateTime, server_default=func.now())
    is_public = Column(Boolean, nullable=False, default=False)
