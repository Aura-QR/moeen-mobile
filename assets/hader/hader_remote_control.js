/*
 * hader_remote_control.js — lets Flutter drive content.js from a native UI.
 *
 * The point is to get the teacher off a desktop schedule table on a phone.
 * Rather than reimplement the automation natively — handleDashboardSave() reads
 * the live Madrasati DOM for subject ids, school ids and lesson tokens, so a
 * reimplementation would have to reproduce all of it — the WebView is kept as
 * the engine and simply moved out of sight.
 *
 * The split:
 *   - harvest()  reads what content.js rendered (lesson cards + their lesson
 *                options) and hands it to Flutter, which draws the real UI.
 *   - apply()    writes the teacher's native choices back into the dropdowns.
 *   - start()    clicks the panel's own save button.
 *
 * So the automation that actually runs is content.js's, untouched, against the
 * real page. This file only moves data across the glass.
 */
(function () {
  'use strict';

  if (window.__HADER_RC_READY__) return;
  window.__HADER_RC_READY__ = true;

  var SELECT_SELECTOR = '.Moeen-2-dashboard-select';
  var SAVE_BUTTON_ID = 'Moeen-2-dashboard-save';
  var STATUS_ID = 'Moeen-2-dashboard-status';
  var COUNTER_ID = 'Moeen-2-dashboard-counter';

  function bridge(name, payload) {
    try {
      if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
        return window.flutter_inappwebview.callHandler(name, payload);
      }
    } catch (_) { /* the harvest below retries, so a miss here is recoverable */ }
    return Promise.resolve(null);
  }

  function text(el) {
    return el && el.textContent ? el.textContent.replace(/\s+/g, ' ').trim() : '';
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Harvest
  // ───────────────────────────────────────────────────────────────────────────

  /// Day and period come from the card's position in Madrasati's table: the
  /// column's header cell and the row's leading cell. Both are best-effort —
  /// the native UI groups by whatever it gets and still works without them.
  function positionOf(card) {
    var out = { day: '', period: '' };
    try {
      var td = card.closest('td');
      if (!td) return out;

      var tr = td.closest('tr');
      var table = td.closest('table');
      if (!tr || !table) return out;

      var cells = Array.prototype.slice.call(tr.children);
      var columnIndex = cells.indexOf(td);

      var headerRow = table.querySelector('thead tr') || table.querySelector('tr');
      if (headerRow && columnIndex >= 0) {
        var headers = Array.prototype.slice.call(headerRow.children);
        if (headers[columnIndex]) out.day = text(headers[columnIndex]);
      }

      // The period label is the row's first cell — unless that cell is the card
      // itself, which happens in layouts without a leading label column.
      if (cells[0] && cells[0] !== td) out.period = text(cells[0]);
    } catch (_) { /* leave both blank */ }
    return out;
  }

  function describeCard(card) {
    // The card contains the dropdown content.js injected, and a <select>'s
    // textContent is every one of its options concatenated. Read from a clone
    // with the dropdown removed, or the description becomes the whole
    // curriculum.
    var clone;
    try {
      clone = card.cloneNode(true);
      clone.querySelectorAll('select, option, .Moeen-2-dashboard-select')
        .forEach(function (el) { el.remove(); });
    } catch (_) {
      clone = card;
    }

    var heading = clone.querySelector(
      'h2,h3,h4,[data-subject-name],.subject-name,.course-name'
    );
    var subject = text(heading) || card.getAttribute('data-subject-name') || '';

    // Whatever the card says besides the subject is the class name in practice
    // ("الاول بنات").
    var full = text(clone);
    var detail = subject ? full.replace(subject, '').trim() : full;

    // A card whose markup we guessed wrong can still yield something long;
    // truncate rather than let it push the native layout around.
    if (detail.length > 60) detail = detail.slice(0, 60).trim() + '…';

    return { subject: subject, detail: detail };
  }

  function harvest() {
    var selects = document.querySelectorAll(SELECT_SELECTOR);
    var seen = {};
    var lessons = [];

    Array.prototype.forEach.call(selects, function (select) {
      var token = select.getAttribute('data-lesson-token');
      // Madrasati renders responsive duplicates of the same card; content.js
      // keeps them in sync by token, so only the first needs reporting.
      if (!token || seen[token]) return;
      seen[token] = true;

      var card = select.closest('div[data-data]') || select.parentElement;
      if (!card) return;

      var options = [];
      Array.prototype.forEach.call(select.options, function (opt) {
        if (!opt.value) return; // the "اختر الدرس..." placeholder
        options.push({ value: opt.value, text: opt.textContent });
      });

      var info = describeCard(card);
      var where = positionOf(card);

      lessons.push({
        token: token,
        subject: info.subject,
        detail: info.detail,
        day: where.day,
        period: where.period,
        subjectId: card.getAttribute('data-subject-id') || '',
        selected: select.value || '',
        options: options
      });
    });

    var saveBtn = document.getElementById(SAVE_BUTTON_ID);

    return {
      ready: lessons.length > 0,
      lessons: lessons,
      counter: text(document.getElementById(COUNTER_ID)),
      status: text(document.getElementById(STATUS_ID)),
      canPrepare: !!(saveBtn && !saveBtn.disabled),
      // A panel with no save button means content.js stopped before rendering
      // it — an auth or subscription block the native UI needs to surface.
      panelPresent: !!document.getElementById('Moeen-2-dashboard-panel'),
      blockedMessage: text(
        document.querySelector('#hadar-subscription-exception .hadar-exception-card')
      )
    };
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Apply
  // ───────────────────────────────────────────────────────────────────────────

  /// Writes native selections into the dropdowns.
  ///
  /// Each write dispatches `change`, which is not cosmetic: content.js's own
  /// listener syncs duplicate cards, starts the AI prefetch for that lesson,
  /// and refreshes the counter that ungates the save button. Setting `.value`
  /// alone would leave the panel thinking nothing was chosen.
  window.__haderApplySelections = function (selections) {
    var applied = 0;
    if (!selections || typeof selections !== 'object') return { applied: 0 };

    document.querySelectorAll(SELECT_SELECTOR).forEach(function (select) {
      var token = select.getAttribute('data-lesson-token');
      if (!token || !Object.prototype.hasOwnProperty.call(selections, token)) return;

      var value = selections[token] || '';
      if (select.value === value) return;

      select.value = value;
      select.dispatchEvent(new Event('change', { bubbles: true }));
      applied++;
    });

    var saveBtn = document.getElementById(SAVE_BUTTON_ID);
    return { applied: applied, canPrepare: !!(saveBtn && !saveBtn.disabled) };
  };

  /// Clicks the panel's own save button — the automation stays content.js's.
  window.__haderStartPreparation = function () {
    var saveBtn = document.getElementById(SAVE_BUTTON_ID);
    if (!saveBtn) return { started: false, reason: 'no_button' };
    if (saveBtn.disabled) return { started: false, reason: 'disabled' };
    saveBtn.click();
    return { started: true };
  };

  window.__haderHarvest = function () { return harvest(); };

  // ───────────────────────────────────────────────────────────────────────────
  // Reporting
  // ───────────────────────────────────────────────────────────────────────────

  var lastSignature = '';

  function reportIfChanged() {
    var data;
    try {
      data = harvest();
    } catch (error) {
      return;
    }

    // Only the parts the native UI renders; ignoring the rest keeps a repainting
    // page from flooding the bridge.
    var signature = [
      data.lessons.length,
      data.counter,
      data.status,
      data.canPrepare,
      data.blockedMessage,
      data.lessons.map(function (l) { return l.token + ':' + l.selected; }).join(',')
    ].join('|');

    if (signature === lastSignature) return;
    lastSignature = signature;
    bridge('haderScheduleUpdate', data);
  }

  // content.js renders the panel and dropdowns asynchronously — it polls the
  // page every 1.5s for late cards — so this watches for as long as that can
  // still be happening, then backs off to a slow heartbeat.
  var ticks = 0;
  var fast = setInterval(function () {
    reportIfChanged();
    if (++ticks >= 40) {
      clearInterval(fast);
      setInterval(reportIfChanged, 3000);
    }
  }, 750);

  reportIfChanged();
})();
