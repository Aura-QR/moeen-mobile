import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/presentations/data/models/presentation_models.dart';
import 'package:moean/features/presentations/presentation/cubit/presentations_cubit.dart';
import  'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:moean/core/utils/constants/assets_helper.dart';
class PresentationThemeData {
  final Color primaryAccent;
  final Color darkAccent;
  final Color softContainer;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const PresentationThemeData({
    required this.primaryAccent,
    required this.darkAccent,
    required this.softContainer,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  factory PresentationThemeData.fromTemplateId(String? templateId) {
    switch (templateId) {
      case 'academic-blue':
        return const PresentationThemeData(
          primaryAccent: Color(0xFF1976D2),
          darkAccent: Color(0xFF173E61),
          softContainer: Color(0xFFEAF3FB),
          backgroundColor: Color(0xFFF7FAFE),
          textColor: Color(0xFF20343F),
          borderColor: Color(0xFFD4E4F7),
        );
      case 'warm-orange':
        return const PresentationThemeData(
          primaryAccent: Color(0xFFD89C22),
          darkAccent: Color(0xFF865806),
          softContainer: Color(0xFFFFF4D8),
          backgroundColor: Color(0xFFFFFCF5),
          textColor: Color(0xFF4E4028),
          borderColor: Color(0xFFFBE8C3),
        );
      case 'emerald-green':
      default:
        return const PresentationThemeData(
          primaryAccent: Color(0xFF0E7A5E),
          darkAccent: Color(0xFF075244),
          softContainer: Color(0xFFEAF7F2),
          backgroundColor: Color(0xFFF7FCFA),
          textColor: Color(0xFF24443D),
          borderColor: Color(0xFFEAF7F2),
        );
    }
  }
}

class PresentationPreviewScreen extends StatefulWidget {
  final PresentationModel presentation;
  final PresentationsCubit cubit;

  const PresentationPreviewScreen({
    super.key,
    required this.presentation,
    required this.cubit,
  });

  @override
  State<PresentationPreviewScreen> createState() => _PresentationPreviewScreenState();
}

class _PresentationPreviewScreenState extends State<PresentationPreviewScreen> {
  bool _isRandomPickerEnabled = false;
  final TextEditingController _namesController = TextEditingController();

  @override
  void dispose() {
    _namesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasTitleSlide = widget.presentation.slides.any((s) => s.slideType == 'title');
    final List<PresentationSlideModel> displaySlides = [];
    
    if (!hasTitleSlide) {
      displaySlides.add(
        PresentationSlideModel(
          id: -1,
          slideOrder: 0,
          slideType: 'title',
          title: widget.cubit.selectedLesson?.title ?? 'عرض تعليمي',
          bodyText: [
            if (widget.cubit.selectedSubject?.name != null) widget.cubit.selectedSubject!.name,
            if (widget.cubit.selectedGrade?.name != null) widget.cubit.selectedGrade!.name,
            if (widget.cubit.selectedUnit?.title != null) widget.cubit.selectedUnit!.title,
          ].where((e) => e.isNotEmpty).join('\n'),
          iconKeyword: 'graduation_cap',
        ),
      );
    }
    displaySlides.addAll(widget.presentation.slides);

    PresentationSlideModel? randomPickerSlide;
    if (_isRandomPickerEnabled && _namesController.text.trim().isNotEmpty) {
      final names = _namesController.text.split(RegExp(r'[,\n]+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (names.isNotEmpty) {
        randomPickerSlide = PresentationSlideModel(
          id: -2,
          slideOrder: 999,
          slideType: 'random_picker',
          title: 'اختيار عشوائي',
          bodyText: names.join('\n'),
          iconKeyword: 'users',
        );
        displaySlides.add(randomPickerSlide);
      }
    }

    final String selectedTemplate = widget.presentation.templateId ?? widget.cubit.selectedTemplate;
    final theme = PresentationThemeData.fromTemplateId(selectedTemplate);

    return BlocProvider.value(
      value: widget.cubit,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: ColorsManager.background,
          appBar: AppBar(
            backgroundColor: ColorsManager.background,
            elevation: 0,
            centerTitle: true,
            title: Text(
              appTranslation().get('presentations_title'),
              style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: ColorsManager.mainText),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.download, color: theme.primaryAccent),
                onPressed: () => widget.cubit.downloadPresentation(extraSlides: randomPickerSlide != null ? [randomPickerSlide] : null),
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(
                        'إضافة شريحة الاختيار العشوائي للطلاب',
                        style: TextStylesManager.bold14.copyWith(color: theme.darkAccent),
                      ),
                      value: _isRandomPickerEnabled,
                      activeColor: theme.primaryAccent,
                      onChanged: (val) {
                        setState(() {
                          _isRandomPickerEnabled = val;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_isRandomPickerEnabled)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: TextField(
                          controller: _namesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'أدخل أسماء الطلاب (مفصولين بفاصلة أو سطر جديد)',
                            hintStyle: TextStylesManager.regular14.copyWith(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: theme.borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: theme.primaryAccent),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: displaySlides.length,
                  itemBuilder: (context, index) {
                    final slide = displaySlides[index];
                    return _buildSlideCard(slide, index + 1, theme);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: PrimaryElevatedButton(
                  text: 'حفظ وتحميل (PPTX)',
                  icon: const Icon(Icons.download),
                  onPressed: () => widget.cubit.downloadPresentation(extraSlides: randomPickerSlide != null ? [randomPickerSlide] : null),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverSlideCard(PresentationSlideModel slide, int slideNumber, PresentationThemeData theme) {
    final randomImages = [
      AssetsHelper.scr1, AssetsHelper.scr2, AssetsHelper.scr3, AssetsHelper.scr4,
      AssetsHelper.scr5, AssetsHelper.scr6, AssetsHelper.scr7, AssetsHelper.scr8,
      AssetsHelper.scr9, AssetsHelper.scr10, AssetsHelper.scr11, AssetsHelper.scr12,
      AssetsHelper.scr13, AssetsHelper.scr14, AssetsHelper.scr15,
    ];
    final stableIndex = slide.title.length % randomImages.length;
    final coverImageAsset = randomImages[stableIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 4, color: theme.primaryAccent),
            
            // Slide Number & Label (Header)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.primaryAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$slideNumber',
                      style: TextStylesManager.bold14.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      slide.title,
                      style: TextStylesManager.bold14.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'عنوان الدرس',
                    style: TextStylesManager.bold12.copyWith(color: theme.primaryAccent),
                  ),
                ],
              ),
            ),

            // Image
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    coverImageAsset,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                slide.title,
                textAlign: TextAlign.center,
                style: TextStylesManager.bold18.copyWith(
                  color: theme.darkAccent,
                  height: 1.4,
                ),
              ),
            ),
            
            verticalSpace16,
            
            // Body text
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: _buildSlideContent(slide, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideCard(PresentationSlideModel slide, int slideNumber, PresentationThemeData theme) {
    if (slide.slideType == 'title') {
      return _buildCoverSlideCard(slide, slideNumber, theme);
    }
    
    if (['static_opening', 'static_greeting', 'static_dua'].contains(slide.slideType)) {
      return _buildSpecialSlideCard(slide, slideNumber, theme);
    }
    
    // Determine the type label
    String typeLabel = _getSlideLabel(slide.slideType);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Accent Line
            Container(
              height: 4,
              color: theme.primaryAccent,
            ),
            
            // Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Slide Number
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.primaryAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$slideNumber',
                      style: TextStylesManager.bold14.copyWith(color: Colors.white),
                    ),
                  ),
                  horizontalSpace12,
                  // Title
                  Expanded(
                    child: Text(
                      slide.title,
                      style: TextStylesManager.bold18.copyWith(
                        color: theme.darkAccent,
                        height: 1.4,
                      ),
                    ),
                  ),
                  horizontalSpace12,
                  // Type Label
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      typeLabel,
                      style: TextStylesManager.bold12.copyWith(color: theme.primaryAccent),
                    ),
                  ),
                  horizontalSpace12,
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primaryAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconData(slide.iconKeyword),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: _buildSlideContent(slide, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideContent(PresentationSlideModel slide, PresentationThemeData theme) {
    // Split bullet points by new line or bullet character
    final lines = slide.bodyText.split('\n').where((l) => l.trim().isNotEmpty).toList();

    if (slide.slideType == 'random_picker') {
      return RandomPickerWidget(names: lines, theme: theme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: lines.map((line) {
        String text = line.trim();
        if (text.startsWith('-') || text.startsWith('•')) {
          text = text.substring(1).trim();
        }
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.borderColor, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4, left: 12), // RTL Support
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.primaryAccent,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  text,
                  style: TextStylesManager.bold14.copyWith(
                    color: theme.textColor,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSpecialSlideCard(PresentationSlideModel slide, int slideNumber, PresentationThemeData theme) {
    String typeLabel = _getSlideLabel(slide.slideType);
    String imagePath;
    if (slide.slideType == 'static_opening') {
      imagePath = AssetsHelper.presentation1;
    } else if (slide.slideType == 'static_greeting') {
      imagePath = AssetsHelper.presentation2;
    } else {
      imagePath = AssetsHelper.presentation3;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Slide Number
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.darkAccent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$slideNumber',
                  style: TextStylesManager.bold14.copyWith(color: Colors.white),
                ),
              ),
              const Spacer(),
              // Subtitle & Title
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    typeLabel,
                    style: TextStylesManager.bold12.copyWith(color: theme.primaryAccent),
                  ),
                  Text(
                    slide.title,
                    style: TextStylesManager.bold20.copyWith(color: theme.darkAccent),
                  ),
                ],
              ),
              horizontalSpace12,
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.darkAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconData(slide.iconKeyword),
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          
          verticalSpace24,

          // Body (Image + Overlapping Card)
          SizedBox(
            height: slide.slideType == 'static_dua' ? 240 : 250,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Image on the Left (end in RTL)
                    PositionedDirectional(
                      end: 0,
                      top: 0,
                      bottom: slide.slideType == 'static_greeting' ? 40 : (slide.slideType == 'static_dua' ? 24 : 0),
                      width: constraints.maxWidth * 0.65,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(imagePath, fit: BoxFit.cover),
                      ),
                    ),
                    
                    // Dots for dua
                    if (slide.slideType == 'static_dua')
                      PositionedDirectional(
                        end: 0,
                        bottom: 0,
                        height: 24,
                        width: constraints.maxWidth * 0.65,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(12, (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: index == 0 ? theme.primaryAccent : theme.primaryAccent.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          )),
                        ),
                      ),

                    // White Card on the Right (start in RTL)
                    PositionedDirectional(
                      start: 0,
                      top: slide.slideType == 'static_dua' ? 40 : 24,
                      bottom: slide.slideType == 'static_dua' ? 40 : (slide.slideType == 'static_greeting' ? 64 : 24),
                      width: constraints.maxWidth * 0.55,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _buildSpecialSlideWhiteCardContent(slide, theme),
                      ),
                    ),

                    // Chips for Greeting
                    if (slide.slideType == 'static_greeting')
                      PositionedDirectional(
                        start: 0,
                        bottom: 0,
                        width: constraints.maxWidth * 0.55,
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.start,
                            children: [
                              if (widget.cubit.selectedSubject?.name != null)
                                _buildChip(widget.cubit.selectedSubject!.name, theme),
                              if (widget.cubit.selectedGrade?.name != null)
                                _buildChip(widget.cubit.selectedGrade!.name, theme),
                              if (widget.cubit.selectedUnit?.title != null)
                                _buildChip(widget.cubit.selectedUnit!.title, theme),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, PresentationThemeData theme) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.borderColor),
      ),
      child: Text(
        label,
        style: TextStylesManager.bold12.copyWith(color: theme.darkAccent),
      ),
    );
  }

  Widget _buildSpecialSlideWhiteCardContent(PresentationSlideModel slide, PresentationThemeData theme) {
    final lines = slide.bodyText.split('\n').where((l) => l.trim().isNotEmpty).toList();

    if (slide.slideType == 'static_opening') {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'نبدأ باسم الله',
                style: TextStylesManager.bold14.copyWith(color: theme.primaryAccent),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lines.length,
                itemBuilder: (context, index) {
                  String lineText = lines[index].trim();
                  if (lineText.startsWith('-') || lineText.startsWith('•')) {
                    lineText = lineText.substring(1).trim();
                  }
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.borderColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            lineText,
                            style: TextStylesManager.bold14.copyWith(color: theme.darkAccent),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.primaryAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else if (slide.slideType == 'static_greeting') {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: lines.asMap().entries.map((entry) {
            int index = entry.key;
            String lineText = entry.value.trim();
            if (lineText.startsWith('-') || lineText.startsWith('•')) {
              lineText = lineText.substring(1).trim();
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: theme.borderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.primaryAccent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStylesManager.bold12.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lineText,
                      style: TextStylesManager.bold14.copyWith(color: theme.darkAccent),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    } else if (slide.slideType == 'static_dua') {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'دعاء قبل التعلم',
                  style: TextStylesManager.bold14.copyWith(color: theme.primaryAccent),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                slide.bodyText.replaceAll('- ', '').replaceAll('• ', ''),
                style: TextStylesManager.bold16.copyWith(
                  color: theme.darkAccent,
                  height: 1.8,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  String _getSlideLabel(String? type) {
    try {
      final Map<String, String> labels = {
        'title': 'عنوان الدرس',
        'static_opening': 'افتتاحية',
        'static_greeting': 'ترحيب',
        'static_dua': 'دعاء اليوم',
        'static_classroom_rules': 'قواعد الصف',
        'static_success_criteria': 'محققات النجاح',
        'lesson_info': 'معلومات الدرس',
        'kwl_open': 'ماذا نعرف',
        'vocabulary': 'مفردات الدرس',
        'hook': 'تمهيد الدرس',
        'random_picker': 'اختيار عشوائي',
        'content': 'شرح الدرس',
        'cross_curricular': 'الربط بالمواد الأخرى',
        'reading_stages': 'مراحل القراءة',
        'closing_strategy': 'استراتيجية الإغلاق',
        'worksheet': 'ورقة عمل',
        'kwl_close': 'ماذا تعلمنا',
        'homework': 'الواجب المنزلي',
        'objectives': 'أهداف التعلم',
        'example': 'مثال تطبيقي',
        'summary': 'ملخص الدرس',
        'quiz_prompt': 'أسئلة ومناقشة',
      };
      return labels[type] ?? 'محتوى تعليمي';
    } catch (e) {
      print('Error in _getSlideLabel for type $type: $e');
      return 'محتوى تعليمي';
    }
  }

  IconData _getIconData(String? keyword) {
    if (keyword == null) return LucideIcons.layoutTemplate;
    final k = keyword.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
    switch (k) {
      case 'lightbulb': return LucideIcons.lightbulb;
      case 'book':
      case 'book_open': return LucideIcons.bookOpen;
      case 'target': return LucideIcons.target;
      case 'users': return LucideIcons.users;
      case 'message_circle': return LucideIcons.messageCircle;
      case 'check_circle': return LucideIcons.checkCircle;
      case 'puzzle': return LucideIcons.puzzle;
      case 'activity': return LucideIcons.activity;
      case 'star': return LucideIcons.star;
      case 'award': return LucideIcons.award;
      case 'file_text': return LucideIcons.fileText;
      case 'play_circle': return LucideIcons.playCircle;
      case 'help_circle': return LucideIcons.helpCircle;
      case 'info': return LucideIcons.info;
      case 'video': return LucideIcons.video;
      case 'mic': return LucideIcons.mic;
      case 'ear': return LucideIcons.ear;
      case 'eye': return LucideIcons.eye;
      case 'pen_tool': return LucideIcons.penTool;
      case 'graduation_cap': return LucideIcons.graduationCap;
      case 'sparkles': return LucideIcons.sparkles;
      default: return LucideIcons.layoutTemplate;
    }
  }
}

class RandomPickerWidget extends StatefulWidget {
  final List<String> names;
  final PresentationThemeData theme;

  const RandomPickerWidget({
    Key? key,
    required this.names,
    required this.theme,
  }) : super(key: key);

  @override
  State<RandomPickerWidget> createState() => _RandomPickerWidgetState();
}

class _RandomPickerWidgetState extends State<RandomPickerWidget> {
  int? _highlightedIndex;
  int? _selectedIndex;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _spin();
    });
  }

  void _spin() async {
    if (_isSpinning || widget.names.isEmpty) return;
    setState(() {
      _isSpinning = true;
      _selectedIndex = null;
      _highlightedIndex = null;
    });

    final random = Random();
    final targetIndex = random.nextInt(widget.names.length);
    
    // Total steps to take
    int steps = widget.names.length * 3 + targetIndex;
    
    for (int i = 0; i < steps; i++) {
      if (!mounted) return;
      setState(() {
        _highlightedIndex = i % widget.names.length;
      });
      
      // Calculate delay: starts fast (50ms), slows down near the end (up to 400ms)
      int delay = 50 + (i / steps * 200).toInt();
      if (i > steps - 5) delay += 100; // Extra slow at the very end
      
      await Future.delayed(Duration(milliseconds: delay));
    }
    
    if (!mounted) return;
    setState(() {
      _isSpinning = false;
      _selectedIndex = targetIndex;
      _highlightedIndex = targetIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(widget.names.length, (index) {
            final name = widget.names[index];
            final isHighlighted = _highlightedIndex == index;
            final isSelected = _selectedIndex == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? widget.theme.primaryAccent 
                    : isHighlighted 
                        ? widget.theme.primaryAccent.withOpacity(0.5) 
                        : widget.theme.softContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isHighlighted || isSelected 
                      ? widget.theme.primaryAccent 
                      : widget.theme.primaryAccent.withOpacity(0.3), 
                  width: isHighlighted || isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: widget.theme.primaryAccent.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ] : null,
              ),
              child: Text(
                name.trim(),
                style: TextStylesManager.bold14.copyWith(
                  color: isSelected || isHighlighted ? Colors.white : widget.theme.darkAccent,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class GreetingWidget extends StatelessWidget {
  final String text;
  final PresentationThemeData theme;
  final PresentationsCubit cubit;

  const GreetingWidget({
    Key? key,
    required this.text,
    required this.theme,
    required this.cubit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lines = text.isEmpty 
      ? [
          'نبدأ يومنا بطاقة إيجابية وحماس للتعلم.',
          'نتمنى لكم درسًا ممتعًا ومليئًا بالإنجاز.'
        ]
      : text.split('\n').where((l) => l.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left side in mockup: Image
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.primaryAccent, width: 2),
            image: const DecorationImage(
              image: AssetImage(AssetsHelper.scr16),
              fit: BoxFit.cover,
            ),
          ),
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
              color: theme.primaryAccent.withValues(alpha: 0.8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'التعليم في المملكة العربية السعودية',
                  style: TextStylesManager.bold14.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Right side in mockup: Bullets
        ...List.generate(lines.length, (index) {
          String lineText = lines[index].trim();
          if (lineText.startsWith('-') || lineText.startsWith('•')) {
            lineText = lineText.substring(1).trim();
          }
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.borderColor, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.primaryAccent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: TextStylesManager.bold12.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    lineText,
                    style: TextStylesManager.bold14.copyWith(color: theme.darkAccent, height: 1.5),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        // Bottom tags
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            if (cubit.selectedSubject?.name != null) _buildTag(cubit.selectedSubject!.name, theme),
            if (cubit.selectedGrade?.name != null) _buildTag(cubit.selectedGrade!.name, theme),
            if (cubit.selectedUnit?.title != null) _buildTag(cubit.selectedUnit!.title, theme),
          ],
        ),
      ],
    );
  }

  Widget _buildTag(String label, PresentationThemeData theme) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.borderColor),
      ),
      child: Text(
        label,
        style: TextStylesManager.bold12.copyWith(color: theme.primaryAccent),
      ),
    );
  }
}
