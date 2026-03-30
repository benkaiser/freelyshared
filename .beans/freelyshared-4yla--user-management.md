---
# freelyshared-4yla
title: User management
status: completed
type: feature
priority: high
created_at: 2026-03-30T00:41:40Z
updated_at: 2026-03-30T01:10:09Z
parent: freelyshared-03k5
---

User management under /superadmin/users:
- Index: list all users across all churches, searchable by email/name. Shows: name, email, church, role (admin/member), status (approved/pending/rejected), superadmin badge
- Show: user detail page with full activity — their listings, borrows, services, needs
- Actions: ban/suspend user (different from delete — sets a 'suspended' flag, prevents login, preserves data), unsuspend, delete user (with confirmation)
- Impersonate: 'Sign in as' button that logs the superadmin in as that user for debugging. Must show a prominent banner 'You are impersonating [name]' with a 'Stop impersonating' button that returns to superadmin.