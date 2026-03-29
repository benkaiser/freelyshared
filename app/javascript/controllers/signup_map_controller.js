import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    lat: Number,
    lng: Number,
    suburb: String,
    signupCount: Number
  }

  connect() {
    this.initializeMap()
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
    }
  }

  async initializeMap() {
    // Load Leaflet CSS and JS dynamically
    await this.loadLeaflet()

    // Initialize the map
    this.map = L.map(this.element).setView([this.latValue, this.lngValue], 11)

    // Add tile layer
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors'
    }).addTo(this.map)

    // Add center marker
    const centerIcon = L.divIcon({
      className: 'center-marker',
      html: '<div class="center-marker-inner"></div>',
      iconSize: [30, 30],
      iconAnchor: [15, 15]
    })

    L.marker([this.latValue, this.lngValue], { icon: centerIcon })
      .addTo(this.map)
      .bindPopup(`<strong>${this.suburbValue}</strong><br>Your selected location`)

    // Add 50km radius circle
    const circle = L.circle([this.latValue, this.lngValue], {
      color: '#0d6efd',
      fillColor: '#0d6efd',
      fillOpacity: 0.1,
      radius: 50000, // 50km in meters
      weight: 2
    }).addTo(this.map)

    // Add some fake pulsing markers for visual effect
    this.addFakeSignupMarkers()

    // Fit map to show the circle
    this.map.fitBounds(circle.getBounds(), { padding: [20, 20] })
  }

  async loadLeaflet() {
    // Load Leaflet CSS
    if (!document.querySelector('link[href*="leaflet"]')) {
      const css = document.createElement('link')
      css.rel = 'stylesheet'
      css.href = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css'
      css.integrity = 'sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY='
      css.crossOrigin = ''
      document.head.appendChild(css)
    }

    // Load Leaflet JS
    if (!window.L) {
      return new Promise((resolve, reject) => {
        const script = document.createElement('script')
        script.src = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.js'
        script.integrity = 'sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo='
        script.crossOrigin = ''
        script.onload = resolve
        script.onerror = reject
        document.head.appendChild(script)
      })
    }
  }

  addFakeSignupMarkers() {
    const fakeSignups = this.generateFakeSignupLocations()

    // Calculate stagger delay - faster for more signups, max 500ms per marker
    const maxDelay = Math.min(500, Math.max(200, 3000 / Math.max(1, fakeSignups.length)))

    fakeSignups.forEach((location, index) => {
      setTimeout(() => {
        const pulseIcon = L.divIcon({
          className: 'pulse-marker',
          html: '<div class="pulse-marker-inner"></div>',
          iconSize: [20, 20],
          iconAnchor: [10, 10]
        })

        L.marker([location.lat, location.lng], { icon: pulseIcon })
          .addTo(this.map)
          .bindPopup(`<strong>Community member</strong><br>Joined the waitlist`)
      }, index * maxDelay) // Dynamic stagger timing
    })
  }

  generateFakeSignupLocations() {
    const locations = []
    const baseRadius = 0.45 // Roughly 50km in degrees at this latitude

    // Use the actual signup count from the database, but don't show more than that
    const count = Math.max(0, this.signupCountValue)

    // If there are no signups, don't show any markers
    if (count === 0) {
      return locations
    }

    for (let i = 0; i < count; i++) {
      const angle = Math.random() * 2 * Math.PI
      const distance = Math.random() * baseRadius

      const lat = this.latValue + (distance * Math.cos(angle))
      const lng = this.lngValue + (distance * Math.sin(angle))

      locations.push({ lat, lng })
    }

    return locations
  }
}
