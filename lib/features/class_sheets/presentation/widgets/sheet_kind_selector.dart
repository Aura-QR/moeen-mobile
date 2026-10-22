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
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: kinds.length,
            separatorBuilder: (_, _) => horizontalSpace12,
            itemBuilder: (context, index) {
              final kind = kinds[index];
              final isSelected = kind.key == selectedKind.key;

              return SizedBox(
                width: 140,
                child: Material(
                  color: isSelected
                      ? ColorsManager.primaryColor.withValues(alpha: 0.08)
                      : ColorsManager.surfacePrimary,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () => onSelected(kind),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? ColorsManager.primaryColor : ColorsManager.borderLightGray,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            kind.icon,
                            color: isSelected ? ColorsManager.primaryColor : ColorsManager.secondaryText,
                            size: 26,
                          ),
                          const Spacer(),
                          Text(
                            appTranslation().get(kind.label),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStylesManager.bold13.copyWith(
                              color: isSelected ? ColorsManager.primaryColor : ColorsManager.mainText,
                            ),
                          ),
                          verticalSpace4,
                          Text(
                            appTranslation().get(kind.description),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStylesManager.regular10.copyWith(color: ColorsManager.secondaryText),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
