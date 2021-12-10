class Header extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    this.innerHTML = `
      <header>
        <a href="home.html">Home</a>
        <a href="contact.html">Contact</a>
      <hr>
      </header>
    `;
  }
}

customElements.define('header-component', Header);
