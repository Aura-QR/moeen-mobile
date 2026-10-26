import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/features/diagnostic_test/data/repositories/diagnostic_repository.dart';
import 'package:moean/features/diagnostic_test/presentation/cubit/diagnostic_create_cubit.dart';
import 'package:moean/features/diagnostic_test/presentation/widgets/diagnostic_pick_view.dart';
import 'package:moean/features/diagnostic_test/presentation/widgets/diagnostic_review_view.dart';

/// «الاختبار التشخيصي»: stage → grade → subject → AI writes questions per skill → review → save.
class DiagnosticCreateScreen extends StatelessWidget {
  const DiagnosticCreateScreen({super.key});

  static Widget create() => BlocProvider(
        create: (_) => DiagnosticCreateCubit(DiagnosticRepository())..loadStages(),
        child: const DiagnosticCreateScreen(),
      );

  @override
  Widget build(BuildContext context) {
    final cubit = DiagnosticCreateCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get('diagnostic_title'),
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
      ),
      body: BlocConsumer<DiagnosticCreateCubit, DiagnosticCreateState>(
        listenWhen: (a, b) => a.error != b.error || a.savedExamId != b.savedExamId,
        buildWhen: (a, b) =>
            a.step != b.step ||
            a.isStagesLoading != b.isStagesLoading ||
            a.stagesError != b.stagesError ||
            a.stages != b.stages ||
            a.selectedStage != b.selectedStage ||
            a.selectedTrack != b.selectedTrack ||
            a.selectedGrade != b.selectedGrade ||
            a.selectedSubject != b.selectedSubject ||
            a.subjectId != b.subjectId ||
            a.isSourceLoading != b.isSourceLoading ||
            a.source != b.source ||
            a.skillsCount != b.skillsCount ||
            a.perSkill != b.perSkill ||
            a.skills != b.skills ||
            a.isSaving != b.isSaving,
        listener: (context, state) {
          if (state.error != null) {
            showPrimarySnackBar(context, appTranslation().get(state.error!), isError: true);
            cubit.clearError();
          }
          if (state.savedExamId != null) {
            showPrimarySnackBar(context, appTranslation().get('diagnostic_saved'), isError: false);
            Navigator.pop(context, true);
          }
        },
        builder: (context, state) {
          if (state.step == DiagnosticStep.review) {
            return DiagnosticReviewView(state: state);
          }
          return DiagnosticPickView(state: state);
        },
      ),
    );
  }
}
