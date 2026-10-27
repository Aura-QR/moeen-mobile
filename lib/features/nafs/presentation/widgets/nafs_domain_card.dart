import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/nafs/data/models/nafs_models.dart';
import 'package:moean/features/nafs/presentation/cubit/nafs_cubit.dart';
import 'package:moean/features/nafs/presentation/widgets/nafs_question_card.dart';

class NafsDomainCard extends StatefulWidget {
  final int domainIndex;
  final NafsDomain domain;

  const NafsDomainCard({
    super.key,
    required this.domainIndex,
    required this.domain,
  });

  @override
  State<NafsDomainCard> createState() => _NafsDomainCardState();
}

class _NafsDomainCardState extends State<NafsDomainCard> {
  late final TextEditingController _nameController = TextEditingController(text: widget.domain.name);

  @override
  void didUpdateWidget(covariant NafsDomainCard oldWidget) {
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
    final cubit = NafsCubit.get(context);
    final label = '${appTranslation().get('nafs_domain')} ${widget.domainIndex + 1}';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: PrimaryTextField(
                  controller: _nameController,
                  label: label,
                  hint: label,
                  maxLength: 140,
                  onChanged: (v) => cubit.renameDomain(widget.domainIndex, v),
                ),
              ),
              horizontalSpace6,
              IconButton(
                icon: const Icon(Icons.delete_outline, color: ColorsManager.errorColor),
                onPressed: () => cubit.removeDomain(widget.domainIndex),
              ),
            ],
          ),
          if (widget.domain.outcome != null && widget.domain.outcome!.isNotEmpty) ...[
            verticalSpace6,
            Text(
              widget.domain.outcome!,
              style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
            ),
          ],
          verticalSpace12,
          for (var qi = 0; qi < widget.domain.questions.length; qi++) ...[
            NafsQuestionCard(
              key: ValueKey('nafs-q-${widget.domainIndex}-$qi-${widget.domain.questions.length}'),
              index: qi,
              question: widget.domain.questions[qi],
              onChanged: (q) => cubit.updateQuestion(widget.domainIndex, qi, q),
              onRemove: () => cubit.removeQuestion(widget.domainIndex, qi),
            ),
            verticalSpace8,
          ],
          TextButton.icon(
            icon: Icon(Icons.add, color: ColorsManager.primaryColor),
            label: Text(
              appTranslation().get('nafs_add_question'),
              style: TextStylesManager.bold13.copyWith(color: ColorsManager.primaryColor),
            ),
            onPressed: () => cubit.addQuestion(widget.domainIndex),
          ),
        ],
      ),
    );
  }
}
