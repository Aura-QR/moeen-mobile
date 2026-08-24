import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/exam_generation/presentation/cubit/exam_info_cubit.dart';
import 'package:moean/features/exam_generation/presentation/cubit/generate_exam_cubit.dart';
import 'package:moean/features/exam_generation/presentation/cubit/lesson_selection_cubit.dart';
import 'package:moean/features/exam_generation/presentation/cubit/question_count_cubit.dart';
import 'package:moean/core/utils/constants/primary/upgrade_prompt_bottom_sheet.dart';

class QuestionCountsScreen extends StatefulWidget {
  const QuestionCountsScreen({super.key});

  @override
  State<QuestionCountsScreen> createState() => _QuestionCountsScreenState();
}

class _QuestionCountsScreenState extends State<QuestionCountsScreen> {
  @override
  void initState() {
    super.initState();
    final selectedLessons = context.read<LessonSelectionCubit>().selectedLessons;
    context.read<QuestionCountCubit>().initForLessons(selectedLessons);
  }

  void _handleGenerate() {
    final infoCubit = context.read<ExamInfoCubit>();
    final lessonCubit = context.read<LessonSelectionCubit>();
    final countCubit = context.read<QuestionCountCubit>();

    final hasBankQuestions = infoCubit.selectedBankQuestionIds.isNotEmpty;

    if (countCubit.totalRequestedQuestions == 0 && !hasBankQuestions) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يجب اختيار سؤال واحد على الأقل', style: TextStylesManager.bold14),
          backgroundColor: ColorsManager.errorColor,
        ),
      );
      return;
    }

    context.read<GenerateExamCubit>().generate(
      title: infoCubit.examTitle,
      grade: infoCubit.selectedGrade?.name ?? '',
      subject: infoCubit.selectedSubject?.name ?? '',
      lessons: lessonCubit.selectedLessons.map((l) => {'id': l.id, 'name': l.title}).toList(),
      counts: countCubit.counts,
      selectedQuestionIds: infoCubit.selectedBankQuestionIds,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GenerateExamCubit, GenerateExamState>(
      listener: (context, state) {
        if (state is GenerateExamError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: TextStylesManager.bold14),
              backgroundColor: ColorsManager.errorColor,
            ),
          );
        } else if (state is GenerateExamPaymentRequired) {
          UpgradePromptBottomSheet.show(
            context,
            message: state.message,
            isQuotaExceeded: state.code == 'quota_exceeded',
          );
        } else if (state is GenerateExamSuccess) {
          // Success, navigate to preview screen passing the exam
          context.push(Routes.examGenerationPreview, arguments: state.exam);
        }
      },
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        appBar: AppBar(
          backgroundColor: ColorsManager.background,
          elevation: 0,
          centerTitle: true,
          title: Text(
            appTranslation().get('exam_question_counts'),
            style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
          ),
          leading: BlocBuilder<GenerateExamCubit, GenerateExamState>(
            builder: (context, state) {
              // Disable back button while generating
              if (state is GenerateExamLoading) return const SizedBox.shrink();
              return IconButton(
                icon:  Icon(Icons.arrow_back_ios, color: ColorsManager.mainText),
                onPressed: () => context.pop(),
              );
            },
          ),
        ),
        body: BlocBuilder<GenerateExamCubit, GenerateExamState>(
          builder: (context, generateState) {
            final isGenerating = generateState is GenerateExamLoading;

            return Stack(
              children: [
                BlocBuilder<QuestionCountCubit, QuestionCountState>(
                  builder: (context, state) {
                    if (state is! QuestionCountUpdated) {
                      return Center(child: CircularProgressIndicator(color: ColorsManager.primaryColor));
                    }

                    final selectedLessons = context.read<LessonSelectionCubit>().selectedLessons;

                    return Column(
                      children: [
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              verticalSpace16,
                              Text(
                                'الخطوة 2 من 3: تحديد الأسئلة',
                                style: TextStylesManager.bold16.copyWith(color: ColorsManager.primaryColor),
                              ),
                              verticalSpace16,
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: ColorsManager.surfacePrimary,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: ColorsManager.borderLightGray),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => context.push(Routes.examBankQuestions),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            color: ColorsManager.surfacePrimary,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'من بنك الأسئلة',
                                            style: TextStylesManager.bold14.copyWith(color: ColorsManager.secondaryText),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: ColorsManager.primaryColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'إنشاء تلقائي',
                                          style: TextStylesManager.bold14.copyWith(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              verticalSpace20,
                              Text(
                                'الدروس المختارة',
                                style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
                              ),
                              verticalSpace12,
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: selectedLessons.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final lesson = entry.value;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: ColorsManager.surfacePrimary,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: ColorsManager.borderLightGray),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
                                          ),
                                        ),
                                        horizontalSpace6,
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context).size.width * 0.6,
                                          ),
                                          child: Text(
                                            lesson.title,
                                            style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              verticalSpace16,
                              if (context.read<ExamInfoCubit>().selectedBankQuestionIds.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'تم اختيار ${context.read<ExamInfoCubit>().selectedBankQuestionIds.values.fold(0, (sum, list) => sum + (list as List).length)} سؤال من بنك الأسئلة. سيتم دمجها مع الأرقام المحددة بالأسفل.',
                                    style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
                                  ),
                                ),
                                verticalSpace16,
                              ],
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'إجمالي الدروس: ${state.totalLessons}',
                                      style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                                    ),
                                  ),
                                  Text(
                                    'إجمالي الأسئلة: ${state.totalQuestions}',
                                    style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor),
                                  ),
                                ],
                              ),
                              verticalSpace16,
                              ...selectedLessons.map((lesson) {
                                final lessonId = lesson.id;
                                final counts = state.counts[lessonId];
                                if (counts == null) return const SizedBox.shrink();

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  elevation: 0,
                                  color: ColorsManager.surfacePrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(color: ColorsManager.borderLightGray),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    lesson.title,
                                                    style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  if (context.read<ExamInfoCubit>().selectedBankQuestionIds[lessonId] != null &&
                                                      context.read<ExamInfoCubit>().selectedBankQuestionIds[lessonId]!.isNotEmpty) ...[
                                                    verticalSpace4,
                                                    Text(
                                                      '${context.read<ExamInfoCubit>().selectedBankQuestionIds[lessonId]!.length} سؤال محدد من البنك',
                                                      style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
                                                    ),
                                                  ]
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: ColorsManager.errorColor),
                                              onPressed: () {
                                                context.read<LessonSelectionCubit>().removeLesson(lessonId);
                                                context.read<QuestionCountCubit>().initForLessons(
                                                  context.read<LessonSelectionCubit>().selectedLessons,
                                                );
                                              },
                                            )
                                          ],
                                        ),
                                        const Divider(),
                                        verticalSpace8,
                                        Text(
                                          'أنواع الأسئلة والدرجات',
                                          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
                                        ),
                                        verticalSpace12,
                                        _buildCounterRow(context, lessonId, 'اختيار من متعدد', 'mcq', counts.mcq),
                                        _buildCounterRow(context, lessonId, 'صح أو خطأ', 'true_false', counts.trueFalse),
                                        _buildCounterRow(context, lessonId, 'أكمل الفراغ', 'fill_blank', counts.fillBlank),
                                        _buildCounterRow(context, lessonId, 'سؤال مقالي', 'essay', counts.essay),
                                        _buildCounterRow(context, lessonId, 'مطابقة', 'matching', counts.matching),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              verticalSpace8,
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: ColorsManager.surfacePrimary,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
                            ],
                          ),
                          child: SafeArea(
                            top: false,
                            left: false,
                            right: false,
                            minimum: const EdgeInsets.all(20),
                            child: generateState is GenerateExamSuccess
                                ? PrimaryElevatedButton(
                                    text: 'المشاركة ومعاينة الاختبار',
                                    onPressed: () {
                                      context.push(Routes.examGenerationPreview, arguments: generateState.exam);
                                    },
                                  )
                                : PrimaryElevatedButton(
                                    text: appTranslation().get('create_exam'),
                                    onPressed: isGenerating ? null : _handleGenerate,
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // Full screen loading
                if (isGenerating)
                  Container(
                    color: ColorsManager.background.withValues(alpha: 0.9),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: ColorsManager.primaryColor),
                          verticalSpace24,
                          Text(
                            'جاري الانشاء الاختبار  ...',
                            style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
                          ),
                          verticalSpace8,
                          Text(
                            'قد يستغرق هذا الإجراء دقيقة',
                            style: TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCounterRow(BuildContext context, int lessonId, String label, String type, int value) {
    const int defaultGrade = 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                verticalSpace4,
                Text(
                  'عدد الأسئلة',
                  style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                ),
              ],
            ),
          ),
          horizontalSpace8,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CounterButton(
                icon: Icons.add,
                onTap: () => context.read<QuestionCountCubit>().updateCount(lessonId, type, 1),
                enabled: true,
                isAdd: true,
              ),
              horizontalSpace6,
              SizedBox(
                width: 22,
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor),
                ),
              ),
              horizontalSpace6,
              _CounterButton(
                icon: Icons.remove,
                onTap: () => context.read<QuestionCountCubit>().updateCount(lessonId, type, -1),
                enabled: value > 0,
                isAdd: false,
              ),
              horizontalSpace8,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$defaultGrade درجة',
                  style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final bool isAdd;

  const _CounterButton({required this.icon, required this.onTap, required this.enabled, this.isAdd = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isAdd 
              ? ColorsManager.primaryColor 
              : ColorsManager.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isAdd 
              ? Colors.white 
              : (enabled ? ColorsManager.primaryColor : Colors.grey),
        ),
      ),
    );
  }
}
