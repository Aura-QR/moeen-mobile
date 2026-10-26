import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_confirm_dialog.dart';
import 'package:moean/core/utils/constants/primary/primary_file_source_sheet.dart';
import 'package:moean/core/utils/constants/primary/primary_input_dialog.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/portfolio/data/models/portfolio_model.dart';
import 'package:moean/features/portfolio/presentation/cubit/portfolio_editor_cubit.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_evidence_badge_widget.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_expandable_card_widget.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_files_strip_widget.dart';

class PortfolioItemCardWidget extends StatelessWidget {
  final PortfolioItemModel item;
  final bool initiallyExpanded;

  const PortfolioItemCardWidget({super.key, required this.item, this.initiallyExpanded = false});

  /// Standard items only allow editing the description.
  Future<void> _edit(BuildContext context) async {
    final cubit = PortfolioEditorCubit.get(context);
    final values = await PrimaryInputDialog.show(context, titleKey: 'portfolio_edit_item', fields: [
      if (item.isCustom) PrimaryInputField(hintKey: 'portfolio_item_title', initialValue: item.title),
      PrimaryInputField(hintKey: 'portfolio_item_description', initialValue: item.description ?? '', maxLines: 3),
    ]);
    if (values == null) return;
    cubit.updateItem(item, title: item.isCustom ? values.first : null, description: values.last);
  }

  Future<void> _addEvidence(BuildContext context) async {
    final cubit = PortfolioEditorCubit.get(context);
    final source = await PrimaryFileSourceSheet.show(context, titleKey: 'portfolio_add_evidence');
    if (source != null) cubit.pickAndUpload(item.id, source);
  }

  Future<void> _addLink(BuildContext context) async {
    final cubit = PortfolioEditorCubit.get(context);
    final values = await PrimaryInputDialog.show(context, titleKey: 'portfolio_add_link', fields: const [
      PrimaryInputField(hintKey: 'portfolio_link_url', keyboardType: TextInputType.url),
      PrimaryInputField(hintKey: 'portfolio_link_title'),
    ]);
    if (values != null) cubit.addLink(item.id, values[0], values[1]);
  }

  Future<void> _delete(BuildContext context) async {
    final cubit = PortfolioEditorCubit.get(context);
    final confirmed = await showPrimaryConfirmDialog(
      context,
      titleKey: 'portfolio_delete_item',
      messageKey: 'portfolio_delete_item_confirm',
    );
    if (confirmed) cubit.deleteItem(item);
  }

  @override
  Widget build(BuildContext context) {
    final muted = item.included ? ColorsManager.mainText : ColorsManager.secondaryText;
    return PortfolioExpandableCardWidget(
      initiallyExpanded: initiallyExpanded,
      leading: Checkbox(
        value: item.included,
        activeColor: ColorsManager.primaryColor,
        onChanged: (value) => PortfolioEditorCubit.get(context).setIncluded(item, value ?? false),
      ),
      title: Text(item.title, style: TextStylesManager.bold14.copyWith(color: muted)),
      subtitle: PortfolioEvidenceBadgeWidget(count: item.files.length),
      children: [
        InkWell(
          onTap: () => _edit(context),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  (item.description ?? '').isEmpty
                      ? appTranslation().get('portfolio_add_description')
                      : item.description!,
                  style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
                ),
              ),
              Icon(Icons.edit_outlined, size: 18, color: ColorsManager.secondaryText),
            ],
          ),
        ),
        verticalSpace12,
        if (item.files.isNotEmpty) PortfolioFilesStripWidget(item: item),
        BlocSelector<PortfolioEditorCubit, PortfolioEditorState, double?>(
          selector: (state) => state.uploadingItemId == item.id ? state.uploadProgress : null,
          builder: (context, progress) => progress == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(6),
                    color: ColorsManager.primaryColor,
                    backgroundColor: ColorsManager.primaryColor.withValues(alpha: 0.12),
                  ),
                ),
        ),
        verticalSpace8,
        Wrap(
          spacing: 4,
          children: [
            TextButton.icon(
              onPressed: () => _addEvidence(context),
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
              label: Text(appTranslation().get('portfolio_add_evidence')),
            ),
            TextButton.icon(
              onPressed: () => _addLink(context),
              icon: const Icon(Icons.link_rounded, size: 20),
              label: Text(appTranslation().get('portfolio_add_link')),
            ),
            if (item.isCustom)
              TextButton.icon(
                onPressed: () => _delete(context),
                style: TextButton.styleFrom(foregroundColor: ColorsManager.errorColor),
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                label: Text(appTranslation().get('portfolio_delete_item')),
              ),
          ],
        ),
      ],
    );
  }
}
