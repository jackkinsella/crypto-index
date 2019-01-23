import 'freshchat-widget'

function initializeFreshchatWidget() {
  const properties = JSON.parse(localStorage.getItem('freshchat') || '{}')

  window.fcWidget.init({
    token: window.config.freshchat.token,
    host: 'https://wchat.freshchat.com'
  })

  if (properties.externalId) {
    window.fcWidget.setExternalId(properties.externalId)
    window.fcWidget.user.setFirstName(properties.firstName)
    window.fcWidget.user.setEmail(properties.email)
  }
}

document.addEventListener(
  'DOMContentLoaded', () => setTimeout(initializeFreshchatWidget, 100)
)
