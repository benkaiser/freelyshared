---
# freelyshared-g2y0
title: Church admin moderation capabilities
status: completed
type: feature
priority: normal
created_at: 2026-03-30T00:41:40Z
updated_at: 2026-03-30T01:10:09Z
parent: freelyshared-03k5
---

Extend existing church admin role so church admins can moderate content within their own church:
- Add 'Remove' action on each item, service listing, and need on their respective index/show pages (visible only to church admins)
- Removal soft-deletes or destroys the record
- All removals are logged to the moderation_actions audit table
- Notify the content owner via email when their content is removed by an admin