import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  connect() {
    this.setLocation();
  }

  setLocation() {
    if ("geolocation" in navigator) {
      navigator.geolocation.getCurrentPosition((position) => {
        const { coords: { latitude: lat, longitude: long } } = position;

        this.updateForm(lat, long)
      });
    }
  }

  updateForm(lat, long) {
    if (!(lat && long)) return;
    const form = this.element.closest("form")

    const latInput = document.createElement('input')
    latInput.type = "hidden";
    latInput.value = lat;
    latInput.name = 'latitude'

    const longInput = document.createElement('input')
    longInput.type = "hidden";
    longInput.value = long;
    longInput.name = 'longitude'

    form.appendChild(latInput);
    form.appendChild(longInput);
  }
}