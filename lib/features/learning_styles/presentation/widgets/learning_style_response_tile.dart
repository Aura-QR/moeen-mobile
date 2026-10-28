import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/learning_styles/data/models/learning_styles_models.dart';

/// One student row: the name and «يميل إلى {leaning}».
class LearningStyleResponseTile extends StatelessWidget {
  final StudentResponse response;

  const LearningStyleResponseTile({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    final leaning = response.leaning.isNotEmpty
        ? '${appTranslation().get('learning_styles_leans_to')} ${response.leaning}'
        : appTranslation().get('learning_styles_balanced');
    return Card(
      color: ColorsManager.surfacePrimary,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.person_outline_rounded, color: ColorsManager.primaryColor),
        title: Text(response.studentName, style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
        subtitle: Text(leaning, style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText)),
      ),
    );
  }
}
