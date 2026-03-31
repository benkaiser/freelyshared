# FreelyShared

**[freelyshared.org](https://freelyshared.org)**

A church-based sharing platform where members can lend goods, offer skills, and post needs within their congregation. Inspired by Acts 4:32: *"They shared everything they had."*

## What it does

Each church gets its own private community. Members can:

- **List items** to lend (tools, kitchen gear, camping equipment, etc.) with photos and a borrow request flow
- **Offer services** (plumbing, tutoring, car maintenance) with contact details
- **Post needs** ("Help moving Saturday", "Looking for a drop saw") that expire after 30 days
- **Browse a member directory** to see who's sharing what

There's no in-app messaging. The app works as a bulletin board; people connect at church or by phone.

Churches need 5 members to activate. Until then they show up in search as "gathering members."

## Admin features

Church admins can:

- Require approval for new members joining
- Approve or reject pending membership requests
- Manage which members have admin privileges

Admins are designated during church registration, and more can be added later from the admin panel.

## Tech stack

- Rails 8, PostgreSQL, Puma
- Hotwire (Turbo + Stimulus), Bootstrap 5
- Devise for authentication
- ActiveStorage with Azure Blob for photo uploads
- Web Push API (VAPID) for notifications
- Solid Queue for background jobs
- PWA with mobile-first bottom tab navigation
- Deployed via Kamal/Dokku

## Development setup

Prerequisites: Docker and Docker Compose.

```bash
# Clone and start
git clone https://github.com/benkaiser/freelyshared.git
cd freelyshared
docker compose up --build

# In another terminal, set up the database
docker compose exec web bin/rails db:create db:migrate db:seed
```

The app runs at `http://localhost:8888`.

Seed data creates a test church ("Grace Community Church") with 5 members. Log in with:

- **Admin:** john@example.com / password123
- **Regular member:** sarah@example.com / password123

### Environment variables

For photo uploads and push notifications, set these in a `.env` file:

```
AZURE_STORAGE_ACCOUNT_NAME=...
AZURE_STORAGE_ACCESS_KEY=...
AZURE_STORAGE_CONTAINER=...
VAPID_PUBLIC_KEY=...
VAPID_PRIVATE_KEY=...
```

The app works without these, you just won't have photo uploads or push notifications.

## Running tests

```bash
docker compose exec -e DB_HOST=db web bin/rails test
```

## Project structure

See `PROJECT_OVERVIEW.md` for the full data model and feature spec. See `ARCHITECTURE.md` for technical decisions and patterns.
