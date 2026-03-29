# Architecture Decisions

## Technology Stack

- **Backend:** Ruby on Rails 8
- **Database:** PostgreSQL (single database)
- **Frontend:** Hotwire (Stimulus + Turbo) — no React/SPA
- **CSS:** Bootstrap 5 + SCSS
- **JS Bundler:** esbuild
- **Geocoding:** Photon by Komoot (free, no API key)
- **Background Jobs:** Solid Queue (runs inside Puma)
- **Deployment:** Kamal (Docker-based)

## Development Setup

- Docker Compose with hot reloading
- `Procfile.dev` runs: Rails server + esbuild watcher + SCSS watcher
- Source code mounted as volumes, no rebuilds for code changes
- PostgreSQL data persisted across restarts

## Key Patterns

- **Church search:** Server-side JSON endpoint (`/churches/search`) queried by Stimulus controller with debounced input
- **Location autocomplete:** Photon/Komoot API for free geocoding, used on church registration form
- **5-member activation:** `Church#check_ready!` called after each member creation, transitions status and sends emails
- **Transactional emails:** `ChurchReadyMailer` sends individual emails to all members via Solid Queue
