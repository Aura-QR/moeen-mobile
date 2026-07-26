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
                      return  Center(child: CircularProgressIndicator(color: ColorsManager.primaryColor));
                    }

                    final selectedLessons = context.read<LessonSelectionCubit>().selectedLessons;

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('الخطوة 2 من 3: تحديد الأسئلة', style: TextStylesManager.bold16.copyWith(color: ColorsManager.primaryColor)),
                              verticalSpace16,
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => context.push(Routes.examBankQuestions),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
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
                              verticalSpace24,
                              Text('الدروس المختارة', style: TextStylesManager.bold16.copyWith(color: const Color(0xFF0F172A))),
                              verticalSpace12,
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: selectedLessons.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final lesson = entry.value;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: ColorsManager.primaryColor.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text('${index + 1}', style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor)),
                                        ),
                                        horizontalSpace8,
                                        Text(lesson.title, style: TextStylesManager.bold14.copyWith(color: const Color(0xFF0F172A))),
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
                                    'تم اختيار ${context.read<ExamInfoCubit>().selectedBankQuestionIds.values.fold(0, (sum, list) => sum + (list as List).length)} سؤال من بنك الأسئلة. سيتم دمجها مع الأرقام المحددة بالأسفل للذكاء الاصطناعي.',
                                    style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
                                  ),
                                ),
                                verticalSpace16,
                              ],
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'إجمالي الدروس: ${state.totalLessons}',
                                    style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                                  ),
                                  Text(
                                    'إجمالي الأسئلة: ${state.totalQuestions}',
                                    style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: selectedLessons.length,
                            itemBuilder: (context, index) {
                              final lesson = selectedLessons[index];
                              final lessonId = lesson.id;
                              final counts = state.counts[lessonId];
                              if (counts == null) return const SizedBox.shrink();

                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: 0,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
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
                                                  style: TextStylesManager.bold16,
                                                  maxLines: 2,
                                                ),
                                                if (context.read<ExamInfoCubit>().selectedBankQuestionIds[lessonId] != null && context.read<ExamInfoCubit>().selectedBankQuestionIds[lessonId]!.isNotEmpty) ...[
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
                                                context.read<LessonSelectionCubit>().selectedLessons
                                              );
                                            },
                                          )
                                        ],
                                      ),
                                      const Divider(),
                                      verticalSpace8,
                                      Text('أنواع الأسئلة والدرجات', style: TextStylesManager.bold16.copyWith(color: const Color(0xFF0F172A))),
                                      verticalSpace16,
                                      _buildCounterRow(context, lessonId, 'اختيار من متعدد', 'mcq', counts.mcq),
                                      _buildCounterRow(context, lessonId, 'صح أو خطأ', 'true_false', counts.trueFalse),
                                      _buildCounterRow(context, lessonId, 'أكمل الفراغ', 'fill_blank', counts.fillBlank),
                                      _buildCounterRow(context, lessonId, 'سؤال مقالي', 'essay', counts.essay),
                                      _buildCounterRow(context, lessonId, 'مطابقة', 'matching', counts.matching),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 10, offset: const Offset(0, -5)),
                            ],
                          ),
                          child: PrimaryElevatedButton(
                            text: appTranslation().get('create_exam'),
                            onPressed: isGenerating ? null : _handleGenerate,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // Full screen loading
                if (isGenerating)
                  Container(
                    color: ColorsManager.background.withOpacity(0.9),
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
                            'قد يستغرق هذا الإجراء حتى 90 ثانية',
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
    int defaultGrade = 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.primaryColor.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStylesManager.bold16.copyWith(color: const Color(0xFF0F172A))),
              verticalSpace4,
              Text('عدد الأسئلة', style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText)),
            ],
          ),
          Row(
            children: [
              _CounterButton(
                icon: Icons.add,
                onTap: () => context.read<QuestionCountCubit>().updateCount(lessonId, type, 1),
                enabled: true,
                isAdd: true,
              ),
              horizontalSpace8,
              SizedBox(
                width: 24,
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: TextStylesManager.bold16.copyWith(color: ColorsManager.primaryColor),
                ),
              ),
              horizontalSpace8,
              _CounterButton(
                icon: Icons.remove,
                onTap: () => context.read<QuestionCountCubit>().updateCount(lessonId, type, -1),
                enabled: value > 0,
                isAdd: false,
              ),
              horizontalSpace12,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$defaultGrade درجة',
                  style: TextStylesManager.bold14.copyWith(color: const Color(0xFF0F172A)),
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
              : ColorsManager.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isAdd 
              ? Colors.white 
              : (enabled ? ColorsManager.primaryColor : Colors.grey),
        ),
      ),
    );
  }
}
