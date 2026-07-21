import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/presentations/data/models/presentation_models.dart';
import 'package:moean/features/presentations/presentation/cubit/presentations_cubit.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
                icon: Icon(Icons.download, color: ColorsManager.primaryColor),
                onPressed: () => cubit.downloadPresentation(),
              ),
            ],
          ),
          body: Column(
            children: [
              // Container(
              //   padding: const EdgeInsets.all(24),
              //   decoration: BoxDecoration(
              //     color: ColorsManager.primaryColor,
              //   ),
              //   child: Column(
              //     children: [
              //       const Icon(Icons.auto_awesome, color: Colors.white, size: 48),
              //       verticalSpace16,
              //       Text(
              //         'تم إنشاء العرض التقديمي بنجاح!',
              //         style: TextStylesManager.bold20.copyWith(color: Colors.white),
              //       ),
              //       verticalSpace8,
              //       Text(
              //         'يحتوي العرض على ${presentation.slideCount ?? presentation.slides.length} شرائح جاهزة للتحميل.',
              //         style: TextStylesManager.regular14.copyWith(color: Colors.white.withValues(alpha: 0.8)),
              //       ),
              //     ],
              //   ),
              // ),
             
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: presentation.slides.length,
                  itemBuilder: (context, index) {
                    final slide = presentation.slides[index];
                    return _buildSlideCard(slide, index + 1);
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
                  ],
                ),
                child: PrimaryElevatedButton(
                  text: 'حفظ وتحميل (PPTX)',
                  icon: const Icon(Icons.download),
                  onPressed: () => cubit.downloadPresentation(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlideCard(PresentationSlideModel slide, int slideNumber) {
    // Determine the type label
    String typeLabel = _getSlideLabel(slide.slideType);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FCFA), // Emerald Green Background
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
              color: const Color(0xFF0E7A5E),
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
                      color: const Color(0xFF0E7A5E),
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
                        color: const Color(0xFF075244),
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
                      style: TextStylesManager.bold12.copyWith(color: const Color(0xFF0E7A5E)),
                    ),
                  ),
                  horizontalSpace12,
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E7A5E),
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
              child: _buildSlideContent(slide.bodyText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideContent(String bodyText) {
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
            border: Border.all(color: const Color(0xFFEAF7F2), width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4, left: 12), // RTL Support
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF0E7A5E),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  text,
                  style: TextStylesManager.bold14.copyWith(
                    color: const Color(0xFF24443D), // Text color from theme
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
