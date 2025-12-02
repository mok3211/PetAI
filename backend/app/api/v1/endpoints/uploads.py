import os
from uuid import uuid4
from fastapi import APIRouter, File, UploadFile, Request
from pathlib import Path

router = APIRouter()

@router.post("/")
async def upload(file: UploadFile = File(...), request: Request):
    ext = os.path.splitext(file.filename)[1]
    name = f"{uuid4().hex}{ext}"
    path = Path("backend/uploads") / name
    content = await file.read()
    path.write_bytes(content)
    base = str(request.base_url).rstrip("/")
    url = f"{base}/uploads/{name}"
    return {"url": url}
