import os
from typing import Optional
from dotenv import load_dotenv
from fastapi import FastAPI, Depends, Header, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from supabase import create_client, Client
import jwt  # PyJWT

load_dotenv()

SUPABASE_URL = os.environ["SUPABASE_URL"]
SERVICE_ROLE = os.environ["SUPABASE_SERVICE_ROLE_KEY"]
JWT_SECRET = os.environ.get("SUPABASE_JWT_SECRET")          # <- ÖNEMLİ
JWT_ALG = os.environ.get("JWT_ALG", "HS256")

print(f"[BOOT] JWT_SECRET set? {'YES' if JWT_SECRET else 'NO'}")
print(f"[BOOT] JWT_ALG = {JWT_ALG}")

supabase: Client = create_client(SUPABASE_URL, SERVICE_ROLE)
app = FastAPI(title="Connectinno Notes API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], allow_credentials=True,
    allow_methods=["*"], allow_headers=["*"]
)

class NoteIn(BaseModel):
    title: str = Field(min_length=1)
    content: str = ""
    pinned: bool = False

def get_user_id(authorization: Optional[str] = Header(None)) -> str:
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing bearer token")
    token = authorization.split(" ", 1)[1]

    try:
        header = jwt.get_unverified_header(token)
        alg = header.get("alg", JWT_ALG)
    except Exception:
        alg = JWT_ALG

    if not JWT_SECRET:
        # .env yüklenmemişse veya değer yoksa
        raise HTTPException(status_code=500, detail="Server JWT secret not configured")

    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[alg], options={"verify_aud": False})
        sub = payload.get("sub")
        if not sub:
            raise ValueError("No sub in token")
        return sub
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Invalid token: {e}")

@app.get("/health")
def health():
    return {"ok": True}

@app.get("/me")
def me(user_id: str = Depends(get_user_id)):
    return {"user_id": user_id}

@app.get("/notes")
def list_notes(user_id: str = Depends(get_user_id), q: Optional[str] = None):
    query = supabase.table("notes").select("*").eq("user_id", user_id)
    if q:
        query = query.or_(f"title.ilike.%{q}%,content.ilike.%{q}%")
    resp = query.order("pinned", desc=True).order("updated_at", desc=True).execute()
    return resp.data

@app.post("/notes")
def create_note(payload: NoteIn, user_id: str = Depends(get_user_id)):
    data = {"user_id": user_id, **payload.dict()}
    resp = supabase.table("notes").insert(data).execute()
    return (resp.data or [{}])[0]

@app.put("/notes/{note_id}")
def update_note(note_id: str, payload: NoteIn, user_id: str = Depends(get_user_id)):
    resp = (
        supabase.table("notes")
        .update(payload.dict())
        .eq("id", note_id).eq("user_id", user_id)
        .execute()
    )
    if not resp.data:
        raise HTTPException(status_code=404, detail="Note not found or not yours")
    return resp.data[0]

@app.delete("/notes/{note_id}")
def delete_note(note_id: str, user_id: str = Depends(get_user_id)):
    resp = supabase.table("notes").delete().eq("id", note_id).eq("user_id", user_id).execute()
    if not resp.data:
        raise HTTPException(status_code=404, detail="Note not found or not yours")
    return {"ok": True}
