import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_choice_chips.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/widgets/document_image_preview.dart';
import 'package:moean/features/reports/data/models/report_block.dart';
import 'package:moean/features/reports/data/models/report_block_edits.dart';
import 'package:moean/features/reports/presentation/cubit/report_editor_cubit.dart';

/// Picks which of the report's photos this block shows, and how many per row.
class ReportImagesBlockEditor extends StatelessWidget {
  final ImagesBlock block;

  const ReportImagesBlockEditor({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    final cubit = ReportEditorCubit.get(context);
    return BlocBuilder<ReportEditorCubit, ReportEditorState>(
      buildWhen: (previous, current) => previous.images != current.images,
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.images.isEmpty)
            Text(
              appTranslation().get('report_images_empty'),
              style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final image in state.images)
                  InkWell(
                    onTap: () => cubit.updateBlock(block.toggle(image.storagePath)),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 72,
                      height: 72,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          width: 2,
                          color: block.items.contains(image.storagePath)
                              ? ColorsManager.primaryColor
                              : ColorsManager.borderLightGray,
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          DocumentImagePreview(image: image),
                          if (block.items.contains(image.storagePath))
                            Align(
                              alignment: AlignmentDirectional.topEnd,
                              child: Icon(Icons.check_circle_rounded, size: 20, color: ColorsManager.primaryColor),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          verticalSpace12,
          PrimaryChoiceChips<int>(
            options: const [1, 2, 3],
            labelOf: (count) => appTranslation().get('report_images_per_row').replaceAll('{n}', '$count'),
            isSelected: (count) => block.columns == count,
            onTap: (count) => cubit.updateBlock(block.copyWith(columns: count)),
          ),
        ],
      ),
    );
  }
}
