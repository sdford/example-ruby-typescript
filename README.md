# Homescan

Homescan turns a phone scan of a house into a measured 3D project that contractors can quote from.

- `backend/`: Rails 8.1 API (Postgres, JWT auth, org-scoped projects with viewer/editor/admin roles)
- `frontend/`: React 18 + TypeScript + Vite

## Running locally

```sh
# backend
cd backend
bundle install
bin/rails db:setup
bin/rails server

# frontend
cd frontend
npm ci
npm run dev
```

The frontend expects the API at `VITE_API_URL` (default `http://localhost:3000`).

## Conventions

- Every query for org data goes through `current_org` so records stay tenant-scoped.
- Role checks use `require_role!` in controllers; the UI hides actions but the API is the source of truth.
- Responses are built with serializers in `app/serializers`, never `as_json` on models.
- `brakeman` and `npm audit` run in CI. Do not add entries to `config/brakeman.ignore` without a security review.
