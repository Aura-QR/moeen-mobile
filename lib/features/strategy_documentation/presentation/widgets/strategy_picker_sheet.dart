import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/no_data_widget.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/strategy_documentation/data/models/strategy_models.dart';
import 'package:moean/features/strategy_documentation/presentation/widgets/strategy_category_group.dart';

/// A searchable list of strategies grouped by category. Pops with the key.
/// The query is local UI state; filtering lives in [StrategyCatalogueModel.grouped].
class StrategyPickerSheet extends StatefulWidget {
  final StrategyCatalogueModel catalogue;
  final String? selectedKey;

  const StrategyPickerSheet({super.key, required this.catalogue, this.selectedKey});

  static Future<String?> show(BuildContext context, StrategyCatalogueModel catalogue, {String? selectedKey}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StrategyPickerSheet(catalogue: catalogue, selectedKey: selectedKey),
    );
  }

  @override
  State<StrategyPickerSheet> createState() => _StrategyPickerSheetState();
}

class _StrategyPickerSheetState extends State<StrategyPickerSheet> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groups = widget.catalogue.grouped(_query);
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.85,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.viewInsetsOf(context).bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                appTranslation().get('strategy_pick_title'),
                style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
              ),
              verticalSpace12,
              PrimaryTextField(
                controller: _controller,
                hint: appTranslation().get('strategy_search_hint'),
                textInputAction: TextInputAction.search,
                prefixIcon: Icon(Icons.search_rounded, color: ColorsManager.secondaryText),
                onChanged: (value) => setState(() => _query = value),
              ),
              verticalSpace8,
              Expanded(
                child: groups.isEmpty
                    ? NoDataWidget(title: appTranslation().get('strategy_no_results'))
                    : ListView.builder(
                        itemCount: groups.length,
                        itemBuilder: (context, index) => StrategyCategoryGroup(
                          category: groups[index].$1,
                          strategies: groups[index].$2,
                          selectedKey: widget.selectedKey,
                          onPick: (key) => Navigator.pop(context, key),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
