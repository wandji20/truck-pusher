import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['label'];

  updateLabel(e) {
    console.log(e.target.files.length)
    if (e.target.files.length !== 0) {
      this.labelTarget.innerHTML = `${this.labelTarget.dataset.selectedLabel} (${e.target.files.length})`
      this.labelTarget.classList.remove("hidden");
    } else {
      this.labelTarget.innerHTML = null;
      this.labelTarget.classList.add("hidden");
    }
  }
}