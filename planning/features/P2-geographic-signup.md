# P2 - Geographic Signup Flow

## Overview
Implement a geographic-based signup system that allows users to indicate interest in AllShared by entering their suburb, viewing local signup activity on a map, and registering for updates when the service becomes available in their area.

## User Story
As a visitor interested in AllShared, I want to enter my suburb to see how many people in my area are also interested, so that I can gauge local community interest and sign up to be notified when the service launches in my area.

## User Flow
1. **Homepage**: User enters suburb in the prominent input field
2. **Interest Page**: User sees signup count, map with range circle, and animated (fake) signup indicators
3. **Registration**: User enters name and email to join the waitlist
4. **Share**: User gets a shareable link to invite others from their area

## Technical Implementation

### Database Schema Changes

#### New Table: `geographic_signups`
```ruby
create_table :geographic_signups do |t|
  t.string :name, null: false
  t.string :email, null: false, index: true
  t.string :suburb_name, null: false
  t.decimal :latitude, precision: 10, scale: 6, null: false
  t.decimal :longitude, precision: 10, scale: 6, null: false
  t.string :country_code, limit: 2, default: 'AU'
  t.string :state_code, limit: 3
  t.string :postcode, limit: 10
  t.boolean :email_verified, default: false
  t.string :verification_token, index: true
  t.datetime :verified_at
  t.timestamps
end

add_index :geographic_signups, [:latitude, longitude]
add_index :geographic_signups, [:suburb_name, :country_code]
add_index :geographic_signups, :email, unique: true
```

#### Model Validations & Methods
```ruby
class GeographicSignup < ApplicationRecord
  validates :name, presence: true, length: { minimum: 1, maximum: 200 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :suburb_name, presence: true, length: { minimum: 1, maximum: 200 }
  validates :latitude, :longitude, presence: true, numericality: true

  scope :verified, -> { where(email_verified: true) }
  scope :within_radius, ->(lat, lng, radius_km = 50) {
    # Haversine formula for geographic distance
    where(
      "6371 * acos(cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude))) <= ?",
      lat, lng, lat, radius_km
    )
  }

  def nearby_signups(radius_km = 50)
    self.class.verified.within_radius(latitude, longitude, radius_km).where.not(id: id)
  end
end
```

### API Integration - Suburb Autocomplete

#### Geocoding Service: Photon by Komoot
- **Service**: Photon API (photon.komoot.io) - Free, open source, no API key required
- **Features**: OpenStreetMap data, GeoJSON responses, multi-language support
- **Integration**: Stimulus controller with debounced search, client-side caching

### Routes & URL Structure

#### New Routes Required
- `GET /interest?suburb=sydney&lat=-33.8688&lng=151.2093` - Interest/map page
- `POST /signups` - Create signup with validation
- `GET /thankyou/` - Post-signup sharing page

#### Controllers Required
- **SignupsController**: Handle interest page, signup creation, thank you page

### Frontend Components

#### Pages Required
1. **Homepage Update**: Replace static suburb input with autocomplete using API from Photon
2. **Interest Page**: Display signup count, OpenStreetMap with 50km radius, signup form
3. **Thank You Page**: Success message with native share API integration

#### Key Features
- **Autocomplete**: Debounced Photon API search with dropdown
- **Interactive Map**: Leaflet.js with pulsing indicators within the outer circle for radius (just fake dots for visual effect)
- **Share Functionality**: Native browser share API with clipboard fallback

### JavaScript & Styling

#### Stimulus Controllers Required
- **suburb_autocomplete_controller**: Photon API integration with debouncing
- **signup_map_controller**: Leaflet.js map with range circle and pulsing indicators

#### CSS Additions Required
- Autocomplete dropdown styling
- Map animation keyframes for pulsing signup indicators


