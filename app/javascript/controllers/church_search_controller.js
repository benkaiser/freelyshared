import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown"]

  connect() {
    this.timeout = null
    this.selectedIndex = -1
    this.results = []

    // Close dropdown on outside click
    this.outsideClickHandler = (e) => {
      if (!this.element.contains(e.target)) {
        this.hideDropdown()
      }
    }
    document.addEventListener("click", this.outsideClickHandler)
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
    document.removeEventListener("click", this.outsideClickHandler)
  }

  search() {
    const query = this.inputTarget.value.trim()

    if (query.length < 2) {
      this.hideDropdown()
      return
    }

    if (this.timeout) clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      this.performSearch(query)
    }, 300)
  }

  async performSearch(query) {
    try {
      const response = await fetch(`/churches/search?q=${encodeURIComponent(query)}`)
      this.results = await response.json()
      this.displayResults(this.results, query)
    } catch (error) {
      console.error("Church search error:", error)
    }
  }

  displayResults(results, query) {
    this.dropdownTarget.innerHTML = ""
    this.selectedIndex = -1

    if (results.length > 0) {
      results.forEach((church, index) => {
        const item = document.createElement("a")
        item.href = `/churches/${church.id}`
        item.className = "dropdown-item d-flex justify-content-between align-items-center"
        item.dataset.index = index

        const info = document.createElement("div")
        info.innerHTML = `
          <strong>${this.escapeHtml(church.name)}</strong>
          <br><small class="text-muted"><i class="bi bi-geo-alt"></i> ${this.escapeHtml(church.location_name)}</small>
        `

        const badge = document.createElement("span")
        if (church.status === "ready") {
          badge.className = "badge bg-success"
          badge.textContent = `${church.member_count} members`
        } else {
          badge.className = "badge bg-warning text-dark"
          badge.textContent = `${church.member_count}/5 members`
        }

        item.appendChild(info)
        item.appendChild(badge)

        item.addEventListener("mouseenter", () => {
          this.clearSelection()
          item.classList.add("active")
          this.selectedIndex = index
        })

        this.dropdownTarget.appendChild(item)
      })
    }

    // Always show "register" option at bottom
    const registerItem = document.createElement("a")
    registerItem.href = `/churches/new`
    registerItem.className = "dropdown-item text-primary border-top"
    registerItem.innerHTML = `
      <i class="bi bi-plus-circle me-2"></i>
      <strong>Can't find your church?</strong> Register it here
    `
    this.dropdownTarget.appendChild(registerItem)

    this.showDropdown()
  }

  handleKeydown(event) {
    const items = this.dropdownTarget.querySelectorAll(".dropdown-item")

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, items.length - 1)
        this.updateSelection()
        break
      case "ArrowUp":
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, -1)
        this.updateSelection()
        break
      case "Enter":
        event.preventDefault()
        if (this.selectedIndex >= 0 && items[this.selectedIndex]) {
          items[this.selectedIndex].click()
        }
        break
      case "Escape":
        this.hideDropdown()
        break
    }
  }

  updateSelection() {
    this.clearSelection()
    const items = this.dropdownTarget.querySelectorAll(".dropdown-item")
    if (this.selectedIndex >= 0 && items[this.selectedIndex]) {
      items[this.selectedIndex].classList.add("active")
    }
  }

  clearSelection() {
    this.dropdownTarget.querySelectorAll(".dropdown-item").forEach(item => {
      item.classList.remove("active")
    })
  }

  showDropdown() {
    this.dropdownTarget.classList.add("show")
  }

  hideDropdown() {
    this.dropdownTarget.classList.remove("show")
    this.selectedIndex = -1
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
