# Website task: «حقائب الأدوار» (role suites, L1)

**For:** the website developer (Next.js, `Hader-frontend`).
**API:** `docs/DOCUMENTS_API.md` section 13, built on section 12 (T8). The AI flow is in `docs/AI_JOBS_API.md`.
**Build no new editor.** Every document opens in the T8 report editor (`FRONTEND_TASK_REPORTS.md`), and certificates open in the T3 form. This task is the catalogue screens, a brief box and the sensitive-form mode.

---

## 1. Menu entry
- Add **«حقائب الأدوار»** to the tools menu, next to the other document tools.
- **Route:** `/tools/roles`.

## 2. Role cards
- Load `GET /tools/roles` and show **4 cards**, with `label` and «N مستند» (`documents_count`).
- If the teacher's portfolio role is one of these, show that card first:
  - `activity_leader` ↔ portfolio `activity_leader`;
  - `health_guide` ↔ `health_guide`;
  - `student_counsellor` ↔ portfolio `student_counselor`.

## 3. A role's documents
**Route:** `/tools/roles/[role]`.
- Load `GET /tools/roles/{role}`. Show the categories as sections or tabs, with a list of documents in each.
- **Each document row shows:**
  - the label;
  - a small «✨» badge when `ai` is true;
  - a grey **«نموذج للطباعة والتعبئة باليد»** tag when `sensitive` is true.
- Add a search box that filters the labels on the page.
- **«فتح»** on a row loads `GET /tools/roles/{role}/{doc}`, then:
  - **`type: "report"`:** open the T8 editor with `input` as its state, exactly like a T8 template, at `/reports/evidence/new?role={role}&doc={doc}`. Keep `term` and `region` from the response for the AI call (section 4).
  - **`type: "certificates"`:** open the T3 form with `input` (reason, design, title, text). The teacher adds the names from «فصولي» as usual. Save with `POST /documents { type: "certificates", input, element }`, sending `element` from the response.
- Saved documents appear in «مستنداتي» and in the reports list (`GET /documents?type=report`) like any report. No list per role is needed in v1.

## 4. «✨ اكتب لي» in the editor (only when `ai` is true)
Use the place left for the disabled «أنشئ بالذكاء الاصطناعي» button in T8, and turn it on for role documents only.

**The box above the blocks:**
- a textarea with `brief_hint` as its placeholder, at most 600 characters, with a counter;
- under it, in small text: «لا تكتب أسماء الطلاب أو بياناتهم.»;
- optional small fields: المرحلة، الصف، التاريخ، المناسبة, sent as `stage`, `grade`, `date`, `occasion`;
- the **«✨ اكتب لي»** button.

**On click:**
1. Send `POST /ai-jobs { kind: "role_document", input: { role, doc, brief, stage?, grade?, date?, occasion?, gender: defaults.gender_form, term?, region? } }`. `term` and `region` are the ones from the opened document (weekly plans).
2. Poll `GET /ai-jobs/{id}` every 2 seconds, for up to 90 seconds, with a «جارٍ الكتابة…» state on the box.
3. On `done`, merge `result` into the open document:
   - replace `title` and `blocks` with the result's;
   - **meta rows and `kv` pairs:** take the result's value, but where it's empty keep the value the teacher already typed (match by label);
   - **photos:** keep the paths the teacher already placed in an images block. Copy each images block's `items` into the result's images block in the same position;
   - signatures, theme and the photos panel don't change.
4. Show «راجع النص وعدّل ما تحتاجه قبل الحفظ.» and leave the document unsaved until the teacher saves or autosave runs. Offer **«تراجع»** to restore the state from before the merge.
5. **On `failed`:** show `error` and a retry button (the same POST).
6. **On `429`:** show the message from the response (the daily or monthly AI limit).

## 5. Sensitive forms (`sensitive: true`)
- A banner at the top: **«نموذج للطباعة والتعبئة باليد. لا تُحفظ فيه بيانات الطلاب.»**
- **Hide** «✨ اكتب لي» and the photos panel.
- Make table cells and field values read-only. The teacher can still:
  - change rows and columns: add or remove empty rows, rename a column;
  - rename field labels and headings;
  - print it.
- The server empties anything typed anyway (API section 13). Read-only cells keep the teacher from typing something that disappears on save.

## 6. Member lists and sign-in sheets (`names_column` is set)
- Add a **«من فصولي»** button above the table. It opens the existing «فصولي» picker.
- The chosen names fill column `names_column`, one per row, from the first empty row. Add rows if needed (≤ 40).
- Names can also be typed. Never offer importing from Madrasati here.

## Done when
- [ ] The 4 roles and all their documents open in the T8 editor, save without editing, print and download as Word.
- [ ] Certificates open in T3 with the role's wording and save with the response's `element`.
- [ ] An AI document fills from a one-line brief in under 60 seconds. It keeps the teacher's typed fields and placed photos, and can be edited and undone.
- [ ] A weekly plan shows 18 week rows with dates. After «✨ اكتب لي», the week numbers and dates are unchanged.
- [ ] A sensitive form shows the banner, has no AI, and prints as an empty grid.
- [ ] Names from «فصولي» fill a club member list.
