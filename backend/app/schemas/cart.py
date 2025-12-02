from pydantic import BaseModel

class CartItemCreate(BaseModel):
    product_id: int
    quantity: int = 1

class CartItemRead(BaseModel):
    id: int
    product_id: int
    quantity: int
    unit_price_cents: int

    class Config:
        from_attributes = True

class CartRead(BaseModel):
    id: int
    items: list[CartItemRead]
    total_cents: int

