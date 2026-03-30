---
# freelyshared-9qwz
title: In-product telemetry tracking
status: completed
type: feature
priority: high
created_at: 2026-03-30T00:41:40Z
updated_at: 2026-03-30T01:10:09Z
parent: freelyshared-03k5
---

Add lightweight in-product telemetry using a new 'telemetry_events' table:
- Track: logins (success/failure), password resets (requested/completed), email sends (type + recipient church), push notification sends (type + recipient church)
- Track page views: home page views (total, by day), per-church page browsing (items index, services index, needs index, item show, service show, need show)
- All events stored with: event_type, church_id (nullable), church_member_id (nullable), metadata (jsonb), created_at
- NO external analytics services — all data stays in our DB
- Add instrumentation hooks in: Devise (login/password reset callbacks), mailers (after_deliver), NotificationService, ApplicationController (page view tracking via after_action)
- Telemetry dashboard under /superadmin/telemetry showing: daily active users, logins over time, page views by section, per-church engagement breakdown, email/notification volume charts
- Use simple server-rendered charts (CSS bar charts or a lightweight JS charting library like Chart.js)