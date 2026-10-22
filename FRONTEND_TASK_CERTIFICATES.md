# Website task: شهادات شكر (certificates, T3)

**For:** the website developer (Next.js, `Hader-frontend`).
**API:** `docs/DOCUMENTS_API.md` section 9, plus sections 2–4 (save, print, Word, and the new preview in 4.3).
**Copy from:**
- the plans page `src/app/tools/remedial-plan/page.tsx` (form, save, reopen, print, Word);
- `src/components/learning-plans/StudentPicker.tsx` (names);
- `listClasses` in `src/lib/api/learning-plans.ts` («فصولي»).

---

## What the teacher does (4 steps)
1. **Names:** pick a class from «فصولي», paste names (one per line), or import Excel. Each name has «معاينة» (preview) and «حذف» (remove).
2. **Design:** choose طلاب or طالبات, then one of the 6 designs.
3. **Data:** the reason (التفوق، حسن السلوك، …), and an optional date. School, teacher and principal come from the defaults.
4. **Text:** the title and the text, prefilled from the reason and editable, with `{name}` where the name goes. Then save, print everything as one PDF, or download Word.

## Build
**Route:** `/tools/certificates`. Add it next to the other tools in the navbar, the home page and «مستنداتي».

**API client:**
- `getCertificatesCatalogue()` → `GET /tools/certificates`.
- `previewDocument(type, input)` → `POST /documents/preview`.
- Create and save with `type: "certificates"`, the same way as the plans.

**Step 1, names:**
- Reuse `StudentPicker`, and add a class picker: `listClasses()`, then `GET /classes/{id}` → `students[].name`. Set `class_id` when a class is picked.
- Add an «استيراد من Excel» button: `POST /classes/import` with the file returns `names`. Show them for review before using them.
- Show the names as a list. Each row has:
  - «معاينة»: calls the preview with `names: [that name]` and shows the `html` in a modal `<iframe srcdoc>`, scaled to fit;
  - «حذف»: removes the name.
- Show the count. The limit is `limits.names` (80).

**Step 2, design:**
- Two buttons for the audience. Preselect from `resolved.gender_form`.
- A grid of the 6 designs. Each is an `<img src={design.image_url}>`; the images are public, so no token is needed.

**Steps 3 and 4, data and text:**
- When the reason or the audience changes, set `title` and `text` from the catalogue, **unless the teacher already edited them**. Add a «استعادة النص الافتراضي» link.
- The text box is limited to 300 characters. Show a hint: «اكتب {name} في مكان اسم الطالب».
- Add a «إدراج الاسم» button that inserts `{name}` at the cursor.
- Date: a date picker, default today. The Hijri date is added by the backend.

**Live preview:**
- Show the first certificate on the side or under the form: `POST /documents/preview` with the first name.
- Call it debounced (≈ 600 ms after the last change), not on every keystroke.

**Save, print and Word:** as for the plans.
- The print HTML already has one landscape page per name. Don't add print CSS.
- The website prints with the browser's print dialog, as for the other tools. Tell the teacher to choose «حفظ كـ PDF» and keep the landscape orientation the page sets.

**Reopen:** `GET /documents/{id}` returns `input`. Fill the four steps from it.

**Images (ZIP):** not in this task. The plan in API section 9 is waiting for the owner.

## Done when
- [ ] 40 names → one PDF with 40 landscape pages, made in under 60 s.
- [ ] A long four-part name stays on one line inside the design. A name with diacritics shows them.
- [ ] Changing the reason or audience updates the text only when the teacher hasn't edited it.
- [ ] «معاينة» shows the right name, and «حذف» removes it before saving.
- [ ] Word downloads with one page per name.
- [ ] Reopening from «مستنداتي» restores every step.
- [ ] Works on a phone-width screen and in dark mode (the certificates themselves stay light).
