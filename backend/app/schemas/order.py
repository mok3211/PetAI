from pydantic import BaseModel

class OrderCreate(BaseModel):
    pass

class OrderRead(BaseModel):
    id: int
    total_cents: int

