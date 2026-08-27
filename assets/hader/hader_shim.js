/*
 * hader_shim.js — Chrome Extension API shim for the in-app WebView.
 *
 * The Hader browser extension talks to Chrome through `chrome.runtime`,
 * `chrome.storage` and a background service worker. Inside the app there is no
 * extension host, so this file recreates that surface on top of the
 * flutter_inappwebview JavaScript bridge.
 *
 * content.js is copied from the extension verbatim and must keep working
 * untouched, so every API it reaches for is implemented here with the same
 * shape and the same callback semantics.
 *
 * Injection order (see HaderWebViewScreen):
 *   1. seed script  — defines window.__HADER_SEED__
 *   2. hader_shim.js (this file)
 *   3. constants.js
 *   4. content.js
 *
 * Runs at document start in every frame, because content.js drives the lesson
 * form inside a hidden same-origin iframe.
 */
(function () {
  'use strict';

  if (window.__HADER_SHIM_READY__) return;
  window.__HADER_SHIM_READY__ = true;

  var SEED = window.__HADER_SEED__ || {};
  var DEBUG = SEED.debug === true;

  function log() {
    if (!DEBUG) return;
    try {
      console.log.apply(console, ['[HaderShim]'].concat([].slice.call(arguments)));
    } catch (_) { /* console may be unavailable in some frames */ }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Flutter bridge
  //
  // At document start the bridge object may not be installed yet, so calls are
  // parked until it appears rather than failing. Without this the very first
  // storage read — which gates the whole boot chain — can be lost.
  // ───────────────────────────────────────────────────────────────────────────
  var pendingBridgeCalls = [];
  var bridgeReady = false;

  function flushBridgeQueue() {
    if (!window.flutter_inappwebview || !window.flutter_inappwebview.callHandler) return;
    bridgeReady = true;
    var queued = pendingBridgeCalls;
    pendingBridgeCalls = [];
    queued.forEach(function (entry) {
      invokeBridge(entry.name, entry.payload, entry.resolve, entry.reject);
    });
  }

  function invokeBridge(name, payload, resolve, reject) {
    try {
      var result = window.flutter_inappwebview.callHandler(name, payload);
      Promise.resolve(result).then(resolve, reject);
    } catch (error) {
      reject(error);
    }
  }

  function bridge(name, payload) {
    return new Promise(function (resolve, reject) {
      if (bridgeReady || (window.flutter_inappwebview && window.flutter_inappwebview.callHandler)) {
        bridgeReady = true;
        invokeBridge(name, payload, resolve, reject);
        return;
      }
      pendingBridgeCalls.push({ name: name, payload: payload, resolve: resolve, reject: reject });
    });
  }

  if (!(window.flutter_inappwebview && window.flutter_inappwebview.callHandler)) {
    // v6 fires this once the bridge is installed; the interval is a fallback for
    // frames where the event does not reach us.
    window.addEventListener('flutterInAppWebViewPlatformReady', flushBridgeQueue);
    var bridgeWatch = setInterval(function () {
      if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
        clearInterval(bridgeWatch);
        flushBridgeQueue();
      }
    }, 30);
    setTimeout(function () { clearInterval(bridgeWatch); }, 15000);
  } else {
    bridgeReady = true;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Storage
  //
  // chrome.storage is callback-based and content.js reads it inside polling
  // loops that run every second, so reads are served synchronously from an
  // in-memory mirror. The mirror is seeded by Dart before this file runs, which
  // is what lets the auth check at content.js boot succeed on the first pass.
  // Writes update the mirror immediately and persist to Dart in the background.
  // ───────────────────────────────────────────────────────────────────────────
  function makeArea(areaName, initial) {
    var store = initial && typeof initial === 'object' ? initial : {};

    function persist() {
      bridge('haderStorageSet', { area: areaName, data: store }).catch(function (error) {
        log('persist failed', areaName, error);
      });
    }

    function selectKeys(keys) {
      var out = {};
      if (keys === null || keys === undefined) {
        for (var all in store) {
          if (Object.prototype.hasOwnProperty.call(store, all)) out[all] = store[all];
        }
        return out;
      }
      if (typeof keys === 'string') {
        if (Object.prototype.hasOwnProperty.call(store, keys)) out[keys] = store[keys];
        return out;
      }
      if (Array.isArray(keys)) {
        keys.forEach(function (key) {
          if (Object.prototype.hasOwnProperty.call(store, key)) out[key] = store[key];
        });
        return out;
      }
      if (typeof keys === 'object') {
        // Object form supplies defaults for missing keys.
        Object.keys(keys).forEach(function (key) {
          out[key] = Object.prototype.hasOwnProperty.call(store, key) ? store[key] : keys[key];
        });
        return out;
      }
      return out;
    }

    // Callbacks are deferred to a microtask so callers never re-enter
    // synchronously — chrome dispatches these asynchronously too, and content.js
    // relies on that ordering when it wraps them in promises.
    function done(callback, value) {
      if (typeof callback !== 'function') return;
      Promise.resolve().then(function () {
        chromeShim.runtime.lastError = undefined;
        try {
          callback(value);
        } catch (error) {
          log('storage callback threw', error);
        }
      });
    }

    return {
      get: function (keys, callback) {
        var value = selectKeys(keys);
        done(callback, value);
        return Promise.resolve(value);
      },
      set: function (data, callback) {
        if (data && typeof data === 'object') {
          Object.keys(data).forEach(function (key) { store[key] = data[key]; });
          persist();
        }
        done(callback, undefined);
        return Promise.resolve();
      },
      remove: function (keys, callback) {
        var list = Array.isArray(keys) ? keys : [keys];
        list.forEach(function (key) { delete store[key]; });
        persist();
        done(callback, undefined);
        return Promise.resolve();
      },
      clear: function (callback) {
        Object.keys(store).forEach(function (key) { delete store[key]; });
        persist();
        done(callback, undefined);
        return Promise.resolve();
      },
      // Exposed for the shim's own bookkeeping, not part of the chrome API.
      __raw: function () { return store; }
    };
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Lesson database
  //
  // Ported from the extension's background.js so subject lookups resolve
  // identically. The JSON is pulled from Flutter assets once, on first use.
  // ───────────────────────────────────────────────────────────────────────────
  var dbCache = {
    courses: [],
    templates: null,
    flatTemplates: null,
    bySubjectId: new Map(),
    bySubjectName: new Map(),
    isLoaded: false,
    loading: null
  };

  function normalizeSubjectName(raw) {
    if (!raw) return '';
    return String(raw)
      .replace(/[ً-ْٰـ]/g, '') // diacritics + tatweel
      .replace(/[إأآا]/g, 'ا')
      .replace(/ى/g, 'ي')
      .replace(/ة/g, 'ه')
      .replace(/\s+/g, ' ')
      .trim()
      .toLowerCase();
  }

  function extractSubjectName(course) {
    var list = course && course.rawLessonsList;
    if (!Array.isArray(list) || !list.length) return '';
    var head = (list[0].name || '').split(' -- ')[0];
    return head.trim();
  }

  function buildSubjectIndex(courses) {
    var byId = new Map();
    var byName = new Map();
    courses.forEach(function (course) {
      if (!course || course.subjectId == null) return;
      byId.set(String(course.subjectId), course);
      var name = extractSubjectName(course);
      if (name) byName.set(normalizeSubjectName(name), course);
    });
    return { byId: byId, byName: byName };
  }

  function flattenTemplates(raw) {
    var flat = {};
    var sections = raw && raw.lesson_plan_sections;
    if (sections && typeof sections === 'object') {
      Object.keys(sections).forEach(function (key) {
        var tpls = sections[key] && sections[key].templates;
        flat[key] = Array.isArray(tpls) ? tpls.slice() : [];
      });
    }
    return flat;
  }

  function loadDatabases() {
    if (dbCache.isLoaded) return Promise.resolve();
    if (dbCache.loading) return dbCache.loading;

    dbCache.loading = bridge('haderLoadDatabase', {})
      .then(function (payload) {
        var data = typeof payload === 'string' ? JSON.parse(payload) : (payload || {});
        // Dart hands over the raw asset text and lets the engine's own parser do
        // the work, so the 1.6 MB course file is never decoded twice.
        dbCache.courses = data.coursesJson ? JSON.parse(data.coursesJson) : [];
        // Templates only improve generated wording — a missing file must not
        // take lesson lookup down with it.
        dbCache.templates = data.templatesJson
          ? JSON.parse(data.templatesJson)
          : { lesson_plan_sections: {} };
        var idx = buildSubjectIndex(dbCache.courses);
        dbCache.bySubjectId = idx.byId;
        dbCache.bySubjectName = idx.byName;
        dbCache.flatTemplates = flattenTemplates(dbCache.templates);
        dbCache.isLoaded = true;
        log('database loaded', dbCache.courses.length, 'subjects');
      })
      .catch(function (error) {
        log('database load failed', error);
        dbCache.loading = null;
        throw error;
      });

    return dbCache.loading;
  }

  function findCourse(msg) {
    var course = null;
    if (msg.subjectId && msg.subjectId !== 'null') {
      course = dbCache.bySubjectId.get(String(msg.subjectId)) || null;
    }
    if (!course && msg.subjectName) {
      var searchName = normalizeSubjectName(msg.subjectName);
      course = dbCache.courses.find(function (c) {
        var cName = '';
        if (Array.isArray(c.groups) && c.groups.length > 0) {
          var firstHead = c.groups[0];
          var firstLesson = null;
          if (Array.isArray(firstHead)) {
            firstLesson = firstHead.find(function (l) { return l && l.info && l.info.name; });
          } else if (firstHead && firstHead.info) {
            firstLesson = firstHead;
          }
          if (firstLesson && firstLesson.info && firstLesson.info.name) {
            cName = normalizeSubjectName(firstLesson.info.name.split('--')[0]);
          }
        }
        if (!cName && c.rawLessonsList && c.rawLessonsList.length > 0 && c.rawLessonsList[0].name) {
          cName = normalizeSubjectName(c.rawLessonsList[0].name.split('--')[0]);
        }
        return cName && (cName.indexOf(searchName) !== -1 || searchName.indexOf(cName) !== -1);
      }) || null;
    }
    return course;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Message router — the in-page stand-in for background.js
  // ───────────────────────────────────────────────────────────────────────────

  // Mirrors the extension's per-tab running flag. A single WebView is a single
  // tab, so one in-memory value is enough.
  var automationRunning = false;

  function routeMessage(msg) {
    if (!msg) return Promise.resolve(undefined);

    var action = msg.action;
    var type = msg.type;

    if (action === 'GET_LESSON_DATA') {
      return loadDatabases()
        .then(function () { return { ok: true, data: findCourse(msg) }; })
        .catch(function (error) { return { ok: false, error: String(error) }; });
    }

    if (action === 'GET_TEMPLATES') {
      return loadDatabases()
        .then(function () { return { ok: true, data: dbCache.templates }; })
        .catch(function (error) { return { ok: false, error: String(error) }; });
    }

    if (action === 'GET_SUBSCRIPTION_CURRENT') {
      // Proxied through Dart: a request to api.haderedu.com from the
      // madrasati.sa origin would be blocked by CORS, which is the same reason
      // the extension routes it through its service worker.
      return bridge('haderApi', {
        method: 'GET',
        path: '/subscription/current'
      });
    }

    if (action === 'LOG_LESSON_PREPARATION') {
      return bridge('haderApi', {
        method: 'POST',
        path: '/lesson-preparations/log',
        body: msg.payload || {}
      });
    }

    if (action === 'PUSH_MADRASATI_SESSION') {
      // In the extension this forwards cookies to an open Moeen web tab. Here
      // the app itself is the consumer, so hand them to Dart instead.
      return bridge('haderMadrasatiSession', {
        session_cookie: msg.session_cookie || '',
        madrasati_school_id: msg.madrasati_school_id || ''
      }).then(function () {
        return { success: true };
      }).catch(function () {
        return { success: false };
      });
    }

    if (type === 'AUTOMATION_STATUS') {
      automationRunning = msg.status === 'START';
      bridge('haderAutomationStatus', {
        status: msg.status || 'STOP',
        detail: msg.detail || null
      }).catch(function () { /* status reporting is best-effort */ });
      return Promise.resolve({ success: true });
    }

    if (type === 'STATUS') {
      automationRunning = !!msg.running;
      return Promise.resolve({ success: true });
    }

    if (type === 'GET_RUNNING') {
      return Promise.resolve({ running: automationRunning });
    }

    log('unhandled message', msg);
    return Promise.resolve(undefined);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // chrome namespace
  // ───────────────────────────────────────────────────────────────────────────
  var messageListeners = [];

  var chromeShim = {
    runtime: {
      // content.js gates every storage call on `chrome.runtime?.id` being
      // truthy as its "is the extension context still alive" probe.
      id: SEED.runtimeId || 'hader-inapp-webview',
      lastError: undefined,

      getURL: function (path) {
        var clean = String(path || '').replace(/^\/+/, '');
        var assets = SEED.assets || {};
        if (assets[clean]) return assets[clean];
        log('getURL miss', clean);
        return '';
      },

      sendMessage: function (message, callback) {
        var promise = routeMessage(message);
        if (typeof callback === 'function') {
          promise.then(function (response) {
            chromeShim.runtime.lastError = undefined;
            try {
              callback(response);
            } catch (error) {
              log('sendMessage callback threw', error);
            }
          }, function (error) {
            chromeShim.runtime.lastError = { message: String(error && error.message ? error.message : error) };
            try {
              callback(undefined);
            } finally {
              // Cleared on the next microtask so the callback can read it, the
              // same window Chrome gives extension code.
              Promise.resolve().then(function () { chromeShim.runtime.lastError = undefined; });
            }
          });
        }
        return promise;
      },

      onMessage: {
        addListener: function (fn) {
          if (typeof fn === 'function') messageListeners.push(fn);
        },
        removeListener: function (fn) {
          var i = messageListeners.indexOf(fn);
          if (i !== -1) messageListeners.splice(i, 1);
        },
        hasListener: function (fn) {
          return messageListeners.indexOf(fn) !== -1;
        }
      }
    },

    storage: {
      local: makeArea('local', SEED.storageLocal),
      sync: makeArea('sync', SEED.storageSync)
    }
  };

  // Dart-initiated dispatch into the page (mirrors chrome.tabs.sendMessage).
  window.__haderDispatch = function (message) {
    messageListeners.forEach(function (fn) {
      try {
        fn(message, { id: chromeShim.runtime.id }, function () { /* responses unused from Dart */ });
      } catch (error) {
        log('listener threw', error);
      }
    });
  };

  // Chromium already defines window.chrome on the page, so extend it rather
  // than replacing it — clobbering it would break the host site's own checks.
  if (window.chrome && typeof window.chrome === 'object') {
    try {
      window.chrome.runtime = chromeShim.runtime;
      window.chrome.storage = chromeShim.storage;
    } catch (_) {
      window.chrome = chromeShim;
    }
  } else {
    window.chrome = chromeShim;
  }

  // content.js reads its config off globalThis before the shim's consumers run.
  window.__HADER_IN_APP__ = true;

  log('ready', {
    frame: window === window.top ? 'top' : 'sub',
    href: window.location.href
  });
})();
