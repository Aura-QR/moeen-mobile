/*
 * hader_desktop_viewport.js — forces a true desktop layout viewport.
 *
 * `preferredContentMode: DESKTOP` gets the page a 980px viewport, which is
 * WebKit's legacy desktop default. That is wide enough to clear Bootstrap's
 * `md` breakpoint (768px) but lands 12px short of `lg` (992px) — so a page
 * that reveals its desktop table with `col-lg-*` or
 * `@media (min-width: 992px)` would still render its tablet layout.
 *
 * content.js looks for Madrasati's desktop schedule table
 * (`td.day-cell div[data-data]`, `.calendar-table`), so the viewport has to
 * clear `lg` — and `xl` too, for margin.
 */
(function () {
  'use strict';

  var TARGET_WIDTH = 1280;
  var CONTENT = 'width=' + TARGET_WIDTH + ', user-scalable=yes';

  function forceDesktopViewport() {
    var head = document.head || document.documentElement;
    if (!head) return;

    var meta = document.querySelector('meta[name="viewport"]');
    if (!meta) {
      meta = document.createElement('meta');
      meta.setAttribute('name', 'viewport');
      head.appendChild(meta);
    }
    if (meta.getAttribute('content') !== CONTENT) {
      meta.setAttribute('content', CONTENT);
    }
  }

  forceDesktopViewport();

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', forceDesktopViewport);
  }

  // Madrasati ships its own viewport tag in <head>; re-assert ours whenever the
  // head changes so a late-parsed tag cannot win.
  try {
    var target = document.head || document.documentElement;
    new MutationObserver(forceDesktopViewport)
      .observe(target, { childList: true });
  } catch (_) {
    // Observer unavailable — the timed passes below still cover the common case.
  }

  [100, 500, 1500].forEach(function (delay) {
    setTimeout(forceDesktopViewport, delay);
  });
})();
