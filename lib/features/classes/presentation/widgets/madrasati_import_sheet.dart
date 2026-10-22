import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';
import 'package:moean/features/classes/data/repositories/classes_repository.dart';

enum _RowStatus { idle, reading, read, failed }

class _Row {
  final MadrasatiClassModel madrasatiClass;
  bool checked = true;
  _RowStatus status = _RowStatus.idle;
  List<String> students = const [];

  _Row(this.madrasatiClass);
}

/// «استيراد من مدرستي»: reads classes and student names from Madrasati
/// (through the backend, with the connected Madrasati account), shows them
/// for review, and saves them to «فصولي». Pops with true when something was saved.
class MadrasatiImportSheet extends StatefulWidget {
  final ClassesRepository repository;

  const MadrasatiImportSheet({super.key, required this.repository});

  static Future<bool> show(BuildContext context, ClassesRepository repository) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => MadrasatiImportSheet(repository: repository),
    );
    return saved ?? false;
  }

  @override
  State<MadrasatiImportSheet> createState() => _MadrasatiImportSheetState();
}

class _MadrasatiImportSheetState extends State<MadrasatiImportSheet> {
  List<_Row> _rows = const [];
  bool _loading = true;
  bool _busy = false;
  bool _readDone = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await widget.repository.getMadrasatiClasses();
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.message;
      }),
      (classes) => setState(() {
        _loading = false;
        _rows = classes.map(_Row.new).toList();
      }),
    );
  }

  Future<void> _read() async {
    final chosen = _rows.where((row) => row.checked).toList();
    if (chosen.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    // One class at a time, so Madrasati isn't asked for everything at once.
    for (final row in chosen) {
      setState(() => row.status = _RowStatus.reading);
      final result = await widget.repository.readMadrasatiClass(row.madrasatiClass.madrasatiId);
      if (!mounted) return;
      result.fold(
        (failure) => setState(() {
          row.status = _RowStatus.failed;
          _error = failure.message;
        }),
        (names) => setState(() {
          row.status = _RowStatus.read;
          row.students = names;
        }),
      );
    }
    setState(() {
      _busy = false;
      _readDone = true;
    });
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    var saved = 0;
    for (final row in _rows.where((r) => r.checked && r.status == _RowStatus.read && r.students.isNotEmpty)) {
      final model = SchoolClassModel(name: row.madrasatiClass.name, grade: row.madrasatiClass.name, students: row.students);
      final id = row.madrasatiClass.existingClassId;
      final result = id != null ? await widget.repository.updateClass(id, model) : await widget.repository.createClass(model);
      if (!mounted) return;
      final failed = result.fold((failure) {
        setState(() => _error = failure.message);
        return true;
      }, (_) => false);
      if (failed) break;
      saved++;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (_error == null) Navigator.pop(context, saved > 0);
  }

  String _statusText(_Row row) => switch (row.status) {
        _RowStatus.reading => appTranslation().get('classes_madrasati_reading'),
        _RowStatus.read => appTranslation().get('classes_madrasati_count').replaceAll('{count}', '${row.students.length}'),
        _RowStatus.failed => appTranslation().get('classes_madrasati_failed'),
        _RowStatus.idle => '',
      };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                appTranslation().get('classes_madrasati_title'),
                style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
              ),
              verticalSpace4,
              Text(
                appTranslation().get('classes_madrasati_subtitle'),
                style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
              ),
              verticalSpace12,
              if (_loading)
                const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _rows.length,
                    separatorBuilder: (_, _) => Divider(height: 1, color: ColorsManager.borderLightGray),
                    itemBuilder: (context, index) {
                      final row = _rows[index];
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: row.checked,
                        onChanged: _busy || _readDone ? null : (value) => setState(() => row.checked = value ?? false),
                        title: Text(row.madrasatiClass.name, style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
                        subtitle: Text(
                          [
                            _statusText(row),
                            if (row.status == _RowStatus.read && row.madrasatiClass.existingClassId != null)
                              appTranslation().get('classes_madrasati_replaces'),
                          ].where((text) => text.isNotEmpty).join(' · '),
                          style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                        ),
                      );
                    },
                  ),
                ),
              if (!_loading && _rows.isEmpty && _error == null)
                Text(appTranslation().get('classes_madrasati_empty'), textAlign: TextAlign.center),
              if (_error != null) ...[
                verticalSpace8,
                Text(appTranslation().get(_error!), style: TextStylesManager.regular13.copyWith(color: ColorsManager.errorColor)),
              ],
              verticalSpace16,
              if (!_loading && _rows.isNotEmpty)
                PrimaryElevatedButton(
                  text: appTranslation().get(_readDone ? 'classes_madrasati_save' : 'classes_madrasati_read'),
                  icon: Icon(_readDone ? Icons.save_rounded : Icons.download_rounded),
                  onPressed: _busy ? null : (_readDone ? _save : _read),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(appTranslation().get('cancel'), style: TextStylesManager.bold14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
