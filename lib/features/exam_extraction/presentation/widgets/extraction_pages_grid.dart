import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_pages_cubit.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_pages_state.dart';
import 'package:moean/features/exam_extraction/presentation/widgets/extraction_page_thumbnail.dart';
import 'package:moean/features/exam_extraction/presentation/widgets/extraction_pdf_tile.dart';

class ExtractionPagesGrid extends StatelessWidget {
  const ExtractionPagesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExtractionPagesCubit, ExtractionPagesState>(
      buildWhen: (previous, current) => previous.pages != current.pages,
      builder: (context, state) {
        if (state.pages.isEmpty) {
          return const SizedBox.shrink();
        }

        final isPdf = state.pages.first.isPdf;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appTranslation()
                      .get('exam_extract_pages_counter')
                      .replaceAll('{count}', '${state.pages.length}'),
                  style: TextStylesManager.bold13.copyWith(
                    color: ColorsManager.primaryColor,
                  ),
                ),
              ],
            ),
            verticalSpace8,
            if (isPdf)
              ExtractionPdfTile(page: state.pages.first)
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: state.pages.length,
                itemBuilder: (context, index) {
                  return ExtractionPageThumbnail(
                    index: index,
                    page: state.pages[index],
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
