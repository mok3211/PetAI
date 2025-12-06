from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pathlib import Path
from .core.config import settings
from .api.v1.api import api_router
from .db.session import engine
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from .models.base import Base

app = FastAPI(title=settings.PROJECT_NAME)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[],
    allow_origin_regex=".*",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
def health():
    return {"status": "ok"}

app.include_router(api_router, prefix=settings.API_V1_STR)

@app.on_event("startup")
def on_startup():
    try:
        Base.metadata.create_all(bind=engine)
    except Exception:
        from .db import session as db_session
        fallback = create_engine("sqlite:///./petai.db", connect_args={"check_same_thread": False})
        db_session.engine = fallback
        db_session.SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=fallback)
        Base.metadata.create_all(bind=fallback)
    uploads_dir = Path("backend/uploads")
    uploads_dir.mkdir(parents=True, exist_ok=True)
    app.mount("/uploads", StaticFiles(directory=str(uploads_dir)), name="uploads")
    try:
        with engine.connect() as conn:
            conn.exec_driver_sql("ALTER TABLE memories ADD COLUMN is_public BOOLEAN DEFAULT 0")
            conn.exec_driver_sql("ALTER TABLE users ADD COLUMN is_admin BOOLEAN DEFAULT 0")
            conn.exec_driver_sql("ALTER TABLE users ADD COLUMN provider VARCHAR")
            conn.exec_driver_sql("ALTER TABLE users ADD COLUMN provider_id VARCHAR")
    except Exception:
        pass
