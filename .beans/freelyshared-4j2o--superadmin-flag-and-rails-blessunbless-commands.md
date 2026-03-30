---
# freelyshared-4j2o
title: Superadmin flag and Rails bless/unbless commands
status: todo
type: task
priority: critical
created_at: 2026-03-30T00:41:00Z
updated_at: 2026-03-30T00:41:00Z
parent: freelyshared-03k5
---

Add a boolean 'superadmin' column to church_members table (default: false). Create two Rails tasks:
- bin/rails superadmin:grant[email] — sets superadmin=true for the given user
- bin/rails superadmin:revoke[email] — sets superadmin=false

The flag is independent of the per-church 'admin' flag. Superadmin grants access to /superadmin routes. Add a 'superadmin?' helper method to ChurchMember model.