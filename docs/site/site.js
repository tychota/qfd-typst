/* The guide is usable without JavaScript. Enhance code copying and section location. */
(() => {
  const french = document.documentElement.lang === 'fr';
  const messages = french ? {
    copy: 'Copier', copied: 'Copié', select: 'Sélectionner',
    label: (name) => `Copier le code ${name}`,
    success: 'Code copié dans le presse-papiers.',
    failure: 'Copie indisponible. Sélectionnez le code et copiez-le manuellement.',
  } : {
    copy: 'Copy', copied: 'Copied', select: 'Select code',
    label: (name) => `Copy ${name} code`,
    success: 'Code copied to clipboard.',
    failure: 'Copy unavailable. Select the code and copy it manually.',
  };
  // Matching section IDs keep language changes at the same point in the guide.
  document.querySelectorAll('.language-switch').forEach((link) => {
    link.addEventListener('click', () => { link.hash = document.querySelector('.guide-nav a[aria-current="location"]')?.hash || window.location.hash; });
  });
  if (navigator.clipboard && window.isSecureContext) {
    const status = document.getElementById('copy-status');
    document.querySelectorAll('.code-block').forEach((block) => {
      const code = block.querySelector('code');
      const button = document.createElement('button');
      button.type = 'button';
      button.className = 'copy-button';
      button.textContent = messages.copy;
      button.setAttribute('aria-label', messages.label(block.querySelector('.code-label').textContent));
      button.addEventListener('click', async () => {
        try {
          await navigator.clipboard.writeText(code.textContent);
          button.textContent = messages.copied;
          status.textContent = messages.success;
        } catch {
          button.textContent = messages.select;
          status.textContent = messages.failure;
        }
        window.setTimeout(() => { button.textContent = messages.copy; }, 2000);
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
