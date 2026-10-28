import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/tahsili/data/models/tahsili_models.dart';
import 'package:moean/features/tahsili/presentation/cubit/tahsili_cubit.dart';
import 'package:moean/features/tahsili/presentation/widgets/tahsili_question_card.dart';

class TahsiliDomainCard extends StatefulWidget {
  final int domainIndex;
  final TahsiliDomain domain;
  final Map<String, String> fieldErrors;

  const TahsiliDomainCard({
    super.key,
    required this.domainIndex,
    required this.domain,
    this.fieldErrors = const {},
  });

  @override
  State<TahsiliDomainCard> createState() => _TahsiliDomainCardState();
}

class _TahsiliDomainCardState extends State<TahsiliDomainCard> {
  late final TextEditingController _nameController = TextEditingController(text: widget.domain.name);

  @override
  void didUpdateWidget(covariant TahsiliDomainCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.domain.name != widget.domain.name && _nameController.text != widget.domain.name) {
      _nameController.text = widget.domain.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = TahsiliCubit.get(context);
    final di = widget.domainIndex;
    final label = '${appTranslation().get('tahsili_domain')} ${di + 1}';
    final domainPath = 'skills.$di';
    final domainNamePath = 'skills.$di.name';
    final domainError = widget.fieldErrors[domainPath] ?? widget.fieldErrors[domainNamePath];

    return PrimarySectionCard(
      icon: Icons.category_outlined,
      title: label,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: ColorsManager.errorColor, size: 20),
        onPressed: () => cubit.removeDomain(di),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryTextField(
            controller: _nameController,
            hint: appTranslation().get('tahsili_domain'),
            onChanged: (v) => cubit.renameDomain(di, v),
          ),
          if (domainError != null) ...[
            verticalSpace4,
            Text(
              domainError,
              style: TextStylesManager.bold12.copyWith(color: ColorsManager.errorColor),
            ),
          ],
          if (widget.domain.outcome != null && widget.domain.outcome!.isNotEmpty) ...[
            verticalSpace6,
            Text(
              widget.domain.outcome!,
              style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
            ),
          ],
          verticalSpace12,
          for (var qi = 0; qi < widget.domain.questions.length; qi++) ...[
            TahsiliQuestionCard(
              key: ValueKey('tahsili-q-$di-$qi-${widget.domain.questions.length}'),
              index: qi,
              question: widget.domain.questions[qi],
              errorMessage: widget.fieldErrors['skills.$di.questions.$qi.text'] ??
                  widget.fieldErrors['skills.$di.questions.$qi'] ??
                  widget.fieldErrors['skills.$di.questions.$qi.correct_answer'],
              onChanged: (q) => cubit.updateQuestion(di, qi, q),
              onRemove: () => cubit.removeQuestion(di, qi),
            ),
            verticalSpace10,
          ],
          OutlinedButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              appTranslation().get('tahsili_add_question'),
              style: TextStylesManager.bold13.copyWith(color: ColorsManager.primaryColor),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: ColorsManager.primaryColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => cubit.addQuestion(di),
          ),
        ],
      ),
    );
  }
}
