import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class LogoutAllOption extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const LogoutAllOption({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appTranslation().get('logout_all_devices'),
                      style: TextStylesManager.bold14.copyWith(
                        color: ColorsManager.textPrimary,
                      ),
                    ),
                    verticalSpace4,
                    Text(
                      appTranslation().get('logout_all_devices_desc'),
                      style: TextStylesManager.regular12.copyWith(
                        color: ColorsManager.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeTrackColor: ColorsManager.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
