class Header extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    this.innerHTML = `
      <header>
        <a href="home">Home</a>
        <a href="projects">Projects</a>
        <a href="contact">Contact</a>
      <hr>
      </header>
    `;
  }
}

customElements.define('header-component', Header);
