from sqlalchemy import Column, Integer, String
from .base import Base

class Product(Base):
    __tablename__ = "products"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(String, nullable=True)
    image_url = Column(String, nullable=True)
    price_cents = Column(Integer, nullable=False, default=0)
    stock = Column(Integer, nullable=False, default=0)

