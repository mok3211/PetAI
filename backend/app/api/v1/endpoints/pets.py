from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ....deps import get_db, get_current_user
from ....models.pet import Pet
from ....schemas.pet import PetCreate, PetRead, PetUpdate

router = APIRouter()

@router.get("/", response_model=List[PetRead])
def list_pets(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return db.query(Pet).filter(Pet.user_id == current_user.id).all()

@router.post("/", response_model=PetRead, status_code=status.HTTP_201_CREATED)
def create_pet(payload: PetCreate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    pet = Pet(user_id=current_user.id, **payload.model_dump())
    db.add(pet)
    db.commit()
    db.refresh(pet)
    return pet

@router.get("/{pet_id}", response_model=PetRead)
def get_pet(pet_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    pet = db.query(Pet).filter(Pet.id == pet_id, Pet.user_id == current_user.id).first()
    if not pet:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Pet not found")
    return pet

@router.put("/{pet_id}", response_model=PetRead)
def update_pet(pet_id: int, payload: PetUpdate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    pet = db.query(Pet).filter(Pet.id == pet_id, Pet.user_id == current_user.id).first()
    if not pet:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Pet not found")
    for k, v in payload.model_dump(exclude_unset=True).items():
        setattr(pet, k, v)
    db.add(pet)
    db.commit()
    db.refresh(pet)
    return pet

@router.delete("/{pet_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_pet(pet_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    pet = db.query(Pet).filter(Pet.id == pet_id, Pet.user_id == current_user.id).first()
    if not pet:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Pet not found")
    db.delete(pet)
    db.commit()
    return None
