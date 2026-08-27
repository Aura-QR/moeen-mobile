/*
 * hader_desktop_viewport.js — owns the layout viewport for the in-app WebView.
 *
 * Two jobs, both about getting Madrasati's desktop schedule onto a phone:
 *
 * 1. Clear Bootstrap's `lg` breakpoint. `preferredContentMode: DESKTOP` gets
 *    the page a 980px viewport — WebKit's legacy desktop default. That clears
 *    `md` (768px) but lands 12px short of `lg` (992px), so a page that reveals
 *    its desktop table with `col-lg-*` or `@media (min-width: 992px)` would
 *    still render its tablet layout, where content.js's selectors match
 *    nothing.
 *
 * 2. Fit the whole table on screen. Madrasati's schedule can be wider than
 *    1280px once a teacher has many lessons, and the overflow forces
 *    horizontal panning to reach the cards on the far side. Widening the
 *    viewport to the content's own width lets the engine scale it down to fit
 *    instead, so the full week is visible at once.
 *
 * This file is the single owner of the viewport meta tag — nothing else should
 * write to it, or the two writers will fight.
 */
(function () {
  'use strict';

  var BASE_WIDTH = 1280;
  // Past this, text is too small to read on a phone and panning is the lesser
  // evil, so the fit stops widening and lets the page overflow.
  var MAX_WIDTH = 2000;
  // Ignore small overshoots; re-laying out the page is not worth a few pixels.
  var SLACK = 24;

  var currentWidth = BASE_WIDTH;
  var fitAttempts = 0;

  var META_MARK = 'data-hader-viewport';

  function applyViewport(width) {
    var head = document.head || document.documentElement;
    if (!head) return;

    var content = 'width=' + width + ', user-scalable=yes';

    // Madrasati ships its own `width=device-width` viewport tag. Ours is
    // injected at document start, so its tag is parsed *after* ours and lands
    // later in <head> — and when a page carries several viewport tags the
    // engine honours the last one. Ours was therefore being overridden the
    // moment the real page's <head> finished parsing, which is why the desktop
    // table rendered at 1:1 on a 402px screen instead of being scaled to fit.
    //
    // So: drop every viewport tag that is not ours, and keep ours last.
    var metas = document.querySelectorAll('meta[name="viewport"]');
    var mine = null;
    for (var i = 0; i < metas.length; i++) {
      if (metas[i].hasAttribute(META_MARK)) {
        mine = metas[i];
      } else {
        metas[i].parentNode && metas[i].parentNode.removeChild(metas[i]);
      }
    }

    if (!mine) {
      mine = document.createElement('meta');
      mine.setAttribute('name', 'viewport');
      mine.setAttribute(META_MARK, '1');
    }

    if (mine.getAttribute('content') !== content) {
      mine.setAttribute('content', content);
    }

    // Re-append so ours stays the last viewport tag even after the page adds
    // more of its own.
    if (mine.parentNode !== head || head.lastChild !== mine) {
      head.appendChild(mine);
    }

    currentWidth = width;
  }

  /// Widens the viewport to whatever the page actually needs, so the engine
  /// scales the table down to fit rather than clipping it.
  function fitToContent() {
    // Three passes are plenty: each one either settles or hits MAX_WIDTH.
    // The cap also stops a page that grows in response to the resize from
    // driving this in a loop.
    if (fitAttempts >= 3) return;

    var doc = document.documentElement;
    if (!doc) return;

    var needed = Math.max(doc.scrollWidth || 0, document.body ? document.body.scrollWidth || 0 : 0);
    if (needed <= currentWidth + SLACK) return;

    fitAttempts++;
    applyViewport(Math.min(Math.max(needed, BASE_WIDTH), MAX_WIDTH));
  }

  applyViewport(BASE_WIDTH);

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function () {
      applyViewport(currentWidth);
    });
  }

  // Madrasati ships its own viewport tag in <head>; re-assert ours whenever the
  // head changes so a late-parsed tag cannot win.
  try {
    new MutationObserver(function () { applyViewport(currentWidth); })
      .observe(document.head || document.documentElement, {
        childList: true,
        subtree: true,
        // A page can also rewrite an existing tag's content rather than
        // adding a new one.
        attributes: true,
        attributeFilter: ['content', 'name']
      });
  } catch (_) {
    // Observer unavailable — the timed passes below still cover the common case.
  }

  // The schedule table is rendered after load, so measure once things settle
  // and again after content.js has had time to add its dropdowns.
  [400, 1200, 2500].forEach(function (delay) {
    setTimeout(fitToContent, delay);
  });

  window.addEventListener('load', function () {
    setTimeout(fitToContent, 300);
  });
})();
