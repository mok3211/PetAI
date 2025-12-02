from sqlalchemy import Column, Integer, String, Date, ForeignKey
from sqlalchemy.orm import relationship
from .base import Base

class Pet(Base):
    __tablename__ = "pets"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), index=True, nullable=False)
    name = Column(String, nullable=False)
    species = Column(String, nullable=True)
    birth_date = Column(Date, nullable=True)
    passed_date = Column(Date, nullable=True)
    portrait_url = Column(String, nullable=True)
    notes = Column(String, nullable=True)

