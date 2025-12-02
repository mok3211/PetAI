from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ....deps import get_db, get_current_user
from ....models.cart import Cart, CartItem
from ....models.product import Product
from ....models.order import Order, OrderItem
from ....schemas.order import OrderRead

router = APIRouter()

from typing import Optional

def _get_cart(db: Session, user_id: int) -> Optional[Cart]:
    return db.query(Cart).filter(Cart.user_id == user_id).first()

@router.post("/", response_model=OrderRead, status_code=status.HTTP_201_CREATED)
def create_order(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    cart = _get_cart(db, current_user.id)
    if not cart:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Cart empty")
    items = db.query(CartItem).filter(CartItem.cart_id == cart.id).all()
    if not items:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Cart empty")
    total = 0
    for i in items:
        product = db.query(Product).filter(Product.id == i.product_id).first()
        if not product or product.stock < i.quantity:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Stock not enough")
        product.stock -= i.quantity
        db.add(product)
        total += i.quantity * i.unit_price_cents
    order = Order(user_id=current_user.id, total_cents=total)
    db.add(order)
    db.commit()
    db.refresh(order)
    for i in items:
        oi = OrderItem(order_id=order.id, product_id=i.product_id, quantity=i.quantity, unit_price_cents=i.unit_price_cents)
        db.add(oi)
    # clear cart
    for i in items:
        db.delete(i)
    db.commit()
    return {"id": order.id, "total_cents": total}
