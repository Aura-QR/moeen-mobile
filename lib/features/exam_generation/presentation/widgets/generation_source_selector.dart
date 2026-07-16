import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/exam_generation/presentation/cubit/exam_info_cubit.dart';

class GenerationSourceSelector extends StatelessWidget {
  const GenerationSourceSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExamInfoCubit, ExamInfoState>(
      builder: (context, state) {
        final cubit = context.read<ExamInfoCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('طريقة بناء الاختبار', style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
            verticalSpace8,
            Row(
              children: [
                Expanded(
                  child: _SourceOptionCard(
                    title: 'توليد تلقائي بالذكاء الاصطناعي',
                    value: GenerationSource.aiOnly,
                    groupValue: cubit.generationSource,
                    onChanged: (val) => cubit.updateGenerationSource(val!),
                  ),
                ),
                horizontalSpace8,
                Expanded(
                  child: _SourceOptionCard(
                    title: 'اختيار من بنك الأسئلة أولاً',
                    value: GenerationSource.mixed,
                    groupValue: cubit.generationSource,
                    onChanged: (val) => cubit.updateGenerationSource(val!),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SourceOptionCard extends StatelessWidget {
  final String title;
  final GenerationSource value;
  final GenerationSource groupValue;
  final ValueChanged<GenerationSource?> onChanged;

  const _SourceOptionCard({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? ColorsManager.primaryColor.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? ColorsManager.primaryColor : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Radio<GenerationSource>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: ColorsManager.primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            ),
            horizontalSpace8,
            Expanded(
              child: Text(
                title,
                style: isSelected ? TextStylesManager.bold12 : TextStylesManager.regular12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
