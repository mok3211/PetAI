from sqlalchemy import Column, Integer, DateTime, ForeignKey, func, UniqueConstraint
from .base import Base

class Like(Base):
    __tablename__ = "likes"
    id = Column(Integer, primary_key=True, index=True)
    memory_id = Column(Integer, ForeignKey("memories.id"), index=True, nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), index=True, nullable=False)
    created_at = Column(DateTime, server_default=func.now())
    __table_args__ = (UniqueConstraint('memory_id', 'user_id', name='uq_like_memory_user'),)

