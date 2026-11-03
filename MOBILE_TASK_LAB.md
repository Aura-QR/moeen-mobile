# Mobile task: the virtual lab «معمل حضر الافتراضي» (L8)

**For:** the mobile developer.
**Read first:** `docs/LAB_TASK_BACKEND.md` §1 and §5, and `docs/FRONTEND_TASK_LAB.md` §3.

## 1. What it is
Interactive science experiments linked to our lessons. The student moves sliders, and the numbers and a chart change live. **No AI, and no login needed to open an experiment.**

**Don't rebuild the engine in Flutter.** The site draws every experiment at `https://haderedu.com/lab/{key}?embed=1`, a page with the engine only. The app shows that page in a WebView, so any fix on the site reaches the app at once.

Start after the site's `/lab/[key]?embed=1` is live.

## 2. Screens (`lib/features/lab/`)

### Library screen «معمل حضر الافتراضي»
- Native list from `GET /public/lab/experiments` (24 per page, load more on scroll).
- **Filters:** stage → grade → subject chips from `GET /public/lab/filters`, plus a search field (`q`).
- **Sort:** «الأكثر تشغيلًا» / «الاسم».
- **Card:** name, area, «يرتبط بـ n دروس». Show a grey «تقريبي» tag when `approximate` is true.
- Opening the screen with a `lessonId` argument filters by `lesson_id`.

### Experiment screen
- App bar:
  - the experiment name;
  - a **share** button with `https://haderedu.com/lab/{key}`, to send to students;
  - «أبلغ عن خطأ», a bottom sheet with a text field (≤ 500) → `POST /lab/experiments/{key}/reports` with the teacher's token. Show «شكرًا، سنراجعها» on 2xx.
- **Body:** `flutter_inappwebview` (already in `pubspec`) on `https://haderedu.com/lab/{key}?embed=1`.
  - Show a loader until the first load ends.
  - On a load error: «تعذر فتح التجربة، تحقق من الاتصال» and «إعادة المحاولة».
  - Keep navigation inside the WebView limited to `haderedu.com/lab/`. Open any other link in the browser.
  - Allow landscape on this screen only, for the board.

## 3. Entry points
- Home: a chip «معمل حضر الافتراضي» next to the other tools.
- «أنشئ تجربة» and «اطلب تجربة» open the site pages `/lab/create` and `/lab/request` in the same WebView, with the teacher logged in. Check first whether the app can pass the teacher's login to a site page in a WebView. If it can't, open these two pages in the phone's browser instead.
- **Where the teacher picks a lesson** (preparation first): if `GET /lessons/{id}/experiments` returns items, show «🧪 تجارب تفاعلية (n)». It opens the library filtered by that lesson.

## 4. Done when
- [ ] The library loads, filters, searches and pages.
- [ ] An experiment opens in the WebView, moves smoothly, and works in landscape.
- [ ] Share sends the public link, and the report reaches the admin.
- [ ] The lesson chip appears on preparation when the lesson has experiments.
- [ ] Tried on a real Android phone and a real iPhone.
