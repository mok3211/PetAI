from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ....deps import get_db, get_current_user
from ....models.cart import Cart, CartItem
from ....models.product import Product
from ....schemas.cart import CartItemCreate, CartRead, CartItemRead

router = APIRouter()

def _get_or_create_cart(db: Session, user_id: int) -> Cart:
    cart = db.query(Cart).filter(Cart.user_id == user_id).first()
    if not cart:
        cart = Cart(user_id=user_id)
        db.add(cart)
        db.commit()
        db.refresh(cart)
    return cart

@router.get("/", response_model=CartRead)
def read_cart(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    cart = _get_or_create_cart(db, current_user.id)
    items = db.query(CartItem).filter(CartItem.cart_id == cart.id).all()
    total = sum(i.quantity * i.unit_price_cents for i in items)
    return {
        "id": cart.id,
        "items": items,
        "total_cents": total,
    }

@router.post("/items", response_model=CartRead, status_code=status.HTTP_201_CREATED)
def add_item(payload: CartItemCreate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    cart = _get_or_create_cart(db, current_user.id)
    product = db.query(Product).filter(Product.id == payload.product_id).first()
    if not product:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")
    if product.stock < payload.quantity:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Stock not enough")
    item = CartItem(cart_id=cart.id, product_id=product.id, quantity=payload.quantity, unit_price_cents=product.price_cents)
    db.add(item)
    db.commit()
    items = db.query(CartItem).filter(CartItem.cart_id == cart.id).all()
    total = sum(i.quantity * i.unit_price_cents for i in items)
    return {"id": cart.id, "items": items, "total_cents": total}

@router.put("/items/{item_id}", response_model=CartRead)
def update_item(item_id: int, payload: CartItemCreate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    cart = _get_or_create_cart(db, current_user.id)
    item = db.query(CartItem).filter(CartItem.id == item_id, CartItem.cart_id == cart.id).first()
    if not item:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Item not found")
    product = db.query(Product).filter(Product.id == item.product_id).first()
    if product.stock < payload.quantity:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Stock not enough")
    item.quantity = payload.quantity
    db.add(item)
    db.commit()
    items = db.query(CartItem).filter(CartItem.cart_id == cart.id).all()
    total = sum(i.quantity * i.unit_price_cents for i in items)
    return {"id": cart.id, "items": items, "total_cents": total}

@router.delete("/items/{item_id}", response_model=CartRead)
def delete_item(item_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    cart = _get_or_create_cart(db, current_user.id)
    item = db.query(CartItem).filter(CartItem.id == item_id, CartItem.cart_id == cart.id).first()
    if not item:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Item not found")
    db.delete(item)
    db.commit()
    items = db.query(CartItem).filter(CartItem.cart_id == cart.id).all()
    total = sum(i.quantity * i.unit_price_cents for i in items)
    return {"id": cart.id, "items": items, "total_cents": total}
