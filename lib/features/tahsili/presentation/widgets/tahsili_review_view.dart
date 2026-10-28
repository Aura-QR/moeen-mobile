import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/tahsili/presentation/cubit/tahsili_cubit.dart';
import 'package:moean/features/tahsili/presentation/widgets/tahsili_domain_card.dart';
import 'package:moean/features/tahsili/presentation/widgets/tahsili_review_banner.dart';

class TahsiliReviewView extends StatefulWidget {
  final TahsiliState state;

  const TahsiliReviewView({
    super.key,
    required this.state,
  });

  @override
  State<TahsiliReviewView> createState() => _TahsiliReviewViewState();
}

class _TahsiliReviewViewState extends State<TahsiliReviewView> {
  late final TextEditingController _titleController = TextEditingController(text: widget.state.title);

  @override
  void didUpdateWidget(covariant TahsiliReviewView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.title != widget.state.title && _titleController.text != widget.state.title) {
      _titleController.text = widget.state.title;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = TahsiliCubit.get(context);
    final state = widget.state;
    final titleError = state.fieldError('title');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const TahsiliReviewBanner(),
        verticalSpace12,
        PrimarySectionCard(
          icon: Icons.assignment_turned_in_outlined,
          title: appTranslation().get('online_tests_test_title'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PrimaryTextField(
                controller: _titleController,
                hint: appTranslation().get('online_tests_test_title'),
                maxLength: 255,
                onChanged: cubit.setTitle,
              ),
              if (titleError != null) ...[
                verticalSpace4,
                Text(
                  titleError,
                  style: TextStylesManager.bold12.copyWith(color: ColorsManager.errorColor),
                ),
              ],
            ],
          ),
        ),
        verticalSpace12,
        for (var di = 0; di < state.domains.length; di++) ...[
          TahsiliDomainCard(
            key: ValueKey('tahsili-domain-$di-${state.domains.length}'),
            domainIndex: di,
            domain: state.domains[di],
            fieldErrors: state.fieldErrors,
          ),
          verticalSpace12,
        ],
        verticalSpace8,
        PrimaryElevatedButton(
          text: appTranslation().get('tahsili_save'),
          isLoading: state.isSaving,
          onPressed: cubit.save,
        ),
        verticalSpace8,
        OutlinedButton(
          onPressed: cubit.restart,
          child: Text(
            appTranslation().get('tahsili_restart'),
            style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor),
          ),
        ),
        verticalSpace8,
        Text(
          appTranslation().get('tahsili_after_save'),
          textAlign: TextAlign.center,
          style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
        ),
        verticalSpace16,
      ],
    );
  }
}
