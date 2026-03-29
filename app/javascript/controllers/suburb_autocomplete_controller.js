import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown", "hiddenLat", "hiddenLng"]
  static values = { debounceDelay: { type: Number, default: 300 } }

  connect() {
    this.timeout = null
    this.cache = new Map()
    this.selectedIndex = -1
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  search() {
    const query = this.inputTarget.value.trim()

    if (query.length < 2) {
      this.hideDropdown()
      return
    }

    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    this.timeout = setTimeout(() => {
      this.performSearch(query)
    }, this.debounceDelayValue)
  }

  async performSearch(query) {
    // Check cache first
    if (this.cache.has(query)) {
      this.displayResults(this.cache.get(query))
      return
    }

    try {
      const response = await fetch(`https://photon.komoot.io/api/?q=${encodeURIComponent(query)}&limit=8&osm_tag=place:suburb&osm_tag=place:town&osm_tag=place:city`)
      const data = await response.json()

      const results = data.features.map(feature => ({
        name: this.formatName(feature),
        lat: feature.geometry.coordinates[1],
        lng: feature.geometry.coordinates[0],
        properties: feature.properties
      }))

      this.cache.set(query, results)
      this.displayResults(results)
    } catch (error) {
      console.error('Geocoding error:', error)
      this.hideDropdown()
    }
  }

  formatName(feature) {
    const props = feature.properties
    let name = props.name || ''

    if (props.state) {
      name += `, ${props.state}`
    }
    if (props.country) {
      name += `, ${props.country}`
    }

    return name
  }

  displayResults(results) {
    if (results.length === 0) {
      this.hideDropdown()
      return
    }

    this.dropdownTarget.innerHTML = ''
    this.selectedIndex = -1

    results.forEach((result, index) => {
      const item = document.createElement('div')
      item.className = 'dropdown-item'
      item.textContent = result.name
      item.dataset.lat = result.lat
      item.dataset.lng = result.lng
      item.dataset.index = index

      item.addEventListener('click', () => this.selectResult(result))
      item.addEventListener('mouseenter', () => {
        this.clearSelection()
        item.classList.add('active')
        this.selectedIndex = index
      })

      this.dropdownTarget.appendChild(item)
    })

    this.showDropdown()
  }

  selectResult(result) {
    this.inputTarget.value = result.name
    this.hiddenLatTarget.value = result.lat
    this.hiddenLngTarget.value = result.lng
    this.hideDropdown()

    // Trigger the form submission or navigation
    const event = new CustomEvent('suburb:selected', {
      detail: { suburb: result.name, lat: result.lat, lng: result.lng }
    })
    this.element.dispatchEvent(event)
  }

  handleKeydown(event) {
    const items = this.dropdownTarget.querySelectorAll('.dropdown-item')

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, items.length - 1)
        this.updateSelection()
        break
      case 'ArrowUp':
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, -1)
        this.updateSelection()
        break
      case 'Enter':
        event.preventDefault()
        if (this.selectedIndex >= 0 && items[this.selectedIndex]) {
          const item = items[this.selectedIndex]
          this.selectResult({
            name: item.textContent,
            lat: parseFloat(item.dataset.lat),
            lng: parseFloat(item.dataset.lng)
          })
        }
        break
      case 'Escape':
        this.hideDropdown()
        break
    }
  }

  updateSelection() {
    this.clearSelection()
    const items = this.dropdownTarget.querySelectorAll('.dropdown-item')
    if (this.selectedIndex >= 0 && items[this.selectedIndex]) {
      items[this.selectedIndex].classList.add('active')
    }
  }

  clearSelection() {
    this.dropdownTarget.querySelectorAll('.dropdown-item').forEach(item => {
      item.classList.remove('active')
    })
  }

  showDropdown() {
    this.dropdownTarget.classList.add('show')
  }

  hideDropdown() {
    this.dropdownTarget.classList.remove('show')
    this.selectedIndex = -1
  }

  // Handle clicks outside the dropdown
  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideDropdown()
    }
  }

  showHint() {
    if (this.inputTarget.value.trim().length === 0) {
      // Show a temporary hint in the dropdown
      this.dropdownTarget.innerHTML = `
        <div class="dropdown-item-text text-muted p-3">
          <i class="bi bi-lightbulb me-2"></i>
          Start typing your suburb, city, or town name to see suggestions
        </div>
      `
      this.showDropdown()

      // Hide hint after 3 seconds or when user starts typing
      setTimeout(() => {
        if (this.inputTarget.value.trim().length === 0) {
          this.hideDropdown()
        }
      }, 3000)
    }
  }

  navigateToInterest(event) {
    const { suburb, lat, lng } = event.detail
    const url = new URL('/interest', window.location.origin)
    url.searchParams.set('suburb', suburb)
    url.searchParams.set('lat', lat)
    url.searchParams.set('lng', lng)
    window.location.href = url.toString()
  }
}
