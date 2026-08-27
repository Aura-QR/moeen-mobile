# Madrasati stand-in schedule page

Madrasati is geo-restricted to Saudi Arabia, so the injected automation cannot
be exercised against the real site from outside it. This page stands in for the
schedule during development.

It is built from the real page's markup, not invented, because two bugs already
reached a teacher's device by being invisible to a simplified stand-in:

- **The viewport tag.** Madrasati ships
  `<meta name="viewport" content="width=device-width, ...">`. Ours is injected
  at document start, so the page's tag is parsed afterwards and lands later in
  `<head>` — and the engine honours the last viewport tag. The desktop table
  rendered at 1:1 on a 402px screen. The earlier stand-in carried no viewport
  tag at all, so ours was unopposed and the bug could not appear.

- **Site chrome.** The header, nav and footer that the mobile polish reclaims
  space from did not exist in the first version of this page.

Madrasati is a Bootstrap 5 app, so the desktop schedule is gated behind the `lg`
breakpoint (992px). That gate is reproduced here: `.schedule-desktop` is hidden
below 992px. It is the reason the layout viewport has to clear 992 — at
WebKit's legacy 980px desktop default it misses by 12px.

## Running against it

```sh
cd test/fixtures/madrasati && python3 -m http.server 8899
flutter run --dart-define=HADER_URL=http://127.0.0.1:8899/schedule.html
```

The page logs two probes to the console, which `flutter run` prints:

- `MADRASATI_READY` at DOMContentLoaded — the moment Madrasati's own scripts
  read `window.innerWidth`. Check `innerWidthAtReady` is 1280 and
  `viewportTags` is 1.
- `REALMOCK` after content.js has settled — check the cards and dropdowns were
  found.

## Still missing

The lesson cards here match the selectors `content.js` looks for
(`td.day-cell div[data-data]`, `data-subject-id`), but the real page's card
markup has not been seen. If a harvest goes wrong on a real device, copy the
schedule table's `outerHTML` from a desktop browser into this file.
