import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';

class AddManualQuestionDialog extends StatefulWidget {
  final int examId;
  final List<int> availableLessonIds;
  final Function(Map<String, dynamic> request) onSubmit;

  const AddManualQuestionDialog({
    super.key,
    required this.examId,
    required this.availableLessonIds,
    required this.onSubmit,
  });

  @override
  State<AddManualQuestionDialog> createState() => _AddManualQuestionDialogState();
}

class _AddManualQuestionDialogState extends State<AddManualQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'mcq';
  int? _selectedLessonId;
  final TextEditingController _pointsController = TextEditingController(text: '1');
  final TextEditingController _questionTextController = TextEditingController();
  final TextEditingController _optionsController = TextEditingController();
  final TextEditingController _columnAController = TextEditingController();
  final TextEditingController _columnBController = TextEditingController();
  final TextEditingController _correctAnswerController = TextEditingController();

  final Map<String, String> _questionTypes = {
    'mcq': 'اختيار من متعدد',
    'true_false': 'صح أو خطأ',
    'fill_blank': 'أكمل الفراغ',
    'essay': 'مقالي',
    'matching': 'مطابقة',
  };

  @override
  void initState() {
    super.initState();
    if (widget.availableLessonIds.isNotEmpty) {
      _selectedLessonId = widget.availableLessonIds.first;
    }
  }

  @override
  void dispose() {
    _pointsController.dispose();
    _questionTextController.dispose();
    _optionsController.dispose();
    _columnAController.dispose();
    _columnBController.dispose();
    _correctAnswerController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedLessonId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء اختيار الدرس')));
        return;
      }

      final request = <String, dynamic>{
        'exam_id': widget.examId,
        'lesson_id': _selectedLessonId,
        'type': _selectedType,
        'difficulty': 'medium',
        'points': double.tryParse(_pointsController.text) ?? 1.0,
        'question_text': _questionTextController.text,
      };

      if (_selectedType == 'mcq') {
        final options = _optionsController.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        if (options.length < 2) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء إدخال خيارين على الأقل')));
          return;
        }
        request['options'] = options;
        request['correct_answer'] = _correctAnswerController.text;
      } else if (_selectedType == 'true_false') {
        request['correct_answer'] = _correctAnswerController.text; // Expected "صح" or "خطأ"
      } else if (_selectedType == 'fill_blank') {
        request['correct_answer'] = _correctAnswerController.text;
      } else if (_selectedType == 'essay') {
        request['correct_answer'] = _correctAnswerController.text;
      } else if (_selectedType == 'matching') {
        final columnALines = _columnAController.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        final columnBLines = _columnBController.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        
        request['options'] = {
          'column_a': columnALines,
          'column_b': columnBLines,
        };
        request['correct_answer'] = _correctAnswerController.text;
      }

      widget.onSubmit(request);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('إضافة سؤال جديد', style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor)),
                      Text('سؤال يدوي داخل نفس الاختبار', style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText)),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: ColorsManager.secondaryText),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
              verticalSpace16,
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('نوع السؤال', style: TextStylesManager.bold14),
                      verticalSpace8,
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _questionTypes.entries.map((entry) {
                          final isSelected = _selectedType == entry.key;
                          return ChoiceChip(
                            label: Text(entry.value, style: TextStylesManager.bold12.copyWith(color: isSelected ? Colors.white : ColorsManager.secondaryText)),
                            selected: isSelected,
                            selectedColor: ColorsManager.primaryColor,
                            backgroundColor: Colors.white,
                            side: BorderSide(color: isSelected ? ColorsManager.primaryColor : Colors.grey.shade300),
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedType = entry.key);
                            },
                          );
                        }).toList(),
                      ),
                      verticalSpace16,
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('الدرجة', style: TextStylesManager.bold14),
                                verticalSpace8,
                                TextFormField(
                                  controller: _pointsController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    isDense: true,
                                  ),
                                  validator: (value) => value!.isEmpty ? 'مطلوب' : null,
                                ),
                              ],
                            ),
                          ),
                          horizontalSpace16,
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('الدرس المرتبط بالسؤال', style: TextStylesManager.bold14),
                                verticalSpace8,
                                DropdownButtonFormField<int>(
                                  value: _selectedLessonId,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    isDense: true,
                                  ),
                                  items: widget.availableLessonIds.map((id) {
                                    return DropdownMenuItem<int>(
                                      value: id,
                                      child: Text('الدرس $id', style: TextStylesManager.regular14),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() => _selectedLessonId = val);
                                  },
                                  validator: (value) => value == null ? 'مطلوب' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      verticalSpace16,
                      Text('نص السؤال', style: TextStylesManager.bold14),
                      verticalSpace8,
                      TextFormField(
                        controller: _questionTextController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'اكتب نص السؤال...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value!.isEmpty ? 'مطلوب' : null,
                      ),
                      verticalSpace16,
                      if (_selectedType == 'mcq') ...[
                        Text('الاختيارات – كل اختيار في سطر', style: TextStylesManager.bold14),
                        verticalSpace8,
                        TextFormField(
                          controller: _optionsController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'الاختيار الأول\nالاختيار الثاني\nالاختيار الثالث\nالاختيار الرابع',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        verticalSpace16,
                      ],
                      if (_selectedType == 'matching') ...[
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('العمود أ – كل عنصر في سطر', style: TextStylesManager.bold14),
                                  verticalSpace8,
                                  TextFormField(
                                    controller: _columnAController,
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                      hintText: '1. المفهوم الأول\n2. المفهوم الثاني',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            horizontalSpace16,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('العمود ب – كل عنصر في سطر', style: TextStylesManager.bold14),
                                  verticalSpace8,
                                  TextFormField(
                                    controller: _columnBController,
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                      hintText: 'أ. الإجابة الأولى\nب. الإجابة الثانية\nج. مشتت إضافي',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        verticalSpace16,
                      ],
                      if (_selectedType == 'true_false') ...[
                         Text('الإجابة الصحيحة', style: TextStylesManager.bold14),
                         verticalSpace8,
                         DropdownButtonFormField<String>(
                            value: _correctAnswerController.text.isEmpty ? null : _correctAnswerController.text,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              isDense: true,
                            ),
                            items: const [
                              DropdownMenuItem(value: 'صح', child: Text('صح')),
                              DropdownMenuItem(value: 'خطأ', child: Text('خطأ')),
                            ],
                            onChanged: (val) {
                              setState(() => _correctAnswerController.text = val ?? '');
                            },
                            validator: (value) => value == null ? 'مطلوب' : null,
                          ),
                          verticalSpace16,
                      ] else ...[
                        Text('الإجابة الصحيحة / النموذجية', style: TextStylesManager.bold14),
                        verticalSpace8,
                        TextFormField(
                          controller: _correctAnswerController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: _selectedType == 'matching' ? 'مثال: 1-أ, 2-ب' : 'اكتب الإجابة الصحيحة...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) => value!.isEmpty ? 'مطلوب' : null,
                        ),
                        verticalSpace16,
                      ],
                    ],
                  ),
                ),
              ),
              verticalSpace16,
              PrimaryElevatedButton(
                text: 'إضافة السؤال',
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
