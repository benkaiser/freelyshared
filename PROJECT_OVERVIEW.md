# FreelyShared — Project Overview

## Purpose

FreelyShared is a platform for sharing goods and services between members of a church community. Inspired by the early church described in Acts 4:32 — *"All the believers were one in heart and mind. No one claimed that any of their possessions was their own, but they shared everything they had."* — the platform helps church members lend items, borrow what they need, and offer their skills and time to serve one another.

Unlike a general-purpose sharing platform, FreelyShared is scoped to **church communities**. Trust is built on existing relationships within a congregation, making sharing natural and low-friction. Members can share physical goods (tools, books, equipment) as well as offer services and skills (plumbing, tutoring, car repairs, meal prep, moving help, etc.).

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

### Authentication

Email + password authentication via Devise. Users are associated with a church through their ChurchMember record. All authenticated views are scoped to the user's own church.

### Item Listings & Borrowing

- Members list items to lend with a title, description, optional photo, and category
- Categories: Tools, Kitchen & Home, Garden & Outdoor, Books & Media, Sports & Recreation, Kids & Family, Electronics, Transport, Other
- Items have manual availability (available/unavailable), toggled by the owner
- **Borrow flow**: a member requests to borrow with a desired time window and their phone number. The owner gets a push notification + email. Both parties confirm the borrow in-app (dual confirmation). Once confirmed, the item is marked unavailable for that period. The owner can override availability at any time. Items do not auto-return — someone must confirm the return. Multiple people can request the same item simultaneously
- All communication about the borrow happens off-platform (phone, at church, etc.)

### Services Directory

Persistent listings of skills and professional services members offer to their church (e.g. plumbing, accounting, face painting, tutoring). Unlike Needs, these are standing offers — always visible so people can proactively reach out to someone with the right skills, even if they don't feel comfortable posting a broad request.

### Needs / Requests Board

Members post needs for help or items (e.g. "need help moving Saturday", "looking for a drop saw", "need DIY assistance with a deck"). Needs include a title, description, and contact info (phone or email recommended). Needs auto-expire after 30 days. The poster manages their own status (open / fulfilled).

### Contact & Communication

No in-app messaging. The app is a **bulletin board** — members discover each other through listings, needs, and services, then connect off-platform. Members list their name and optionally their phone number. Email can be shown but is hidden by default. Members can also simply connect at church.

### User Profiles

- Name, optional phone number, optional email visibility
- Profile photo via Gravatar
- Toggle to hide from the member directory
- Profile settings page to manage preferences

### Member Directory

A simple, subtle list of church members (name + Gravatar). Only shows members who haven't opted to be hidden. Accessible from navigation but not prominently featured.

### Notifications

Web Push (VAPID keys, service worker). All opt-in, off by default:
- New needs posted in your church
- New service listings in your church
- New item postings in your church
- Transactional: someone requests to borrow your item

Toggles available both on a central settings page and contextually on relevant pages.

### Multi-Campus Note

Churches with multiple campuses are encouraged to group geographically close campuses together. This maximizes the sharing pool — members are more likely to share with and serve people they can physically meet.

## Current Scope

**Only the landing page and signup flow are built.** See `beans list` for the full backlog of features to be implemented. Current functionality:

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
| **Auth** | Devise | Email + password authentication |
| **Frontend JS** | Hotwire (Stimulus + Turbo) | Lightweight, no SPA complexity |
| **CSS** | Bootstrap 5 + SCSS | Mobile-first responsive, component library |
| **JS Bundler** | esbuild | Fast builds |
| **File Storage** | ActiveStorage + Azure Blob (S3-compatible) | Photo uploads for item listings |
| **Geocoding** | Photon by Komoot | Free, no API key required |
| **Push Notifications** | Web Push API (VAPID) | PWA with service worker |
| **Background Jobs** | Solid Queue (built into Puma) | For emails and push notifications |
| **Deployment** | Dokku | Rails app with local docker-compose for dev |

## Data Model

### Churches
- `name` — church name
- `location_name` — human-readable location (suburb/city)
- `latitude`, `longitude` — for geographic search
- `status` — `pending` (< 5 members) or `ready` (>= 5 members)

### Church Members / Users
- `name`, `email`, `phone` (optional) — member details
- `church_id` — belongs to a church
- `is_registrant` — whether this member registered the church
- `show_email`, `show_in_directory` — visibility preferences
- Devise fields for authentication

### Item Listings
- `title`, `description`, `category` — item details
- Photo via ActiveStorage
- `available` — boolean, manually toggled
- `user_id`, `church_id` — ownership and scoping

### Borrow Requests
- `item_id`, `requester_id` — what and who
- `start_date`, `end_date` — desired time window
- `phone` — requester's contact
- `owner_confirmed`, `borrower_confirmed` — dual confirmation
- `status` — pending / confirmed / returned / cancelled

### Services
- `title`, `description` — skill/service offered
- `user_id`, `church_id` — ownership and scoping

### Needs
- `title`, `description`, `contact_info` — what's needed and how to reach the poster
- `status` — open / fulfilled
- `expires_at` — auto-set to 30 days from creation
- `user_id`, `church_id` — ownership and scoping

### Push Subscriptions
- `user_id`, `endpoint`, `keys` — Web Push subscription data
- Notification preferences (needs, services, items, transactional)

## Values

- **Generosity** — Share goods freely and offer your skills to serve your church family (Luke 6:38)
- **Fellowship** — Deepen relationships through sharing and serving one another (Galatians 6:2)
- **Stewardship** — Be good stewards of what God has given — possessions, skills, and time (1 Peter 4:10)
