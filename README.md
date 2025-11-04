# Connectinno Notes (Flutter + Supabase + FastAPI)

Cross-platform notes app with auth, CRUD, pin, undo, search, and offline cache.

## ✨ Features
- Supabase Auth (Sign up / Login / Logout)
- Notes CRUD (create, update, delete, list)
- Pin / Undo delete
- Search in title & content
- Offline-first (Hive cache) + offline banner
- REST backend (FastAPI + Supabase)

## 📦 Requirements
- Flutter 3.x
- Android Studio / Xcode
- Supabase project (URL + anon key)
- Local FastAPI backend running at `8000`

## 🔧 Setup
```bash
cp .env.example .env   # kendi değerlerini yaz
flutter pub get
flutter run
/auth` (AuthGate/AuthPage)
