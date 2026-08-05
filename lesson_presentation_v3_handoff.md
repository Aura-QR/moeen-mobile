# Lesson Presentation — Backend & Frontend Changes

## Backend (Laravel)

Accept 2 new optional fields in the lesson-creation request and forward them **unchanged** to the n8n webhook, alongside the existing fields:

```json
{
  "include_random_picker": true,
  "student_names": ["Ahmed", "Sara", "Faisal"]
}
```

- `include_random_picker`: boolean, optional, default `false`.
- `student_names`: array of non-empty strings, optional, default `[]`.
- If `include_random_picker` is `true` but `student_names` is empty, no picker slide is produced — validate loosely, no error needed.

No other backend changes.

---

## Frontend (`moeen_front`)

### 1. New UI in lesson-creation form
- Toggle: **"Enable random student picker"**.
- When enabled, show a field to enter/select student names.
- Send `include_random_picker` + `student_names` with the create-lesson request.

### 2. `src/lib/presentations/presentation-pptx.ts` — two edits

**a) `getSlideLabel()` — add the new slide-type labels:**
```ts
function getSlideLabel(type: string) {
  const labels: Record<string, string> = {
    title: "عنوان الدرس",
    static_opening: "افتتاحية",
    static_greeting: "ترحيب",
    static_dua: "دعاء اليوم",
    static_classroom_rules: "قواعد الصف",
    static_success_criteria: "محققات النجاح",
    lesson_info: "معلومات الدرس",
    kwl_open: "ماذا نعرف",
    vocabulary: "مفردات الدرس",
    hook: "تمهيد الدرس",
    random_picker: "اختيار عشوائي",
    content: "شرح الدرس",
    cross_curricular: "الربط بالمواد الأخرى",
    reading_stages: "مراحل القراءة",
    closing_strategy: "استراتيجية الإغلاق",
    worksheet: "ورقة عمل",
    kwl_close: "ماذا تعلمنا",
    homework: "الواجب المنزلي",
  };
  return labels[type] || "محتوى تعليمي";
}
```

**b) `addContentSlide()` — add a dedicated grid layout for `random_picker` instead of letting it fall into the generic bullet layout.**

Add this new function anywhere near `addBulletColumns`:
```ts
function addNameGrid(
  slide: pptxgen.Slide,
  names: string[],
  theme: Theme,
) {
  const normalized = names.filter(Boolean);
  const columns = 4;
  const gap = 0.2;
  const areaX = 0.78;
  const areaY = 1.6;
  const areaW = 11.75;
  const areaH = 4.9;

  const rows = Math.ceil(normalized.length / columns) || 1;
  const cardW = (areaW - gap * (columns - 1)) / columns;
  const cardH = Math.min(
    1.1,
    (areaH - gap * (rows - 1)) / rows,
  );

  normalized.forEach((name, i) => {
    const col = i % columns;
    const row = Math.floor(i / columns);
    const cardX = areaX + col * (cardW + gap);
    const cardY = areaY + row * (cardH + gap);

    slide.addShape("roundRect", {
      x: cardX,
      y: cardY,
      w: cardW,
      h: cardH,
      rectRadius: 0.1,
      fill: { color: theme.soft },
      line: { color: theme.accent, width: 1.2 },
    });

    slide.addText(name, {
      x: cardX,
      y: cardY,
      w: cardW,
      h: cardH,
      fontFace: "Arial",
      fontSize: 16,
      bold: true,
      color: theme.accentDark,
      align: "center",
      valign: "middle",
      rtlMode: true,
      fit: "shrink",
    });
  });
}
```

Then update the branching in `addContentSlide()`:
```ts
if (item.type === "example") {
  // ...existing example branch, unchanged
} else if (item.type === "quiz_prompt" || item.type === "summary") {
  // ...existing full-width bullets branch, unchanged
} else if (item.type === "random_picker") {
  addNameGrid(slide, item.body, theme);
} else {
  // ...existing default branch, unchanged — used by all other new types
  // (lesson_info, kwl_open, vocabulary, hook, content, cross_curricular,
  // reading_stages, closing_strategy, worksheet, kwl_close, homework,
  // and all static_* slides)
}
```

That's it — no other file needs to change. All other new slide types already render correctly through the existing default branch; only `random_picker` needed its own layout.
