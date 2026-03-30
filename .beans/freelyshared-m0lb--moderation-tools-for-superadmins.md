---
# freelyshared-m0lb
title: Moderation tools for superadmins
status: todo
type: feature
priority: high
created_at: 2026-03-30T00:41:40Z
updated_at: 2026-03-30T00:41:40Z
parent: freelyshared-03k5
---

Superadmin moderation capabilities:
- From any church detail or user detail page, ability to remove/delete: items, services listings, needs, borrow requests
- Moderation audit log: a new 'moderation_actions' table that records who did what and when (actor, action_type, target_type, target_id, reason, created_at)
- Audit log viewable under /superadmin/moderation_log with filtering by church, actor, action type, date range
- All moderation actions (by both superadmins and church admins) are logged