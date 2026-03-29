# CLAUDE.md

Read `PROJECT_OVERVIEW.md` for the project's purpose, how it works, and current scope. Read `ARCHITECTURE.md` for technical decisions and patterns.

## Key points

- This is a **church-based sharing platform**, not a general community sharing app
- Only the **landing page + signup flow** is built — no item listing/borrowing yet
- Churches need **5 members** to activate
- The codebase uses **Rails 8 + Stimulus + Bootstrap** (no React)
- Use `beans` CLI to manage work items (`.beans/` directory)
- Run `beans prime` at the start of a session to get context on current work items
