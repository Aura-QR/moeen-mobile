# Mobile app task: «فصولي», AI suggestions, and the remedial and enrichment plans

The next two document tools in the Flutter app, plus two shared pieces. Everything the app needs from the backend is done.

**API references** (in `moeen-backend/docs/`):
- `DOCUMENTS_API.md` section 8: the two tools;
- `CLASSES_API.md`: «فصولي»;
- `AI_JOBS_API.md`: AI suggestions.

**Builds on** the strategy documentation task: `lib/features/documents/` (defaults screen, «مستنداتي», the upload helper, the export sheet). Reuse them.

**Release note:** «فصولي» stores student names. The owner must publish the privacy policy update **before** this ships to the stores. Build it now; release only after the owner confirms.

Estimated time: 5–7 days.

---

## 1. Shared pieces

### 1.1 «فصولي» (`lib/features/classes/`)
- **List screen** (`GET /classes`): name, grade and number of students; add; swipe or menu to delete, with a confirm: «سيتم حذف الفصل وجميع الأسماء نهائيًا».
- **Class screen:**
  - name, grade and subject;
  - the student list, with edit, delete and drag to reorder;
  - **«إضافة أسماء»:** a multiline field, one name per line, split on the device;
  - **«استيراد من Excel»:** `file_picker` (xlsx, xls, csv) → `POST /classes/import` (multipart `file`) → review the `names`, then append them;
  - save sends the whole list (`PUT` replaces it).
- Add «فصولي» to the home menu and the profile screen.

### 1.2 Student picker (bottom sheet)
- Choose a class from «فصولي»: its names load **all ticked**, and the teacher can untick some.
- Or type the names.
- Returns `class_id` and `students`.

### 1.3 Checklist section widget
- Ready options and AI options as checkboxes. AI options carry a «مقترح» chip.
- «إضافة بند آخر» adds a custom line, ticked; custom lines can be edited and deleted.
- The value is **only the ticked lines**, in order.

### 1.4 AI suggestions («اقترح من الدرس»)
1. `POST /ai-jobs { kind, input: { lesson_ids } }`.
2. On `200`, use `data.result` now. On `202`, show progress and poll `GET /ai-jobs/{id}` every 2 s, for up to 60 s.
3. On `done`, add each list in `result` to the section with the same key, as AI options.
4. On `failed`, show `error` and «إعادة المحاولة».
5. Handle `429` (limit reached) and `402` (no subscription) the same way the other AI features do.

Shown only when lessons are picked. Never untick or overwrite what the teacher chose.

---

## 2. T1 الخطة العلاجية (`lib/features/remedial_plan/`)
Options from `GET /tools/remedial`. One scrollable form:
1. **نوع الخطة:** مرتبطة بدروس / عامة.
2. **الدروس:** reuse the curriculum pickers; multi-select up to 5. Prefill subject and grade.
3. **البيانات:** المادة، الصف، الفصل، التاريخ، مدة الخطة. The header is read-only, with «تعديل لهذا المستند فقط».
4. **الطلاب:** the picker (1.2).
5. **«اقترح من الدرس»** (`remedial_suggestions`).
6. **Sections** `weaknesses`, `methods` and `actions` (1.3).
7. **مستوى التحسن:** single choice.
8. **ملاحظات**, **الشواهد** (camera or gallery, up to 6), **التصميم**.
9. **Actions:**
   - «حفظ» (`type: "remedial_plan"`);
   - «تصدير» (the export sheet);
   - «إضافة إلى ملف الإنجاز», preselecting `learner_results`.

## 3. T2 الخطة الإثرائية (`lib/features/enrichment_plan/`)
Same as T1, with options from `GET /tools/enrichment`, except:
- no نوع الخطة switch; lessons are optional;
- **الفئة المستهدفة** is a multi-select from `target_groups`, plus «أخرى»;
- 8 sections;
- the AI kind is `enrichment_suggestions`;
- no مستوى التحسن;
- `type: "enrichment_plan"`.

Strings go in `assets/translations/ar.json` and `en.json`. Code comments in English.

---

## Done when
- [ ] Classes: paste, Excel import, edit, reorder and delete work on Android and iOS.
- [ ] A linked remedial plan:
  - AI suggestions appear as unticked options;
  - only the ticked lines are exported;
  - the PDF shares to WhatsApp.
- [ ] The same lessons a second time give suggestions instantly.
- [ ] A general plan works without lessons.
- [ ] Reopening a plan restores custom and AI lines, ticked.
- [ ] «إضافة إلى ملف الإنجاز» works.
- [ ] `flutter analyze` is clean for the new features.
