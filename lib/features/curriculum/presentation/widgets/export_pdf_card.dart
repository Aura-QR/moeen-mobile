import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class ExportPdfCard extends StatefulWidget {
  final Future<void> Function(String school, String teacher, String manager)? onExport;

  const ExportPdfCard({super.key, this.onExport});

  @override
  State<ExportPdfCard> createState() => _ExportPdfCardState();
}

class _ExportPdfCardState extends State<ExportPdfCard> {
  final _schoolController = TextEditingController();
  final _teacherController = TextEditingController();
  final _managerController = TextEditingController();
  bool _isExporting = false;

  @override
  void dispose() {
    _schoolController.dispose();
    _teacherController.dispose();
    _managerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.borderLightGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.print_outlined,
                  color: ColorsManager.primaryColor,
                  size: 22,
                ),
              ),
              horizontalSpace12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تنزيل التوزيع',
                      style: TextStylesManager.bold14.copyWith(
                        color: ColorsManager.mainText,
                      ),
                    ),
                    verticalSpace2,
                    Text(
                      'أضف بيانات مدرستك ثم اطبع الخطة أو احفظها بتنسيق PDF',
                      style: TextStylesManager.regular12.copyWith(
                        color: ColorsManager.secondaryText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpace16,
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;
              if (isWide) {
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اسم المدرسة',
                            style: TextStylesManager.bold12.copyWith(
                              color: ColorsManager.mainText,
                            ),
                          ),
                          verticalSpace6,
                          PrimaryTextField(
                            controller: _schoolController,
                            hint: 'مثال: ابتدائية الأندلس',
                          ),
                        ],
                      ),
                    ),
                    horizontalSpace12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المعلم /ة',
                            style: TextStylesManager.bold12.copyWith(
                              color: ColorsManager.mainText,
                            ),
                          ),
                          verticalSpace6,
                          PrimaryTextField(
                            controller: _teacherController,
                            hint: 'اسم المعلم',
                          ),
                        ],
                      ),
                    ),
                    horizontalSpace12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المدير /ة',
                            style: TextStylesManager.bold12.copyWith(
                              color: ColorsManager.mainText,
                            ),
                          ),
                          verticalSpace6,
                          PrimaryTextField(
                            controller: _managerController,
                            hint: 'اسم المدير',
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اسم المدرسة',
                    style: TextStylesManager.bold12.copyWith(
                      color: ColorsManager.mainText,
                    ),
                  ),
                  verticalSpace6,
                  PrimaryTextField(
                    controller: _schoolController,
                    hint: 'مثال: ابتدائية الأندلس',
                  ),
                  verticalSpace12,
                  Text(
                    'المعلم /ة',
                    style: TextStylesManager.bold12.copyWith(
                      color: ColorsManager.mainText,
                    ),
                  ),
                  verticalSpace6,
                  PrimaryTextField(
                    controller: _teacherController,
                    hint: 'اسم المعلم',
                  ),
                  verticalSpace12,
                  Text(
                    'المدير /ة',
                    style: TextStylesManager.bold12.copyWith(
                      color: ColorsManager.mainText,
                    ),
                  ),
                  verticalSpace6,
                  PrimaryTextField(
                    controller: _managerController,
                    hint: 'اسم المدير',
                  ),
                ],
              );
            },
          ),
          verticalSpace16,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isExporting
                  ? null
                  : () async {
                      if (widget.onExport != null) {
                        setState(() => _isExporting = true);
                        await widget.onExport!(
                          _schoolController.text.trim(),
                          _teacherController.text.trim(),
                          _managerController.text.trim(),
                        );
                        if (mounted) setState(() => _isExporting = false);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('سيتم توفير هذه الميزة قريباً')),
                        );
                      }
                    },
              icon: _isExporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.print, size: 18),
              label: Text(_isExporting ? 'جاري التصدير...' : 'تنزيل PDF / طباعة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF13192B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
