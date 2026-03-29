import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { text: String }

  copy() {
    if (navigator.clipboard) {
      navigator.clipboard.writeText(this.textValue).then(() => {
        this.showSuccess()
      }).catch(() => {
        this.legacyCopy()
      })
    } else {
      this.legacyCopy()
    }
  }

  legacyCopy() {
    const textArea = document.createElement('textarea')
    textArea.value = this.textValue
    textArea.style.position = 'fixed'
    textArea.style.left = '-999999px'
    textArea.style.top = '-999999px'
    document.body.appendChild(textArea)
    textArea.focus()
    textArea.select()

    try {
      document.execCommand('copy')
      this.showSuccess()
    } catch (error) {
      console.error('Copy failed:', error)
      this.showError()
    } finally {
      document.body.removeChild(textArea)
    }
  }

  showSuccess() {
    const originalText = this.element.innerHTML
    this.element.innerHTML = '<i class="bi bi-check me-2"></i>Copied!'
    this.element.classList.add('btn-success')
    this.element.classList.remove('btn-outline-secondary')

    setTimeout(() => {
      this.element.innerHTML = originalText
      this.element.classList.remove('btn-success')
      this.element.classList.add('btn-outline-secondary')
    }, 2000)
  }

  showError() {
    const originalText = this.element.innerHTML
    this.element.innerHTML = '<i class="bi bi-x me-2"></i>Failed'
    this.element.classList.add('btn-danger')
    this.element.classList.remove('btn-outline-secondary')

    setTimeout(() => {
      this.element.innerHTML = originalText
      this.element.classList.remove('btn-danger')
      this.element.classList.add('btn-outline-secondary')
    }, 2000)
  }
}
