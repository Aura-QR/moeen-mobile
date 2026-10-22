part of 'madrasati_import_cubit.dart';

enum MadrasatiImportStatus { loading, success, failure }

enum MadrasatiRowStatus { idle, reading, read, failed, saved }

/// One Madrasati class in the sheet.
class MadrasatiImportRow {
  final MadrasatiClassModel madrasatiClass;
  final bool isChecked;
  final MadrasatiRowStatus status;
  final List<String> students;

  const MadrasatiImportRow(
    this.madrasatiClass, {
    this.isChecked = true,
    this.status = MadrasatiRowStatus.idle,
    this.students = const [],
  });

  bool get canSave => isChecked && status == MadrasatiRowStatus.read && students.isNotEmpty;

  /// A «فصولي» class with the same name exists; saving replaces its names.
  bool get replacesExisting => madrasatiClass.existingClassId != null;

  MadrasatiImportRow copyWith({bool? isChecked, MadrasatiRowStatus? status, List<String>? students}) =>
      MadrasatiImportRow(
        madrasatiClass,
        isChecked: isChecked ?? this.isChecked,
        status: status ?? this.status,
        students: students ?? this.students,
      );
}

class MadrasatiImportState {
  final MadrasatiImportStatus status;
  final List<MadrasatiImportRow> rows;
  final bool isBusy;

  /// After «قراءة الأسماء»: the next step is saving.
  final bool isRead;

  /// Saving finished; the sheet closes.
  final bool isDone;

  /// A message for the user; stays until the next action.
  final String? errorMessage;

  const MadrasatiImportState({
    this.status = MadrasatiImportStatus.loading,
    this.rows = const [],
    this.isBusy = false,
    this.isRead = false,
    this.isDone = false,
    this.errorMessage,
  });

  bool get savedAny => rows.any((row) => row.status == MadrasatiRowStatus.saved);

  MadrasatiImportState copyWith({
    MadrasatiImportStatus? status,
    List<MadrasatiImportRow>? rows,
    bool? isBusy,
    bool? isRead,
    bool? isDone,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MadrasatiImportState(
      status: status ?? this.status,
      rows: rows ?? this.rows,
      isBusy: isBusy ?? this.isBusy,
      isRead: isRead ?? this.isRead,
      isDone: isDone ?? this.isDone,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
