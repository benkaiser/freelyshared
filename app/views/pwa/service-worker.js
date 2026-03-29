// FreelyShared Service Worker
// Handles push notifications and basic offline support

// Cache name for offline support
const CACHE_NAME = "freelyshared-v1"
const OFFLINE_URL = "/offline.html"

// Install event — cache offline page
self.addEventListener("install", (event) => {
  self.skipWaiting()
})

// Activate event — clean up old caches
self.addEventListener("activate", (event) => {
  event.waitUntil(clients.claim())
})

// Push notification handler
self.addEventListener("push", async (event) => {
  if (!event.data) return

  const data = event.data.json()
  const options = {
    body: data.body,
    icon: data.icon || "/icon.png",
    badge: "/icon.png",
    data: { url: data.url },
    vibrate: [100, 50, 100]
  }

  event.waitUntil(
    self.registration.showNotification(data.title, options)
  )
})

// Notification click handler — open the relevant page
self.addEventListener("notificationclick", (event) => {
  event.notification.close()

  const urlToOpen = event.notification.data?.url || "/"

  event.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true }).then((clientList) => {
      // If there's already a window open, focus it and navigate
      for (const client of clientList) {
        if ("focus" in client) {
          client.focus()
          client.navigate(urlToOpen)
          return
        }
      }
      // Otherwise open a new window
      if (clients.openWindow) {
        return clients.openWindow(urlToOpen)
      }
    })
  )
})
