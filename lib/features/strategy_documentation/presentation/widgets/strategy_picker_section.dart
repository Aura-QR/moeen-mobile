import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/documents/presentation/widgets/document_picker_tile.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/features/strategy_documentation/presentation/cubit/strategy_documentation_cubit.dart';
import 'package:moean/features/strategy_documentation/presentation/widgets/strategy_picker_sheet.dart';

/// «الاستراتيجية».
class StrategyPickerSection extends StatelessWidget {
  const StrategyPickerSection({super.key});

  Future<void> _pick(BuildContext context, StrategyDocumentationState state) async {
    final cubit = StrategyDocumentationCubit.get(context);
    final key = await StrategyPickerSheet.show(context, state.catalogue, selectedKey: state.strategyKey);
    if (key != null) cubit.selectStrategy(key);
  }

  @override
  Widget build(BuildContext context) {
    return PrimarySectionCard(
      icon: Icons.tips_and_updates_outlined,
      title: appTranslation().get('strategy_section_strategy'),
      child: BlocBuilder<StrategyDocumentationCubit, StrategyDocumentationState>(
        buildWhen: (previous, current) =>
            previous.strategyKey != current.strategyKey ||
            previous.strategy != current.strategy ||
            previous.isLoadingStrategy != current.isLoadingStrategy,
        builder: (context, state) => DocumentPickerTile(
          icon: Icons.search_rounded,
          hint: appTranslation().get('strategy_pick_hint'),
          value: state.strategyName,
          isLoading: state.isLoadingStrategy,
          onTap: () => _pick(context, state),
        ),
      ),
    );
  }
}
