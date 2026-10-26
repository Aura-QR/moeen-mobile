import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/qr_codes/presentation/widgets/qr_tab_button_item.dart';

class QrTabSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const QrTabSelector({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Row(
        children: [
          Expanded(
            child: QrTabButtonItem(
              label: appTranslation().get('qr_tab_link'),
              icon: Icons.link_rounded,
              isSelected: selectedIndex == 0,
              onTap: () => onTabChanged(0),
            ),
          ),
          horizontalSpace8,
          Expanded(
            child: QrTabButtonItem(
              label: appTranslation().get('qr_tab_file'),
              icon: Icons.upload_file_outlined,
              isSelected: selectedIndex == 1,
              onTap: () => onTabChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}
