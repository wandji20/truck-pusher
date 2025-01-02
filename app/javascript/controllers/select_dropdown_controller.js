import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { searchUrl: String, selected: { type: String, default: "" }, template: "dropdown" }
  static targets = ["input", "label", "options", "option", "content", "dropdownTemplate", "newTemplate", "displayButton"]

  connect() {
    this.#setTemplate();
    document.addEventListener('click', this.handleClickOutside.bind(this));
  }

  disconnect() {
    document.removeEventListener('click', this.handleClickOutside.bind(this));
  }

  search() {
    if (!this.searchUrlValue) return;
  
    // replace non integer values before peforming search
    if (this.inputTarget.dataset.fieldType === "integer") {
      const value = this.inputTarget.value.replace(/[^-0-9.]/g, '');
      this.inputTarget.value = value;
  
      if(!value) return;
    }

    clearTimeout(this.debouncedSearch);

    this.debouncedSearch = setTimeout(async () => {
      if (this.inputTarget.value === '') {
        this.selectedValue = null;

        const placeholder = this.displayButtonTarget.querySelector('.label').dataset.placeholder;
        this.displayButtonTarget.querySelector('.label').innerHTML = placeholder;
        this.displayButtonTarget.classList.add('placeholder');
      }

      // Set url params
      const url = new URL(this.searchUrlValue);
      const search_params = url.searchParams;
      search_params.append('search', this.inputTarget.value);
      search_params.append('selected', this.selectedValue);

      url.search = search_params.toString();
    
      const response = await fetch(url, { headers: { "Accept": "text/vnd.turbo-stream.html" } });
      const streamContent = await response.text();
      await Turbo.renderStreamMessage(streamContent);
    
    }, 500);
  }

  toggleOption(e) {
    const value = e.target.closest('li').dataset.value;

    if (value === "new") {
      this.templateValue = "new";
      this.#setTemplate();
    } else {
      this.#updateValue(value);
    }
  }

  close(event = null) {
    // Prevent closing modal and hide options
    if (event)
      event.stopPropagation();
    
    if (this.hasOptionsTarget) this.optionsTarget.classList.add('hidden');

    // Hide input and show display button
    this.inputTarget.closest('.search-section')?.classList?.add('hidden');

    if (this.hasDisplayButtonTarget) this.displayButtonTarget.classList.remove('hidden');
  }

  toggleDropdown() {
    if (this.hasInputTarget) {
      this.inputTarget.focus();
    }
  
    if (this.optionsTarget.dataset.show === 'true') {
      if (this.optionsTarget.classList.contains('hidden'))  {
        this.optionsTarget.classList.remove('hidden')
      } else {
        this.close();
      }
    }
  }

  showSearchInput() {
    // Show input field and hide display button
    this.inputTarget.closest('div').classList.remove('hidden');
    this.inputTarget.focus();

    this.displayButtonTarget.classList.add('hidden');

    // open dropdown it has options
    if (this.optionsTarget.dataset.show === 'true') 
      this.optionsTarget.classList.toggle('hidden');
  }

  handleClickOutside(event) {
    // Close list when clicked on dropdown label or outside dropdown
    if (!this.element.contains(event.target) ||
          (this.hasLabelTarget && this.labelTarget.contains(event.target)))
      this.close(event);
  }

  toggleTemplate(e) {
    this.templateValue = e.target.dataset.value;
    this.#setTemplate();
  }

  #updateValue(value) {
    let selected = this.selectedValue;

    if (selected === value) {
      selected = '';
    } else {
      selected = value;
    }

    this.selectedValue = selected
    this.#setDisplayValue();

    this.#markSelected();
  }

  #markSelected() {
    this.optionTargets.forEach((option) => {
      const checkbox = option.querySelector('input[type="checkbox"]');
      const optionValue = option.dataset.value;
      if (this.selectedValue === optionValue) {
        if (checkbox) checkbox.checked = true;
      } else {
        if (checkbox) checkbox.checked = false;
      }
    })
  }

  #setDisplayValue() {
    if (this.selectedValue === '') {
      this.inputTarget.value = '';
      // Update display value
      const placeholder = this.displayButtonTarget.querySelector('.label').dataset.placeholder;
      this.displayButtonTarget.querySelector('.label').innerHTML = placeholder;
      this.displayButtonTarget.classList.add('placeholder');
      this.close();

      return
    }
  
    const labelHtml = this.optionsTarget.querySelector(`li[data-value="${this.selectedValue}"]`);
    
    this.inputTarget.value = labelHtml.dataset.label;
    this.displayButtonTarget.querySelector('.label').innerHTML = labelHtml.querySelector('.label').innerHTML;
    this.displayButtonTarget.classList.remove('placeholder');
    this.close()
  }

  #setTemplate() {
    if (this.templateValue === "dropdown") {
      this.contentTarget.innerHTML = null;
      this.contentTarget.appendChild(this.dropdownTemplateTarget.content.cloneNode(true));
      this.#setDisplayValue();
    }

    if (this.templateValue === "new") {
      let newValue = null

      if (this.hasInputTarget) newValue = this.inputTarget.value;

      this.contentTarget.innerHTML = null;
      this.contentTarget.appendChild(this.newTemplateTarget.content.cloneNode(true));
      if (newValue) this.inputTarget.value = newValue;
    }
  }
}