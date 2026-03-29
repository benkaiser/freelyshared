# P1 - Landing Page Creation

## Overview
Create an initial landing page that introduces the AllShared community sharing platform concept, showcasing the values of generosity, sustainability, and community connection.

## User Story
As a visitor to the site, I want to understand what AllShared is about and how I can participate in community sharing, so that I can decide if this platform aligns with my values and needs.

## Design Requirements

### Hero Section
- **Headline**: Clear, compelling tagline that captures the sharing economy concept
- **Subheadline**: Brief explanation of peer-to-peer borrowing within communities
- **Suburb Input**: Prominent search input field (inactive for now) with placeholder text like "Enter your suburb to get started"
- **Visual**: Hero image or illustration representing community sharing

### Core Concept Section
- **What is AllShared**: Explain the platform as a way to share items within your community
- **How it Works**: Simple 3-step process (List items → Browse nearby → Borrow for free)
- **Community Focus**: Emphasize local, trusted neighborhood connections

### Values Highlighting
- **Generosity**: Highlight the culture of giving and sharing without profit motive
- **Optional Donations**: Explain how borrowers can thank lenders through optional charity donations
- **Sustainability**: Emphasize reducing consumption by reusing existing items
- **Trust & Safety**: Mention community-driven reputation and safe meeting practices

### Key Features Preview
- Peer-to-peer borrowing
- Community-based trust system
- Pseudonymous profiles for privacy
- Optional collateral system for valuable items
- Charity donation integration

## Technical Implementation

### Pages to Create
- Root route (`/`) - Landing page
- Update `config/routes.rb` to set root route
- Create `app/controllers/pages_controller.rb` with `home` action
- Create `app/views/pages/home.html.erb` template

### Styling Requirements
- Bootstrap-based responsive design
- Mobile-first approach
- Clean, modern aesthetic that conveys trust and community
- Consistent color scheme that reflects generosity and sustainability values

### Components Structure
```erb
<!-- Hero Section -->
<section class="hero">
  <!-- Suburb input field (inactive) -->
  <!-- Main headline and value proposition -->
</section>

<!-- How It Works Section -->
<section class="how-it-works">
  <!-- 3-step process explanation -->
</section>

<!-- Values Section -->
<section class="values">
  <!-- Generosity, sustainability, community cards -->
</section>

<!-- Features Preview Section -->
<section class="features">
  <!-- Key platform features -->
</section>

<!-- Call to Action Section -->
<section class="cta">
  <!-- Encouragement to join the community -->
</section>
```

### Content Guidelines
- **Tone**: Warm, welcoming, community-focused
- **Language**: Simple, accessible, avoiding jargon
- **Messaging**: Focus on community benefit rather than personal gain
- **Inclusivity**: Welcome people of all backgrounds and beliefs

## Acceptance Criteria
- [ ] Landing page loads at root URL (`/`)
- [ ] Responsive design works on mobile, tablet, and desktop
- [ ] Suburb input field is present but inactive
- [ ] All key concepts are clearly explained
- [ ] Bootstrap styling is consistent and professional
- [ ] Page conveys trust, generosity, and community values
- [ ] Load time is under 3 seconds
- [ ] No console errors or broken links

## Future Integration Points
- Suburb input will become interactive in next phase
- User registration/login flows will be added
- Item browsing and listing features will be integrated
- Community trust features will be expanded

## Inspiration Reference
Based on Acts 4:32 principle of communal sharing, but presented in a modern, inclusive way that welcomes everyone regardless of background.
