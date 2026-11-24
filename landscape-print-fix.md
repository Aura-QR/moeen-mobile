# Fix: Landscape documents print in portrait

## Problem

`printPdf` in `document_file_service.dart` calls `Printing.layoutPdf` without specifying the page orientation, so it always falls back to A4 portrait.

## Fix

1. In `_print()` in `document_export_cubit.dart`, pass `landscape: page.isLandscape` (the same way it is already done for `htmlToPdf`).
2. In `printPdf`, add the following:

```dart
await Printing.layoutPdf(
  format: landscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4,
  onLayout: (_) async => bytes,
  name: safeFileName(name),
);
```

## Impact

This fixes printing for **all** landscape documents (the activity plan, the rosters, the learning outcomes map, and so on), not just the activity plan.
