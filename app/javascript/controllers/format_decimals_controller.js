
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  formatValue(e) {
    const decimalValue = e.target.value.replace(/[^-0-9.]/g, '');

    e.target.value = decimalValue;
  }
}


