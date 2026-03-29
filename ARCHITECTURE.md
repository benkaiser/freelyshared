# Architecture Decisions

## Technology Stack

- **Backend:** Ruby on Rails 8
- **Database:** PostgreSQL (single database)
- **Auth:** Devise (email + password)
- **Frontend:** Hotwire (Stimulus + Turbo) — no React/SPA
- **CSS:** Bootstrap 5 + SCSS (mobile-first)
- **JS Bundler:** esbuild
- **File Storage:** ActiveStorage + Azure Blob Storage (S3-compatible, env vars)
- **Geocoding:** Photon by Komoot (free, no API key)
- **Push Notifications:** Web Push API with VAPID keys
- **Background Jobs:** Solid Queue (runs inside Puma)
- **Deployment:** Dokku (production), Docker Compose (development)

## Development Setup

- Docker Compose with hot reloading
- `Procfile.dev` runs: Rails server + esbuild watcher + SCSS watcher
- Source code mounted as volumes, no rebuilds for code changes
- PostgreSQL data persisted across restarts

## Key Patterns

- **Church scoping:** All authenticated queries scoped to `current_user.church` — members never see other churches' data
- **No in-app messaging:** The app is a bulletin board. Contact happens off-platform (phone, at church, other channels)
- **Church search:** Server-side JSON endpoint (`/churches/search`) queried by Stimulus controller with debounced input
- **Location autocomplete:** Photon/Komoot API for free geocoding, used on church registration form
- **5-member activation:** `Church#check_ready!` called after each member creation, transitions status and sends emails
- **Borrow flow:** Request → dual confirmation (owner + borrower) → item marked unavailable → manual return confirmation
- **Needs expiry:** Needs auto-expire after 30 days via scope/query (no background job needed — just filter on `expires_at`)
- **Photo uploads:** ActiveStorage with Azure Blob Storage backend, configured via env vars (`AZURE_STORAGE_ACCOUNT_NAME`, `AZURE_STORAGE_ACCESS_KEY`, `AZURE_STORAGE_CONTAINER`)
- **Push notifications:** VAPID keys, service worker registration, per-user opt-in toggles stored in DB
- **PWA:** Manifest + service worker for installable web app, offline support, push handling
- **Navigation:** Mobile-first bottom tabs (Browse Items, Services, Needs, My Listings, Profile), responsive to sidebar/top nav on desktop
- **Transactional emails:** `ChurchReadyMailer` and borrow notification emails via Solid Queue
