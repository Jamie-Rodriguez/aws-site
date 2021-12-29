class Header extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    this.innerHTML = `
      <header>
        <nav>
          <a href="/home">Home</a>
          <a href="/projects">Projects</a>
          <a href="/blog">Blog</a>
          <a href="/contact">Contact</a>
        </nav>
        <hr>
      </header>
    `;
  }
}

customElements.define('header-component', Header);
