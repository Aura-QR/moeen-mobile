# Mobile task: «الكشوف» (class sheets)

The same tool as on the website: the teacher picks a class from «فصولي» and a kind of sheet, and prints or shares it as PDF, Word or Excel. The backend is done.

**API reference:** `moeen-backend/docs/CLASS_SHEETS_API.md`.

**Reuse:** the document screens from the other tools (save, «مستنداتي», PDF with `Printing.convertHtml`, and the Word download) and the «فصولي» picker.

**Privacy:** no new data (names only).

Estimated time: 2–3 days.

---

## 1. Screens
1. **The kind:** 5 cards from `GET /tools/sheets`.
2. **The class:** «اختيار من فصولي», or «كشف فارغ» with a number of empty rows. Then المادة، الصف، الفصل الدراسي.
3. **The columns:** a reorderable list (`ReorderableListView`) where each column has a label and an optional «الدرجة» field (`max`, empty by default), plus «+ إضافة عمود» and «استعادة الافتراضي».
   - **Attendance:** a start date picker and the number of weeks (1–4) instead of columns.
   - **Daily follow-up:** a date field.
4. **Preview:** `POST /documents/preview` → `Printing.layoutPdf` / `PdfPreview` from the HTML.
5. **Save, PDF, Word, Excel:** Excel works like Word, with `format: "xlsx"`. Open or share the file with `share_plus`.

From the «فصولي» screen, add «طباعة كشف» to each class. It opens this screen with the class already picked.

Add the **Excel** button to **grade analysis** too.

## 2. Translations
Add every new string in both translation files, with keys like `sheets_*`.

## 3. Checklist
- [ ] A grade sheet for 25 students prints as one portrait page.
- [ ] A 2-week attendance sheet is landscape, with the right dates.
- [ ] A custom sheet with empty rows.
- [ ] Excel opens on the phone and can be shared.
- [ ] Reopening a saved sheet restores everything.
