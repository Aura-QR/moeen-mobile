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

  // The dropdown content.js injects into each lesson card.
  var SELECT_SELECTOR = '.Moeen-2-dashboard-select';

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

    // The dropdowns sit in the table's flow, where a transform would misalign
    // the cells, so their type is grown instead. That adds row height without
    // widening a column, so it cannot push the table wider and set the viewport
    // fitting off again.
    //
    // But the box cannot grow: its width is the table column's, which at this
    // zoom is only ~57 device px. Scaling the type blindly overflowed it and
    // clipped "اختر الدرس..." down to "اخ". So the size is capped at whatever
    // actually fits the text currently shown.
    document.querySelectorAll(SELECT_SELECTOR).forEach(function (select) {
      shortenPlaceholder(select);
      sizeSelectType(select, scale);

      // Picking a lesson swaps a four-character placeholder for a long title,
      // so the size has to be recomputed. The polling below stops after ~30s,
      // well before a teacher has worked through a week, so this cannot rely
      // on it.
      showChosenLesson(select, scale);

      if (!select.getAttribute('data-hader-resize-bound')) {
        select.setAttribute('data-hader-resize-bound', '1');
        select.addEventListener('change', function () {
          sizeSelectType(select, currentScale);
          showChosenLesson(select, currentScale);
        });
      }
    });
  }

  /// Echoes the chosen lesson under the dropdown, where it can wrap.
  ///
  /// A lesson title runs about 40 characters and the column is ~129px wide, so
  /// inside the closed dropdown it is clipped at any size a teacher could read.
  /// The column cannot widen — that would push the table out and restart the
  /// viewport fitting — but the row can grow taller, so the confirmation goes
  /// below the control instead of inside it.
  ///
  /// Only the tail after "--" is shown: Madrasati's option text is
  /// "<unit> -- <lesson>", and the lesson is the part being confirmed.
  function showChosenLesson(select, scale) {
    var card = select.parentElement;
    if (!card) return;

    var label = card.querySelector('.hader-chosen');
    var opt = select.selectedIndex >= 0 ? select.options[select.selectedIndex] : null;
    var value = select.value;

    if (!value || !opt) {
      if (label) label.remove();
      return;
    }

    var full = opt.textContent || '';
    var parts = full.split('--');
    var lesson = (parts[parts.length - 1] || full).trim();

    if (!label) {
      label = document.createElement('div');
      label.className = 'hader-chosen';
      card.appendChild(label);
    }

    if (label.getAttribute('data-hader-text') === lesson) return;
    label.setAttribute('data-hader-text', lesson);
    label.textContent = '✓ ' + lesson;
    label.style.cssText = [
      'margin:' + Math.round(3 * scale) + 'px auto 0',
      'width:90%',
      'font-size:' + Math.round(9 * scale) + 'px',
      'line-height:1.35',
      'color:#0E7A5E',
      'font-weight:700',
      'text-align:center',
      'direction:rtl',
      'word-break:break-word'
    ].join(';');
  }

  /// content.js labels the empty option "اختر الدرس...", which cannot fit the
  /// column at this zoom no matter the type size. The shorter label can.
  ///
  /// Only the placeholder is touched. It carries an empty value, and
  /// handleDashboardSave() skips empty selects and reads option text only for a
  /// real choice, so nothing downstream sees this.
  function shortenPlaceholder(select) {
    var first = select.options && select.options[0];
    if (!first || first.value) return;
    if (first.getAttribute('data-hader-short')) return;
    first.setAttribute('data-hader-short', '1');
    first.textContent = 'اختر';
  }

  /// Grows the type toward the counter-scaled size, but never past what the
  /// box can show. A long lesson title lands smaller than the placeholder does,
  /// which is the trade that keeps it legible instead of clipped.
  function sizeSelectType(select, scale) {
    var label = '';
    if (select.selectedIndex >= 0 && select.options[select.selectedIndex]) {
      label = select.options[select.selectedIndex].textContent || '';
    }

    var boxWidth = select.clientWidth || select.offsetWidth || 0;
    if (!boxWidth) return;

    // What the text actually gets is the box minus the engine's dropdown arrow
    // and our own padding. The first cut of this ignored both and scaled the
    // horizontal padding with the type, which ate 46px of a 129px column and
    // clipped "اختر" to "اخـ" — the very thing it was meant to fix.
    var ARROW = 34;
    var PAD_X = 6;

    var usable = boxWidth - ARROW - (PAD_X * 2);
    // Arabic glyphs run about half the type size wide on average.
    var fits = Math.floor(usable / Math.max(label.length, 1) / 0.55);

    var target = Math.round(12 * scale);
    var size = Math.max(13, Math.min(target, fits));

    var applied = select.getAttribute('data-hader-type');
    if (applied === String(size)) return;
    select.setAttribute('data-hader-type', String(size));

    select.style.setProperty('font-size', size + 'px', 'important');
    // Vertical padding still scales — that is what makes the control easy to
    // hit. Horizontal padding stays tight, because width is the scarce one.
    select.style.setProperty(
      'padding',
      Math.round(size * 0.45) + 'px ' + PAD_X + 'px',
      'important'
    );
    select.style.setProperty('border-width', Math.max(1, Math.round(scale)) + 'px', 'important');
    select.style.setProperty('border-radius', Math.round(3 * scale) + 'px', 'important');
    select.style.setProperty('text-overflow', 'ellipsis', 'important');
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
