import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/exam_generation/presentation/cubit/custom_questions_cubit.dart';
import 'package:moean/features/exam_generation/presentation/cubit/custom_questions_state.dart';
import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';

class CustomQuestionsScreen extends StatefulWidget {
  const CustomQuestionsScreen({super.key});

  @override
  State<CustomQuestionsScreen> createState() => _CustomQuestionsScreenState();
}

class _CustomQuestionsScreenState extends State<CustomQuestionsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomQuestionsCubit>().fetchQuestions(isRefresh: true);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<CustomQuestionsCubit>().fetchQuestions();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
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
          appTranslation().get('my_custom_questions'),
          style: TextStylesManager.bold18,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: ColorsManager.mainText),
          onPressed: () => context.pop(),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<CustomQuestionsCubit, CustomQuestionsState>(
          listener: (context, state) {
            if (state is CustomQuestionActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
            } else if (state is CustomQuestionActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            } else if (state is CustomQuestionsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            bool isLoading = state is CustomQuestionsLoading && !state.isPagination;
            bool isPaginationLoading = state is CustomQuestionsLoading && state.isPagination;
            QuestionPaginationEntity? paginationEntity;
            String selectedStatus = 'all';

            if (state is CustomQuestionsLoaded) {
              paginationEntity = state.questions;
              selectedStatus = state.selectedStatus;
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildHeaderFilters(context, selectedStatus),
                  verticalSpace16,
                  Expanded(
                    child: ConditionalBuilder(
                      loadingState: isLoading,
                      emptyState: paginationEntity?.data.isEmpty ?? true,
                      emptyBuilder: (context) => Center(
                        child: Text(
                          appTranslation().get('no_questions_found'),
                          style: TextStylesManager.bold16.copyWith(color: ColorsManager.placeholder),
                        ),
                      ),
                      successBuilder: (context) => ListView.separated(
                        controller: _scrollController,
                        itemCount: (paginationEntity?.data.length ?? 0) + (isPaginationLoading ? 1 : 0),
                        separatorBuilder: (_, __) => verticalSpace16,
                        itemBuilder: (context, index) {
                          if (index == paginationEntity?.data.length) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final question = paginationEntity!.data[index];
                          return _buildQuestionItem(context, question);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderFilters(BuildContext context, String selectedStatus) {
    return Column(
      children: [
        PrimaryTextField(
          controller: _searchController,
          hint: appTranslation().get('search_questions'),
          prefixIcon: const Icon(Icons.search, color: ColorsManager.mutedDark),
          onChanged: (value) {
            context.read<CustomQuestionsCubit>().searchQuestions(value);
          },
        ),
        verticalSpace12,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(context, 'all', appTranslation().get('all'), selectedStatus),
              horizontalSpace8,
              _buildFilterChip(context, 'pending', appTranslation().get('pending'), selectedStatus),
              horizontalSpace8,
              _buildFilterChip(context, 'approved', appTranslation().get('approved'), selectedStatus),
              horizontalSpace8,
              _buildFilterChip(context, 'rejected', appTranslation().get('rejected'), selectedStatus),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(BuildContext context, String statusKey, String label, String selectedStatus) {
    final isSelected = selectedStatus == statusKey;
    
    Color statusColor;
    switch (statusKey) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'all':
      default:
        statusColor = ColorsManager.primaryColor;
        break;
    }

    return GestureDetector(
      onTap: () {
        context.read<CustomQuestionsCubit>().changeStatus(statusKey);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ColorsManager.background : statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? statusColor : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStylesManager.bold14.copyWith(
            color: statusColor,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionItem(BuildContext context, QuestionEntity question) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color statusColor;
    String statusText;
    
    switch (question.reviewStatus) {
      case 'approved':
        statusColor = Colors.green;
        statusText = appTranslation().get('approved');
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = appTranslation().get('rejected');
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        statusText = appTranslation().get('pending');
        break;
    }

    List<String> parsedOptions = [];
    if (question.options is List) {
      parsedOptions = (question.options as List).map((e) => e.toString()).toList();
    } else if (question.options is String) {
      try {
        final decoded = jsonDecode(question.options as String);
        if (decoded is List) {
          parsedOptions = decoded.map((e) => e.toString()).toList();
        }
      } catch (e) {
        // Ignored
      }
    }

    String typeLabel = _getQuestionTypeLabel(question.type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : ColorsManager.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      typeLabel,
                      style: TextStylesManager.bold12.copyWith(color: const Color(0xFF2E7D32)),
                    ),
                  ),
                ],
              ),
              if (question.reviewStatus != 'approved')
                GestureDetector(
                  onTap: () => _showEditQuestionSheet(context, question),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: ColorsManager.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          appTranslation().get('edit_question') ?? 'تعديل السؤال',
                          style: TextStylesManager.bold12.copyWith(color: ColorsManager.white),
                        ),
                        horizontalSpace4,
                        const Icon(Icons.edit_outlined, color: ColorsManager.white, size: 16),
                      ],
                    ),
                  ),
                )
              else
                const SizedBox(),
            ],
          ),
          verticalSpace16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  question.questionText,
                  style: TextStylesManager.bold16,
                  textAlign: TextAlign.right,
                ),
              ),
              horizontalSpace12,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        if (question.reviewStatus == 'approved') ...[
                          Icon(Icons.check_circle_outline, color: statusColor, size: 16),
                          horizontalSpace4,
                        ],
                        Text(
                          statusText,
                          style: TextStylesManager.bold12.copyWith(color: statusColor),
                        ),
                      ],
                    ),
                  ),
                  horizontalSpace12,
                  Text(
                    'استخدم ${question.usageCount} مرة',
                    style: TextStylesManager.bold12.copyWith(color: ColorsManager.mutedDark),
                  ),
                ],
              ),
            ],
          ),
          if (question.reviewStatus == 'rejected' && question.rejectionReason != null && question.rejectionReason!.isNotEmpty) ...[
            verticalSpace12,
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  horizontalSpace8,
                  Expanded(
                    child: Text(
                      '${appTranslation().get('rejection_reason')}: ${question.rejectionReason}',
                      style: TextStylesManager.medium14.copyWith(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (parsedOptions.isNotEmpty) ...[
            verticalSpace16,
            ...parsedOptions.asMap().entries.map((entry) {
              int index = entry.key;
              String optionText = entry.value;
              String prefix = _getOptionPrefix(index);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3A3A3C) : ColorsManager.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorsManager.borderLight),
                ),
                child: Text(
                  '$prefix) $optionText',
                  style: TextStylesManager.bold14,
                  textAlign: TextAlign.right,
                ),
              );
            }),
          ],
          if (question.correctAnswer.isNotEmpty) ...[
            verticalSpace16,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${appTranslation().get('correct_answer') ?? "الإجابة الصحيحة"}: ${question.correctAnswer}',
                style: TextStylesManager.bold14.copyWith(color: const Color(0xFFF57F17)),
                textAlign: TextAlign.right,
              ),
            ),
          ],
          verticalSpace16,
          Text(
            'يظهر الآن ضمن الأسئلة الجاهزة للمعلمين.',
            style: TextStylesManager.medium12.copyWith(color: ColorsManager.mutedDark),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  String _getQuestionTypeLabel(String type) {
    switch (type) {
      case 'mcq': return 'اختيار من متعدد';
      case 'true_false': return 'صح وخطأ';
      case 'essay': return 'مقالي';
      case 'fill_blank': return 'أكمل الفراغ';
      case 'matching': return 'مزاوجة';
      default: return type;
    }
  }

  String _getOptionPrefix(int index) {
    const prefixes = ['أ', 'ب', 'ج', 'د', 'هـ', 'و'];
    if (index < prefixes.length) {
      return prefixes[index];
    }
    return '${index + 1}';
  }

  void _showEditQuestionSheet(BuildContext context, QuestionEntity question) {
    final TextEditingController textController = TextEditingController(text: question.questionText);
    final TextEditingController correctAnswerController = TextEditingController(text: question.correctAnswer);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appTranslation().get('edit_question'),
                style: TextStylesManager.bold18,
              ),
              verticalSpace16,
              PrimaryTextField(
                controller: textController,
                hint: appTranslation().get('question_text'),
                maxLines: 3,
              ),
              verticalSpace16,
              PrimaryTextField(
                controller: correctAnswerController,
                hint: appTranslation().get('correct_answer'),
              ),
              verticalSpace24,
              PrimaryElevatedButton(
                text: appTranslation().get('save'),
                onPressed: () {
                  final data = {
                    'question_text': textController.text.trim(),
                    'correct_answer': correctAnswerController.text.trim(),
                  };
                  context.read<CustomQuestionsCubit>().updateQuestion(question.id, data);
                  Navigator.pop(ctx);
                },
              ),
              verticalSpace24,
            ],
          ),
        );
      },
    );
  }
}
