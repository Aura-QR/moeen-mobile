import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/cubit/document_preview_cubit.dart';

/// The page from the [DocumentPreviewCubit] above, portrait or landscape as
/// the page is. The last image stays, dimmed, while a newer one renders.
class DocumentPreviewImage extends StatelessWidget {
  const DocumentPreviewImage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentPreviewCubit, DocumentPreviewState>(
      builder: (context, state) {
        final image = state.image;
        final isLoading = state.status == DocumentPreviewStatus.loading;
        return AspectRatio(
          aspectRatio: state.aspectRatio,
          child: DecoratedBox(
            decoration: BoxDecoration(
              // The page itself stays light in dark mode, as printed.
              color: ColorsManager.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorsManager.borderLightGray),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (image != null)
                    AnimatedOpacity(
                      opacity: isLoading ? 0.45 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: Image.memory(image, fit: BoxFit.contain, gaplessPlayback: true),
                    ),
                  if (isLoading) const Center(child: CircularProgressIndicator()),
                  if (state.status == DocumentPreviewStatus.failure && image == null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image_outlined, color: ColorsManager.secondaryText),
                            verticalSpace6,
                            Text(
                              appTranslation().get(state.errorMessage ?? 'document_preview_failed'),
                              textAlign: TextAlign.center,
                              style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
