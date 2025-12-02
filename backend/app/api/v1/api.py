from fastapi import APIRouter
from .endpoints import auth, users, pets, memories, uploads, products, cart, orders, comments, likes, ai

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(pets.router, prefix="/pets", tags=["pets"])
api_router.include_router(memories.router, prefix="/memories", tags=["memories"])
api_router.include_router(uploads.router, prefix="/uploads", tags=["uploads"])
api_router.include_router(products.router, prefix="/products", tags=["products"])
api_router.include_router(cart.router, prefix="/cart", tags=["cart"])
api_router.include_router(orders.router, prefix="/orders", tags=["orders"])
api_router.include_router(comments.router, prefix="/comments", tags=["comments"])
api_router.include_router(likes.router, prefix="/likes", tags=["likes"])
api_router.include_router(ai.router, prefix="/ai", tags=["ai"])
