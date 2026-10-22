import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// Shows the names read from Excel before they're added. Pops with true to add.
class ClassImportReviewSheet extends StatelessWidget {
  final List<String> names;

  const ClassImportReviewSheet({super.key, required this.names});

  static Future<bool> show(BuildContext context, List<String> names) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => ClassImportReviewSheet(names: names),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                appTranslation().get('class_import_review_title'),
                style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
              ),
              verticalSpace4,
              Text(
                appTranslation().get('class_import_review_subtitle').replaceAll('{count}', '${names.length}'),
                style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
              ),
              verticalSpace12,
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: names.length,
                  separatorBuilder: (_, _) => Divider(height: 1, color: ColorsManager.borderLightGray),
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 32,
                          child: Text(
                            '${index + 1}',
                            style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            names[index],
                            style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              verticalSpace16,
              PrimaryElevatedButton(
                text: appTranslation().get('class_import_add'),
                icon: const Icon(Icons.playlist_add_rounded),
                onPressed: () => Navigator.pop(context, true),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(appTranslation().get('cancel'), style: TextStylesManager.bold14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
