# FreelyShared — Project Overview

## Purpose

FreelyShared is a platform for sharing goods between members of a church community. Inspired by the early church described in Acts 4:32 — *"All the believers were one in heart and mind. No one claimed that any of their possessions was their own, but they shared everything they had."* — the platform helps church members lend and borrow items freely from one another.

Unlike a general-purpose sharing platform, FreelyShared is scoped to **church communities**. Trust is built on existing relationships within a congregation, making sharing natural and low-friction.

## How It Works

### Church Registration & Activation

1. A person searches for their church on the landing page
2. If found, they join it by providing their name and email
3. If not found, they can **register** their church:
   - Provide the church name and location (suburb/city autocomplete)
   - Provide their own name and email
   - Optionally provide 5 initial member names + emails to activate immediately
4. A church needs **5 members** to become "active" (ready)
5. Churches with fewer than 5 members appear in search as "gathering members"
6. When a church reaches 5 members, all members receive a notification email

### Multi-Campus Note

Churches with multiple campuses are encouraged to group geographically close campuses together. This maximizes the sharing pool — members are more likely to share with people they can physically meet.

## Current Scope

**Only the landing page and signup flow are built.** The actual item-listing, browsing, and borrowing features are not yet implemented. Current functionality:

- Landing page with church search
- Church registration form (with location autocomplete via Photon/Komoot)
- Join existing church flow
- 5-member activation with "church ready" transactional email
- Thank you page with share/copy-link buttons

## Technical Decisions

| Layer | Choice | Notes |
|-------|--------|-------|
| **Backend** | Ruby on Rails 8 | Convention over configuration, rapid development |
| **Database** | PostgreSQL | Single database, Haversine queries for location search |
| **Frontend JS** | Hotwire (Stimulus + Turbo) | Lightweight, no SPA complexity |
| **CSS** | Bootstrap 5 + SCSS | Responsive, component library with custom theming |
| **JS Bundler** | esbuild | Fast builds |
| **Geocoding** | Photon by Komoot | Free, no API key required |
| **Background Jobs** | Solid Queue (built into Puma) | For sending emails |
| **Deployment** | Kamal (Docker-based) | Simple server deployment |

## Data Model

### Churches
- `name` — church name
- `location_name` — human-readable location (suburb/city)
- `latitude`, `longitude` — for geographic search
- `status` — `pending` (< 5 members) or `ready` (>= 5 members)

### Church Members
- `name`, `email` — member details
- `church_id` — belongs to a church
- `is_registrant` — whether this member registered the church
- `verification_token` — for future email verification

## Values

- **Generosity** — Share freely with your church family (Luke 6:38)
- **Fellowship** — Deepen relationships through sharing (Galatians 6:2)
- **Stewardship** — Be good stewards of what God has given (1 Peter 4:10)
