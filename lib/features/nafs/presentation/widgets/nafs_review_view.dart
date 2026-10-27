import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/nafs/presentation/cubit/nafs_cubit.dart';
import 'package:moean/features/nafs/presentation/widgets/nafs_domain_card.dart';
import 'package:moean/features/nafs/presentation/widgets/nafs_passage_card.dart';

class NafsReviewView extends StatefulWidget {
  final NafsState state;

  const NafsReviewView({
    super.key,
    required this.state,
  });

  @override
  State<NafsReviewView> createState() => _NafsReviewViewState();
}

class _NafsReviewViewState extends State<NafsReviewView> {
  late final TextEditingController _titleController = TextEditingController(text: widget.state.title);

  @override
  void didUpdateWidget(covariant NafsReviewView oldWidget) {
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
    final cubit = NafsCubit.get(context);
    final state = widget.state;
    final showPassage = state.isReading || state.passage.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
              verticalSpace8,
              Text(
                appTranslation().get('nafs_review_hint'),
                style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
              ),
            ],
          ),
        ),
        verticalSpace12,
        if (showPassage) ...[
          NafsPassageCard(passage: state.passage),
          verticalSpace12,
        ],
        for (var di = 0; di < state.domains.length; di++)
          NafsDomainCard(
            key: ValueKey('nafs-domain-$di-${state.domains.length}'),
            domainIndex: di,
            domain: state.domains[di],
          ),
        verticalSpace8,
        PrimaryElevatedButton(
          text: appTranslation().get('nafs_save'),
          isLoading: state.isSaving,
          onPressed: cubit.save,
        ),
        verticalSpace8,
        OutlinedButton(
          onPressed: cubit.restart,
          child: Text(
            appTranslation().get('nafs_restart'),
            style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor),
          ),
        ),
        verticalSpace8,
        Text(
          appTranslation().get('nafs_after_save'),
          textAlign: TextAlign.center,
          style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
        ),
        verticalSpace16,
      ],
    );
  }
}
