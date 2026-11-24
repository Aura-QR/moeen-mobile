# Mobile task: the activities plan from the official guide (1448)

## Why

«خطة النشاط الطلابي» currently suggests activities we wrote ourselves. Activity leaders must use the **approved programs** of the National Curriculum Center's guide (دليل الخطط الدراسية – الإصدار السادس 1448).

The backend now builds the plan from the official list, one program per week. The website gets the same change: `docs/FRONTEND_TASK_ACTIVITIES_PLAN_OFFICIAL.md`. API details: `docs/BACKEND_TASK_ACTIVITIES_PLAN_OFFICIAL.md` §2.

**Start after the backend is on `main`.**

## Changes in `lib/features/activities_plan/`

### Models

- `activities_catalogue_model.dart`: read the new catalogue fields:
  - `bands`;
  - `programs` (by domain, with `periods` per band and `outside_hours`);
  - `extracurricular`;
  - `official_days`;
  - `ein_url`;
  - `layouts`.
- `activities_plan_input.dart`: add `layout` (`"official"`), `band` and `periods_per_week`.
  - New plans send `layout: "official"`.
  - `domains` is not sent for official plans.
- `activities_grid_model.dart`: read `summary`.
  - Cell keys for official plans: `domain`, `program`, `periods`, `extracurricular`, `occasion`.

### Form (`activities_settings_section.dart`, `activities_domains_section.dart`)

- New plans:
  - show a **band** picker (4 choices) and a **periods per week** stepper (1–6, prefilled with the band's default) in place of stage + domains;
  - hide `activities_domains_section` and `activities_domain_order_list`.
- Load the grid with `GET /tools/activities/plan?layout=official&band=…&term=…&region=…&periods_per_week=…`.

### Week card (`activities_week_card.dart`, `activities_cell_tile.dart`)

For an official plan, each teaching week shows:
- **المجال:** a picker of the 5 domains plus «الأيام والمناسبات».
- **البرنامج:** a picker of the official programs for the band and domain (programs with 0 periods hidden). The last item is «برنامج آخر معتمد محليًا…», which turns the field into free text.
- **الحصص:** a number. Prefill it with the program's periods when the program changes.
- **الفترات اللاصفية:** a picker of the 10 programs, empty by default.
- **المناسبات:** text, as today.

Holidays and exam weeks stay as today (`activities_holiday_tile.dart`). Send only changed cells, as today.

### Under the grid

- The **summary**: periods per domain, and the total against the term's available periods. Show a soft warning when a domain has 0 periods.
- A line «الفترات اللاصفية وفق الخطة الزمنية الموحدة على بوابة عين الإثرائية» that opens `ein_url` in the browser.

### Saved plans

A saved document whose `input` has no `layout` opens in today's screen, unchanged. Show a note with a button: «هذه خطة بالنسخة السابقة. أنشئ خطة جديدة وفق دليل 1448».

## Test

The same tests as the website task (`FRONTEND_TASK_ACTIVITIES_PLAN_OFFICIAL.md` → Test), on Android and iOS:
1. A new plan for الصفوف الأولية.
2. Overrides, then save and print.
3. Switching bands.
4. The Ein link.
5. An old saved plan.

## Order of work

1. Wait for the backend on `main`.
2. Models, then form, then week card, then summary, then old-plan note.
3. Ship with the next app version.
