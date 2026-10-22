/// Leading numbering such as «1.», «٢-», «3)» or «4 ـ».
final RegExp _numbering = RegExp(r'^[0-9٠-٩]+\s*[.\-)ـ:]\s*');

/// Splits pasted text into names, one per line, cleaned the way the API
/// cleans them: numbering and empty lines dropped, spaces trimmed.
/// Duplicates are kept, since two students can share a name.
List<String> splitStudentNames(String text) => text
    .split(RegExp(r'\r?\n'))
    .map((line) => line.trim().replaceFirst(_numbering, '').trim())
    .where((name) => name.isNotEmpty)
    .toList();
