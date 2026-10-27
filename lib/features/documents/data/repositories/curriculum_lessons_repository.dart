import 'package:dartz/dartz.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/features/documents/data/models/picked_lesson_model.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';

/// The curriculum, for picking «الدرس» in a document form.
class CurriculumLessonsRepository {
  /// Full curriculum tree: Stage → Grade → Subject.
  Future<Either<Failure, List<CurriculumStageModel>>> getStages() async {
    final result = await ApiService.getSubjects();
    return result.leftMap(_userFacing);
  }

  /// Every subject, flattened from stages and grades.
  Future<Either<Failure, List<LessonPickerSubjectModel>>> getSubjects() async {
    final result = await ApiService.getSubjects();
    return result.bimap(
      _userFacing,
      (stages) => [
        for (final stage in stages)
          for (final grade in stage.grades)
            for (final subject in grade.subjects)
              LessonPickerSubjectModel(
                subjectId: subject.id,
                subjectName: subject.name,
                gradeName: grade.name,
              ),
      ],
    );
  }

  Future<Either<Failure, List<CurriculumChapterModel>>> getChapters(
    int subjectId,
  ) async {
    final result = await ApiService.getSubjectLessons(subjectId);
    return result.bimap(
      _userFacing,
      (details) => details.chapters
          .where((chapter) => chapter.lessons.isNotEmpty)
          .toList(),
    );
  }

  /// ApiService keeps DioHelper's raw error; map it to a message the UI can show.
  static Failure _userFacing(Failure failure) =>
      failureFromApiError(failure.message);
}
