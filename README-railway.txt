# Platforma Anunțuri - Backend (Railway)

## Cum pornești pe Railway
1) Adaugă un serviciu PostgreSQL în proiect (ai făcut deja).
2) Creează un serviciu din GitHub Repo cu acest cod.
3) În Variables, setează:
   - DATABASE_URL = ${{ Postgres.DATABASE_URL }}
   - JWT_SECRET = (orice șir lung, random)
   - PORT = 5000
4) Deploy. La pornire se rulează automat `schema.sql` (idempotent).

## Test API
GET /api/health -> {"ok":true}
GET /api/categories
GET /api/counties
GET /api/announcements
