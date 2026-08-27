/*
 * hader_mobile_polish.js — makes the injected desktop experience usable on a
 * phone, without editing content.js.
 *
 * content.js is copied from the browser extension verbatim so future updates
 * stay a file copy, and it was written for a desktop browser window. Three
 * things follow from that, and all three are fixed from the outside here:
 *
 *   1. Madrasati's own header, nav and footer eat vertical space that a phone
 *      does not have to spare.
 *   2. The dashboard panel is pinned to the bottom and covers the lesson cards
 *      the teacher is trying to pick from.
 *   3. The presence badge tells the teacher to sign in "from the extension
 *      icon" — there is no extension icon inside the app.
 *
 * Everything here is additive and defensive: it must never break the page it
 * is decorating, and above all must never hide the schedule itself.
 */
(function () {
  'use strict';

  if (window.__HADER_POLISH_READY__) return;
  window.__HADER_POLISH_READY__ = true;

  // Selectors content.js uses to find the schedule. Anything containing one of
  // these is off-limits to the chrome-hiding pass below.
  var SCHEDULE_SELECTOR =
    '.calendar-table, .table-schedule, .schedule-table, .fc-view, .timetable, ' +
    '.scheduler-table, td.day-cell, div.cs-lesson-card, [data-data]';

  // Site furniture worth reclaiming on a small screen. Deliberately generic:
  // the guard below is what makes guessing safe.
  var CHROME_SELECTOR = [
    'header', 'nav', 'footer',
    '.navbar', '.main-header', '.site-header', '.page-header',
    '.top-bar', '.topbar', '.breadcrumb', '.breadcrumbs',
    '#header', '#footer', '#navbar'
  ].join(',');

  function findSchedule() {
    return document.querySelector(SCHEDULE_SELECTOR);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 1. Reclaim vertical space
  // ───────────────────────────────────────────────────────────────────────────

  var chromeHidden = false;

  function hideSiteChrome() {
    if (chromeHidden) return;

    var schedule = findSchedule();
    // Without the schedule on screen there is nothing to protect a guess
    // against, so wait rather than hide anything.
    if (!schedule) return;

    var hidden = 0;
    document.querySelectorAll(CHROME_SELECTOR).forEach(function (el) {
      // The guard: an ancestor of the schedule is layout, not furniture.
      // This is what makes a generic selector list safe to apply to a page
      // whose markup we cannot see from here.
      if (el.contains(schedule) || schedule.contains(el)) return;
      if (el.querySelector(SCHEDULE_SELECTOR)) return;
      // Leave anything of Hader's own alone.
      if (el.id && el.id.indexOf('hadar') === 0) return;
      if (el.id && el.id.indexOf('Moeen') === 0) return;

      el.setAttribute('data-hader-hidden', '1');
      el.style.setProperty('display', 'none', 'important');
      hidden++;
    });

    if (hidden > 0) chromeHidden = true;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 2. Let the dashboard panel get out of the way
  // ───────────────────────────────────────────────────────────────────────────

  function injectPanelStyles() {
    if (document.getElementById('hader-polish-styles')) return;
    var style = document.createElement('style');
    style.id = 'hader-polish-styles';
    style.textContent = [
      // The panel is fixed to the bottom of the viewport; on a phone that is a
      // third of the screen sitting on top of the cards being chosen.
      '#Moeen-2-dashboard-panel{max-height:60vh;overflow-y:auto;transition:transform .22s ease}',
      '#Moeen-2-dashboard-panel.hader-collapsed>*:not(.hader-panel-toggle){opacity:0;pointer-events:none}',
      '.hader-panel-toggle{position:sticky;top:0;display:flex;align-items:center;justify-content:center;',
      'gap:6px;width:100%;height:34px;margin:0 0 8px;padding:0;border:none;border-radius:10px;',
      'background:rgba(14,122,94,.10);color:#0E7A5E;font-family:inherit;font-size:13px;font-weight:700;',
      'cursor:pointer;opacity:1 !important;pointer-events:auto !important;z-index:2}',
      '.hader-panel-toggle:active{background:rgba(14,122,94,.18)}'
    ].join('');
    (document.head || document.documentElement).appendChild(style);
  }

  function addPanelToggle() {
    var panel = document.getElementById('Moeen-2-dashboard-panel');
    if (!panel || panel.querySelector('.hader-panel-toggle')) return;

    injectPanelStyles();

    var toggle = document.createElement('button');
    toggle.type = 'button';
    toggle.className = 'hader-panel-toggle';

    function label() {
      toggle.textContent = panel.classList.contains('hader-collapsed')
        ? '▲  إظهار لوحة التحضير'
        : '▼  إخفاء اللوحة مؤقتاً';
    }

    toggle.addEventListener('click', function () {
      panel.classList.toggle('hader-collapsed');
      applyPanelTransform(panel);
      label();
    });

    label();
    panel.insertBefore(toggle, panel.firstChild);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 3. Keep Hader's own UI at a readable size
  //
  // The layout viewport is forced to 1280px so Madrasati serves its desktop
  // schedule, which means the engine scales the whole page down to fit a ~400px
  // screen — roughly a third. That is the right trade for the table (the whole
  // week is visible), but Hader's own panel and dropdowns are shrunk by it too,
  // to the point of being unreadable.
  //
  // So they are scaled back up by the same factor the page was scaled down by.
  // ───────────────────────────────────────────────────────────────────────────

  function pageScaleFactor() {
    var layoutWidth = window.innerWidth || 0;
    var deviceWidth = (window.screen && window.screen.width) || 0;
    if (!layoutWidth || !deviceWidth) return 1;
    var factor = layoutWidth / deviceWidth;
    // Below this the page is near 1:1 and there is nothing to correct.
    if (factor < 1.2) return 1;
    // Guard against a bogus reading turning the panel into a wall.
    return Math.min(factor, 4);
  }

  var currentScale = 1;

  /// Single writer for the panel's transform. Collapsing and counter-scaling
  /// both need it, and two writers would mean whoever ran last silently undid
  /// the other.
  function applyPanelTransform(panel) {
    if (!panel) return;
    var parts = [];
    if (currentScale !== 1) parts.push('scale(' + currentScale + ')');
    if (panel.classList.contains('hader-collapsed')) {
      parts.push('translateY(calc(100% - 46px))');
    }
    if (parts.length) {
      panel.style.setProperty('transform-origin', 'bottom right', 'important');
      panel.style.setProperty('transform', parts.join(' '), 'important');
    } else {
      panel.style.removeProperty('transform');
    }
  }

  function rescaleHaderUi() {
    var scale = pageScaleFactor();
    if (scale === 1) return;
    currentScale = scale;

    var deviceWidth = window.screen.width;

    // The panel is position:fixed, so a transform moves it without disturbing
    // the page around it. Anchoring the origin to its own corner keeps it
    // pinned where content.js put it while it grows.
    var panel = document.getElementById('Moeen-2-dashboard-panel');
    if (panel) {
      applyPanelTransform(panel);
      // Width is set pre-scale, so it has to be the device width divided back
      // out — otherwise the scaled panel is three times wider than the screen.
      var width = Math.max(240, deviceWidth - 24);
      panel.style.setProperty('width', width + 'px', 'important');
      panel.style.setProperty('max-width', width + 'px', 'important');
      panel.style.setProperty(
        'max-height',
        Math.round((window.innerHeight * 0.6) / scale) + 'px',
        'important'
      );
    }

    var badge = document.getElementById('hadar-presence-badge');
    if (badge) {
      badge.style.setProperty('transform-origin', 'bottom right', 'important');
      badge.style.setProperty('transform', 'scale(' + scale + ')', 'important');
    }

    // The dropdowns sit in the table's flow, so scaling them with a transform
    // would misalign the cells. Their type is grown instead — that adds height
    // to a row without widening a column, so it cannot push the table wider and
    // set the viewport fitting off again.
    document.querySelectorAll('.Moeen-2-dashboard-select').forEach(function (select) {
      if (select.getAttribute('data-hader-scaled') === String(scale)) return;
      select.setAttribute('data-hader-scaled', String(scale));
      select.style.setProperty('font-size', Math.round(12 * scale) + 'px', 'important');
      select.style.setProperty(
        'padding',
        Math.round(5 * scale) + 'px ' + Math.round(8 * scale) + 'px',
        'important'
      );
      select.style.setProperty('border-width', Math.max(1, Math.round(1.5 * scale)) + 'px', 'important');
      select.style.setProperty('border-radius', Math.round(4 * scale) + 'px', 'important');
    });
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 4. Correct copy that assumes a browser extension
  // ───────────────────────────────────────────────────────────────────────────

  function fixExtensionWording() {
    // content.js rewrites the badge on every state change, so this re-runs
    // rather than patching once.
    var sub = document.querySelector('#hadar-presence-badge .hadar-presence-sub');
    if (sub && sub.textContent.indexOf('أيقونة الإضافة') !== -1) {
      sub.textContent = 'سجّل الدخول من التطبيق';
    }

    var banner = document.getElementById('hadar-auth-banner');
    if (banner && banner.innerHTML.indexOf('أيقونة الامتداد') !== -1) {
      banner.innerHTML =
        '🔒 <strong>حضر</strong> — سجّل الدخول من التطبيق لتفعيل التحضير';
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Drive it
  //
  // Everything above targets elements content.js and Madrasati render after
  // load, so this polls briefly rather than running once. It stops on its own
  // so nothing is left ticking for the life of the page.
  // ───────────────────────────────────────────────────────────────────────────

  function pass() {
    try {
      hideSiteChrome();
      addPanelToggle();
      rescaleHaderUi();
      fixExtensionWording();
    } catch (error) {
      // Polish must never take the automation down with it.
      if (window.console && console.warn) {
        console.warn('[HaderPolish] pass failed:', error);
      }
    }
  }

  var ticks = 0;
  var timer = setInterval(function () {
    pass();
    // ~30s of coverage: long enough for a slow schedule render, short enough
    // that nothing keeps running once the page has settled.
    if (++ticks >= 30) clearInterval(timer);
  }, 1000);

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', pass);
  } else {
    pass();
  }
})();
