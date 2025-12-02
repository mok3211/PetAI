from pydantic import BaseModel

class ProductCreate(BaseModel):
    name: str
    description: str | None = None
    image_url: str | None = None
    price_cents: int
    stock: int = 0

class ProductRead(BaseModel):
    id: int
    name: str
    description: str | None = None
    image_url: str | None = None
    price_cents: int
    stock: int

    class Config:
        from_attributes = True

class ProductUpdate(BaseModel):
    name: str | None = None
    description: str | None = None
    image_url: str | None = None
    price_cents: int | None = None
    stock: int | None = None
