import 'package:equatable/equatable.dart';
import 'package:moean/features/exam_extraction/data/models/extraction_page_model.dart';

class ExtractionPagesState extends Equatable {
  final List<ExtractionPageModel> pages;
  final int count;
  final String? notes;
  final String? error;

  const ExtractionPagesState({
    this.pages = const [],
    this.count = 10,
    this.notes,
    this.error,
  });

  bool get canStart => pages.isNotEmpty;

  ExtractionPagesState copyWith({
    List<ExtractionPageModel>? pages,
    int? count,
    String? notes,
    String? error,
    bool clearError = false,
  }) {
    return ExtractionPagesState(
      pages: pages ?? this.pages,
      count: count ?? this.count,
      notes: notes ?? this.notes,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [pages, count, notes, error];
}
