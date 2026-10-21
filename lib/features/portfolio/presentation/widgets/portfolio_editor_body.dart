import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/portfolio/data/models/portfolio_model.dart';
import 'package:moean/features/portfolio/presentation/cubit/portfolio_editor_cubit.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_basic_info_section.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_editor_header_widget.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_input_dialog.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_item_card_widget.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_share_sheet.dart';

/// Holds one key per item so a missing-item chip can scroll to it.
class PortfolioEditorBody extends StatefulWidget {
  const PortfolioEditorBody({super.key});

  @override
  State<PortfolioEditorBody> createState() => _PortfolioEditorBodyState();
}

class _PortfolioEditorBodyState extends State<PortfolioEditorBody> {
  final Map<int, GlobalKey> _itemKeys = {};

  void _scrollTo(String title) {
    final items = PortfolioEditorCubit.get(context).state.portfolio?.items ?? const <PortfolioItemModel>[];
    final match = items.where((item) => item.title == title).firstOrNull;
    final targetContext = match == null ? null : _itemKeys[match.id]?.currentContext;
    if (targetContext == null) return;
    Scrollable.ensureVisible(targetContext, duration: const Duration(milliseconds: 400), alignment: 0.1);
  }

  Future<void> _addItem() async {
    final cubit = PortfolioEditorCubit.get(context);
    final values = await PortfolioInputDialog.show(context, titleKey: 'portfolio_add_item', fields: const [
      PortfolioInputField(hintKey: 'portfolio_item_title'),
      PortfolioInputField(hintKey: 'portfolio_item_description', maxLines: 3),
    ]);
    if (values != null) cubit.addItem(values[0], values[1]);
  }

  @override
  Widget build(BuildContext context) {
    final profile = PortfolioEditorCubit.get(context).state.portfolio?.profile ?? const PortfolioProfileModel();
    return RefreshIndicator(
      onRefresh: PortfolioEditorCubit.get(context).refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PortfolioEditorHeaderWidget(
              onMissingTap: _scrollTo,
              onShareTap: () => PortfolioShareSheet.show(context),
            ),
            verticalSpace16,
            PortfolioBasicInfoSection(profile: profile),
            verticalSpace24,
            Text(
              appTranslation().get('portfolio_evidence'),
              style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
            ),
            verticalSpace12,
            BlocBuilder<PortfolioEditorCubit, PortfolioEditorState>(
              buildWhen: (previous, current) => previous.portfolio?.items != current.portfolio?.items,
              builder: (context, state) => Column(
                children: [
                  for (final item in state.portfolio?.items ?? const <PortfolioItemModel>[])
                    Padding(
                      key: _itemKeys.putIfAbsent(item.id, GlobalKey.new),
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PortfolioItemCardWidget(item: item),
                    ),
                ],
              ),
            ),
            verticalSpace6,
            OutlinedButton.icon(
              onPressed: _addItem,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: ColorsManager.primaryColor,
                side: BorderSide(color: ColorsManager.primaryColor.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text(appTranslation().get('portfolio_add_item'), style: TextStylesManager.bold14),
            ),
          ],
        ),
      ),
    );
  }
}
