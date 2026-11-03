# Review: virtual lab in the app (`moeen-mobile` `f0daa29`, 2026-11-03)

**For:** Azza.
**Result:** very good work.

**What works, checked in the code:**
- the library;
- filters, search, sorting and paging;
- the experiment WebView on `?embed=1`, with the loader, the error view, links outside `/lab/` opening in the browser, and landscape on this screen only;
- share;
- the report sheet;
- the admin screen.

The admin screen already does what the site still misses: «تم» on requests and reports, and «موافقة» on community experiments (`{approve: true}`).

Four fixes follow, then a check on real phones.

## 1. The lesson chip is built but never shown
`LessonExperimentsChip` and `LabRepository.getLessonExperiments` exist, but no screen uses them.

**Fix:** where the teacher picks a lesson (preparation first):
1. call `GET /lessons/{id}/experiments`;
2. when it returns items, show `LessonExperimentsChip(count: items.length, lessonId: id, lessonTitle: …)`.

`MOBILE_TASK_LAB.md` §3.

## 2. No way to «أنشئ تجربة» or «اطلب تجربة»
The library screen has no entry for these two.

**Fix:** add two buttons to the library app bar (or a small menu) that open `https://haderedu.com/lab/create` and `https://haderedu.com/lab/request`.
- **If the app can pass the teacher's login to a site page in the WebView:** open them there.
- **If it can't:** open them in the phone's browser with `launchUrl(..., mode: LaunchMode.externalApplication)`.

`MOBILE_TASK_LAB.md` §3.

## 3. Admin experiments: only the first 100 show
`AdminLabRepository.getExperiments` asks for `per_page: 100` and never loads page 2. There are 167 experiments today: 127 published and 40 hidden scene experiments.

**Fix:** either
- load more on scroll from `meta.last_page`; or
- send `per_page: 200`, the server's maximum.

Also add a search field. The repository already supports `search`.

## 4. Each opening counts as 2 plays
- The app calls `POST /public/lab/experiments/{key}/play` when the WebView finishes loading (`LabExperimentCubit._recordPlayOnce`).
- The embed page calls it again after the first slider move.

So «الأكثر تشغيلًا» counts app openings double, even when nobody touched the experiment.

**Fix:** remove `_recordPlayOnce` and `playExperiment` from the app. The site already records the play once, after a real interaction.

## 5. Check on real phones
Do both on one Android phone and one iPhone:
- open `ohm` and `density`;
- move the sliders;
- turn the phone to landscape;
- send a report and check it appears in the admin screen;
- tap «تم» on it.
