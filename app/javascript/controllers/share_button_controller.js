import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
    title: String,
    text: String
  }

  async share() {
    if (navigator.share) {
      try {
        await navigator.share({
          title: this.titleValue,
          text: this.textValue,
          url: this.urlValue
        })
      } catch (error) {
        if (error.name !== 'AbortError') {
          console.error('Error sharing:', error)
          this.fallbackShare()
        }
      }
    } else {
      this.fallbackShare()
    }
  }

  fallbackShare() {
    // Copy to clipboard as fallback
    const shareText = `${this.textValue}\n\n${this.urlValue}`

    if (navigator.clipboard) {
      navigator.clipboard.writeText(shareText).then(() => {
        this.showToast('Link copied to clipboard!')
      }).catch(() => {
        this.legacyCopy(shareText)
      })
    } else {
      this.legacyCopy(shareText)
    }
  }

  legacyCopy(text) {
    const textArea = document.createElement('textarea')
    textArea.value = text
    textArea.style.position = 'fixed'
    textArea.style.left = '-999999px'
    textArea.style.top = '-999999px'
    document.body.appendChild(textArea)
    textArea.focus()
    textArea.select()

    try {
      document.execCommand('copy')
      this.showToast('Link copied to clipboard!')
    } catch (error) {
      console.error('Fallback copy failed:', error)
      this.showToast('Unable to copy link')
    } finally {
      document.body.removeChild(textArea)
    }
  }

  showToast(message) {
    // Create a simple toast notification
    const toast = document.createElement('div')
    toast.className = 'toast-notification'
    toast.textContent = message
    toast.style.cssText = `
      position: fixed;
      top: 20px;
      right: 20px;
      background: #198754;
      color: white;
      padding: 12px 24px;
      border-radius: 6px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.15);
      z-index: 1050;
      font-size: 14px;
      transform: translateY(-100px);
      transition: transform 0.3s ease;
    `

    document.body.appendChild(toast)

    // Animate in
    setTimeout(() => {
      toast.style.transform = 'translateY(0)'
    }, 100)

    // Remove after 3 seconds
    setTimeout(() => {
      toast.style.transform = 'translateY(-100px)'
      setTimeout(() => {
        if (toast.parentNode) {
          document.body.removeChild(toast)
        }
      }, 300)
    }, 3000)
  }
}
