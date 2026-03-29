import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["subscribeBtn", "status"]
  static values = { vapidKey: String }

  async subscribe() {
    try {
      const permission = await Notification.requestPermission()
      if (permission !== "granted") {
        alert("Please allow notifications to enable this feature.")
        return
      }

      const registration = await navigator.serviceWorker.ready
      const subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: this._urlBase64ToUint8Array(this.vapidKeyValue)
      })

      const response = await fetch("/push_subscriptions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ subscription: subscription.toJSON() })
      })

      if (response.ok) {
        this.subscribeBtnTarget.classList.add("d-none")
        this.statusTarget.classList.remove("d-none")
        // Reload to show preference toggles
        window.location.reload()
      } else {
        alert("Failed to save subscription. Please try again.")
      }
    } catch (error) {
      console.error("Push subscription error:", error)
      alert("Failed to enable notifications. Your browser may not support this feature.")
    }
  }

  _urlBase64ToUint8Array(base64String) {
    const padding = "=".repeat((4 - base64String.length % 4) % 4)
    const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/")
    const rawData = window.atob(base64)
    const outputArray = new Uint8Array(rawData.length)
    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i)
    }
    return outputArray
  }
}
