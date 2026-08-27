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
      '#Moeen-2-dashboard-panel.hader-collapsed{transform:translateY(calc(100% - 46px))}',
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
      label();
    });

    label();
    panel.insertBefore(toggle, panel.firstChild);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 3. Correct copy that assumes a browser extension
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
