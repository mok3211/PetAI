from typing import Optional
from pydantic import BaseModel
from datetime import date

class PetCreate(BaseModel):
    name: str
    species: Optional[str] = None
    birth_date: Optional[date] = None
    passed_date: Optional[date] = None
    portrait_url: Optional[str] = None
    notes: Optional[str] = None

class PetUpdate(BaseModel):
    name: Optional[str] = None
    species: Optional[str] = None
    birth_date: Optional[date] = None
    passed_date: Optional[date] = None
    portrait_url: Optional[str] = None
    notes: Optional[str] = None

class PetRead(BaseModel):
    id: int
    name: str
    species: Optional[str]
    birth_date: Optional[date]
    passed_date: Optional[date]
    portrait_url: Optional[str]
    notes: Optional[str]

    class Config:
        from_attributes = True

