# Mobile task: «✨ اكتب لي» in «تقرير لقاء أولياء الأمور»

## Why

The report editor already has the «✨ اكتب لي» box for role documents (`ReportRoleAiCard`). The backend now offers the same for the report designer's own templates. The first one is **«تقرير لقاء أولياء الأمور»** (`parents_meeting`). More templates can be turned on later from the backend config, with no app change.

The same change is going to the website: `docs/FRONTEND_TASK_REPORT_TEMPLATE_AI.md`.

## Backend API (on `main`, live after the backend deploy)

- **`GET /tools/reports`**: each template now has **`ai`** (`true` or `false`).
- **`GET /tools/reports/{key}`** now also returns:
  - **`ai`**;
  - **`brief_hint`**: the box's placeholder, or `null`.
- **The job:**

  ```
  POST /ai-jobs
  { "kind": "report_template",
    "input": { "template": "parents_meeting", "brief": "…", "gender": "male",
               "stage": "…", "grade": "…", "date": "…", "occasion": "…" } }
  ```

  - `template` and `brief` (≤ 600 characters) are required.
  - The other fields work as in `role_document`.
  - Don't send `role`, `doc`, `term` or `region`.
- **Polling, the result `{ title, meta, blocks }` and the merge** are exactly as for `role_document`.
- The error message for this kind is «تعذرت كتابة التقرير، حاول مرة أخرى.»

Details: `docs/DOCUMENTS_API.md`, section 12 «✨ اكتب لي».

## Changes in the app

1. **`lib/features/documents/data/models/ai_job_model.dart`**: add `static const String reportTemplate = 'report_template';` next to `roleDocument`.
2. **When a report opens from a template** (`reportTemplateApi(key)`), keep `ai` and `brief_hint`:
   - `canUseAi` becomes true when the template has `ai: true`;
   - `briefHint` is `brief_hint`.

   Do the same for a **saved** report whose `input.template` is a plain template key (not `role:…`): load the template and keep its `ai` and `brief_hint`.
3. **`ReportEditorCubit`, where it builds the payload and calls `aiRepo.start(AiJobKinds.roleDocument, …)`:**
   - a role document still sends `role_document` with `role` and `doc`, as today;
   - a template sends `AiJobKinds.reportTemplate` with `template: <the template key>`;
   - `brief`, `gender` and the optional fields are the same in both.

   Remove the `roleDoc == null` early return for this case.
4. **No change** to `ReportRoleAiCard`, the merge of the result, the undo button or the status banner.

## Test

1. Reports, then «تقرير لقاء أولياء الأمور». The «✨ اكتب لي» box shows with the example placeholder.
2. Write a short line about the meeting and set «الصف».
3. The report fills in:
   - goals, topics and «ما اتُّفق عليه» are written;
   - parents' notes contain only what was written in the box;
   - «الصف أو الفصل» is filled;
   - «عدد الحاضرين» and «المكان» stay empty.
4. Every field can still be edited, and undo works.
5. Save, reopen the report, and use the box again.
6. Another template, for example «تقرير ورشة عمل», has no box.
7. A role document still works as before.
