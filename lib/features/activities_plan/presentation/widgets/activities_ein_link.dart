import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// «الفترات اللاصفية وفق الخطة الزمنية الموحدة على بوابة عين الإثرائية»;
/// opens the portal in the browser.
class ActivitiesEinLink extends StatelessWidget {
  final String url;

  const ActivitiesEinLink({super.key, required this.url});

  Future<void> _open() async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _open,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(Icons.open_in_new_rounded, size: 18, color: ColorsManager.primaryColor),
            horizontalSpace8,
            Expanded(
              child: Text(
                appTranslation().get('activities_plan_ein_link'),
                style: TextStylesManager.medium13.copyWith(
                  color: ColorsManager.primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
