import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/class_sheets/data/models/class_sheets_catalogue_model.dart';

class SheetKindSelector extends StatelessWidget {
  final List<SheetKindModel> kinds;
  final SheetKindModel selectedKind;
  final ValueChanged<SheetKindModel> onSelected;

  const SheetKindSelector({
    super.key,
    required this.kinds,
    required this.selectedKind,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            appTranslation().get('sheets_kind'),
            style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
          ),
        ),
        verticalSpace12,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int index = 0; index < kinds.length; index++) ...[
                  if (index > 0) horizontalSpace10,
                  _KindCard(
                    kind: kinds[index],
                    isSelected: kinds[index].key == selectedKind.key,
                    onTap: () => onSelected(kinds[index]),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _KindCard extends StatelessWidget {
  final SheetKindModel kind;
  final bool isSelected;
  final VoidCallback onTap;

  const _KindCard({
    required this.kind,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 156,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected
              ? ColorsManager.primaryColor.withValues(alpha: 0.09)
              : ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? ColorsManager.primaryColor : ColorsManager.borderColor,
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ColorsManager.primaryColor
                              : ColorsManager.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          kind.icon,
                          color: isSelected ? Colors.white : ColorsManager.primaryColor,
                          size: 20,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: ColorsManager.primaryColor,
                          size: 18,
                        ),
                    ],
                  ),
                  verticalSpace10,
                  Text(
                    appTranslation().get(kind.label),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStylesManager.bold13.copyWith(
                      color: isSelected ? ColorsManager.primaryColor : ColorsManager.mainText,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
