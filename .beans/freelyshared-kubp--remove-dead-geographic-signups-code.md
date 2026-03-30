---
# freelyshared-kubp
title: Remove dead geographic signups code
status: completed
type: task
priority: low
created_at: 2026-03-30T00:47:14Z
updated_at: 2026-03-30T00:51:47Z
parent: freelyshared-03k5
---

Clean up the orphaned geographic signups feature (replaced by church-based signup in freelyshared-qt2f). Remove:
- app/models/geographic_signup.rb
- app/controllers/signups_controller.rb
- app/views/signups/ (interest.html.erb, thankyou.html.erb)
- app/javascript/controllers/signup_map_controller.js
- planning/features/P2-geographic-signup.md
- Dead navigateToInterest() method in app/javascript/controllers/suburb_autocomplete_controller.js (keep the rest of the file — it's used for church creation)
- Create a migration to drop the geographic_signups table
- Remove signup_map controller registration from app/javascript/controllers/index.js