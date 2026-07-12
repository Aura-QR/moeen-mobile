import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';

class SelectionBottomSheet extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<String> initialSelectedItems;
  final bool isMultiSelect;
  final ValueChanged<List<String>> onSelectionConfirmed;

  const SelectionBottomSheet({
    super.key,
    required this.title,
    required this.items,
    this.initialSelectedItems = const [],
    this.isMultiSelect = true,
    required this.onSelectionConfirmed,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<String> items,
    List<String> initialSelectedItems = const [],
    bool isMultiSelect = true,
    required ValueChanged<List<String>> onSelectionConfirmed,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectionBottomSheet(
        title: title,
        items: items,
        initialSelectedItems: initialSelectedItems,
        isMultiSelect: isMultiSelect,
        onSelectionConfirmed: onSelectionConfirmed,
      ),
    );
  }

  @override
  State<SelectionBottomSheet> createState() => _SelectionBottomSheetState();
}

class _SelectionBottomSheetState extends State<SelectionBottomSheet> {
  late List<String> _selectedItems;
  List<String> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.initialSelectedItems);
    _filteredItems = List.from(widget.items);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(widget.items);
      } else {
        _filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _toggleItem(String item) {
    setState(() {
      if (widget.isMultiSelect) {
        if (_selectedItems.contains(item)) {
          _selectedItems.remove(item);
        } else {
          _selectedItems.add(item);
        }
      } else {
        _selectedItems = [item];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: ColorsManager.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorsManager.borderColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStylesManager.bold16.copyWith(
                            color: ColorsManager.mainText,
                          ),
                        ),
                        if (widget.isMultiSelect) ...[
                          verticalSpace2,
                          Text(
                            'تم اختيار ${_selectedItems.length} من ${widget.items.length}',
                            style: TextStylesManager.regular12.copyWith(
                              color: ColorsManager.primaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: ColorsManager.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Search Box
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: ColorsManager.surfacePrimary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorsManager.borderColor),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: appTranslation().get('search_hint'),
                    hintStyle: TextStylesManager.regular14.copyWith(
                      color: ColorsManager.secondaryText,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: ColorsManager.secondaryText,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            // List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredItems.length,
                separatorBuilder: (context2, index2) => verticalSpace8,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final isSelected = _selectedItems.contains(item);
                  return GestureDetector(
                    onTap: () => _toggleItem(item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ColorsManager.primaryColor.withValues(alpha: 0.1)
                            : ColorsManager.surfacePrimary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? ColorsManager.primaryColor
                              : ColorsManager.borderColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            widget.isMultiSelect
                                ? (isSelected
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded)
                                : (isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked),
                            color: isSelected
                                ? ColorsManager.primaryColor
                                : ColorsManager.placeholder,
                          ),
                          horizontalSpace12,
                          Expanded(
                            child: Text(
                              item,
                              style: isSelected
                                  ? TextStylesManager.bold14.copyWith(
                                      color: ColorsManager.primaryColor)
                                  : TextStylesManager.regular14.copyWith(
                                      color: ColorsManager.mainText),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Bottom Action
            Padding(
              padding: const EdgeInsets.all(20),
              child: PrimaryElevatedButton(
                text: 'تأكيد',
                onPressed: () {
                  widget.onSelectionConfirmed(_selectedItems);
                  context.pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
