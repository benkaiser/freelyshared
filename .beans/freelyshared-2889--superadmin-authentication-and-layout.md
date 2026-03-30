---
# freelyshared-2889
title: Superadmin authentication and layout
status: todo
type: task
priority: critical
created_at: 2026-03-30T00:41:40Z
updated_at: 2026-03-30T00:41:40Z
parent: freelyshared-03k5
---

Create a SuperadminController base class that:
- Requires authentication (Devise)
- Checks current_member.superadmin? before every action, returns 404 if not (404 not 403 to hide existence)
- Has its own layout with a sidebar nav for the superadmin sections
- Mounts all routes under /superadmin namespace
- Includes a top bar showing 'Superadmin: [name]' and a link back to the main app