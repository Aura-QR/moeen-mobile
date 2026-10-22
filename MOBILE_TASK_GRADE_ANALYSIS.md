# Mobile task: T7 «تحليل نتائج الطلاب»

The same tool as on the website: the teacher enters one test's grades and gets a report with statistics and charts. The backend is done.

**API reference:** `moeen-backend/docs/GRADE_ANALYSIS_API.md`. Read it first.

**Reuse:**
- the document screens from the strategy and remedial tasks (save, «مستنداتي», PDF with `Printing.convertHtml`, Word download, adding to the portfolio);
- the «فصولي» picker;
- the AI polling helper and the checklist widget.

**Release note:** ship only after the owner publishes the privacy update (`moeen-backend/docs/PRIVACY_GRADES_DRAFT.md`). That includes the new app privacy card `privacy_sec2_card8`.

Estimated time: 4–5 days.

---

## 1. Screens
**1. The report** (`GET /tools/grades`):
- سريع / مفصّل;
- the test details: المادة، الصف، الاختبار، التاريخ، **الدرجة الكلية**, and **درجة النجاح** (default 50% of the total);
- an «مستويات الأداء» expandable section.

**2. The classes** (1 to 5, one tab each, «+ فصل للمقارنة»):
- «اختيار من فصولي» fills the name and the student names.
- A list of rows. Each row has a name and a **number field** for the grade, using the numeric keyboard with decimals. Pressing «التالي» moves to the next student, so the teacher can type the grades quickly.
- An empty grade means «غائب».
- «رفع ملف Excel» opens `file_picker` and calls `POST /tools/grades/import`. Show the rows for review, and «تم أخذ الدرجات من عمود: …».
- In quick reports, names are optional. Add a «إدخال الدرجات فقط» mode: one grade per line.

**3. The results:**
- Call `POST /tools/grades/analyze` with a debounce of 600 ms.
- Show cards for the average, the pass rate, the highest and lowest grades, and the standard deviation.
- Show a band bar chart (`fl_chart` if it's already in the project; otherwise simple bars).
- With 2 or more classes, show a comparison with «الترتيب».

**4. «التوصيات»:**
- «اقترح توصيات» sends `POST /ai-jobs` with `{ kind: "grade_recommendations", input: ai_input }`, then polls.
- Show the suggestions as checkboxes marked «مقترح», not ticked, plus «إضافة توصية».

**5. Save, PDF, Word and the portfolio:** the same as the other tools (`type: "grade_analysis"`). The portfolio item is `results_analysis`.

**6. «حذف كل بيانات التحليل»:** a confirm dialog, then `DELETE /tools/grades/data`.

## 2. Translations
- Add every new string in **both** translation files, with keys like `grades_*`.
- **The «فصولي» translations are still missing.** Add them in the same release.

## 3. Checklist
- [ ] Quick report with grades only: the PDF is one page.
- [ ] Detailed report with 2 classes and one absent student.
- [ ] Excel import.
- [ ] Grades above the total are blocked, and the `422` from the backend shows.
- [ ] Reopening a saved report fills everything back in.
- [ ] Delete all.
- [ ] Small phones, and the keyboard doesn't hide the field being typed in.
