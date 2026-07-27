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

class PresentationPreviewScreen extends StatelessWidget {
  final PresentationModel presentation;
  final PresentationsCubit cubit;

  const PresentationPreviewScreen({
    super.key,
    required this.presentation,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasTitleSlide = presentation.slides.any((s) => s.slideType == 'title');
    final List<PresentationSlideModel> displaySlides = [];
    
    if (!hasTitleSlide) {
      displaySlides.add(
        PresentationSlideModel(
          id: -1,
          slideOrder: 0,
          slideType: 'title',
          title: cubit.selectedLesson?.title ?? 'عرض تعليمي',
          bodyText: [
            if (cubit.selectedSubject?.name != null) cubit.selectedSubject!.name,
            if (cubit.selectedGrade?.name != null) cubit.selectedGrade!.name,
            if (cubit.selectedUnit?.title != null) cubit.selectedUnit!.title,
          ].where((e) => e.isNotEmpty).join('\n'),
          iconKeyword: 'graduation_cap',
        ),
      );
    }
    displaySlides.addAll(presentation.slides);

    final String selectedTemplate = presentation.templateId ?? cubit.selectedTemplate;
    final theme = PresentationThemeData.fromTemplateId(selectedTemplate);

    return BlocProvider.value(
      value: cubit,
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
                onPressed: () => cubit.downloadPresentation(),
              ),
            ],
          ),
          body: Column(
            children: [
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
              PrimaryElevatedButton(
                text: 'حفظ وتحميل (PPTX)',
                icon: const Icon(Icons.download),
                onPressed: () => cubit.downloadPresentation(),
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
              child: _buildSlideContent(slide.bodyText, theme),
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
              child: _buildSlideContent(slide.bodyText, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideContent(String bodyText, PresentationThemeData theme) {
    // Split bullet points by new line or bullet character
    final lines = bodyText.split('\n').where((l) => l.trim().isNotEmpty).toList();

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

  String _getSlideLabel(String type) {
    final Map<String, String> labels = {
      'title': 'عنوان الدرس',
      'objectives': 'أهداف التعلم',
      'content': 'شرح الدرس',
      'example': 'مثال تطبيقي',
      'summary': 'ملخص الدرس',
      'quiz_prompt': 'أسئلة ومناقشة',
    };
    return labels[type] ?? 'محتوى تعليمي';
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
