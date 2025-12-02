from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ....deps import get_db, get_current_user
from ....models.memory import Memory
from ....schemas.memory import MemoryCreate, MemoryRead, MemoryUpdate

router = APIRouter()

@router.get("/pets/{pet_id}", response_model=List[MemoryRead])
def list_memories(pet_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return (
        db.query(Memory)
        .filter(Memory.user_id == current_user.id, Memory.pet_id == pet_id)
        .order_by(Memory.id.desc())
        .all()
    )

@router.post("/", response_model=MemoryRead, status_code=status.HTTP_201_CREATED)
def create_memory(payload: MemoryCreate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    mem = Memory(user_id=current_user.id, **payload.model_dump())
    db.add(mem)
    db.commit()
    db.refresh(mem)
    return mem

@router.get("/{memory_id}", response_model=MemoryRead)
def get_memory(memory_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    mem = db.query(Memory).filter(Memory.id == memory_id, Memory.user_id == current_user.id).first()
    if not mem:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Memory not found")
    return mem

@router.put("/{memory_id}", response_model=MemoryRead)
def update_memory(memory_id: int, payload: MemoryUpdate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    mem = db.query(Memory).filter(Memory.id == memory_id, Memory.user_id == current_user.id).first()
    if not mem:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Memory not found")
    for k, v in payload.model_dump(exclude_unset=True).items():
        setattr(mem, k, v)
    db.add(mem)
    db.commit()
    db.refresh(mem)
    return mem

@router.get("/public", response_model=List[MemoryRead])
def list_public_memories(db: Session = Depends(get_db)):
    return db.query(Memory).filter(Memory.is_public == True).order_by(Memory.id.desc()).all()

@router.delete("/{memory_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_memory(memory_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    mem = db.query(Memory).filter(Memory.id == memory_id, Memory.user_id == current_user.id).first()
    if not mem:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Memory not found")
    db.delete(mem)
    db.commit()
    return None
