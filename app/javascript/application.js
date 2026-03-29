// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import * as bootstrap from "bootstrap"

// Register service worker for PWA and push notifications
if ("serviceWorker" in navigator) {
  navigator.serviceWorker.register("/service-worker.js")
    .then((registration) => {
      console.log("Service Worker registered:", registration.scope)
    })
    .catch((error) => {
      console.log("Service Worker registration failed:", error)
    })
}
