/* The guide is usable without JavaScript. Enhance code copying and section location. */
(() => {
  if (navigator.clipboard && window.isSecureContext) {
    const status = document.getElementById('copy-status');
    document.querySelectorAll('.code-block').forEach((block) => {
      const code = block.querySelector('code');
      const button = document.createElement('button');
      button.type = 'button';
      button.className = 'copy-button';
      button.textContent = 'Copy';
      button.setAttribute('aria-label', `Copy ${block.querySelector('.code-label').textContent} code`);
      button.addEventListener('click', async () => {
        try {
          await navigator.clipboard.writeText(code.textContent);
          button.textContent = 'Copied';
          status.textContent = 'Code copied to clipboard.';
        } catch {
          button.textContent = 'Select code';
          status.textContent = 'Copy unavailable. Select the code and copy it manually.';
        }
        window.setTimeout(() => { button.textContent = 'Copy'; }, 2000);
      });
      block.append(button);
    });
  }

  if ('IntersectionObserver' in window) {
    const links = [...document.querySelectorAll('.guide-nav nav a')];
    const visible = new Set();
    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) visible.add(entry.target.id);
        else visible.delete(entry.target.id);
      });
      const current = links.find((link) => visible.has(link.hash.slice(1)));
      links.forEach((link) => {
        if (link === current) link.setAttribute('aria-current', 'location');
        else link.removeAttribute('aria-current');
      });
    }, { rootMargin: '-5% 0px -45% 0px', threshold: 0 });
    document.querySelectorAll('.guide-section').forEach((section) => observer.observe(section));
  }
})();
