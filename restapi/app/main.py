from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from uuid import uuid4

app = FastAPI(title="Ecosystem Model API", version="1.0.0")

class Ecosystem(BaseModel):
    id: str
    name: str
    description: Optional[str] = None

class Patch(BaseModel):
    id: str
    ecosystemId: str
    name: str
    details: Optional[str] = None

ecosystems = []
patches = []

@app.get("/")
def read_root():
    return {"Ecosystem Model"}

@app.get("/ecosystems", response_model=List[Ecosystem])
def get_ecosystems():
    return ecosystems

@app.post("/ecosystems", response_model=Ecosystem, status_code=201)
def create_ecosystem(ecosystem: Ecosystem):
    ecosystems.append(ecosystem)
    return ecosystem

@app.get("/ecosystems/{id}", response_model=Ecosystem)
def get_ecosystem(id: str):
    for eco in ecosystems:
        if eco.id == id:
            return eco
    raise HTTPException(status_code=404, detail="Ecosystem not found")

@app.get("/patches", response_model=List[Patch])
def get_patches():
    return patches

@app.post("/patches", response_model=Patch, status_code=201)
def create_patch(patch: Patch):
    patches.append(patch)
    return patch

@app.get("/patches/{id}", response_model=Patch)
def get_patch(id: str):
    for p in patches:
        if p.id == id:
            return p
    raise HTTPException(status_code=404, detail="Patch not found")
from typing import Union
from fastapi import FastAPI
