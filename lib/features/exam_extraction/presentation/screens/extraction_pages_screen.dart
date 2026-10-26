import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_pages_cubit.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_pages_state.dart';
import 'package:moean/features/exam_extraction/presentation/widgets/extraction_count_field.dart';
import 'package:moean/features/exam_extraction/presentation/widgets/extraction_notes_field.dart';
import 'package:moean/features/exam_extraction/presentation/widgets/extraction_pages_grid.dart';
import 'package:moean/features/exam_extraction/presentation/widgets/extraction_privacy_card.dart';
import 'package:moean/features/exam_extraction/presentation/widgets/extraction_source_buttons.dart';

class ExtractionPagesScreen extends StatelessWidget {
  const ExtractionPagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        title: Text(
          appTranslation().get('exam_extract_title'),
          style: TextStylesManager.bold16.copyWith(
            color: ColorsManager.mainText,
          ),
        ),
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocConsumer<ExtractionPagesCubit, ExtractionPagesState>(
          listenWhen: (previous, current) =>
              current.error != null && previous.error != current.error,
          listener: (context, state) {
            if (state.error != null) {
              showPrimarySnackBar(context, state.error!, isError: true);
              ExtractionPagesCubit.get(context).clearError();
            }
          },
          buildWhen: (previous, current) =>
              previous.canStart != current.canStart,
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ExtractionPrivacyCard(),
                  verticalSpace16,
                  const ExtractionSourceButtons(),
                  verticalSpace16,
                  const ExtractionPagesGrid(),
                  verticalSpace16,
                  const ExtractionCountField(),
                  verticalSpace12,
                  const ExtractionNotesField(),
                  verticalSpace24,
                  PrimaryElevatedButton(
                    text: appTranslation().get('exam_extract_start'),
                    onPressed: state.canStart
                        ? () {
                            final cubit = ExtractionPagesCubit.get(context);
                            Navigator.pushNamed(
                              context,
                              Routes.examExtractionReading,
                              arguments: {
                                'pages': cubit.state.pages,
                                'count': cubit.state.count,
                                'notes': cubit.state.notes,
                              },
                            );
                          }
                        : null,
                  ),
                  verticalSpace24,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
