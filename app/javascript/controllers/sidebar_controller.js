import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "overlay", "popup"]

  connect() {
    // Контролер підключений
  }

  open() {
    if (this.hasSidebarTarget) {
      this.sidebarTarget.classList.add("open")
      if (this.hasOverlayTarget) {
        this.overlayTarget.classList.add("active")
      }
      document.body.style.overflow = "hidden" // Блокуємо прокрутку
    }
  }

  close() {
    if (this.hasSidebarTarget) {
      this.sidebarTarget.classList.remove("open")
      if (this.hasOverlayTarget) {
        this.overlayTarget.classList.remove("active")
      }
      document.body.style.overflow = "" // Відновлюємо прокрутку
    }
  }

  openPopup() {
    if (this.hasPopupTarget) {
      this.popupTarget.style.display = "flex"
      document.body.style.overflow = "hidden"
    }
  }

  closePopup() {
    if (this.hasPopupTarget) {
      this.popupTarget.style.display = "none"
      document.body.style.overflow = ""
    }
  }
}

