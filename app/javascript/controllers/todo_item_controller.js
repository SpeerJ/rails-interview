import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="todo-item"
export default class extends Controller {
  static targets = ["description"]

  toggle() {
    console.log("he")
    this.descriptionTarget.classList.toggle("hidden")
  }
}
