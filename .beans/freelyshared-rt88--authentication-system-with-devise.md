---
# freelyshared-rt88
title: Authentication system with Devise
status: todo
type: feature
created_at: 2026-03-29T12:46:00Z
updated_at: 2026-03-29T12:46:00Z
---

Add Devise gem for email+password authentication. Users must be associated with a church (ChurchMember record). After login, scope everything to the user's church. Include sign up, sign in, sign out, password reset. New users should only be able to sign up by joining an existing church (link from church page or invite flow).