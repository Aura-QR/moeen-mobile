# Flutter Task: Lesson Presentation — In-App Preview + Real .pptx Export

## Context

The web app already has a working pptx generator (`pptxgenjs` + `canvas` for
Arabic title rendering, three color themes, per-slide icons via Iconify).
The mobile app needs two separate things, and they have very different
levels of effort:

1. **In-app preview** (slides + icons as native widgets) — straightforward.
2. **Real `.pptx` file download from inside the app** — needs a decision,
   see below.

---

## Part 1: In-app preview (do this first, it's simple)

The `/presentation` API returns the same slide JSON the web app uses —
`order`, `type`, `title`, `body[]`, `icon_keyword`, `icon_id`. Build native
widgets that render this directly (cards/list per slide), no pptx
involved at all here.

### Icon package

Use **`iconify_design`** (pub.dev): it takes the `icon_id` string exactly
as the API returns it (e.g. `"mdi:family-tree"`) with no mapping needed on
your side — same identifier as the web app, so icons stay visually
consistent across platforms.

```dart
import 'package:iconify_design/iconify_design.dart';

IconifyIcon(
  icon: slide.iconId ?? 'lucide:sparkles', // same fallback as web
  size: 28.0,
  color: Colors.blueGrey,
  placeholder: const SizedBox(
    width: 28, height: 28,
    child: CircularProgressIndicator(strokeWidth: 2),
  ),
  errorWidget: const Icon(Icons.school_outlined), // generic fallback icon
)
```

`errorWidget` and `placeholder` give you the same "never show a broken
icon" safety net the web app has via its `.catch()` fallback.

### Offline behavior

Per the original plan, cache the downloaded slide JSON locally (e.g.
`shared_preferences` or a local db) so a teacher who already opened a
lesson can re-view it offline. Icons themselves are fetched over network
by `iconify_design` — if you want icons to also work offline after first
view, check whether `iconify_design_flutter` (the caching variant) fits
better, since it persists fetched SVGs locally after first load instead of
re-fetching every time.

---

## Part 2: Real `.pptx` export — the actual decision needed

There is no mature native-Dart library that can reproduce what the web
generator does (RTL Arabic title rendering via canvas + a custom font,
themed shapes, multi-column bullet layout). Rewriting all of that in Dart
from scratch would be a large duplicate effort **and** risks the mobile
file looking different from the web file for the same lesson. Two real
options:

### Option A (recommended): Hidden WebView running the existing JS code

Reuse the exact same `pptx-builder.ts` logic that already works on web,
unmodified, inside an invisible WebView inside the Flutter app.

**How it works:**
1. Package the existing web pptx-builder code (the file with
   `downloadPresentationPptx`) as a small standalone bundle — same code,
   just wrapped so it can run inside a bare WebView page instead of the
   full web app.
2. In Flutter, use **`flutter_inappwebview`** (better support than
   `webview_flutter` for large binary data transfer between JS and Dart)
   to load that bundle in an off-screen `InAppWebView`.
3. Flutter calls a JS function inside the WebView, passing the slide JSON
   + theme + lesson metadata (same inputs the web app already passes to
   `downloadPresentationPptx`).
4. Inside the WebView, `pptxgenjs`'s `writeFile` is swapped for
   `write("base64")` — instead of triggering a browser download, it
   returns the file as a base64 string.
5. The WebView sends that base64 string back to Flutter via a
   `JavascriptHandler` / `addJavaScriptHandler` channel.
6. Flutter decodes the base64, saves it with `path_provider` +
   `dart:io File`, then offers it via `open_filex` (open in the device's
   PowerPoint/Office app) or `share_plus` (share/save elsewhere).

**Why this is the better option:** zero visual drift between web and
mobile output (it's literally the same code), and no duplicate maintenance
— any future change to slide layout/themes only has to be made once.

**Tradeoff to flag to the team:** the WebView needs network access at
generation time (same as web) to fetch icons from Iconify and to load the
Arabic font if it isn't bundled locally — this is a real dependency, not
a nice-to-have, so make sure there's a friendly error message if the
device is offline when the teacher taps "Download."

### Option B: Server-side rendering (fallback if Option A proves too fiddly)

Laravel/n8n runs the same JS logic headlessly on the server (via a small
Node service using Puppeteer, since plain Node lacks the `canvas`/
`document.fonts` APIs the Arabic title trick needs) and the app just
downloads the finished binary from a URL.

This reintroduces the exact server-side rendering step + file storage the
plan had originally removed when we moved to client-side generation — so
only fall back to this if Option A turns out to be impractical
(e.g. WebView binary transfer proves unreliable on low-end Android
devices during testing). It has one advantage: the mobile app becomes a
"dumb downloader" with no JS/WebView complexity at all, at the cost of
server compute + storage coming back into the plan.

---

## What to build first, concretely

1. Ship **Part 1 (native preview)** immediately — it's independent of the
   export decision and unblocks the rest of the mobile UI.
2. Prototype **Option A** with one real lesson end-to-end (WebView → base64
   → saved file → opens correctly in a PowerPoint viewer on both Android
   and iOS) before committing to it across the app. If binary transfer
   through the WebView bridge is flaky on any target device, fall back to
   Option B rather than fighting it — don't lose more than a day or two
   confirming which path works before moving forward.

## Open question for you (Azza) to resolve with your own project setup

- Which WebView package is already in the project, if any (avoids adding
  a second WebView dependency if `flutter_inappwebview` isn't already a
  fit for other reasons)?
- Confirm the Tajawal font (used for the Arabic cover title) is loadable
  inside a WebView context — either bundled as a local asset served to the
  WebView, or loaded from Google Fonts if the device is online.
