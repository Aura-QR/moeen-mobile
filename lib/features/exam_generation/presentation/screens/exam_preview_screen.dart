import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';
import 'package:moean/features/exam_generation/data/models/exam_models.dart';
import 'package:moean/features/exam_generation/presentation/cubit/exam_preview_cubit.dart';
import 'package:moean/features/reports/presentation/screen/pdf_preview_screen.dart';
import 'package:moean/features/exam_generation/data/services/exam_pdf_service.dart';
import 'package:moean/core/network/local/cache_helper.dart';
import 'package:moean/features/exam_generation/presentation/widgets/add_manual_question_dialog.dart';

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
    return Scaffold(
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
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('وضع المعلم', style: TextStylesManager.bold14),
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
                          Text('إظهار الإجابات', style: TextStylesManager.bold14),
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
                color: ColorsManager.primaryColor.withOpacity(0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('إجمالي الدرجات:', style: TextStylesManager.bold14),
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
                    color: Colors.white,
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
    );
  }

  Widget _buildQuestionCard(BuildContext context, QuestionEntity q, ExamPreviewLoaded state) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${q.questionOrder}. ', style: TextStylesManager.bold16),
                Expanded(
                  child: Text(q.questionText, style: TextStylesManager.bold16),
                ),
                if (state.exam.status == 'draft')
                  SizedBox(
                    width: 60,
                    child: TextFormField(
                      initialValue: (state.pendingPointsChanges[q.id] ?? q.points).toString(),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val);
                        if (parsed != null && parsed >= 0) {
                          context.read<ExamPreviewCubit>().updatePendingPoints(q.id, parsed);
                        }
                      },
                    ),
                  )
                else
                  Text('${q.points} درجة', style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor)),
              ],
            ),
            verticalSpace12,
            _buildQuestionOptions(q, state.showAnswers),
            if (state.isTeacherMode && state.showAnswers && q.type != 'matching' && q.type != 'mcq') ...[
              verticalSpace12,
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorsManager.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: ColorsManager.successColor, size: 16),
                    horizontalSpace8,
                    Expanded(
                      child: Text('الإجابة: ${q.correctAnswer}', style: TextStylesManager.bold14.copyWith(color: ColorsManager.successColor)),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionOptions(QuestionEntity q, bool showAnswers) {
    if (q.type == 'mcq') {
      final options = List<String>.from(q.options ?? []);
      return Column(
        children: options.map((opt) {
          final isCorrect = opt == q.correctAnswer;
          return RadioListTile<String>(
            value: opt,
            groupValue: showAnswers && isCorrect ? opt : null,
            activeColor: ColorsManager.successColor,
            title: Text(
              opt,
              style: showAnswers && isCorrect
                  ? TextStylesManager.bold14.copyWith(color: ColorsManager.successColor)
                  : TextStylesManager.regular14,
            ),
            onChanged: (_) {},
          );
        }).toList(),
      );
    } else if (q.type == 'true_false') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              Radio<String>(
                value: 'صح',
                groupValue: showAnswers && q.correctAnswer == 'صح' ? 'صح' : null,
                activeColor: ColorsManager.successColor,
                onChanged: (_) {},
              ),
              const Text('صح'),
            ],
          ),
          Row(
            children: [
              Radio<String>(
                value: 'خطأ',
                groupValue: showAnswers && q.correctAnswer == 'خطأ' ? 'خطأ' : null,
                activeColor: ColorsManager.successColor,
                onChanged: (_) {},
              ),
              const Text('خطأ'),
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
              children: columnA.map((a) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(a))).toList(),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columnB.map((b) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(b))).toList(),
            ),
          ),
        ],
      );
    } else if (q.type == 'essay') {
      return Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }
    return const SizedBox.shrink(); // fill_blank text is already rendered in questionText
  }
}
