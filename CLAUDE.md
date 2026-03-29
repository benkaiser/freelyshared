# CLAUDE.md

Read `PROJECT_OVERVIEW.md` for the project's purpose, how it works, current scope, and full data model. Read `ARCHITECTURE.md` for technical decisions and patterns.

## Key points

- This is a **church-based sharing platform** for both **goods and services/skills**, not a general community sharing app
- Everything is **scoped to a single church** — members only see their own church's content
- **No in-app messaging** — the app is a bulletin board; people connect off-platform (phone, at church, etc.)
- Auth is **Devise** (email + password)
- Photos use **ActiveStorage + Azure Blob** (S3-compatible, configured via env vars)
- Push notifications via **Web Push API** (VAPID keys), all opt-in
- The app is a **mobile-first PWA** with bottom tab navigation: Browse Items | Services | Needs | My Listings | Profile
- Churches need **5 members** to activate
- The codebase uses **Rails 8 + Stimulus + Bootstrap** (no React)
- Deployed to **Dokku** with local docker-compose for development
- Use `beans` CLI to manage work items (`.beans/` directory)
- Run `beans prime` at the start of a session to get context on current work items
