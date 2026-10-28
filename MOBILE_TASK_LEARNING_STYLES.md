# Mobile task: «أنماط التعلم» learning styles (L3), teacher side

**For:** the mobile developer.
**API:** `docs/LEARNING_STYLES_API.md`. Students answer on the **website** link (`/s/{token}`), so the app has the teacher side only.

> **The privacy text is approved** (`docs/PRIVACY_LEARNING_STYLES_DRAFT.md`, 2026-10-27). Add it to the app's privacy screen in the same release.

## Screens
1. **List:** `GET /learning-styles`, from a home chip «أنماط التعلم».
2. **New survey:** the title, the version (٤–١٢ / ١–٣), classes from «فصولي» or typed names, a statements preview (`GET /learning-styles/options`), then `POST /learning-styles`.
3. **Share:** per class, the link and QR (from `qr`), share sheet, save QR to gallery, and open/close (`PATCH { is_open }`).
4. **Results:** `GET …/results`: a chart of `percents` with a class filter, the students per class («يميل إلى {leaning}», swipe to delete), and the strategy cards.
5. **Report:** `POST …/report`, then the existing document PDF and Word flow.
6. The note «النتائج ميول وتفضيلات، وليست تصنيفًا ثابتًا للطالب» on the results screen.

Add the Arabic and English translation keys, and cubit tests like the online tests ones.

## Check
- [ ] Create → share → answer from a phone browser → results update after a refresh → report PDF, on a real phone.
