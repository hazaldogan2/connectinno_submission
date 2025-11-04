# Connectinno Notes API (FastAPI + Supabase)

Provides protected CRUD endpoints for notes. Auth uses Supabase JWT.

## Run
```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # gerçek değerleri doldur
uvicorn main:app --reload --port 8000
