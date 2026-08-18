import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';
import 'package:moean/features/exam_generation/data/models/exam_models.dart';
import 'package:moean/features/exam_generation/presentation/cubit/exam_preview_cubit.dart';
import 'package:moean/features/reports/presentation/screen/pdf_preview_screen.dart';
import 'package:moean/features/exam_generation/data/services/exam_pdf_service.dart';
import 'package:moean/core/network/local/cache_helper.dart';
import 'package:moean/features/exam_generation/presentation/widgets/add_manual_question_dialog.dart';
import 'package:moean/core/utils/constants/primary/upgrade_prompt_bottom_sheet.dart';

class ExamPreviewScreen extends StatefulWidget {
  final ExamEntity initialExam;

  const ExamPreviewScreen({super.key, required this.initialExam});

  @override
  State<ExamPreviewScreen> createState() => _ExamPreviewScreenState();
}

class _ExamPreviewScreenState extends State<ExamPreviewScreen> {
  @override
  void initState() {
    super.initState();
    // Load fresh exam data in case it was edited elsewhere or points need refresh
    context.read<ExamPreviewCubit>().loadExam(widget.initialExam.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExamPreviewCubit, ExamPreviewState>(
      listener: (context, state) {
        if (state is ExamPreviewPaymentRequired) {
          UpgradePromptBottomSheet.show(
            context,
            message: state.message,
            isQuotaExceeded: state.code == 'quota_exceeded',
          );
        } else if (state is ExamPreviewError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: ColorsManager.errorColor),
          );
        }
      },
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get('exam_preview_title'),
          style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
        ),
        leading: IconButton(
          icon:  Icon(Icons.arrow_back_ios, color: ColorsManager.mainText),
          onPressed: () => context.pop(),
        ),
        actions: [
          BlocBuilder<ExamPreviewCubit, ExamPreviewState>(
            builder: (context, state) {
              if (state is ExamPreviewLoaded) {
                return IconButton(
                  icon:  Icon(Icons.picture_as_pdf, color: ColorsManager.primaryColor),
                  onPressed: () {
                    final teacherName = CacheHelper.getData(key: 'teacher_name') as String? ?? '';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfPreviewScreen(
                          title: 'معاينة الاختبار (PDF)',
                          buildPdf: () => ExamPdfService.generatePdf(
                            exam: state.exam,
                            showAnswers: state.showAnswers,
                            teacherName: teacherName,
                            schoolName: '',
                            educationOffice: '',
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<ExamPreviewCubit, ExamPreviewState>(
        builder: (context, state) {
          if (state is ExamPreviewLoading || state is ExamPreviewInitial) {
            return  Center(child: CircularProgressIndicator(color: ColorsManager.primaryColor));
          }

          if (state is ExamPreviewError) {
            return Center(
              child: Text(state.message, style: TextStylesManager.bold16.copyWith(color: ColorsManager.errorColor)),
            );
          }

          final loadedState = state as ExamPreviewLoaded;
          final exam = loadedState.exam;
          
          // Sort by question_order
          final questions = List<QuestionEntity>.from(exam.questions)
            ..sort((a, b) => a.questionOrder.compareTo(b.questionOrder));

          return Column(
            children: [
              // Settings Header
              Container(
                padding: const EdgeInsets.all(16),
                color: ColorsManager.surfacePrimary,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('وضع المعلم', style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
                        Switch(
                          value: loadedState.isTeacherMode,
                          activeColor: ColorsManager.primaryColor,
                          onChanged: (val) => context.read<ExamPreviewCubit>().toggleMode(val),
                        ),
                      ],
                    ),
                    if (loadedState.isTeacherMode)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('إظهار الإجابات', style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
                          Switch(
                            value: loadedState.showAnswers,
                            activeColor: ColorsManager.primaryColor,
                            onChanged: (val) => context.read<ExamPreviewCubit>().toggleAnswers(val),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              
              // Total points live calculator
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('إجمالي الدرجات:', style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
                    Text(
                      loadedState.provisionalTotalPoints.toStringAsFixed(2),
                      style: TextStylesManager.bold16.copyWith(color: ColorsManager.primaryColor),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    return _buildQuestionCard(context, q, loadedState);
                  },
                ),
              ),
              
              // Save points button
              if (exam.status == 'draft' && loadedState.pendingPointsChanges.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ColorsManager.surfacePrimary,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                    ],
                  ),
                  child: state is ExamPreviewSaving 
                    ? const Center(child: CircularProgressIndicator()) 
                    : PrimaryElevatedButton(
                    text: 'حفظ الدرجات',
                    onPressed: () => context.read<ExamPreviewCubit>().savePoints(),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: BlocBuilder<ExamPreviewCubit, ExamPreviewState>(
        builder: (context, state) {
          if (state is ExamPreviewLoaded && state.exam.status == 'draft') {
            return FloatingActionButton.extended(
              onPressed: () {
                final uniqueLessonIds = state.exam.questions.map((q) => q.lessonId).toSet().toList();
                showDialog(
                  context: context,
                  builder: (_) => AddManualQuestionDialog(
                    examId: state.exam.id,
                    availableLessonIds: uniqueLessonIds,
                    onSubmit: (request) {
                      context.read<ExamPreviewCubit>().addManualQuestion(request);
                    },
                  ),
                );
              },
              backgroundColor: ColorsManager.primaryColor,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text('إضافة سؤال', style: TextStylesManager.bold14.copyWith(color: Colors.white)),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, QuestionEntity q, ExamPreviewLoaded state) {
    final isEnglish = ExamPdfService.isEnglishText(q.questionText);
    final textDir = isEnglish ? TextDirection.ltr : TextDirection.rtl;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 0,
      color: ColorsManager.surfacePrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: ColorsManager.borderLightGray),
      ),
      child: Directionality(
        textDirection: textDir,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${q.questionOrder}. ', style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText)),
                  Expanded(
                    child: Text(
                      q.questionText,
                      style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
                      textDirection: textDir,
                    ),
                  ),
                  if (state.exam.status == 'draft')
                    _PointsEditor(
                      initialPoints: state.pendingPointsChanges[q.id] ?? q.points.toDouble(),
                      onChanged: (parsed) {
                        context.read<ExamPreviewCubit>().updatePendingPoints(q.id, parsed);
                      },
                    )
                  else
                    Text(
                      isEnglish ? '${q.points} point${q.points > 1 ? "s" : ""}' : '${q.points} درجة',
                      style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor),
                    ),
                ],
              ),
              verticalSpace12,
              _buildQuestionOptions(q, state.showAnswers, isEnglish),
              if (state.isTeacherMode && state.showAnswers && q.type != 'matching' && q.type != 'mcq') ...[
                verticalSpace12,
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorsManager.successColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: ColorsManager.successColor, size: 16),
                      horizontalSpace8,
                      Expanded(
                        child: Text(
                          isEnglish ? 'Answer: ${q.correctAnswer}' : 'الإجابة: ${q.correctAnswer}',
                          style: TextStylesManager.bold14.copyWith(color: ColorsManager.successColor),
                          textDirection: textDir,
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionOptions(QuestionEntity q, bool showAnswers, bool isEnglish) {
    final textDir = isEnglish ? TextDirection.ltr : TextDirection.rtl;

    if (q.type == 'mcq') {
      final options = List<String>.from(q.options ?? []);
      return Column(
        children: options.map((opt) {
          final isCorrect = opt == q.correctAnswer;
          return RadioGroup<String>(
            groupValue: showAnswers && isCorrect ? opt : null,
            onChanged: (_) {},
            child: RadioListTile<String>(
              value: opt,
              activeColor: ColorsManager.successColor,
              title: Text(
                opt,
                style: showAnswers && isCorrect
                    ? TextStylesManager.bold14.copyWith(
                        color: ColorsManager.successColor,
                      )
                    : TextStylesManager.regular14.copyWith(
                        color: ColorsManager.mainText,
                      ),
                textDirection: textDir,
              ),
            ),
          );
        }).toList(),
      );
    } else if (q.type == 'true_false') {
      final isTrueCorrect = showAnswers && (q.correctAnswer == 'صح' || q.correctAnswer.toLowerCase() == 'true');
      final isFalseCorrect = showAnswers && (q.correctAnswer == 'خطأ' || q.correctAnswer.toLowerCase() == 'false');

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              Radio<String>(
                value: 'صح',
                groupValue: isTrueCorrect ? 'صح' : null,
                activeColor: ColorsManager.successColor,
                onChanged: (_) {},
              ),
              Text(isEnglish ? 'True' : 'صح', style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
            ],
          ),
          Row(
            children: [
              Radio<String>(
                value: 'خطأ',
                groupValue: isFalseCorrect ? 'خطأ' : null,
                activeColor: ColorsManager.successColor,
                onChanged: (_) {},
              ),
              Text(isEnglish ? 'False' : 'خطأ', style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
            ],
          ),
        ],
      );
    } else if (q.type == 'matching') {
      List<String> columnA = [];
      List<String> columnB = [];
      
      if (q.options is MatchingOptionsModel) {
        columnA = (q.options as MatchingOptionsModel).columnA;
        columnB = (q.options as MatchingOptionsModel).columnB;
      } else if (q.options is Map) {
        columnA = List<String>.from(q.options['column_a'] ?? []);
        columnB = List<String>.from(q.options['column_b'] ?? []);
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columnA.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(a, textDirection: textDir, style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText)),
              )).toList(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columnB.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(b, textDirection: textDir, style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText)),
              )).toList(),
            ),
          ),
        ],
      );
    } else if (q.type == 'essay') {
      return Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: ColorsManager.surfacePrimary,
          border: Border.all(color: ColorsManager.borderLightGray),
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _PointsEditor extends StatefulWidget {
  final double initialPoints;
  final ValueChanged<double> onChanged;

  const _PointsEditor({required this.initialPoints, required this.onChanged});

  @override
  State<_PointsEditor> createState() => _PointsEditorState();
}

class _PointsEditorState extends State<_PointsEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialPoints.toString());
  }

  @override
  void didUpdateWidget(covariant _PointsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPoints != widget.initialPoints) {
      if (double.tryParse(_controller.text) != widget.initialPoints) {
        _controller.text = widget.initialPoints.toString();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() {
    double current = double.tryParse(_controller.text) ?? widget.initialPoints;
    current += 1.0;
    _controller.text = current.toString();
    widget.onChanged(current);
  }

  void _decrement() {
    double current = double.tryParse(_controller.text) ?? widget.initialPoints;
    if (current >= 1.0) {
      current -= 1.0;
      _controller.text = current.toString();
      widget.onChanged(current);
    } else if (current > 0) {
      current = 0.0;
      _controller.text = current.toString();
      widget.onChanged(current);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.add_circle_outline, size: 24, color: ColorsManager.primaryColor),
          onPressed: _increment,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: PrimaryTextField(
            controller: _controller,
            hint: 'الدرجة',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (val) {
              final parsed = double.tryParse(val);
              if (parsed != null && parsed >= 0) {
                widget.onChanged(parsed);
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.remove_circle_outline, size: 24, color: ColorsManager.primaryColor),
          onPressed: _decrement,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
